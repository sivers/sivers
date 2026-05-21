package main

import (
	"log"
	"net/http"
	"sive.rs/sivers/internal/xx"
)

func main() {
	f, err := os.OpenFile("/tmp/storm.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
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
		if err := xx.Web2(w, "storm.authform"); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /login", func(w http.ResponseWriter, r *http.Request) {
		email := r.FormValue("email")
		password := r.FormValue("password")
		if err := xx.Web2(w, "storm.authpost", email, password); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /logout", func(w http.ResponseWriter, r *http.Request) {
		if err := xx.Web2(w, "storm.logout"); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		if err := xx.Web2(w, "storm.home"); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /search", func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query().Get("q")
		if err := xx.Web2(w, "storm.search", q); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /person/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		if err := xx.Web2(w, "storm.person", id); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /person/{id}/login", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		if err := xx.Web2(w, "storm.person_login", id); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /person/{id}/invoice", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		if err := xx.Web2(w, "storm.invoice_create", id); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /invoice/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		if err := xx.Web2(w, "storm.invoice", id); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /invoice/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		// TODO: data := JSON of all posted form values
		if err := xx.Web2(w, "storm.invoice_update", id, data); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /invoice/{id}/lineitem", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		item_id := r.FormValue("item_id")
		if err := xx.Web2(w, "storm.lineitem_add", id, item_id); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /invoice/{id}/lineitems", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		// TODO: data := JSON of all posted form values
		if err := xx.Web2(w, "storm.lineitems_update", id, data); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /preship", func(w http.ResponseWriter, r *http.Request) {
		if err := xx.Web2(w, "storm.preship"); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /preship.csv", func(w http.ResponseWriter, r *http.Request) {
		if err := xx.Web2(w, "storm.preship_csv"); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /customs/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		if err := xx.Web2(w, "storm.invoice_customs", id); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /postship", func(w http.ResponseWriter, r *http.Request) {
		if err := xx.Web2(w, "storm.postship1"); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /postship", func(w http.ResponseWriter, r *http.Request) {
		csv := r.FormValue("csv")
		if err := xx.Web2(w, "storm.postship2", csv); err != nil {
			xx.Oops(w, err)
		}
	})

	log.Println("Storm @ :2208")
	log.Fatal(http.ListenAndServe(":2208", xx.AuthExcept(mux, "/login", "/logout")))
}
