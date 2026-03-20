package main

import (
	"log"
	"net/http"
	"os"
	"os/signal"
	"sive.rs/sivers/internal/xx"
	"syscall"
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

	go telegram()
	go listener()

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
	_ = srv.Close() // instantly kills HTTP server
	log.Println("ding exit")
}
