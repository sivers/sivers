package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"sive.rs/sivers/internal/xx"
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

	// PostgreSQL
	go listener()

	// HTTP
	mux := router()
	fmt.Println("ding server starting on :2407")
	http.ListenAndServe(":2407", mux)
}

