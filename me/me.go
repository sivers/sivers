package main

// DO LATER: /cal /meet1

import (
	"log"
	"math/rand"
	"net/http"
	"os"

	"sive.rs/sivers/internal/xx"
)

func main() {
	f, err := os.OpenFile("/tmp/me.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
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

	// load URIs in advance for "GET /random"
	var allURIs []string
	rows, err := xx.DB.Query("select uri from me.random_uris()")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	for rows.Next() {
		var uri string
		if err := rows.Scan(&uri); err != nil {
			log.Fatal(err)
		}
		allURIs = append(allURIs, uri)
	}

	mux := http.NewServeMux()

	mux.HandleFunc("GET /contact", func(w http.ResponseWriter, r *http.Request) {
		// TODO: lookup ip location
		// show form name, email, and location prefilled
	})

	mux.HandleFunc("POST /contact", func(w http.ResponseWriter, r *http.Request) {
		// TODO: validate and clean inputs
		// save name & email into people
		// email outgoing email to reply to
	})

	mux.HandleFunc("POST /comments", func(w http.ResponseWriter, r *http.Request) {
		// TODO: validate and clean inputs
		// insert into db, with ip
		// redirect to posting uri
	})

	mux.HandleFunc("GET /list", func(w http.ResponseWriter, r *http.Request) {
		// TODO: get id and lopass ([1-9][0-9]{0,6})/([a-zA-Z0-9]{4})
		// if none, show anon form
		// if valid, welcome form
	})

	mux.HandleFunc("POST /list", func(w http.ResponseWriter, r *http.Request) {
		// TODO: validate inputs
		// update list
		// redirect to /thanks?for=list
	})

	mux.HandleFunc("GET /random", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/" + allURIs[rand.Intn(len(allURIs))], 307)
	})

	log.Println("sive.rs @ :2209")
	log.Fatal(http.ListenAndServe(":2209", mux))
}
