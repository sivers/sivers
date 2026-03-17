package main

import (
	"github.com/lib/pq"
	"log"
	"os"
	"os/signal"
	"sive.rs/sivers/internal/xx"
	"strconv"
	"syscall"
	"time"
)

type Tweet struct {
	ID      int
	Time    time.Time
	Message string
}

// PostgreSQL LISTEN for NOTIFY channels that need to be named in 3 places, below:
func listener() {
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
	if err := lq.Listen("email"); err != nil {
		log.Fatalf("Listener failed: %v", err)
	}
	if err := lq.Listen("tweet"); err != nil {
		log.Fatalf("Listener failed: %v", err)
	}
	log.Printf("listener() listening")

	done := make(chan os.Signal, 1)
	signal.Notify(done, os.Interrupt, syscall.SIGTERM)

	for {
		select {
		case n := <-lq.Notify:
			if n == nil {
				continue
			}
			log.Printf("listener heard channel=%s pid=%d payload=%s\n", n.Channel, n.BePid, n.Extra)
			switch n.Channel {
			// NOTIFY NAMES HERE
			case "email":
				id, _ := strconv.Atoi(n.Extra)
				log.Printf("SENDING EMAIL: %d", id)
				go dbmail(id)
			case "tweet":
				id, _ := strconv.Atoi(n.Extra)
				var tw Tweet
				err := xx.DB.QueryRow("select id, time, message from tweets where id = $1", id).Scan(&tw.ID, &tw.Time, &tw.Message)
				if err == nil {
					log.Printf("POSTing Tweet: %s", tw.Message)
					go post2Fedi(tw)
					go post2Bluesky(tw)
					go post2X(tw)
					go post2Telegram(tw)
				}
			}

		case <-time.After(90 * time.Second):
			go func() { _ = lq.Ping() }()

		case <-done:
			// NOTIFY NAMES HERE
			_ = lq.Unlisten("email")
			_ = lq.Unlisten("tweet")
			_ = lq.Close()
			return
		}
	}
}
