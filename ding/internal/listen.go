// Listen for PostgreSQL notifications, and dispatch to handlers.

package main

import (
	"log"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/lib/pq"
	"sive.rs/sivers/internal/xx"
)

// First initialize logging, database connection, and dispatchers' configs
//
// Then create the listener with pq.NewListener timings
//
// Then tell it which channels to listen for.
// Each listen channel needs to be named in three places:
// 
// 1. above the switch, in listener.Listen("channelhere")
// 2. in the case switch, to respond with dispatch
// 3. below the switch, in listener.Unlisten("channelhere")
//
// Then cleanup
func main() {
	f, err := os.OpenFile("/tmp/bellhop.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Printf("warning: couldn't open log file: %v", err)
	} else {
		log.SetOutput(f)
		defer f.Close()
	}

	if err := xx.InitDB(); err != nil {
		log.Fatalf("InitDB failed: %v", err)
	}

	if err := InitEmail(); err != nil {
		log.Fatalf("InitEmail failed: %v", err)
	}

	if err := xx.InitAP(); err != nil {
		log.Fatalf("InitAP failed: %v", err)
	}

	if err := InitBluesky(); err != nil {
		log.Fatalf("InitBluesky failed: %v", err)
	}

	if err := InitX(); err != nil {
		log.Fatalf("InitX failed: %v", err)
	}

	listener := pq.NewListener(xx.DSN,
		10*time.Second,
		time.Minute,
		func(ev pq.ListenerEventType, err error) {
			if err != nil {
				log.Printf("listener error: %v (err=%v)\n", ev, err)
			}
		},
	)

	if err := listener.Listen("email2send"); err != nil {
		log.Fatalf("listen failed: %v", err)
	}
	if err := listener.Listen("newtweet"); err != nil {
		log.Fatalf("listen failed: %v", err)
	}

	done := make(chan os.Signal, 1)
	signal.Notify(done, os.Interrupt, syscall.SIGTERM)

	for {
		select {
		case n := <-listener.Notify:
			if n == nil {
				continue
			}
			log.Printf("heard channel=%s pid=%d payload=%s\n", n.Channel, n.BePid, n.Extra)
			switch n.Channel {
			case "email2send":
				id, _ := strconv.Atoi(n.Extra)
				go DBMail(id)
			case "newtweet":
				id, _ := strconv.Atoi(n.Extra)
				var tw xx.Tweet
				err = xx.DB.QueryRow("select id, time, message from tweets where id = $1", id).Scan(&tw.ID, &tw.Time, &tw.Message)
				if err == nil {
					go Toot(tw)
					go Bloop(tw)
					go Xeet(tw)
				}
			}

		case <-time.After(90 * time.Second):
			go func() { _ = listener.Ping() }()

		case <-done:
			_ = listener.Unlisten("email2send")
			_ = listener.Unlisten("newtweet")
			_ = listener.Close()
			return
		}
	}
}
