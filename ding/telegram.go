package main

import (
	"github.com/zelenin/go-tdlib/client"
	"log"
	"os"
	"os/signal"
	"syscall"
	"sive.rs/sivers/internal/xx"
)

var (
	tAPIId   int32
	tAPIHash string
	tChatId  int64
	tdlibClient *client.Client
)

func post2Telegram(tw Tweet) {
	log.Printf("Telegram got Tweet ID=%d message=%s", tw.ID, tw.Message)
	_, err := tdlibClient.SendMessage(&client.SendMessageRequest{
		ChatId: tChatId,
		InputMessageContent: &client.InputMessageText{
			Text: &client.FormattedText{Text: tw.Message},
		},
	})
	if err != nil {
		log.Fatalf("Telegram error: %v", err)
	} else {
		log.Printf("Telegram sent OK")
	}
}

func telegram() {
	log.Printf("telegram() starting")

	_ = xx.DB.QueryRow("select o.config('telegram_api_id')").Scan(&tAPIId)
	_ = xx.DB.QueryRow("select o.config('telegram_api_hash')").Scan(&tAPIHash)
	_ = xx.DB.QueryRow("select o.config('telegram_chatid')").Scan(&tChatId)

	tdlibParameters := &client.SetTdlibParametersRequest{
		UseTestDc:           false,
		DatabaseDirectory:   "/var/telegram/database",
		FilesDirectory:      "/var/telegram/files",
		UseFileDatabase:     true,
		UseChatInfoDatabase: true,
		UseMessageDatabase:  true,
		UseSecretChats:      false,
		ApiId:               tAPIId,
		ApiHash:             tAPIHash,
		SystemLanguageCode:  "en",
		DeviceModel:         "Server",
		SystemVersion:       "1.0.0",
		ApplicationVersion:  "1.0.0",
	}
	// client authorizer
	authorizer := client.ClientAuthorizer(tdlibParameters)
	go client.CliInteractor(authorizer)

	_, err := client.SetLogVerbosityLevel(&client.SetLogVerbosityLevelRequest{
		NewVerbosityLevel: 1,
	})
	if err != nil {
		log.Fatalf("SetLogVerbosityLevel error: %v", err)
	}

	tdlibClient, err = client.NewClient(authorizer)
	if err != nil {
		log.Fatalf("NewClient error: %v", err)
	}

	versionOption, err := client.GetOption(&client.GetOptionRequest{
		Name: "version",
	})
	if err != nil {
		log.Fatalf("GetOption error: %v", err)
	}

	commitOption, err := client.GetOption(&client.GetOptionRequest{
		Name: "commit_hash",
	})
	if err != nil {
		log.Fatalf("GetOption error: %v", err)
	}
	log.Printf("TDLib version: %s (commit: %s)", versionOption.(*client.OptionValueString).Value, commitOption.(*client.OptionValueString).Value)

	me, err := tdlibClient.GetMe()
	if err != nil {
		log.Fatalf("GetMe error: %s", err)
	}
	log.Printf("Telegram client for %s %s", me.FirstName, me.LastName)

	ch := make(chan os.Signal, 2)
	signal.Notify(ch, syscall.SIGINT, syscall.SIGTERM)
	<-ch
	tdlibClient.Close()
	os.Exit(1)
}
