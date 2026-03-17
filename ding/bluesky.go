package main

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"regexp"
	"sive.rs/sivers/internal/xx"
	"time"
)

var BSKYPASS string

// load my Bluesky server password
func InitBluesky() error {
	_ = xx.DB.QueryRow("select o.config('bluesky')").Scan(&BSKYPASS)
	return nil
}

func post2Bluesky(tw Tweet) {
	log.Printf("Bluesky got Tweet ID=%d message=%s", tw.ID, tw.Message)
	client := &http.Client{Timeout: 10 * time.Second}

	// Create Session with my password to get DID and Access Token
	sReq, _ := json.Marshal(map[string]string{
		"identifier": "sive.rs",
		"password":   BSKYPASS,
	})
	resp, err := client.Post("https://p.sive.rs/xrpc/com.atproto.server.createSession", "application/json", bytes.NewReader(sReq))
	if err != nil {
		log.Printf("Bluesky createSession error: %v", err)
		return
	}
	defer resp.Body.Close()
	bodyBytes, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		log.Printf("Bluesky createSession StatsCode not OK")
		return
	}

	// From createSession response, extract DID and AccessToken
	var sResp struct {
		Did       string `json:"did"`
		AccessJwt string `json:"accessJwt"`
	}
	if err := json.Unmarshal(bodyBytes, &sResp); err != nil {
		log.Printf("Bluesky JSON unmarshal error: %v", err)
		return
	}

	// Post message (Create Record) through blueRich enhancements
	cReq, _ := json.Marshal(map[string]any{
		"repo":       sResp.Did,
		"collection": "app.bsky.feed.post",
		"record":     blueRich(tw.Message),
	})
	req, _ := http.NewRequest("POST", "https://p.sive.rs/xrpc/com.atproto.repo.createRecord", bytes.NewReader(cReq))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+sResp.AccessJwt)
	log.Printf("Bluesky posting Tweet ID %d", tw.ID)
	recResp, err := client.Do(req)
	if err != nil {
		log.Printf("Bluesky client POST error: %v", err)
		return
	}
	defer recResp.Body.Close()
	recBodyBytes, _ := io.ReadAll(recResp.Body)
	if recResp.StatusCode != http.StatusOK {
		log.Printf("Bluesky POST StatsCode not OK")
		return
	}

	// From createRecord HTTP response, extract URI, and update tweets table with it
	var cResp struct {
		URI string `json:"uri"`
	}
	if err := json.Unmarshal(recBodyBytes, &cResp); err != nil {
		return
	}
	log.Printf("Bluesky setting Tweet ID %d to ATP %s", tw.ID, cResp.URI)
	_, err = xx.DB.Exec("update tweets set atp = $1 where id = $2", cResp.URI, tw.ID)
}

// given plain text that might have URLs, add ATProto facets to hyperlink URLs
func blueRich(text string) map[string]any {
	re := regexp.MustCompile(`https://[^\s]+`)
	matches := re.FindAllStringIndex(text, -1)

	var facets []map[string]any
	for _, m := range matches {
		facets = append(facets, map[string]any{
			"index": map[string]int{
				"byteStart": m[0],
				"byteEnd":   m[1],
			},
			"features": []map[string]string{
				{
					"$type": "app.bsky.richtext.facet#link",
					"uri":   text[m[0]:m[1]],
				},
			},
		})
	}

	return map[string]any{
		"text":      text,
		"createdAt": time.Now().UTC().Format(time.RFC3339),
		"facets":    facets,
	}
}
