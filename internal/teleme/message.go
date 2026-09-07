package teleme

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"
)

type message struct {
	ID     int64 `json:"id"`
	ChatID int64 `json:"chat_id"`
}

type messageKey struct{ chatID, temporaryID int64 }
type sendResult struct {
	id  int64
	err error
}

func searchRequest(username string) object {
	return object{"@type": "searchPublicChat", "username": username}
}

func messageRequest(chatID int64, text string) object {
	return object{"@type": "sendMessage", "chat_id": chatID,
		"input_message_content": object{"@type": "inputMessageText",
			"text": object{"@type": "formattedText", "text": text, "entities": []any{}}}}
}

// ResolvePublicChat resolves a public username (with an optional leading @) to
// the numeric chat ID used by SendText.
func (c *Client) ResolvePublicChat(ctx context.Context, username string) (int64, error) {
	username = strings.TrimPrefix(strings.TrimSpace(username), "@")
	if username == "" {
		return 0, errors.New("public chat username is empty")
	}
	var chat struct {
		ID int64 `json:"id"`
	}
	if err := c.call(ctx, searchRequest(username), &chat); err != nil {
		return 0, fmt.Errorf("searchPublicChat %q: %w", username, err)
	}
	return chat.ID, nil
}

// SendText sends plain text and returns its final message ID only after TDLib
// confirms delivery. Calls may overlap. The maximum wait is two minutes.
// Cancellation stops waiting, not the Telegram send; check before retrying an
// unconfirmed send. SendText never retries or closes the client.
func (c *Client) SendText(ctx context.Context, chatID int64, text string) (int64, error) {
	if chatID == 0 || strings.TrimSpace(text) == "" {
		return 0, errors.New("chat ID and nonempty text are required")
	}
	ctx, cancel := context.WithTimeout(ctx, 2*time.Minute)
	defer cancel()
	c.mu.Lock()
	c.starting++
	c.mu.Unlock()
	var outgoing message
	err := c.call(ctx, messageRequest(chatID, text), &outgoing)
	key := messageKey{chatID, outgoing.ID}
	reply := make(chan sendResult, 1)
	c.mu.Lock()
	c.starting--
	if err == nil {
		if result, ok := c.early[key]; ok {
			delete(c.early, key)
			reply <- result
		} else {
			c.deliveries[key] = reply
		}
	}
	if c.starting == 0 {
		clear(c.early)
	}
	c.mu.Unlock()
	if err != nil {
		if errors.Is(err, context.Canceled) || errors.Is(err, context.DeadlineExceeded) || errors.Is(err, errClosed) {
			return 0, fmt.Errorf("sendMessage outcome is unconfirmed; check the channel before retrying: %w", err)
		}
		return 0, fmt.Errorf("sendMessage: %w", err)
	}
	defer func() { c.mu.Lock(); delete(c.deliveries, key); c.mu.Unlock() }()
	select {
	case result := <-reply:
		return result.id, result.err
	case <-ctx.Done():
		err = ctx.Err()
	case <-c.done:
		err = errClosed
	}
	// A definitive result takes precedence if cancellation/closure raced with it.
	select {
	case result := <-reply:
		return result.id, result.err
	default:
		return 0, fmt.Errorf("delivery of temporary message %d is unconfirmed; check the channel before retrying: %w", outgoing.ID, err)
	}
}
