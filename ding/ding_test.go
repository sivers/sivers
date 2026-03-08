package main

import (
	_ "github.com/lib/pq"
	"net/http/httptest"
	"os"
	"sive.rs/sivers/internal/xx"
	"strings"
	"testing"
)

// repeat init stuff from ding.go's main()
func TestMain(m *testing.M) {
	xx.InitDB(false)
	InitActivityPub()
	xx.DB.Exec(PGSETUP)
	code := m.Run()
	xx.DB.Exec(PGTEARDOWN)
	os.Exit(code)
}

// everything in activitypub.go
func TestActivityPub(t *testing.T) {
	mux := Router()

	tests := []struct {
		name     string
		method   string
		path     string
		header   string
		body     string
		contains string
	}{
		{"APClient /d", "GET", "/d", "Accept: application/activity+json", "", "slow thinker, explorer, xenophile"},
		{"HTML /d", "GET", "/d", "Accept: text/html", "", "<dt>2026-03-03</dt><dd>newer tweet</dd>"},
		{"/d/", "GET", "/d/", "Accept: text/html", "", `<a href="/d">See Other</a>`},
		{"/d/outbox", "GET", "/d/outbox", "Accept: application/activity+json", "", `first":"https://sive.rs/d/outbox?page=true`},
		{"/d/outbox?page=true", "GET", "/d/outbox?page=true", "Accept: application/activity+json", "", "newer tweet"},
		{"/d/followers", "GET", "/d/followers", "Accept: application/activity+json", "", `"totalItems":2`},
		{"/d/posts/2", "GET", "/d/posts/2", "Accept: application/activity+json", "", "newer tweet"},
		{"unsigned inbox", "POST", "/d/inbox", "Accept: application/activity+json", "", "inbox signature verification failed"},
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
			resBody := rec.Body.String()
			if !strings.Contains(resBody, tt.contains) {
				t.Errorf("body doesn’t contain %q see:\n%q", tt.contains, resBody)
			}
		})
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
