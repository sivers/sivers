package main

import (
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
		log.Printf("Verified actor %s (key %s)\n", info.ActorID, info.KeyID)
		if err := xx.Web2(w, "fed.inbox", body); err != nil {
			xx.Oops(w, err)
		}
	})

	log.Println("Fed @ :2407")
	log.Fatal(http.ListenAndServe(":2407", xx.JSONly(mux)))
}
