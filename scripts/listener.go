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

func main() {
	f, _ := os.Create("/tmp/listener.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	log.SetOutput(f)

	if err := xx.InitEmail(); err != nil {
		log.Fatalf("InitEmail failed: %v", err)
	}

	listener := pq.NewListener(
		"host=/tmp user=sivers dbname=sivers sslmode=disable",
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

	// clean shutdown.
	done := make(chan os.Signal, 1)
	signal.Notify(done, os.Interrupt, syscall.SIGTERM)

	for {
		select {
		case n := <-listener.Notify:
			if n == nil {
				continue
			}
			switch n.Channel {
			case "email2send":
				log.Println("email2send: " + n.Extra)
				id, _ := strconv.Atoi(n.Extra)
				go xx.DBMail(id)
			default:
				log.Printf("channel=%s pid=%d payload=%s\n", n.Channel, n.BePid, n.Extra)
			}

		case <-time.After(90 * time.Second):
			go func() { _ = listener.Ping() }()

		case <-done:
			_ = listener.Unlisten("email2send")
			_ = listener.Close()
			return
		}
	}
}
