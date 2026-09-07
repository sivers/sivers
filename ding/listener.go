package main

import (
	"fmt"
	"github.com/lib/pq"
	"log"
	"os"
	"sive.rs/sivers/internal/xx"
	"strconv"
	"sync"
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
		log.Printf("DB.QueryRow FAIL: %s, Error: %v", sql, err)
		return
	}
	err = os.WriteFile(filepath, []byte(xml), 0644)
	if err != nil {
		log.Printf("WriteFile FAIL: %s, Error: %v", filepath, err)
		return
	}
}

// sive.rs/__{uri}__ - get the HTML and write to disk
func writearticle(uri string) {
	var body string
	filepath := fmt.Sprintf("/var/www/html/sive.rs/%s", uri)
	sql := "select body from me.article($1)"
	err := xx.DB.QueryRow(sql, uri).Scan(&body)
	if err != nil {
		log.Printf("DB.QueryRow FAIL: %s, Error: %v", sql, err)
		return
	}
	err = os.WriteFile(filepath, []byte(body), 0644)
	if err != nil {
		log.Printf("WriteFile FAIL: %s, Error: %v", filepath, err)
		return
	}
}

// write sive.rs site to disk
func mysite() {
	if err := siversite(); err != nil {
		log.Printf("siversite failed: %v", err)
	}
}

// PostgreSQL LISTEN for NOTIFY channels that need to be named in 2 places, below:
func listener(stop <-chan struct{}) {
	var jobs sync.WaitGroup
	defer jobs.Wait()
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
		"comments_changed",
		"mysite",
	}

	// LISTEN
	for _, channel := range channels {
		if err := lq.Listen(channel); err != nil {
			log.Fatalf("Listener failed for %s: %v", channel, err)
		}
	}
	log.Printf("listener() listening")

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
				jobs.Go(func() {
					if err := dbmail(id); err != nil {
						log.Printf("Email %d failed: %v", id, err)
					}
				})
			case "tweet":
				sql2xml("all", "/var/www/html/sive.rs/feed.xml")
				id, _ := strconv.Atoi(n.Extra)
				var tw Tweet
				err := xx.DB.QueryRow("select id, time, message from tweets where id = $1", id).Scan(&tw.ID, &tw.Time, &tw.Message)
				if err == nil {
					log.Printf("POSTing Tweet: %s", tw.Message)
					jobs.Go(func() { post2Fedi(tw) })
					jobs.Go(func() { post2Bluesky(tw) })
					jobs.Go(func() { post2X(tw) })
					jobs.Go(func() { post2Telegram(tw) })
				}
				mysite()
			case "now_page":
				sql2xml("nownownow", "/var/www/html/nownownow.com/feed.xml")
			case "audio":
				sql2xml("podcast", "/var/www/html/sive.rs/podcast.rss")
				mysite()
			case "article":
				sql2xml("all", "/var/www/html/sive.rs/feed.xml")
				sql2xml("articles", "/var/www/html/sive.rs/articles.xml")
				sql2xml("tech", "/var/www/html/sive.rs/tech.xml")
				mysite()
			case "interview":
				sql2xml("all", "/var/www/html/sive.rs/feed.xml")
				sql2xml("interviews", "/var/www/html/sive.rs/i.xml")
				sql2xml("i", "/var/www/html/sive.rs/i.rss")
				mysite()
			case "ebook":
				sql2xml("all", "/var/www/html/sive.rs/feed.xml")
				sql2xml("ebooks", "/var/www/html/sive.rs/book.xml")
				mysite()
			case "comments_changed":
				writearticle(n.Extra)
			case "mysite":
				mysite()
			}

		case <-time.After(90 * time.Second):
			jobs.Go(func() { _ = lq.Ping() })

		case <-stop:
			// STOP LISTENING
			for _, channel := range channels {
				_ = lq.Unlisten(channel)
			}
			_ = lq.Close()
			return
		}
	}
}
