package main

import (
	"fmt"
	"github.com/lib/pq"
	"log"
	"net/http"
	"os"
	"os/signal"
	"sive.rs/sivers/internal/xx"
	"strconv"
	"syscall"
	"time"
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

// PostgreSQL LISTEN for NOTIFY channels that need to be named in 3 places, below:
func Listener() {
	lq := pq.NewListener(xx.DSN,
		10*time.Second,
		time.Minute,
		func(ev pq.ListenerEventType, err error) {
			if err != nil {
				log.Printf("NewListener error: %v (err=%v)\n", ev, err)
			}
		},
	)

	// NOTIFY NAMES HERE
	if err := lq.Listen("email2send"); err != nil {
		log.Fatalf("Listener failed: %v", err)
	}
	if err := lq.Listen("newtweet"); err != nil {
		log.Fatalf("Listener failed: %v", err)
	}

	done := make(chan os.Signal, 1)
	signal.Notify(done, os.Interrupt, syscall.SIGTERM)

	for {
		select {
		case n := <-lq.Notify:
			if n == nil {
				continue
			}
			log.Printf("Listener heard channel=%s pid=%d payload=%s\n", n.Channel, n.BePid, n.Extra)
			switch n.Channel {
			// NOTIFY NAMES HERE
			case "email2send":
				id, _ := strconv.Atoi(n.Extra)
				log.Printf("SENDING EMAIL: %d", id)
				go DBMail(id)
			case "newtweet":
				id, _ := strconv.Atoi(n.Extra)
				var tw Tweet
				err := xx.DB.QueryRow("select id, time, message from tweets where id = $1", id).Scan(&tw.ID, &tw.Time, &tw.Message)
				if err == nil {
					log.Printf("SENDING TWEET: %s", tw.Message)
					//go Toot(tw)
					//go Bloop(tw)
					//go Xeet(tw)
				}
			}

		case <-time.After(90 * time.Second):
			go func() { _ = lq.Ping() }()

		case <-done:
			// NOTIFY NAMES HERE
			_ = lq.Unlisten("email2send")
			_ = lq.Unlisten("newtweet")
			_ = lq.Close()
			return
		}
	}
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
	if err := InitEmail(); err != nil {
		log.Fatal(err)
	}
	if err := InitActivityPub(); err != nil {
		log.Fatal(err)
	}

	// PostgreSQL
	go Listener()

	// HTTP
	mux := Router()
	fmt.Println("ding server starting on :8080")
	http.ListenAndServe(":8080", mux)
}
