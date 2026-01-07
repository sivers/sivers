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

	f, _ := os.Create("/tmp/peep.log")
	log.SetOutput(f)

	mux := http.NewServeMux()

	mux.HandleFunc("GET /login", func(w http.ResponseWriter, r *http.Request) {
		if err := xx.Web2(w, "peep.loginform"); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /login", func(w http.ResponseWriter, r *http.Request) {
		email := r.FormValue("email")
		pass := r.FormValue("password")
		if err := xx.Web2(w, "peep.login", email, pass); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		if err := xx.Web2(w, "peep.home"); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /next/{cat}", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		cat := r.PathValue("cat")
		if err := xx.Web2(w, "peep.email_open_next", kk, cat); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /list/{cat}", func(w http.ResponseWriter, r *http.Request) {
		cat := r.PathValue("cat")
		if err := xx.Web2(w, "peep.emails_unopened", cat); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /email/{id}", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		id := r.PathValue("id")
		if err := xx.Web2(w, "peep.email_view", kk, id); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /vt", func(w http.ResponseWriter, r *http.Request) {
		if err := xx.Web2(w, "peep.videotext_list"); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /vt/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		if err := xx.Web2(w, "peep.videotext_one", id); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /vt/phrase/add/{id1}/{id2}", func(w http.ResponseWriter, r *http.Request) {
		id1 := r.PathValue("id1")
		id2 := r.PathValue("id2")
		if err := xx.Web2(w, "peep.videotext_phrase_add", id1, id2); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /vt/phrase/del/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		if err := xx.Web2(w, "peep.videotext_phrase_del", id); err != nil {
			xx.Oops(w, err)
		}
	})

	log.Println("peep @ :2222")
	log.Fatal(http.ListenAndServe(":2222", xx.AuthExcept(mux, "/login")))
}
