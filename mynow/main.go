package main

import (
	"log"
	"net/http"
	"sive.rs/sivers/internal/shared"
)

func main() {
	if err := shared.InitDB(); err != nil {
		log.Fatalf("InitDB %v", err)
	}
	defer shared.DB.Close()

	mux := http.NewServeMux()

	mux.HandleFunc("GET /f", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		m := r.URL.Query().Get("m")
		if err := shared.Web2(w, "mynow.authform", kk, m); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /f", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		email := r.FormValue("email")
		if err := shared.Web2(w, "mynow.authpost", kk, email); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /e", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		t := r.URL.Query().Get("t")
		if err := shared.Web2(w, "mynow.welcome", kk, t); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /e", func(w http.ResponseWriter, r *http.Request) {
		t := r.FormValue("t")
		i := r.FormValue("i")
		if err := shared.Web2(w, "mynow.login", t, i); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /z", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		if err := shared.Web2(w, "mynow.logout", kk); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		if err := shared.Web2(w, "mynow.whereru", kk); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /where", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		city := r.FormValue("city")
		state := r.FormValue("state")
		country := r.FormValue("country")
		if err := shared.Web2(w, "mynow.whereset", kk, city, state, country); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /urls", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		if err := shared.Web2(w, "mynow.urls", kk); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /urls", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		url := r.FormValue("url")
		if err := shared.Web2(w, "mynow.urladd", kk, url); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /url/{id}/main", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		id := r.PathValue("id")
		if err := shared.Web2(w, "mynow.urlmain", kk, id); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /url/{id}/delete", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		id := r.PathValue("id")
		if err := shared.Web2(w, "mynow.urldel", kk, id); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /photo", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		if err := shared.Web2(w, "mynow.photo", kk); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /profile", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		edit1 := r.URL.Query().Get("edit1")
		if err := shared.Web2(w, "mynow.profile", kk, edit1); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /profile", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		qcode := r.FormValue("qcode")
		answer := r.FormValue("answer")
		if err := shared.Web2(w, "mynow.profileset", kk, qcode, answer); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /check/{id}/{action}", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		id := r.PathValue("id")
		action := r.PathValue("action")
		if err := shared.Web2(w, "mynow.checkdone", kk, id, action); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /check/{id}", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		id := r.PathValue("id")
		look4 := r.FormValue("look4")
		updatedAt := r.FormValue("updated_at")
		if err := shared.Web2(w, "mynow.checkupdate", kk, id, look4, updatedAt); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /check/{id}", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		id := r.PathValue("id")
		if err := shared.Web2(w, "mynow.checkone", kk, id); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /check", func(w http.ResponseWriter, r *http.Request) {
		kk := shared.GetCookie(r)
		if err := shared.Web2(w, "mynow.checknext", kk); err != nil {
			shared.Oops(w, err)
		}
	})

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.NotFound(w, r)
	})

	log.Println("MyNow @ :2206")
	if err := http.ListenAndServe(":2206", mux); err != nil {
		log.Fatal(err)
	}
}
