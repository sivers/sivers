package xx

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
)

// turn PostgreSQL's head+body response into real HTTP response
func Web(w http.ResponseWriter, r DBHB) {
	status := 200
	w.Header().Set("Content-Type", "text/html;charset=utf-8")

	if r.Head.Valid {
		lines := strings.Split(r.Head.String, "\r\n")

		// first line might be HTTP status code ("303", "404")
		if len(lines) > 0 && len(lines[0]) == 3 {
			if code, err := strconv.Atoi(lines[0]); err == nil {
				status = code
				lines = lines[1:] // remove status from lines
			}
		}

		// remaining lines are HTTP headers
		for _, line := range lines {
			parts := strings.SplitN(line, ": ", 2)
			w.Header().Set(parts[0], parts[1])
		}
	}

	w.WriteHeader(status)
	if r.Body.Valid {
		w.Write([]byte(r.Body.String))
	}
}

// sugar for the most frequent query form:
// "select head, body from schema.function($1, $2)", [param1, param2]
// call WebDB with the function name and var-arg parameters
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

	Web(w, response)
}

// ROUTER HELPERS

func GetCookie(r *http.Request) string {
	c, err := r.Cookie("ok")
	if err != nil || len(c.Value) != 32 {
		return ""
	}
	return c.Value
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
		if GetCookie(r) == "" {
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
