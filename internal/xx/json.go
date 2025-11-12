package xx

import (
	"encoding/json"
	"io"
	"net/http"
	"strings"
)

// wraps mux handler to ensure:
// 1. Content-Type is JSON
// 2. Request body is valid JSON
func JSONly(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		contentType := r.Header.Get("Content-Type")
		mediaType := strings.Split(contentType, ";")[0] // strip "; charset=utf-8"
		mediaType = strings.TrimSpace(mediaType)

		// says it's JSON?
		validTypes := []string{
			"application/activity+json",
			"application/ld+json",
			"application/json",
		}
		isValid := false
		for _, vt := range validTypes {
			if mediaType == vt {
				isValid = true
				break
			}
		}
		if !isValid {
			http.Error(w, "gimme JSON!", 415)
			return
		}

		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "bad body, bad!", 400)
			return
		}
		defer r.Body.Close()
		// valid JSON?
		var js any
		if err := json.Unmarshal(body, &js); err != nil {
			http.Error(w, "bad JSON, bad!", 400)
			return
		}

		next.ServeHTTP(w, r)
	})
}
