# Code Conventions

This repository is my database and web applications.
Follow these conventions strictly when writing SQL, tests, or Go code.

---

## 1. Core Architecture: Fat PostgreSQL, Thin Go

- **Keep everything possible in PostgreSQL.** Data cleaning, validation, authentication, authorization, business logic, Mustache HTML rendering, XML feed generation, and HTTP status/header overrides all happen inside PostgreSQL functions.
- **Keep as little as possible in Go.** Go is a thin I/O layer that may be replaced by another language in the future. Only use Go for things PostgreSQL cannot do directly:
  - HTTP request parsing and response writing (`internal/xx`)
  - `LISTEN` / `NOTIFY` event loop (`ding/listener.go`)
  - Writing static HTML/XML/binary files to disk
  - Outbound/inbound network protocols (SMTPS, ActivityPub, Bluesky ATProto, X OAuth, Telegram TDLib, CDN uploading and purging)
- **Templates live in the database, not on disk.** Mustache templates are stored in the `templates (code, template)` table and rendered inside PostgreSQL via `o.template(...)`.

---

## 2. Repository & Schema Layout

### Schemas vs. Tables
- **Tables** are defined in `tables.sql` in the top-level `public` schema. Production tables and data are never dropped.
- **Functions, views, and triggers** live in schemas that map to directories:
  - `o/` — "omni" shared functions used across multiple apps (`clean_*`, `template`, `must_*`, `temp_*`, `email*`, `login`, `ipcc`, etc.)
  - `ding/` — `NOTIFY` triggers (`NOTIFY.sql`), XML feed generators (`xml_*.sql`), and the `ding` network daemon (`*.go`)
  - `me/` — `sive.rs` static site generators and dynamic endpoints
  - `mynow/` — `my.nownownow.com` authenticated user portal
  - `nnn/` — `nownownow.com` static site generators and search/random endpoints
  - `store/` — shared store pricing, shipping, and invoice recalculation logic/triggers
  - `stork/` — storekeeper admin web app
  - `peep/` — people and email admin web app
- **Stateless function reloading:** `reset.sh` drops and recreates each function schema (`drop schema if exists $schema cascade; create schema $schema`) and reloads `"$schema"/*.sql` on both `sivers` (live) and `siverstest` (test) with `set plpgsql.extra_warnings to 'all'`.

### File Naming Rules
- **One function per file:** `<schema>/<function_name>.sql` defines `<schema>.<function_name>`.
  - *Exception 1 — Load-order dependencies:* Prefix filename with `0_` (e.g., `me/0_topics.sql` for `me.topics()`, `store/0_price.sql` for `store.price()`) so the shell glob `"$schema"/*.sql` in `reset.sh` loads it before functions in the same schema that call it.
  - *Exception 2 — Triggers:* Group triggers and their trigger functions in `TRIGGERS.sql` (`o/TRIGGERS.sql`, `store/TRIGGERS.sql`) or `ding/NOTIFY.sql`.
  - *Exception 3 — Tightly coupled overloads/helpers:* Function overloads or private helpers used only by that file may share the file (e.g., `o/template.sql`, `o/temp_add.sql`, `o/temp_get.sql`, `o/mustkey.sql`).
- **One test file per function file:** `<schema>/test/<function_name>.sql` contains the pgTAP tests for `<schema>/<function_name>.sql`.

---

## 3. PostgreSQL & PL/pgSQL Style

### Formatting & Syntax
- **All SQL is lowercase:** Examples: `create function`, `returns`, `declare`, `begin`, `select`, `from`, `where`, `join`, `left join`, `insert into`, `values`, `update`, `set`, `$$ language plpgsql;`, `$$ language sql;`. Never write uppercase `SELECT`, `FROM`, `WHERE`, etc.
- **Column names unescaped:** Column names will never have spaces or special characters, so don't escape column names with backticks.
- **Indentation:** Use hard tabs (`\t`), never spaces.
- **No `or replace` on schema functions:** Write `create function schema.func(...)` because `reset.sh` drops the schema before loading. Use `create or replace trigger` on triggers attached to `public` tables.
- **Assignment operator:** Use `=` (not `:=`) for PL/pgSQL variable initialization and assignment:
  ```sql
  declare
  	txt text = template;
  	pid integer;
  begin
  	pid = 1;
  	head = e'303\r\nLocation: /';
  end;
  ```
- **String literals:**
  - Use `e'...'` (lowercase `e`) when strings contain escape sequences like `\r`, `\n`, `\t` (e.g., `e'303\r\nLocation: /f'`).
  - Use `$$` for function bodies. If dollar-quoting is needed inside a function body, use named tags like `$sql$...$sql$` or `$html$...$html$`.

### Parameters & Return Signatures
- **Input parameter names:** Prefix input parameters with `_` (e.g., `_pid integer`, `_email text`, `_uri text`, `_formdata jsonb`) to avoid shadowing table column names.
- `pid` variable name always refers to the common column name `person_id`, the foreign key for `people.id` integer.
- `kk` variable name always refers to the HTTP cookie, stored in `logins.cookie` char(32).
- **Positional parameters in bodies:** Inside function bodies, prefer `$1`, `$2`, `$3` over parameter names in SQL queries and PL/pgSQL expressions.
- **Prefer `out` parameters over `returns <type>`:**
  - **Web functions** always use `(..., out head text, out body text)` with no `returns` clause:
```sql
create function mynow.logout(kk char(32),
    out head text, out body text) as $$
begin
    delete from logins where cookie = $1;
    head = e'303\r\nSet-Cookie: ok=; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=0\r\nLocation: /f';
end;
$$ language plpgsql;
```
  - **Static HTML-generating functions** use `out body text`:
```sql
create function me.articles(out body text) as $$
    select o.template('me-wrap', 'me-articles', jsonb_build_object(...));
$$ language sql;
```
  - **XML feed functions** use `out xml text`.
  - **Single-value getters/cleaners** often use `out <colname> <type>` so callers can `select pid from o.pid_from_email(...)`:
```sql
create function o.pid_from_cookie(_cookie text, out pid integer) as $$
    select person_id from logins where cookie = $1;
$$ language sql stable;
```
  - **Multi-row functions** use `returns table(...)`.
- **`language sql` vs. `language plpgsql`:**
  - Use `language sql` for single-expression functions (mark `immutable`, `stable`, `strict`, `parallel safe` where applicable, especially if used in indexes).
  - Use `language plpgsql` when procedural control flow (`if`, `loop`, `perform`, early `return`, `exception`) is needed.
  - Because `plpgsql.extra_warnings` is set to `'all'`, avoid unused variables or shadowed identifiers.

### Common `o.*` Function Signatures
- `o.template(_wrapcode text, _corecode text, _data jsonb, out html text)`
- `o.template(_code text, _data jsonb, out html text)`
- `o.pid_from_cookie(_cookie text, out pid integer)`
- `o.clean_name(_name text, out clean text)`
- `o.clean_email(_email text, out clean text)`
- `o.clean_url(_url text, out clean text)`
- `o.config(_k text, out v text)`

### Web Function Contract (`head`, `body`)
All HTTP-facing PostgreSQL functions return `(out head text, out body text)` and are converted to HTTP response by `xx.WebDB`:
- **`head` is `null`?** Defaults to HTTP `200` and `Content-Type: text/html;charset=utf-8`, sending `body`.
- **First line of `head` is 3 digits?** Override the HTTP status code (`303`, `404`, etc.). Lines in `head` are separated by `\r\n`.
- **Remaining lines of `head`?** Parse as `Header: Value` (split on `": "`) and set on the HTTP response.
- **Common `head` patterns:**
  - Redirect (`303`):
    ```sql
    head = e'303\r\nLocation: /contact';
    return;
    ```
  - Login cookie + redirect:
    ```sql
    head = concat(e'303\r\nSet-Cookie: ok=', cookie, e'; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=604800\r\nLocation: /');
    ```
  - Custom content type:
    ```sql
    head = e'Content-Type: text/csv; charset=utf-8\r\nContent-Disposition: attachment; filename="preship.csv"';
    ```

### Mustache Templates & JSONB Construction
- Wrap + core template rendering uses `o.template('app-wrap', 'app-core', data_jsonb)`.
  - `o.template` renders `'app-core'` with `data_jsonb`, injects the result as `{{{core}}}`, and renders `'app-wrap'` with the same `data_jsonb`.
- Partial/unwrapped template rendering uses `o.template('template-code', data_jsonb)`.
- Build template data directly in SQL using `to_jsonb(r)`, `jsonb_build_object(...)`, and `jsonb_agg(r)`:
  ```sql
  create function me.topic_page(_topic text, out body text) as $$
  	select o.template('me-wrap', 'me-topic', (select jsonb_build_object(
  		'pagetitle', 'Derek Sivers ' || name || ' articles',
  		'name', name,
  		'description', description,
  		'howmany', (select count(*) from articles where topic = $1),
  		'articles', (select jsonb_agg(r) from (
  			select uri, posted as ymd, title
  			from articles
  			where topic = $1
  			and posted is not null
  			order by posted desc, id desc
  		) r)
  	) from topics where uri = $1));
  $$ language sql;
  ```
- When an empty list is required instead of `null`, wrap `jsonb_agg` in `coalesce((select jsonb_agg(r) from (...) r), '[]')`.

### Table Definitions (`tables.sql`) & Data Hygiene
- **Foreign keys as comments:** In `tables.sql`, never write inline `references` constraints. Write them as trailing comments in the exact format `-- references table(column) [on delete cascade]`:
  ```sql
  person_id integer not null, -- references people(id) on delete cascade
  ```
  `scripts/table-refs.awk` parses `-- references ` comments to generate `alter table ... add foreign key ...` statements after data loads. Any extra comment after the reference must be separated by ` --` (e.g., `-- references people(id) on delete cascade -- null if new`).
- **NULL over empty strings:** Nullable text columns must be `null` rather than `''`. Tables enforce `check (length(col) > 0)`. When updating from user input, convert blank strings to `null` (or use `o.update_white` / `o.update_black`).
- **Data cleaning helpers:** Always use `o.clean_name`, `o.clean_email`, `o.clean_url`, `o.clean_code`, and `o.clean4search` (which are also wired into `before insert or update` triggers in `o/TRIGGERS.sql`).

### Perfect Example of Web Function and its pgTAP test

Filename: `mynow/urls.sql`

```sql
create function mynow.urls(kk char(32),
	out head text, out body text) as $$
declare
	pid integer;
begin
	select logins.person_id into pid
	from logins
	where cookie = $1;
	if pid is null then
		head = e'303\r\nLocation: /f';
	else
		body = o.template('mynow-wrap', 'mynow-urls', 
			jsonb_build_object('urls', coalesce((select jsonb_agg(r) from (
				select id, main, url
				from urls where person_id = pid
				order by main desc nulls last, id asc
			) r), '[]'))
		);
	end if;
end;
$$ language plpgsql;
```

Filename: `mynow/test/urls.sql`

```sql
insert into templates (code, template) values ('mynow-wrap', '<html>{{{core}}}</html>');
insert into templates (code, template) values ('mynow-urls', '<ul>{{#urls}}<li>{{id}} {{#main}}<strong>{{/main}}{{url}}{{#main}}</strong>{{/main}}</li>{{/urls}}</ul>');
insert into people (id, name) values (1, 'Person A');
insert into people (id, name) values (2, 'Person B');
insert into logins (cookie, person_id) values ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 1);
insert into urls (id, person_id, url, main) values (1, 1, 'https://x.com/a', false);
insert into urls (id, person_id, url, main) values (2, 1, 'https://a.com/', true);
insert into urls (id, person_id, url, main) values (3, 2, 'https://not-their-url.com', false);
insert into urls (id, person_id, url, main) values (4, 1, 'https://aaa.net/', false);

select plan(6);

select is(head, e'303\r\nLocation: /f', 'nocookie'),
	is(body, null)
from mynow.urls(null);

select is(head, e'303\r\nLocation: /f', 'badcookie'),
	is(body, null)
from mynow.urls('aaaXaaaXaaaXaaaXaaaXaaaaaaaaXaaa');

select is(head, null, 'good'),
	is(body, '<html><ul><li>2 <strong>https://a.com/</strong></li><li>1 https://x.com/a</li><li>4 https://aaa.net/</li></ul></html>')
from mynow.urls('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
```

---

## 4. pgTAP Testing Conventions (`*/test/*.sql`)

- **Run a single test file:** `scripts/tap <schema>/test/<file>.sql` (or `tap <file>.sql` if `scripts/tap` is in `$PATH`).
- **Reload functions before testing changes:** Run `./reset.sh` whenever SQL functions or tables change.
- **No transaction wrapper in test files:** `scripts/tap` wraps every test run in `begin; \i :FILENAME; select * from finish(); rollback;`. Never put `begin;`, `finish()`, or `rollback;` inside a test file.
- **Self-contained minimal fixtures:** `siverstest` starts completely empty. Each test file inserts only the minimal rows required to test its target function:
  - Insert minimal `templates` rows with compact test templates (e.g., `'<title>{{pagetitle}}</title><body>{{{core}}}</body>'`) rather than full production HTML.
  - Insert only required parent rows (e.g., `countries`, `currencies`, `people`, `logins`).
  - Reset identity sequences with `select setval('<table>_id_seq', <n>);` when asserting on newly generated IDs.
- **Assertions:**
  - Declare the exact test count with `select plan(N);` after fixture setup.
  - Prefer `is(actual, expected, 'description')`, grouping multiple assertions from a single function call into one `select`:
    ```sql
    select is(head, e'303\r\nLocation: /f'),
    	is(body, null, 'bad cookie')
    from mynow.whereset('dddXdddXdddXdddXdddXdddXdddXdddd', 'My City', 'My State', 'GB');
    ```
  - Cast `count(*)` to `integer` for pgTAP type matching: `select is(count(*)::integer, 1, 'one row') from ...;`.

---

## 5. Go Conventions (`*/*.go`, `internal/xx/*.go`)

### HTTP Servers & Routing
- Use the standard library `http.NewServeMux()` with Go 1.22+ method and path patterns (`"GET /{$}"`, `"GET /comments/{uri}"`, `"POST /url/{id}/main"`).
- Use `internal/xx` for database initialization, request-to-SQL dispatch, cookie reading, and auth middleware:
```go
mux.HandleFunc("POST /url/{id}/main", func(w http.ResponseWriter, r *http.Request) {
    xx.WebDB(w, r, "mynow.urlmain", xx.GetCookie(r), r.PathValue("id"))
})
```
- **Multi-field POST forms:** When an endpoint accepts many form fields, pack them into a `map[string]string`, marshal to JSON, and pass a single `json`/`jsonb` parameter to the PostgreSQL function:
```go
formData := map[string]string{
    "uri":     r.PathValue("uri"),
    "name":    r.PostFormValue("name"),
    "email":   r.PostFormValue("email"),
    "comment": r.PostFormValue("comment"),
    "ip":      r.Header.Get("X-Real-IP"),
}
jsonData, _ := json.Marshal(formData)
xx.WebDB(w, r, "me.comment_post", jsonData)
```
- **Authentication middleware:** Wrap `mux` with `xx.AuthExcept(mux, "/login", "/logout")` (or `"/f", "/e", "/z"` for `mynow`) when the entire app requires the `"ok"` cookie except for login routes; still validate `kk` inside each SQL function to resolve `person_id`.
- **Configuration & secrets:** Load API keys, passwords, and hostnames from the `configs` table via `select o.config('key')` during startup (`Init*` functions).
- **Server setup:**
  - Log to `/tmp/<app>.log` via `os.OpenFile`.
  - Initialize the database with `xx.InitDB(true)` in `main()` and `xx.InitDB(false)` in `TestMain`.
  - Listen on the app's local port behind nginx (which supplies `X-Real-IP`).
  - Handle unexpected errors in HTTP handlers with `xx.Oops(w, err)`.

### internal/xx/db.go

```go
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
```

### internal/xx/web.go

```go
package xx

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
)

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
		lines := strings.Split(response.Head.String, "\r\n")

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
	if response.Body.Valid {
		w.Write([]byte(response.Body.String))
	}
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
```

