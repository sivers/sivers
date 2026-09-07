package main

import (
	"context"
	"errors"
	"strings"
	"testing"

	"sive.rs/sivers/internal/teleme"
)

func TestHelpWithoutDatabase(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	if err := run(ctx, []string{"--help"}); err != nil {
		t.Fatal(err)
	}
}

func TestNoMessageAcceptsAuthorizationMode(t *testing.T) {
	t.Setenv("TELEGRAM_API_ID", "123")
	t.Setenv("TELEGRAM_API_HASH", "test-hash")
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	err := run(ctx, nil)
	if !errors.Is(err, context.Canceled) || !strings.Contains(err.Error(), "Telegram config") {
		t.Fatalf("should attempt to load credentials and respect cancellation: %v", err)
	}
}

func TestCredentialsFallback(t *testing.T) {
	dbErr := errors.New("database unavailable")
	dbConfig := teleme.Config{APIID: 1, APIHash: "database"}
	for _, tc := range []struct {
		name            string
		envID, envHash  string
		db              teleme.Config
		dbErr           error
		want            teleme.Config
		wantDB, wantErr bool
	}{
		{"environment wins", "2", "environment", dbConfig, nil, teleme.Config{APIID: 2, APIHash: "environment"}, false, false},
		{"environment needs no database", "2", "environment", teleme.Config{}, dbErr, teleme.Config{APIID: 2, APIHash: "environment"}, false, false},
		{"missing environment", "", "", dbConfig, nil, dbConfig, true, false},
		{"missing hash uses database pair", "2", "", dbConfig, nil, dbConfig, true, false},
		{"missing ID uses database pair", "", "environment", dbConfig, nil, dbConfig, true, false},
		{"blank hash", "2", "  ", dbConfig, nil, dbConfig, true, false},
		{"invalid environment ID", "abc", "environment", dbConfig, nil, teleme.Config{}, false, true},
		{"zero environment ID", "0", "environment", dbConfig, nil, teleme.Config{}, false, true},
		{"overflow environment ID", "2147483648", "environment", dbConfig, nil, teleme.Config{}, false, true},
		{"database unavailable", "", "", teleme.Config{}, dbErr, teleme.Config{}, true, true},
		{"invalid database credentials", "", "", teleme.Config{}, nil, teleme.Config{}, true, true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			t.Setenv("TELEGRAM_API_ID", tc.envID)
			t.Setenv("TELEGRAM_API_HASH", tc.envHash)
			called := false
			got, err := credentialsWithFallback(context.Background(), func(ctx context.Context) (teleme.Config, error) {
				called = true
				if _, ok := ctx.Deadline(); !ok {
					t.Error("database lookup has no timeout")
				}
				return tc.db, tc.dbErr
			})
			if called != tc.wantDB {
				t.Fatalf("database called = %v, want %v", called, tc.wantDB)
			}
			if (err != nil) != tc.wantErr || got != tc.want {
				t.Fatalf("got %+v, %v; want %+v, error=%v", got, err, tc.want, tc.wantErr)
			}
			if tc.wantDB && tc.dbErr != nil && !errors.Is(err, tc.dbErr) {
				t.Fatalf("database error was lost: %v", err)
			}
		})
	}
}

func TestBlankMessageRejectedBeforeLogin(t *testing.T) {
	if err := run(context.Background(), []string{"  "}); err == nil || !strings.Contains(err.Error(), "blank") {
		t.Fatal(err)
	}
}
