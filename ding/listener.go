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
				go dbmail(id)
			case "newtweet":
				id, _ := strconv.Atoi(n.Extra)
				var tw Tweet
				err := xx.DB.QueryRow("select id, time, message from tweets where id = $1", id).Scan(&tw.ID, &tw.Time, &tw.Message)
				if err == nil {
					log.Printf("SENDING TWEET: %s", tw.Message)
					go toot(tw)
					go bloop(tw)
					go xeet(tw)
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
