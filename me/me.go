package main

// DO LATER: /cal /meet1

import (
	"encoding/json"
	"log"
	"math/rand"
	"net/http"
	"os"
	"regexp"

	"sive.rs/sivers/internal/xx"
)

var (
	idRx     = regexp.MustCompile(`^[1-9][0-9]{0,6}$`)
	lopassRx = regexp.MustCompile(`^[a-zA-Z0-9]{4}$`)
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
		if err := xx.Web2(w, "me.contact_form", r.Header.Get("X-Real-IP")); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /contact", func(w http.ResponseWriter, r *http.Request) {
		if err := r.ParseForm(); err != nil {
			xx.Oops(w, err)
		}
		formData := map[string]string{
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
		if err := xx.Web2(w, "me.contact_post", jsonData); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /comments/{uri}", func(w http.ResponseWriter, r *http.Request) {
		uri := r.PathValue("uri")
		if err := xx.Web2(w, "me.comments", uri); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /comments/{uri}", func(w http.ResponseWriter, r *http.Request) {
		if err := r.ParseForm(); err != nil {
			xx.Oops(w, err)
		}
		formData := map[string]string{
			"uri":     r.PathValue("uri"),
			"name":    r.PostFormValue("name"),
			"email":   r.PostFormValue("email"),
			"comment": r.PostFormValue("comment"),
			"ip":      r.Header.Get("X-Real-IP"),
		}
		jsonData, err := json.Marshal(formData)
		if err != nil {
			xx.Oops(w, err)
		}
		if err := xx.Web2(w, "me.comment_post", jsonData); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /list", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/contact", 307)
	})

	mux.HandleFunc("GET /list/{id}/{lopass}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		lopass := r.PathValue("lopass")
		if idRx.MatchString(id) && lopassRx.MatchString(lopass) {
			if err := xx.Web2(w, "me.list_form", id, lopass); err != nil {
				xx.Oops(w, err)
			}
		} else {
			http.Redirect(w, r, "/contact", 307)
		}
	})

	mux.HandleFunc("POST /list/{id}/{lopass}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		lopass := r.PathValue("lopass")
		listype := r.PostFormValue("listype")
		if idRx.MatchString(id) &&
			lopassRx.MatchString(lopass) &&
			(listype == "all" || listype == "some" || listype == "none") {
			if err := xx.Web2(w, "me.list_post", id, lopass, listype); err != nil {
				xx.Oops(w, err)
			}
		} else {
			http.Redirect(w, r, "/contact", 307)
		}
	})

	mux.HandleFunc("GET /random", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/"+allURIs[rand.Intn(len(allURIs))], 307)
	})

	log.Println("sive.rs @ :2209")
	log.Fatal(http.ListenAndServe(":2209", mux))
}
