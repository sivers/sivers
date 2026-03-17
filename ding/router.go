package main

import (
	"net/http"
)

func router() *http.ServeMux {
	mux := http.NewServeMux()

	// activitypub.go
	mux.HandleFunc("GET /d", apProfileOrWeb)
	mux.HandleFunc("GET /d/", apDeSlash)
	mux.HandleFunc("GET /d/outbox", apOutbox)
	mux.HandleFunc("GET /d/followers", apFollowers)
	mux.HandleFunc("GET /d/posts/{id}", apPost1)
	mux.HandleFunc("POST /d/inbox", apInbox)

	return mux
}
