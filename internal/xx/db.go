package xx

import (
	"database/sql"
	"fmt"

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
