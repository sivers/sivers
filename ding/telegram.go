package main

import (
	"context"
	"fmt"
	"log"
	"sive.rs/sivers/internal/teleme"
	"sive.rs/sivers/internal/xx"
)

var (
	tAPIId      int32
	tAPIHash    string
	tChatId     int64
	tdlibClient *teleme.Client
)

// load my Telegram credentials and open the saved session
func InitTelegram() error {
	if err := xx.DB.QueryRow(`select
		o.config('telegram_api_id'),
		o.config('telegram_api_hash'),
		o.config('telegram_chatid')
	`).Scan(&tAPIId, &tAPIHash, &tChatId); err != nil {
		return fmt.Errorf("Telegram config: %w", err)
	}
	if tChatId == 0 {
		return fmt.Errorf("Telegram config: telegram_chatid must not be zero")
	}
	var err error
	tdlibClient, err = teleme.New(context.Background(), teleme.Config{
		APIID: int(tAPIId), APIHash: tAPIHash,
	})
	if err != nil {
		return fmt.Errorf("Telegram startup: %w", err)
	}
	return nil
}

func post2Telegram(tw Tweet) {
	log.Printf("Telegram got Tweet ID=%d message=%s", tw.ID, tw.Message)

	// Post message and wait for the confirmed Telegram message ID
	id, err := tdlibClient.SendText(context.Background(), tChatId, tw.Message)
	if err != nil {
		log.Printf("Telegram SendText error for Tweet ID %d: %v", tw.ID, err)
		return
	}

	// From the confirmed message, update tweets table with its ID
	log.Printf("Telegram setting Tweet ID %d to TLG %d", tw.ID, id)
	if _, err := xx.DB.Exec("update tweets set tlg = $1 where id = $2", id, tw.ID); err != nil {
		log.Printf("Telegram failed to save TLG %d for Tweet ID %d: %v", id, tw.ID, err)
	}
}
