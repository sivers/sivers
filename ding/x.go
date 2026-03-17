package main

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha1"
	"encoding/base64"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/url"
	"sive.rs/sivers/internal/xx"
	"sort"
	"strconv"
	"strings"
	"time"
)

const xEndpoint = "https://api.twitter.com/2/tweets"

var (
	xConsumerKey    string
	xConsumerSecret string
	xAccessToken    string
	xAccessSecret   string
)

func InitX() error {
	_ = xx.DB.QueryRow("select o.config('x-consumer-key')").Scan(&xConsumerKey)
	_ = xx.DB.QueryRow("select o.config('x-consumer-secret')").Scan(&xConsumerSecret)
	_ = xx.DB.QueryRow("select o.config('x-access-token')").Scan(&xAccessToken)
	_ = xx.DB.QueryRow("select o.config('x-access-secret')").Scan(&xAccessSecret)
	return nil
}

func post2X(tw Tweet) {
	log.Printf("Xitter got Tweet ID=%d message=%s", tw.ID, tw.Message)
	// prep OAuth 1.0a parameters
	payload := map[string]string{"text": tw.Message}
	bodyBytes, _ := json.Marshal(payload)
	timestamp := strconv.FormatInt(time.Now().Unix(), 10)
	nonce := strconv.FormatInt(time.Now().UnixNano(), 10)
	params := map[string]string{
		"oauth_consumer_key":     xConsumerKey,
		"oauth_nonce":            nonce,
		"oauth_signature_method": "HMAC-SHA1",
		"oauth_timestamp":        timestamp,
		"oauth_token":            xAccessToken,
		"oauth_version":          "1.0",
	}

	// OAuth Signature, params sorted alphabetically by key
	var keys []string
	for k := range params {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	var paramPairs []string
	for _, k := range keys {
		paramPairs = append(paramPairs, percentEncode(k)+"="+percentEncode(params[k]))
	}
	paramString := strings.Join(paramPairs, "&")

	// base string is HTTP Method + Endpoint + Sorted Parameters
	baseString := "POST&" + percentEncode(xEndpoint) + "&" + percentEncode(paramString)

	// HMAC-SHA1 Signature
	signingKey := percentEncode(xConsumerSecret) + "&" + percentEncode(xAccessSecret)
	mac := hmac.New(sha1.New, []byte(signingKey))
	mac.Write([]byte(baseString))
	signature := base64.StdEncoding.EncodeToString(mac.Sum(nil))
	params["oauth_signature"] = signature

	// final Authorization Header
	var authPairs []string
	for k, v := range params {
		authPairs = append(authPairs, percentEncode(k)+"=\""+percentEncode(v)+"\"")
	}
	authHeader := "OAuth " + strings.Join(authPairs, ", ")

	// finally HTTP POST it
	req, _ := http.NewRequest("POST", xEndpoint, bytes.NewBuffer(bodyBytes))
	req.Header.Set("Authorization", authHeader)
	req.Header.Set("Content-Type", "application/json")
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		log.Println("Xitter POST error:", err)
		return
	}
	defer resp.Body.Close()

	// get response to get Tweet ID from "data" object, update database, then early return
	respBody, _ := io.ReadAll(resp.Body)
	var result map[string]interface{}
	json.Unmarshal(respBody, &result)
	if data, ok := result["data"].(map[string]interface{}); ok {
		if xid, ok := data["id"].(string); ok {
			log.Printf("Xitter setting Tweet ID %d to XID %s", tw.ID, xid)
			_, err = xx.DB.Exec("update tweets set xid = $1 where id = $2", xid, tw.ID)
			return
		}
	}
	// print if failed
	log.Printf("Xitter failed to read body. Status: %d\nResponse: %s\n", resp.StatusCode, string(respBody))
}

// Go's default url.QueryEscape doesn't do RFC 3986, which OAuth 1.0a requires
func percentEncode(s string) string {
	s = url.QueryEscape(s)
	s = strings.ReplaceAll(s, "+", "%20")
	s = strings.ReplaceAll(s, "%7E", "~")
	return s
}
