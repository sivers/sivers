package main

import (
	"fmt"
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

// give it the PostgreSQL function suffix, and filepath
// it queries, then outputs the XML there
func sql2xml(dingfunk string, filepath string) {
	var xml string
	sql := fmt.Sprintf("select xml from ding.xml_%s()", dingfunk)
	err := xx.DB.QueryRow(sql).Scan(&xml)
	if err != nil {
		log.Fatalf("DB.QueryRow FAIL: %s, Error: %v", sql, err)
	}
	err = os.WriteFile(filepath, []byte(xml), 0644)
	if err != nil {
		log.Fatalf("WriteFile FAIL: %s, Error: %v", filepath, err)
	}
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

	// NOTIFY/LISTEN channels
	channels := []string{
		"email",
		"tweet",
		"now_page",
		"audio",
		"article",
		"interview",
		"ebook",
	}

	// LISTEN
	for _, channel := range channels {
		if err := lq.Listen(channel); err != nil {
			log.Fatalf("Listener failed for %s: %v", channel, err)
		}
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
			// NOTIFY/LISTEN case using same order as "channels" array
			switch n.Channel {
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
			case "now_page":
				sql2xml("nownownow", "/var/www/html/nownownow.com/feed.xml")
			case "audio":
				sql2xml("podcast", "/var/www/code/sive.rs/site/podcast.xml") // TODO: make it .rss
			case "article":
				sql2xml("articles", "/var/www/code/sive.rs/site/articles.xml")
			case "interview":
				sql2xml("interviews", "/var/www/code/sive.rs/site/i.xml")
			case "ebook":
				sql2xml("ebooks", "/var/www/code/sive.rs/site/book.xml")
			}

		case <-time.After(90 * time.Second):
			go func() { _ = lq.Ping() }()

		case <-done:
			// STOP LISTENING
			for _, channel := range channels {
				_ = lq.Unlisten(channel)
			}
			_ = lq.Close()
			return
		}
	}
}
