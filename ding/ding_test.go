package main

import (
	"log"
	"net/http/httptest"
	"os"
	"sive.rs/sivers/internal/xx"
	"strings"
	"testing"
)

// repeat init stuff from ding.go's main()
func TestMain(m *testing.M) {
	if err := xx.InitDB(false); err != nil {
		log.Fatal(err)
	}
	if err := InitActivityPub(); err != nil {
		log.Fatal(err)
	}
	if _, err := xx.DB.Exec(PGSETUP); err != nil {
		log.Fatalf("test setup: %v", err)
	}
	code := m.Run()
	if _, err := xx.DB.Exec(PGTEARDOWN); err != nil {
		log.Printf("test cleanup: %v", err)
		code = 1
	}
	xx.DB.Close()
	os.Exit(code)
}

// everything in activitypub.go
func TestActivityPub(t *testing.T) {
	mux := router()

	tests := []struct {
		name     string
		method   string
		path     string
		header   string
		body     string
		status   int
		contains string
	}{
		{"APClient /d", "GET", "/d", "Accept: application/activity+json", "", 200, "slow thinker, explorer, xenophile"},
		{"/d/", "GET", "/d/", "Accept: text/html", "", 303, `<a href="/d">See Other</a>`},
		{"/d/outbox", "GET", "/d/outbox", "Accept: application/activity+json", "", 200, `first":"https://sive.rs/d/outbox?page=true`},
		{"/d/outbox?page=true", "GET", "/d/outbox?page=true", "Accept: application/activity+json", "", 200, "newer tweet"},
		{"/d/followers", "GET", "/d/followers", "Accept: application/activity+json", "", 200, `"totalItems":2`},
		{"/d/posts/2", "GET", "/d/posts/2", "Accept: application/activity+json", "", 200, "newer tweet"},
		{"unsigned inbox", "POST", "/d/inbox", "Accept: application/activity+json", "", 401, "inbox signature verification failed"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest(tt.method, tt.path, strings.NewReader(tt.body))
			if tt.header != "" {
				parts := strings.SplitN(tt.header, ": ", 2)
				req.Header.Set(parts[0], parts[1])
			}
			if tt.method == "POST" {
				req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
			}
			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, req)
			if rec.Code != tt.status {
				t.Errorf("status = %d, want %d", rec.Code, tt.status)
			}
			resBody := rec.Body.String()
			if !strings.Contains(resBody, tt.contains) {
				t.Errorf("body doesn’t contain %q see:\n%q", tt.contains, resBody)
			}
		})
	}
}

func TestActivityPubHTML(t *testing.T) {
	want, err := os.ReadFile("/var/www/html/sive.rs/d")
	if os.IsNotExist(err) {
		t.Skip("static /d file is not installed")
	}
	if err != nil {
		t.Fatal(err)
	}
	req := httptest.NewRequest("GET", "/d", nil)
	req.Header.Set("Accept", "text/html")
	rec := httptest.NewRecorder()
	router().ServeHTTP(rec, req)
	if rec.Code != 200 {
		t.Fatalf("status = %d, want 200", rec.Code)
	}
	if rec.Body.String() != string(want) {
		t.Error("response does not match the static /d file")
	}
}

const PGSETUP = `
insert into tweets (id, time, message) values (1, '2026-02-02 01:23:45+00', 'older tweet');
insert into tweets (id, time, message) values (2, '2026-03-03 01:23:45+00', 'newer tweet');

insert into people (id, name) values (1, 'Uno');
insert into people (id, name) values (2, 'Dos');

insert into followers (id, person_id, actor, inbox, profile, pubkey) values (1, 1, 'https://localhost.uno/', 'https://localhost.uno/inbox', '{}', 'xunox');
insert into followers (id, person_id, actor, inbox, profile, pubkey) values (2, 2, 'https://localhost.dos/', 'https://localhost.dos/inbox', '{}', 'xdosx');
`

const PGTEARDOWN = `
delete from tweets;
delete from followers;
delete from people;
`
