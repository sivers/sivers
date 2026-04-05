package main

// DO LATER: /cal /meet1

import (
	"encoding/json"
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

	// HTML form with country, state, city looked-up by ip address
	mux.HandleFunc("GET /contact", func(w http.ResponseWriter, r *http.Request) {
		if err := xx.Web2(w, "me.contact_form", r.Header.Get("X-Real-IP")); err != nil {
			xx.Oops(w, err)
		}
	})

	// form POST from GET /contact
	mux.HandleFunc("POST /contact", func(w http.ResponseWriter, r *http.Request) {
		if err := r.ParseForm(); err != nil {
			xx.Oops(w, err)
		}
		formData := map[string]string {
			"ip":      r.Header.Get("X-Real-IP"),
			"name":    r.PostFormValue("name"),
			"email":   r.PostFormValue("email"),
			"country": r.PostFormValue("country"),
			"city":    r.PostFormValue("city"),
			"state":   r.PostFormValue("state"),
			"sivers":  r.PostFormValue("sivers"),
			"url":     r.PostFormValue("url"),
		}
		jsonData, err := json.Marshal(formData)
		if err != nil {
			xx.Oops(w, err)
		}
		// if spam/junk/missing redirects to /contact or /thanks, otherwise
		// sends email and shows "thanks go check your email" page
		if err := xx.Web2(w, "me.contact_post", jsonData); err != nil {
			xx.Oops(w, err)
		}
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
