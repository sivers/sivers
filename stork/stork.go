package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"sive.rs/sivers/internal/xx"
)

// why no cookies in each route? see below.
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
		xx.WebDB(w, r, "stork.home")
	})

	mux.HandleFunc("GET /search", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.search", r.URL.Query().Get("q"))
	})

	mux.HandleFunc("GET /person/{id}", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.person", r.PathValue("id"))
	})

	mux.HandleFunc("POST /person/{id}/login", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.person_login", r.PathValue("id"))
	})

	mux.HandleFunc("POST /person/{id}/invoice", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.invoice_create", r.PathValue("id"))
	})

	mux.HandleFunc("GET /invoice/{id}", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.invoice", r.PathValue("id"))
	})

	mux.HandleFunc("POST /invoice/{id}", func(w http.ResponseWriter, r *http.Request) {
		_ = r.ParseForm()
		form := make(map[string]string, len(r.PostForm))
		for key := range r.PostForm {
			form[key] = r.PostForm.Get(key)
		}
		data, _ := json.Marshal(form)
		xx.WebDB(w, r, "stork.invoice_update", r.PathValue("id"), string(data))
	})

	mux.HandleFunc("POST /invoice/{id}/lineitem", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.lineitem_add", r.PathValue("id"), r.FormValue("item_id"))
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
		xx.WebDB(w, r, "stork.lineitems_update", r.PathValue("id"), string(data))
	})

	mux.HandleFunc("POST /invoice/{id}/giftall", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.giftall", r.PathValue("id"))
	})

	mux.HandleFunc("GET /preship", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.preship_see")
	})

	mux.HandleFunc("GET /preship.csv", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.preship_csv")
	})

	mux.HandleFunc("GET /postship", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "stork.postship1")
	})

	mux.HandleFunc("POST /postship", func(w http.ResponseWriter, r *http.Request) {
		verify := r.PostFormValue("verify") == "true"
		xx.WebDB(w, r, "stork.postship2", r.PostFormValue("csv"), verify)
	})

	log.Println("stork @ :2208")
	log.Fatal(http.ListenAndServe(":2208", storkAuth(mux)))
}

// Different approach to auth than usual, because doesn't matter who is logged in as long as it's an approved admin.
// So instead of passing cookie into each function, since it's not a personalized response,
// just check once with each HTTP request (except "/login") that it's a stork admin.
// If not, redirect to /login
// If so, carry on, anon.
func storkAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/login" {
			next.ServeHTTP(w, r)
			return
		}
		var auth bool
		err := xx.DB.QueryRowContext(r.Context(), "select stork.auth($1)", xx.GetCookie(r)).Scan(&auth)
		if err != nil {
			xx.Oops(w, err)
			return
		}
		if auth != true {
			http.Redirect(w, r, "/login", 303)
			return
		}
		next.ServeHTTP(w, r)
	})
}
