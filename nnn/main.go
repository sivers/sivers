package main

import (
	"log"
	"net/http"
	"sive.rs/sivers/internal/xx"
)

func main() {
	if err := xx.InitDB(); err != nil {
		log.Fatalf("InitDB %v", err)
	}
	defer xx.DB.Close()

	mux := http.NewServeMux()

	mux.HandleFunc("GET /random", func(w http.ResponseWriter, r *http.Request) {
		if err := xx.Web2(w, "nnn.random"); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /search", func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query().Get("q")
		if err := xx.Web2(w, "nnn.search", q); err != nil {
			xx.Oops(w, err)
		}
	})

	log.Println("NNN @ :2203")
	if err := http.ListenAndServe(":2203", mux); err != nil {
		log.Fatal(err)
	}
}
