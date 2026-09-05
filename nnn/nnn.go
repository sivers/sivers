package main

import (
	"log"
	"net/http"
	"os"
	"sive.rs/sivers/internal/xx"
)

func main() {
	f, err := os.OpenFile("/tmp/nnn.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Printf("warning: couldn't open log file: %v", err)
	} else {
		log.SetOutput(f)
		defer f.Close()
	}

	if err := xx.InitDB(true); err != nil {
		log.Fatalf("InitDB %v", err)
	}
	defer xx.DB.Close()

	mux := http.NewServeMux()

	mux.HandleFunc("GET /random", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "nnn.random")
	})

	mux.HandleFunc("GET /search", func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query().Get("q")
		xx.WebDB(w, r, "nnn.search", q)
	})

	log.Println("NNN @ :2203")
	log.Fatal(http.ListenAndServe(":2203", mux))
}
