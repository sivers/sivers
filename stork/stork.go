package main

import (
	"log"
	"net/http"
	"sive.rs/sivers/internal/xx"
)

func main() {
	f, err := os.OpenFile("/tmp/stork.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
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

	mux.HandleFunc("GET /login", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.authform")
	})

	mux.HandleFunc("POST /login", func(w http.ResponseWriter, r *http.Request) {
		email := r.FormValue("email")
		password := r.FormValue("password")
		xx.WebDB(w, r, "stork.authpost", email, password)
	})

	mux.HandleFunc("GET /logout", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		xx.WebDB(w, r, "stork.logout", kk)
	})

	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.home")
	})

	mux.HandleFunc("GET /search", func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query().Get("q")
		xx.WebDB(w, r, "stork.search", q)
	})

	mux.HandleFunc("GET /person/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		xx.WebDB(w, r, "stork.person", id)
	})

	mux.HandleFunc("POST /person/{id}/login", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		xx.WebDB(w, r, "stork.person_login", id)
	})

	mux.HandleFunc("POST /person/{id}/invoice", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		xx.WebDB(w, r, "stork.invoice_create", id)
	})

	mux.HandleFunc("GET /invoice/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		xx.WebDB(w, r, "stork.invoice", id)
	})

	mux.HandleFunc("POST /invoice/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		// TODO: data := JSON of all posted form values
		xx.WebDB(w, r, "stork.invoice_update", id, data)
	})

	mux.HandleFunc("POST /invoice/{id}/lineitem", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		item_id := r.FormValue("item_id")
		xx.WebDB(w, r, "stork.lineitem_add", id, item_id)
	})

	mux.HandleFunc("POST /invoice/{id}/lineitems", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		// TODO: data := JSON of all posted form values
		xx.WebDB(w, r, "stork.lineitems_update", id, data)
	})

	mux.HandleFunc("GET /preship", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.preship")
	})

	mux.HandleFunc("GET /preship.csv", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.preship_csv")
	})

	mux.HandleFunc("GET /customs/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		xx.WebDB(w, r, "stork.invoice_customs", id)
	})

	mux.HandleFunc("GET /postship", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.postship1")
	})

	mux.HandleFunc("POST /postship", func(w http.ResponseWriter, r *http.Request) {
		csv := r.FormValue("csv")
		xx.WebDB(w, r, "stork.postship2", csv)
	})

	log.Println("Storm @ :2208")
	log.Fatal(http.ListenAndServe(":2208", xx.AuthExcept(mux, "/login", "/logout")))
}
