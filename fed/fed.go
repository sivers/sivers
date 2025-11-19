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
		body, info, err := xx.VerifyActivityPubRequest(r)
		if err != nil {
			http.Error(w, "unauthorized: "+err.Error(), 401)
			return
		}
		w.WriteHeader(200)
		io.WriteString(w, "ok\n")
	})

	log.Println("Fed @ :2407")
	log.Fatal(http.ListenAndServe(":2407", xx.JSONly(mux)))
}
