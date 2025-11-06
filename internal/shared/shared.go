package shared

import (
	"database/sql"
	"fmt"
	"net/http"
	"runtime"
	"strconv"
	"strings"

	_ "github.com/lib/pq"
)

var DB *sql.DB

func InitDB() error {
	var err error
	var pgsock string
	var connStr string

	// sql.Open() needs path to unix socket for PostgreSQL
	switch runtime.GOOS {
		case "openbsd", "freebsd", "darwin":
			pgsock = "/tmp"
		case "linux":
			pgsock = "/var/run/postgresql"
		default:
			pgsock = "/tmp"
	}
	connStr = fmt.Sprintf("host=%s user=sivers dbname=sivers sslmode=disable", pgsock)

	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		return fmt.Errorf("DB connect: %w", err)
	}
	if err = DB.Ping(); err != nil {
		return fmt.Errorf("DB ping: %w", err)
	}
	return nil
}

type DBHB struct {
	Head sql.NullString
	Body sql.NullString
}

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
