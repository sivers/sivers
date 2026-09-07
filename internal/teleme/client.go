package teleme

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"maps"
	"strconv"
	"sync"
	"sync/atomic"
	"time"
)

type object = map[string]any

type envelope struct {
	Type     string          `json:"@type"`
	Extra    json.RawMessage `json:"@extra"`
	ClientID int             `json:"@client_id"`
}

type tdError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (e *tdError) Error() string { return fmt.Sprintf("TDLib %d: %s", e.Code, e.Message) }

var errClosed = errors.New("TDLib closed")

// td_receive is process-wide. Keep one receiver, even if New is called twice.
var active atomic.Bool

// Client owns a persistent TDLib session. Create it with New, share the pointer
// across goroutines, and Close it when the application shuts down. Do not copy it.
type Client struct {
	id         int
	send       func(int, any) error
	mu         sync.Mutex
	serial     uint64
	pending    map[string]chan json.RawMessage
	events     []json.RawMessage
	wake       chan struct{}
	done       chan struct{}
	closing    bool
	ready      bool
	starting   int
	deliveries map[messageKey]chan sendResult
	early      map[messageKey]sendResult
}

func newClient(id int, send func(int, any) error) *Client {
	return &Client{id: id, send: send, pending: make(map[string]chan json.RawMessage),
		wake: make(chan struct{}, 1), done: make(chan struct{}),
		deliveries: make(map[messageKey]chan sendResult), early: make(map[messageKey]sendResult)}
}

func startClient() (*Client, error) {
	if !active.CompareAndSwap(false, true) {
		return nil, errors.New("teleme already has an active client; reuse it or Close it first")
	}
	c := newClient(createClientID(), sendJSON)
	go c.receive()
	return c, nil
}

func (c *Client) call(ctx context.Context, request object, out any) error {
	ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()
	if err := ctx.Err(); err != nil {
		return err
	}
	select {
	case <-c.done:
		return errClosed
	default:
	}
	reply := make(chan json.RawMessage, 1)
	c.mu.Lock()
	if c.closing {
		c.mu.Unlock()
		return errClosed
	}
	c.serial++
	id := strconv.FormatUint(c.serial, 10)
	c.pending[id] = reply
	c.mu.Unlock()
	defer func() { c.mu.Lock(); delete(c.pending, id); c.mu.Unlock() }()
	request = maps.Clone(request)
	request["@extra"] = id
	if err := c.send(c.id, request); err != nil {
		return err
	}
	var raw json.RawMessage
	var waitErr error
	select {
	case raw = <-reply:
	case <-ctx.Done():
		waitErr = ctx.Err()
	case <-c.done:
		waitErr = errClosed
	}
	if raw == nil {
		// Preserve a response already received when cancellation or close races it.
		select {
		case raw = <-reply:
		default:
			return waitErr
		}
	}
	var env envelope
	if err := json.Unmarshal(raw, &env); err != nil {
		return err
	}
	if env.Type == "error" {
		var e tdError
		if err := json.Unmarshal(raw, &e); err != nil {
			return err
		}
		return &e
	}
	if out != nil {
		return json.Unmarshal(raw, out)
	}
	return nil
}

func (c *Client) receive() {
	defer func() {
		active.Store(false)
		close(c.done)
	}()
	for {
		if raw := receiveJSON(); raw != nil && c.dispatch(raw) {
			return
		}
	}
}

// Authentication updates are queued only during startup. Delivery updates go to
// their own send waiter; unrelated updates do not accumulate in a running client.
func (c *Client) dispatch(raw json.RawMessage) bool {
	var env envelope
	if json.Unmarshal(raw, &env) != nil || env.ClientID != c.id {
		return false
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	var id string
	if json.Unmarshal(env.Extra, &id) == nil && id != "" {
		if reply := c.pending[id]; reply != nil {
			delete(c.pending, id)
			reply <- raw
		}
		return false
	}
	if env.Type == "updateAuthorizationState" {
		var u struct {
			State envelope `json:"authorization_state"`
		}
		if json.Unmarshal(raw, &u) != nil {
			return false
		}
		if u.State.Type == "authorizationStateClosing" || u.State.Type == "authorizationStateClosed" || u.State.Type == "authorizationStateLoggingOut" {
			c.closing = true
		}
		if !c.ready {
			c.events = append(c.events, raw)
			select {
			case c.wake <- struct{}{}:
			default:
			}
		}
		return u.State.Type == "authorizationStateClosed"
	}
	if env.Type == "updateMessageSendSucceeded" || env.Type == "updateMessageSendFailed" {
		var u struct {
			Message message `json:"message"`
			OldID   int64   `json:"old_message_id"`
			Error   tdError `json:"error"`
		}
		if json.Unmarshal(raw, &u) != nil {
			return false
		}
		key := messageKey{u.Message.ChatID, u.OldID}
		result := sendResult{id: u.Message.ID}
		if env.Type == "updateMessageSendFailed" {
			result = sendResult{err: &u.Error}
		}
		if reply := c.deliveries[key]; reply != nil {
			delete(c.deliveries, key)
			reply <- result
		} else if c.starting > 0 {
			// The update can beat the goroutine reading its sendMessage response.
			c.early[key] = result
		}
	}
	return false
}

func (c *Client) next(ctx context.Context) (json.RawMessage, error) {
	for {
		if err := ctx.Err(); err != nil {
			return nil, err
		}
		c.mu.Lock()
		if len(c.events) > 0 {
			raw := c.events[0]
			c.events[0] = nil
			c.events = c.events[1:]
			c.mu.Unlock()
			return raw, nil
		}
		select {
		case <-c.done:
			c.mu.Unlock()
			return nil, errClosed
		default:
		}
		c.mu.Unlock()
		select {
		case <-c.wake:
		case <-ctx.Done():
			return nil, ctx.Err()
		case <-c.done:
			// Recheck queued updates before reporting closure.
		}
	}
}

// Close starts shutdown and waits for authorizationStateClosed. It is safe to
// call again, including after a timeout. It preserves the saved authorization.
// Use a fresh context here if the application's operation context was canceled.
func (c *Client) Close(ctx context.Context) error {
	select {
	case <-c.done:
		return nil
	default:
	}
	c.mu.Lock()
	start := !c.closing
	c.closing = true
	c.mu.Unlock()
	if start {
		if err := c.send(c.id, object{"@type": "close"}); err != nil {
			c.mu.Lock()
			c.closing = false
			c.mu.Unlock()
			return err
		}
	}
	select {
	case <-c.done: // receive exits only after authorizationStateClosed
		return nil
	case <-ctx.Done():
		return fmt.Errorf("waiting for authorizationStateClosed: %w", ctx.Err())
	}
}
