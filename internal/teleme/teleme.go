// Package teleme provides a small, persistent client for posting text through
// TDLib's JSON C interface. One client may be active per process.
package teleme

import (
	"context"
	"errors"
	"fmt"
	"os"
	"strings"
	"time"
)

// Config supplies Telegram application credentials and the saved session path.
type Config struct {
	APIID       int
	APIHash     string
	DBDir       string // Defaults to /var/telegram.
	Interactive bool   // Allow stdin login prompts; enable only for the setup utility.
}

// New starts TDLib and waits for authorization. Without Interactive, a session
// requiring login returns an error. The context governs startup only; after New
// succeeds, the client stays alive until Close. Failed startup attempts cleanup
// with a separate shutdown timeout.
func New(ctx context.Context, cfg Config) (_ *Client, err error) {
	if cfg.APIID <= 0 || int64(cfg.APIID) > 2147483647 || strings.TrimSpace(cfg.APIHash) == "" {
		return nil, errors.New("teleme requires a positive int32 APIID and an APIHash")
	}
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	if cfg.DBDir == "" {
		cfg.DBDir = "/var/telegram"
	}
	if err := os.MkdirAll(cfg.DBDir, 0700); err != nil {
		return nil, err
	}
	c, err := startClient()
	if err != nil {
		return nil, err
	}
	defer func() {
		if err != nil {
			closing, cancel := context.WithTimeout(context.Background(), 15*time.Second)
			defer cancel()
			err = errors.Join(err, c.Close(closing))
		}
	}()
	ctx, cancel := context.WithTimeout(ctx, 5*time.Minute)
	defer cancel()
	if err = c.call(ctx, object{"@type": "getOption", "name": "version"}, nil); err != nil {
		return nil, err
	}
	if err = c.call(ctx, object{"@type": "setLogVerbosityLevel", "new_verbosity_level": 1}, nil); err != nil {
		return nil, err
	}
	if err = c.authorize(ctx, cfg); err != nil {
		return nil, fmt.Errorf("authorize: %w", err)
	}
	return c, nil
}
