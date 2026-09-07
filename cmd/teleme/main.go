package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"

	"sive.rs/sivers/internal/teleme"
	"sive.rs/sivers/internal/xx"
)

func envOr(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	if err := run(ctx, os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, "Error:", err)
		os.Exit(1)
	}
}

func loadCredentials(ctx context.Context) (teleme.Config, error) {
	return credentialsWithFallback(ctx, databaseCredentials)
}

// Use a complete environment credential pair before attempting PostgreSQL.
func credentialsWithFallback(ctx context.Context, fromDB func(context.Context) (teleme.Config, error)) (teleme.Config, error) {
	if err := ctx.Err(); err != nil {
		return teleme.Config{}, fmt.Errorf("Telegram config: %w", err)
	}
	idText := os.Getenv("TELEGRAM_API_ID")
	hash := os.Getenv("TELEGRAM_API_HASH")
	if strings.TrimSpace(idText) != "" && strings.TrimSpace(hash) != "" {
		id, err := strconv.ParseInt(idText, 10, 32)
		if err != nil || id <= 0 {
			return teleme.Config{}, errors.New("Telegram config: TELEGRAM_API_ID must be a positive int32")
		}
		return teleme.Config{APIID: int(id), APIHash: hash}, nil
	}
	dbCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	cfg, err := fromDB(dbCtx)
	if err != nil {
		return teleme.Config{}, fmt.Errorf("%w; set both TELEGRAM_API_ID and TELEGRAM_API_HASH to use environment credentials", err)
	}
	if cfg.APIID <= 0 || int64(cfg.APIID) > 2147483647 || strings.TrimSpace(cfg.APIHash) == "" {
		return teleme.Config{}, errors.New("Telegram config: database API ID or hash is missing or invalid")
	}
	return cfg, nil
}

func databaseCredentials(ctx context.Context) (teleme.Config, error) {
	db, err := sql.Open("postgres", xx.DSN)
	if err != nil {
		return teleme.Config{}, fmt.Errorf("Telegram database: %w", err)
	}
	defer db.Close()
	var id int32
	var hash string
	if err := db.QueryRowContext(ctx, `select
		o.config('telegram_api_id'),
		o.config('telegram_api_hash')
	`).Scan(&id, &hash); err != nil {
		return teleme.Config{}, fmt.Errorf("Telegram config: %w", err)
	}
	return teleme.Config{APIID: int(id), APIHash: hash}, nil
}

func run(ctx context.Context, args []string) (err error) {
	if len(args) == 1 && (args[0] == "-h" || args[0] == "--help") {
		fmt.Println("Usage: teleme [message text]")
		fmt.Println("Without a message: authorize or verify the saved session, then close.")
		fmt.Println("With a message: authorize, post to TELEGRAM_CHANNEL (default dereksivers), then close.")
		fmt.Println("API credentials: TELEGRAM_API_ID and TELEGRAM_API_HASH first.")
		fmt.Println("If either is missing, use PostgreSQL o.config('telegram_api_id') and o.config('telegram_api_hash').")
		fmt.Println("Optional: TELEGRAM_DB_DIR (default /var/telegram).")
		return nil
	}
	text := strings.Join(args, " ")
	if len(args) > 0 && strings.TrimSpace(text) == "" {
		return errors.New("message must not be blank")
	}
	cfg, err := loadCredentials(ctx)
	if err != nil {
		return err
	}
	dbDir := envOr("TELEGRAM_DB_DIR", "/var/telegram")
	cfg.DBDir = dbDir
	cfg.Interactive = true
	c, err := teleme.New(ctx, cfg)
	if err != nil {
		return err
	}
	defer func() {
		closing, cancel := context.WithTimeout(context.Background(), 15*time.Second)
		defer cancel()
		err = errors.Join(err, c.Close(closing))
	}()
	fmt.Println("Authorized. Saved session:", dbDir)
	if len(args) == 0 {
		return nil
	}
	posting, cancel := context.WithTimeout(ctx, 2*time.Minute)
	defer cancel()
	channel := envOr("TELEGRAM_CHANNEL", "dereksivers")
	chatID, err := c.ResolvePublicChat(posting, channel)
	if err != nil {
		return err
	}
	finalID, err := c.SendText(posting, chatID, text)
	if err != nil {
		return err
	}
	fmt.Printf("Sent successfully to @%s; final message ID: %d\n", strings.TrimPrefix(channel, "@"), finalID)
	return nil
}
