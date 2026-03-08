package main
import (
	"fmt"
	"log"
	"net/http"
	"os"
	"sive.rs/sivers/internal/xx"
)

func Router() *http.ServeMux {
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

func main() {
	f, err := os.OpenFile("/tmp/ding.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Printf("warning: couldn't open log file: %v", err)
	} else {
		log.SetOutput(f)
		defer f.Close()
	}

	if err := xx.InitDB(true); err != nil {
		log.Fatal(err)
	}
	if err := InitActivityPub(); err != nil {
		log.Fatal(err)
	}

	mux := Router()
	fmt.Println("ding server starting on :8080")
        http.ListenAndServe(":8080", mux)
}
