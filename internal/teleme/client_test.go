package teleme

import (
	"bufio"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"reflect"
	"strings"
	"testing"
	"time"
)

func testContext(t *testing.T) context.Context {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	t.Cleanup(cancel)
	return ctx
}

func TestEnvelope(t *testing.T) {
	var env envelope
	raw := []byte(`{"@type":"message","@extra":"42","@client_id":7,"id":9007199254740991,"unknown":true}`)
	if err := json.Unmarshal(raw, &env); err != nil {
		t.Fatal(err)
	}
	if env.Type != "message" || string(env.Extra) != `"42"` || env.ClientID != 7 {
		t.Fatalf("wrong envelope: %+v", env)
	}
	if json.Unmarshal([]byte(`{"@type":`), &env) == nil {
		t.Fatal("accepted malformed JSON")
	}
}

func TestRequestJSON(t *testing.T) {
	for _, tc := range []struct {
		name    string
		request object
		want    string
	}{
		{"search", searchRequest("dereksivers"), `{"@type":"searchPublicChat","username":"dereksivers"}`},
		{"send", messageRequest(-1001234567890, "Hello \"Telegram\"\n世界"),
			`{"@type":"sendMessage","chat_id":-1001234567890,"input_message_content":{"@type":"inputMessageText","text":{"@type":"formattedText","text":"Hello \"Telegram\"\n世界","entities":[]}}}`},
	} {
		t.Run(tc.name, func(t *testing.T) {
			b, err := json.Marshal(tc.request)
			if err != nil {
				t.Fatal(err)
			}
			var got, want any
			if err := json.Unmarshal(b, &got); err != nil {
				t.Fatal(err)
			}
			if err := json.Unmarshal([]byte(tc.want), &want); err != nil {
				t.Fatal(err)
			}
			if !reflect.DeepEqual(got, want) {
				t.Fatalf("got %s; want %s", b, tc.want)
			}
		})
	}
}

func TestCorrelationOutOfOrder(t *testing.T) {
	ctx := testContext(t)
	requests := make(chan object, 2)
	c := newClient(7, func(_ int, v any) error { requests <- v.(object); return nil })
	results := make(chan error, 2)
	for _, name := range []string{"first", "second"} {
		go func() {
			var response struct{ Value string }
			err := c.call(ctx, object{"@type": "getOption", "name": name}, &response)
			if err == nil && response.Value != name {
				err = fmt.Errorf("%s received %q", name, response.Value)
			}
			results <- err
		}()
	}
	var sent []object
	for range 2 {
		select {
		case request := <-requests:
			sent = append(sent, request)
		case <-ctx.Done():
			t.Fatal(ctx.Err())
		}
	}
	for i := len(sent) - 1; i >= 0; i-- {
		request := sent[i]
		// Another client must not satisfy this request, even with the same extra.
		c.dispatch(json.RawMessage(fmt.Sprintf(`{"@type":"optionValueString","@client_id":8,"@extra":%q,"value":"wrong"}`, request["@extra"])))
		c.dispatch(json.RawMessage(fmt.Sprintf(`{"@type":"optionValueString","@client_id":7,"@extra":%q,"value":%q}`, request["@extra"], request["name"])))
	}
	for range 2 {
		select {
		case err := <-results:
			if err != nil {
				t.Fatal(err)
			}
		case <-ctx.Done():
			t.Fatal(ctx.Err())
		}
	}
	if len(c.pending) != 0 {
		t.Fatal("pending requests leaked")
	}
}

func TestCanceledRequestAndLateResponse(t *testing.T) {
	ctx, cancel := context.WithCancel(testContext(t))
	var extra string
	c := newClient(7, func(_ int, v any) error {
		extra = v.(object)["@extra"].(string)
		cancel()
		return nil
	})
	if err := c.call(ctx, object{"@type": "getMe"}, nil); !errors.Is(err, context.Canceled) {
		t.Fatal(err)
	}
	if len(c.pending) != 0 {
		t.Fatal("canceled request leaked")
	}
	c.dispatch(json.RawMessage(fmt.Sprintf(`{"@type":"user","@client_id":7,"@extra":%q}`, extra)))
	if len(c.events) != 0 {
		t.Fatal("late reply treated as an update")
	}
}

func TestRequestErrors(t *testing.T) {
	for _, tc := range []struct {
		name      string
		transport bool
	}{
		{"TDLib error", false}, {"transport error", true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			var c *Client
			c = newClient(7, func(_ int, v any) error {
				if tc.transport {
					return errors.New("marshal failed")
				}
				c.dispatch(json.RawMessage(fmt.Sprintf(`{"@type":"error","@client_id":7,"@extra":%q,"code":400,"message":"CHAT_WRITE_FORBIDDEN"}`, v.(object)["@extra"])))
				return nil
			})
			err := c.call(testContext(t), object{"@type": "getMe"}, nil)
			if err == nil {
				t.Fatal("missing error")
			}
			if !tc.transport {
				var td *tdError
				if !errors.As(err, &td) || td.Code != 400 || td.Message != "CHAT_WRITE_FORBIDDEN" {
					t.Fatal(err)
				}
			}
			if len(c.pending) != 0 {
				t.Fatal("failed request leaked")
			}
		})
	}
}

func TestDeliveryBeforeSendResponse(t *testing.T) {
	for _, kind := range []string{"updateMessageSendSucceeded", "updateMessageSendFailed"} {
		t.Run(kind, func(t *testing.T) {
			var c *Client
			c = newClient(7, func(_ int, v any) error {
				// Both identifiers must match. Unrelated updates must be ignored.
				c.dispatch(json.RawMessage(`{"@type":"updateNewMessage","@client_id":7}`))
				c.dispatch(json.RawMessage(`{"@type":"updateMessageSendSucceeded","@client_id":7,"old_message_id":-1,"message":{"id":99,"chat_id":-200}}`))
				c.dispatch(json.RawMessage(`{"@type":"updateMessageSendSucceeded","@client_id":7,"old_message_id":-2,"message":{"id":99,"chat_id":-100}}`))
				c.dispatch(json.RawMessage(fmt.Sprintf(`{"@type":%q,"@client_id":7,"old_message_id":-1,"message":{"id":123,"chat_id":-100},"error":{"code":403,"message":"denied"}}`, kind)))
				c.dispatch(json.RawMessage(fmt.Sprintf(`{"@type":"message","@client_id":7,"@extra":%q,"id":-1,"chat_id":-100}`, v.(object)["@extra"])))
				return nil
			})
			ctx := testContext(t)
			id, err := c.SendText(ctx, -100, "test")
			if kind == "updateMessageSendSucceeded" {
				if err != nil || id != 123 {
					t.Fatalf("id=%d err=%v", id, err)
				}
			} else {
				var td *tdError
				if !errors.As(err, &td) || td.Code != 403 {
					t.Fatalf("wrong failure: %v", err)
				}
			}
		})
	}
}

func TestUnconfirmedDelivery(t *testing.T) {
	ctx, cancel := context.WithCancel(testContext(t))
	var c *Client
	c = newClient(7, func(_ int, v any) error {
		c.dispatch(json.RawMessage(fmt.Sprintf(`{"@type":"message","@client_id":7,"@extra":%q,"id":-1,"chat_id":-100}`, v.(object)["@extra"])))
		cancel()
		return nil
	})
	if _, err := c.SendText(ctx, -100, "test"); !errors.Is(err, context.Canceled) || !strings.Contains(err.Error(), "unconfirmed") {
		t.Fatal(err)
	}
	if c.starting != 0 || len(c.deliveries) != 0 || len(c.early) != 0 || len(c.pending) != 0 {
		t.Fatal("canceled send leaked state")
	}
}

func TestPromptCancellation(t *testing.T) {
	reader, writer := io.Pipe()
	defer reader.Close()
	defer writer.Close()
	ctx, cancel := context.WithCancel(testContext(t))
	defer cancel()
	c := newClient(7, nil)
	result := make(chan error, 1)
	go func() {
		_, err := c.prompt(ctx, bufio.NewReader(reader), "", false)
		result <- err
	}()
	cancel()
	select {
	case err := <-result:
		if !errors.Is(err, context.Canceled) {
			t.Fatal(err)
		}
	case <-testContext(t).Done():
		t.Fatal("stdin prevented cancellation")
	}
}

func TestCloseWaitsForClosed(t *testing.T) {
	ctx := testContext(t)
	sent := make(chan object, 1)
	c := newClient(7, func(_ int, v any) error { sent <- v.(object); return nil })
	result := make(chan error, 1)
	go func() { result <- c.Close(ctx) }()
	select {
	case request := <-sent:
		if request["@type"] != "close" {
			t.Fatal(request)
		}
	case <-ctx.Done():
		t.Fatal(ctx.Err())
	}
	if c.dispatch(json.RawMessage(`{"@type":"updateAuthorizationState","@client_id":7,"authorization_state":{"@type":"authorizationStateClosing"}}`)) {
		t.Fatal("closing is not closed")
	}
	select {
	case err := <-result:
		t.Fatalf("closed prematurely: %v", err)
	default:
	}
	if !c.dispatch(json.RawMessage(`{"@type":"updateAuthorizationState","@client_id":7,"authorization_state":{"@type":"authorizationStateClosed"}}`)) {
		t.Fatal("missed closed")
	}
	close(c.done)
	if err := <-result; err != nil {
		t.Fatal(err)
	}
}

// Exercises the real shared library without parameters, credentials, a database,
// or Telegram authorization. There is no sendMessage call in this smoke test.
func TestTDLibVersionAndClose(t *testing.T) {
	c, err := startClient()
	if err != nil {
		t.Fatal(err)
	}
	if _, err := startClient(); err == nil {
		t.Fatal("allowed a second native receiver")
	}
	t.Cleanup(func() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := c.Close(ctx); err != nil {
			t.Error(err)
		}
	})
	var version struct{ Value string }
	if err := c.call(testContext(t), object{"@type": "getOption", "name": "version"}, &version); err != nil {
		t.Fatal(err)
	}
	if version.Value == "" {
		t.Fatal("empty TDLib version")
	}
	t.Log("linked TDLib version:", version.Value)
	if err := c.Close(testContext(t)); err != nil {
		t.Fatal(err)
	}
	// A completed close releases the process-wide receiver for another client.
	second, err := startClient()
	if err != nil {
		t.Fatal(err)
	}
	if err := second.Close(testContext(t)); err != nil {
		t.Fatal(err)
	}
}

func TestConcurrentSends(t *testing.T) {
	ctx := testContext(t)
	requests := make(chan object, 2)
	c := newClient(7, func(_ int, v any) error { requests <- v.(object); return nil })
	results := make(chan error, 2)
	for _, chatID := range []int64{-100, -200} {
		go func() {
			id, err := c.SendText(ctx, chatID, "test")
			if err == nil && id != -chatID {
				err = fmt.Errorf("chat %d got message %d", chatID, id)
			}
			results <- err
		}()
	}
	var sent []object
	for range 2 {
		select {
		case request := <-requests:
			sent = append(sent, request)
		case <-ctx.Done():
			t.Fatal(ctx.Err())
		}
	}
	for _, request := range sent {
		// The temporary ID is deliberately identical in both chats.
		c.dispatch(json.RawMessage(fmt.Sprintf(`{"@type":"message","@client_id":7,"@extra":%q,"id":-1,"chat_id":%d}`, request["@extra"], request["chat_id"])))
	}
	for i := len(sent) - 1; i >= 0; i-- {
		chatID := sent[i]["chat_id"].(int64)
		c.dispatch(json.RawMessage(fmt.Sprintf(`{"@type":"updateMessageSendSucceeded","@client_id":7,"old_message_id":-1,"message":{"id":%d,"chat_id":%d}}`, -chatID, chatID)))
	}
	for range 2 {
		select {
		case err := <-results:
			if err != nil {
				t.Fatal(err)
			}
		case <-ctx.Done():
			t.Fatal(ctx.Err())
		}
	}
	if len(c.deliveries) != 0 || len(c.early) != 0 || c.starting != 0 {
		t.Fatal("completed sends leaked state")
	}
}

func TestReadyClientIgnoresUnrelatedUpdates(t *testing.T) {
	c := newClient(7, nil)
	c.ready = true
	for range 100 {
		c.dispatch(json.RawMessage(`{"@type":"updateNewMessage","@client_id":7}`))
		c.dispatch(json.RawMessage(`{"@type":"updateAuthorizationState","@client_id":7,"authorization_state":{"@type":"authorizationStateReady"}}`))
		c.dispatch(json.RawMessage(`{"@type":"updateMessageSendSucceeded","@client_id":7,"old_message_id":-1,"message":{"id":123,"chat_id":-100}}`))
	}
	if len(c.events) != 0 || len(c.early) != 0 {
		t.Fatal("idle client accumulated updates")
	}
}

func TestCloseTimeoutCanBeRetried(t *testing.T) {
	count := 0
	c := newClient(7, func(_ int, _ any) error { count++; return nil })
	ctx, cancel := context.WithCancel(testContext(t))
	cancel()
	if err := c.Close(ctx); !errors.Is(err, context.Canceled) {
		t.Fatal(err)
	}
	if err := c.call(testContext(t), object{"@type": "getMe"}, nil); !errors.Is(err, errClosed) {
		t.Fatal(err)
	}
	close(c.done)
	if err := c.Close(testContext(t)); err != nil {
		t.Fatal(err)
	}
	if count != 1 {
		t.Fatalf("sent %d close requests", count)
	}
}

func TestAuthorizationReusesSessionWithoutPrompts(t *testing.T) {
	var c *Client
	c = newClient(7, func(_ int, v any) error {
		request := v.(object)
		if request["@type"] != "setTdlibParameters" || request["database_directory"] != "session" {
			t.Errorf("unexpected request: %v", request["@type"])
		}
		c.dispatch(json.RawMessage(fmt.Sprintf(`{"@type":"ok","@client_id":7,"@extra":%q}`, request["@extra"])))
		c.dispatch(json.RawMessage(`{"@type":"updateAuthorizationState","@client_id":7,"authorization_state":{"@type":"authorizationStateReady"}}`))
		return nil
	})
	c.dispatch(json.RawMessage(`{"@type":"updateAuthorizationState","@client_id":7,"authorization_state":{"@type":"authorizationStateWaitTdlibParameters"}}`))
	if err := c.authorize(testContext(t), Config{APIID: 1, APIHash: "test", DBDir: "session"}); err != nil {
		t.Fatal(err)
	}
	if !c.ready {
		t.Fatal("client did not become ready")
	}
}

func TestNoninteractiveAuthorizationRequiresSavedSession(t *testing.T) {
	c := newClient(7, nil)
	c.dispatch(json.RawMessage(`{"@type":"updateAuthorizationState","@client_id":7,"authorization_state":{"@type":"authorizationStateWaitPhoneNumber"}}`))
	if err := c.authorize(testContext(t), Config{}); err == nil || !strings.Contains(err.Error(), "run teleme") {
		t.Fatal(err)
	}
}

func TestConfirmedSendSurvivesClosure(t *testing.T) {
	var c *Client
	c = newClient(7, func(_ int, v any) error {
		c.dispatch(json.RawMessage(fmt.Sprintf(`{"@type":"message","@client_id":7,"@extra":%q,"id":-1,"chat_id":-100}`, v.(object)["@extra"])))
		c.dispatch(json.RawMessage(`{"@type":"updateMessageSendSucceeded","@client_id":7,"old_message_id":-1,"message":{"id":123,"chat_id":-100}}`))
		close(c.done)
		return nil
	})
	if id, err := c.SendText(testContext(t), -100, "test"); err != nil || id != 123 {
		t.Fatalf("id=%d err=%v", id, err)
	}
}

func TestClosureDuringAuthorization(t *testing.T) {
	c := newClient(7, nil)
	c.dispatch(json.RawMessage(`{"@type":"updateAuthorizationState","@client_id":7,"authorization_state":{"@type":"authorizationStateReady"}}`))
	c.dispatch(json.RawMessage(`{"@type":"updateAuthorizationState","@client_id":7,"authorization_state":{"@type":"authorizationStateClosed"}}`))
	close(c.done)
	if err := c.authorize(testContext(t), Config{}); !errors.Is(err, errClosed) {
		t.Fatal(err)
	}
}
