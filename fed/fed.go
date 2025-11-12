package main

import (
	"io"
	"log"
	"net/http"
	"os"
	"sive.rs/sivers/internal/xx"
)

func main() {
	if err := xx.InitDB(); err != nil {
		log.Fatalf("InitDB %v", err)
	}
	defer xx.DB.Close()

	f, _ := os.Create("/tmp/fed.log")
	log.SetOutput(f)

	mux := http.NewServeMux()

	mux.HandleFunc("POST /d/inbox", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
		io.WriteString(w, "found me\n")
	})

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.NotFound(w, r)
	})

	log.Println("Fed @ :2407")
	log.Fatal(http.ListenAndServe(":2407", xx.JSONly(mux)))
}
