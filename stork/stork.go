package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

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
		_ = r.ParseForm()
		form := make(map[string]string, len(r.PostForm))
		for key := range r.PostForm {
			form[key] = r.PostForm.Get(key)
		}
		data, _ := json.Marshal(form)
		xx.WebDB(w, r, "stork.invoice_update", id, string(data))
	})

	mux.HandleFunc("POST /invoice/{id}/lineitem", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		item_id := r.FormValue("item_id")
		xx.WebDB(w, r, "stork.lineitem_add", id, item_id)
	})

	mux.HandleFunc("POST /invoice/{id}/lineitems", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		_ = r.ParseForm()
		ids := r.PostForm["lineitem"]
		quantities := r.PostForm["quantity"]
		if len(ids) != len(quantities) {
			http.Error(w, "bad lineitem/quantity count", 400)
			return
		}
		items := make([]map[string]string, 0, len(ids))
		for i, value := range ids {
			items = append(items, map[string]string{"id": value, "quantity": quantities[i]})
		}
		data, _ := json.Marshal(items)
		xx.WebDB(w, r, "stork.lineitems_update", id, string(data))
	})

	mux.HandleFunc("GET /preship", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.preship_see")
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
		csv := r.PostFormValue("csv")
		_, verify := r.PostForm["verify"]
		xx.WebDB(w, r, "stork.postship2", csv, verify)
	})

	log.Println("Storm @ :2208")
	log.Fatal(http.ListenAndServe(":2208", xx.AuthExcept(mux, "/login", "/logout")))
}
