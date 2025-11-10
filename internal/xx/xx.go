package xx

import (
	"database/sql"
	"fmt"
	"net/http"
	"regexp"
	"strconv"
	"strings"

	_ "github.com/lib/pq"
)

var DB *sql.DB

func InitDB() error {
	var err error
	DB, err = sql.Open("postgres", "host=/tmp user=sivers dbname=sivers sslmode=disable")
	if err != nil {
		return fmt.Errorf("DB connect: %w", err)
	}
	if err = DB.Ping(); err != nil {
		return fmt.Errorf("DB ping: %w", err)
	}
	return nil
}

// DataBase Head Body - for all the "select head, body from _._()"
type DBHB struct {
	Head sql.NullString
	Body sql.NullString
}

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
// call Web2 with the function name and var-arg parameters
func Web2(w http.ResponseWriter, funk string, params ...interface{}) error {
	placeholders := make([]string, len(params))
	for i := range params {
		placeholders[i] = fmt.Sprintf("$%d", i+1)
	}
	sql := fmt.Sprintf("select head, body from %s(%s)",
		funk,
		strings.Join(placeholders, ","))

	var r DBHB
	err := DB.QueryRow(sql, params...).Scan(&r.Head, &r.Body)
	if err != nil {
		return fmt.Errorf("DB query: %w", err)
	}

	Web(w, r)
	return nil
}

// ROUTER HELPERS

var (
	rxOK = regexp.MustCompile(`^[A-Za-z0-9]{32}$`) // logins.cookie
)

// some day it might make sense to use this pattern more,
// getting a value from the HTTP request in an expected format
// or none at all, then making sure the values are in place
// before sending anything to the database.

func GetCookie(r *http.Request) any {
	c, err := r.Cookie("ok")
	if err != nil {
		return nil
	}
	s := c.Value
	if rxOK.MatchString(s) {
		return s
	}
        return nil
}

// TODO: log?
func Oops(w http.ResponseWriter, e error) {
	w.WriteHeader(500)
	w.Write([]byte(fmt.Sprintf("I messed up: %s", e)))
}

