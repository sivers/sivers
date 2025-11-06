package main

import (
	"database/sql"
	"log"
	"net/http"
	"sive.rs/sivers/internal/shared"
)

func main() {
	if err := shared.InitDB(); err != nil {
		log.Fatalf("InitDB %v", err)
	}
	defer shared.DB.Close()

	http.HandleFunc("GET /random", func(w http.ResponseWriter, r *http.Request) {
		if err := shared.Web2(w, "nnn.random"); err != nil {
			http.Error(w, err.Error(), 500)
			return
		}
	})

	http.HandleFunc("GET /search", func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query().Get("q")
		if len(q) < 3 || len(q) > 50 {
			shared.Web(w, shared.DBHB{
				Head: sql.NullString{String: "303\r\nLocation: /", Valid: true}})
			return
		}
		if err := shared.Web2(w, "nnn.search", q); err != nil {
			http.Error(w, err.Error(), 500)
			return
		}
	})

	log.Println("NNN @ :2203")
	if err := http.ListenAndServe(":2203", nil); err != nil {
		log.Fatal(err)
	}
}
