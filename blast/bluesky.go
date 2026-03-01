package bluesky

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"time"
	"sive.rs/sivers/internal/xx"
)

var BSKYPASS string

// load my Bluesky server password into a constant
func InitBluesky() error {
	_ = xx.DB.QueryRow("select o.config('bluesky')").Scan(&BSKYPASS)
	return nil
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

// Given just plain text, which might have URLs in it, 
func BlueskyPost(text string) (string, error) {
	client := &http.Client{Timeout: 10 * time.Second}

	// Create Session with my password to get DID and Access Token
	sReq, _ := json.Marshal(map[string]string{
		"identifier": "sive.rs",
		"password": BSKYPASS,
	})
	resp, err := client.Post("https://p.sive.rs/xrpc/com.atproto.server.createSession", "application/json", bytes.NewReader(sReq))
	if err != nil {
		return "", fmt.Errorf("session request failed: %w", err)
	}
	defer resp.Body.Close()
	bodyBytes, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("session creation failed: %s", string(bodyBytes))
	}

	// From createSession response, extract DID and AccessToken
	var sResp struct {
		Did       string `json:"did"`
		AccessJwt string `json:"accessJwt"`
	}
	if err := json.Unmarshal(bodyBytes, &sResp); err != nil {
		return "", fmt.Errorf("failed to parse session: %w", err)
	}

	// Post message (Create Record) through blueRich enhancements
	cReq, _ := json.Marshal(map[string]any{
		"repo":       sResp.Did,
		"collection": "app.bsky.feed.post",
		"record":     blueRich(text),
	})
	req, _ := http.NewRequest("POST", "https://p.sive.rs/xrpc/com.atproto.repo.createRecord", bytes.NewReader(cReq))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+sResp.AccessJwt)
	recResp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("post request failed: %w", err)
	}
	defer recResp.Body.Close()
	recBodyBytes, _ := io.ReadAll(recResp.Body)
	if recResp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("post creation failed: %s", string(recBodyBytes))
	}

	// From createRecord HTTP response, extract and return URI 
	var cResp struct {
		URI string `json:"uri"`
	}
	if err := json.Unmarshal(recBodyBytes, &cResp); err != nil {
		return "", fmt.Errorf("failed to parse post response: %w", err)
	}
	return cResp.URI, nil
}
