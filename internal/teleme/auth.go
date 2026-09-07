package teleme

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"
)

func (c *Client) authorize(ctx context.Context, cfg Config) error {
	reader := bufio.NewReader(os.Stdin)
	for {
		raw, err := c.next(ctx)
		if err != nil {
			return err
		}
		var u struct {
			Type  string `json:"@type"`
			State struct {
				Type string `json:"@type"`
				Link string `json:"link"`
			} `json:"authorization_state"`
		}
		if err := json.Unmarshal(raw, &u); err != nil {
			return err
		}
		if u.Type != "updateAuthorizationState" {
			continue
		}
		if !cfg.Interactive && strings.HasPrefix(u.State.Type, "authorizationStateWait") && u.State.Type != "authorizationStateWaitTdlibParameters" {
			return fmt.Errorf("login required (%s); run teleme with the same TELEGRAM_DB_DIR to authorize", u.State.Type)
		}
		var request object
		var label, field string
		switch u.State.Type {
		case "authorizationStateWaitTdlibParameters":
			request = object{"@type": "setTdlibParameters", "use_test_dc": false,
				"database_directory": cfg.DBDir, "use_message_database": true,
				"use_chat_info_database": true, "use_secret_chats": false,
				"api_id": cfg.APIID, "api_hash": cfg.APIHash, "system_language_code": "en",
				"device_model": "Server", "application_version": "teleme/1"}
		case "authorizationStateWaitPhoneNumber":
			request, label, field = object{"@type": "setAuthenticationPhoneNumber"}, "Phone number (international format): ", "phone_number"
		case "authorizationStateWaitEmailAddress":
			request, label, field = object{"@type": "setAuthenticationEmailAddress"}, "Email address: ", "email_address"
		case "authorizationStateWaitEmailCode":
			request, label, field = object{"@type": "checkAuthenticationEmailCode"}, "Email code: ", "code"
		case "authorizationStateWaitCode":
			request, label, field = object{"@type": "checkAuthenticationCode"}, "Telegram authentication code: ", "code"
		case "authorizationStateWaitPassword":
			request, label, field = object{"@type": "checkAuthenticationPassword"}, "2FA password: ", "password"
		case "authorizationStateWaitOtherDeviceConfirmation":
			fmt.Fprintln(os.Stderr, "Confirm login on your other Telegram device:", u.State.Link)
			continue
		case "authorizationStateReady":
			c.mu.Lock()
			if c.closing {
				c.mu.Unlock()
				return errClosed
			}
			c.ready = true
			c.events = nil
			c.mu.Unlock()
			return nil
		case "authorizationStateClosing", "authorizationStateClosed", "authorizationStateLoggingOut":
			return fmt.Errorf("authorization stopped: %s", u.State.Type)
		case "authorizationStateWaitRegistration":
			return fmt.Errorf("this phone number needs registration; create the account in an official Telegram app first")
		case "authorizationStateWaitPremiumPurchase":
			return fmt.Errorf("Telegram requires a Premium purchase for this login; complete it in an official Telegram app")
		default:
			return fmt.Errorf("unsupported authorization state: %s", u.State.Type)
		}
		if label != "" {
			value, err := c.prompt(ctx, reader, label, field == "password")
			if err != nil {
				return err
			}
			request[field] = value
			if u.State.Type == "authorizationStateWaitEmailCode" {
				request[field] = object{"@type": "emailAddressAuthenticationCode", "code": value}
			}
		}
		if err := c.call(ctx, request, nil); err != nil {
			return fmt.Errorf("%s: %w (run again to retry login)", request["@type"], err)
		}
	}
}

func (c *Client) prompt(ctx context.Context, reader *bufio.Reader, label string, secret bool) (string, error) {
	if secret {
		restore, err := hideInput()
		if err != nil {
			return "", err
		}
		defer restore()
	}
	fmt.Fprint(os.Stderr, label)
	type input struct {
		text string
		err  error
	}
	result := make(chan input, 1)
	// At most one stdin read is active. Cancellation ends authorization and the
	// process, so a blocked read cannot prevent TDLib shutdown or echo restoration.
	go func() {
		text, err := reader.ReadString('\n')
		result <- input{strings.TrimSuffix(strings.TrimSuffix(text, "\n"), "\r"), err}
	}()
	select {
	case r := <-result:
		return r.text, r.err
	case <-ctx.Done():
		return "", ctx.Err()
	case <-c.done:
		return "", errClosed
	}
}
