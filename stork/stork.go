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
		xx.WebDB(w, r, "stork.authpost", r.FormValue("email"), r.FormValue("password"))
	})

	mux.HandleFunc("GET /logout", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.logout", xx.GetCookie(r))
	})

	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.home", xx.GetCookie(r))
	})

	mux.HandleFunc("GET /search", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.search", xx.GetCookie(r), r.URL.Query().Get("q"))
	})

	mux.HandleFunc("GET /person/{id}", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.person", xx.GetCookie(r), r.PathValue("id"))
	})

	mux.HandleFunc("POST /person/{id}/login", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.person_login", xx.GetCookie(r), r.PathValue("id"))
	})

	mux.HandleFunc("POST /person/{id}/invoice", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.invoice_create", xx.GetCookie(r), r.PathValue("id"))
	})

	mux.HandleFunc("GET /invoice/{id}", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.invoice", xx.GetCookie(r), r.PathValue("id"))
	})

	mux.HandleFunc("POST /invoice/{id}", func(w http.ResponseWriter, r *http.Request) {
		_ = r.ParseForm()
		form := make(map[string]string, len(r.PostForm))
		for key := range r.PostForm {
			form[key] = r.PostForm.Get(key)
		}
		data, _ := json.Marshal(form)
		xx.WebDB(w, r, "stork.invoice_update", xx.GetCookie(r), r.PathValue("id"), string(data))
	})

	mux.HandleFunc("POST /invoice/{id}/lineitem", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.lineitem_add", xx.GetCookie(r), r.PathValue("id"), r.FormValue("item_id"))
	})

	mux.HandleFunc("POST /invoice/{id}/lineitems", func(w http.ResponseWriter, r *http.Request) {
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
		xx.WebDB(w, r, "stork.lineitems_update", xx.GetCookie(r), r.PathValue("id"), string(data))
	})

	mux.HandleFunc("GET /preship", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.preship_see", xx.GetCookie(r))
	})

	mux.HandleFunc("GET /preship.csv", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.preship_csv", xx.GetCookie(r))
	})

	mux.HandleFunc("GET /customs/{id}", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.invoice_customs", xx.GetCookie(r), r.PathValue("id"))
	})

	mux.HandleFunc("GET /postship", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.postship1", xx.GetCookie(r))
	})

	mux.HandleFunc("POST /postship", func(w http.ResponseWriter, r *http.Request) {
		_, verify := r.PostForm["verify"]
		xx.WebDB(w, r, "stork.postship2", xx.GetCookie(r), r.PostFormValue("csv"), verify)
	})

	log.Println("Storm @ :2208")
	log.Fatal(http.ListenAndServe(":2208", xx.AuthExcept(mux, "/login", "/logout")))
}
