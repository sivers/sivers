package xx

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
)

// INPUT: HTTP headers (given by PostgreSQL). Parse to ReponseWriter.
// Set-Cookie lines use Add (not Set) then AddCookie so next route sees them.
// OUTPUT: HTTP status integer
func SetHead(w http.ResponseWriter, r *http.Request, head string) int {
	status := 200
	lines := strings.Split(head, "\r\n")

	// first line might be HTTP status code ("303", "404")
	if len(lines) > 0 && len(lines[0]) == 3 {
		if code, err := strconv.Atoi(lines[0]); err == nil {
			status = code
			lines = lines[1:] // remove status from lines
		}
	}

	// remaining lines are full HTTP headers
	for _, line := range lines {
		parts := strings.SplitN(line, ": ", 2)
		if parts[0] == "Set-Cookie" {
			w.Header().Add(parts[0], parts[1])
			if c, err := http.ParseSetCookie(parts[1]); err == nil {
				r.AddCookie(c)
			}
		} else {
			w.Header().Set(parts[0], parts[1])
		}
	}
	return status
}

// WebDB runs "select head, body from schema.function($1, $2)" with given params,
// then turns that PostgreSQL head+body row into a real HTTP response.
func WebDB(w http.ResponseWriter, r *http.Request, funk string, params ...any) {
	placeholders := make([]string, len(params))
	for i := range params {
		placeholders[i] = fmt.Sprintf("$%d", i+1)
	}
	sql := fmt.Sprintf("select head, body from %s(%s)",
		funk,
		strings.Join(placeholders, ","))

	var response DBHB
	err := DB.QueryRowContext(r.Context(), sql, params...).Scan(&response.Head, &response.Body)
	if err != nil {
		Oops(w, fmt.Errorf("%s: %w", funk, err))
		return
	}

	status := 200
	w.Header().Set("Content-Type", "text/html;charset=utf-8")
	if response.Head.Valid {
		status = SetHead(w, r, response.Head.String)
	}

	w.WriteHeader(status)
	if response.Body.Valid {
		w.Write([]byte(response.Body.String))
	}
}


// ROUTER HELPERS

func Cookie(r *http.Request, name string) string {
	if c, err := r.Cookie(name); err == nil {
		return c.Value
	}
	return ""
}

func OKCookie(r *http.Request) string {
	val := Cookie(r, "ok")
	if len(val) != 32 {
		return ""
	}
	return val
}

// http.ListenAndServe(":2222", xx.AuthExcept(mux, "/login", "/logout"))
func AuthExcept(next http.Handler, except ...string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// "except" paths pass without cookie
		for _, p := range except {
			if r.URL.Path == p {
				next.ServeHTTP(w, r)
				return
			}
		}
		// if no "ok" cookie, redirect to first exempt param URL
		if OKCookie(r) == "" {
			http.Redirect(w, r, except[0], 303)
			return
		}
		// authed! carry on
		next.ServeHTTP(w, r)
	})
}

func Oops(w http.ResponseWriter, e error) {
	log.Printf("OOOPS ERROR 500: %v", e)
	http.Error(w, "Oh man. I messed up. So sorry.", 500)
}

