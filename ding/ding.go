package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"sive.rs/sivers/internal/xx"
	"syscall"
	"time"
)

func main() {
	f, err := os.OpenFile("/tmp/ding.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Printf("warning: couldn't open log file: %v", err)
	} else {
		log.SetOutput(f)
		defer f.Close()
	}

	if err := xx.InitDB(true); err != nil {
		log.Fatal(err)
	}
	if err := InitEmail(); err != nil {
		log.Fatal(err)
	}
	if err := InitActivityPub(); err != nil {
		log.Fatal(err)
	}
	if err := InitBluesky(); err != nil {
		log.Fatal(err)
	}
	if err := InitX(); err != nil {
		log.Fatal(err)
	}

	if err := InitTelegram(); err != nil {
		log.Fatal(err)
	}

	stop := make(chan struct{})
	listenerDone := make(chan struct{})
	go func() {
		listener(stop)
		close(listenerDone)
	}()

	mux := router()
	srv := &http.Server{Addr: ":2407", Handler: mux}
	go func() {
		log.Println("ding server starting on :2407")
		err := srv.ListenAndServe()
		log.Printf("srv.ListenAndServe returned: %v", err)
		if err != nil && err != http.ErrServerClosed {
			log.Fatalf("HTTP server error: %v", err)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	<-quit // block here until Ctrl-C or rcctl restart

	log.Println("ding shutdown")
	close(stop)
	if err := srv.Shutdown(context.Background()); err != nil {
		log.Printf("HTTP shutdown: %v", err)
	}
	<-listenerDone

	closing, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	if err := tdlibClient.Close(closing); err != nil {
		log.Printf("Telegram shutdown: %v", err)
	}
	cancel()

	xx.DB.Close()
	log.Println("ding exit")
}
