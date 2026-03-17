package xx

import (
	"database/sql"
	"fmt"
	"time"

	_ "github.com/lib/pq"
)

var DB *sql.DB

const DSN = "host=/tmp user=sivers dbname=sivers sslmode=disable"
const TestDSN = "host=/tmp user=sivers dbname=siverstest sslmode=disable"

func InitDB(useLiveDB bool) error {
	var err error
	if useLiveDB == true {
		DB, err = sql.Open("postgres", DSN)
	} else {
		DB, err = sql.Open("postgres", TestDSN)
	}
	if err != nil {
		return fmt.Errorf("DB connect: %w", err)
	}
	if err = DB.Ping(); err != nil {
		return fmt.Errorf("DB ping: %w", err)
	}
	DB.SetMaxOpenConns(4)
	DB.SetMaxIdleConns(2)
	DB.SetConnMaxLifetime(5 * time.Minute)
	DB.SetConnMaxIdleTime(2 * time.Minute)
	return nil
}

// DataBase Head Body - for all the "select head, body from _._()"
type DBHB struct {
	Head sql.NullString
	Body sql.NullString
}
