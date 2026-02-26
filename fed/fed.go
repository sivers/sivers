package main

import (
	"bytes"
	"context"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"fmt"
	vocab "github.com/go-ap/activitypub"
	"github.com/go-ap/auth"
	clientS2S "github.com/go-ap/client/s2s"
	"github.com/go-ap/filters"
	"github.com/go-ap/jsonld"
	"github.com/lib/pq"
	"github.com/openshift/osin"
	"io"
	"log"
	"net/http"
	"os"
	"regexp"
	"sive.rs/sivers/internal/xx"
	"strconv"
	"strings"
	"time"
)

// go-ap/httpsig is the HTTP Signature library from the GoActivityPub suite
// (github.com/go-ap). It is the same underlying library that go-ap/auth
// wraps for ActivityPub S2S authentication. We use it directly here for
// both inbound verification (via KeyGetter) and outbound signing.

// ── Hardcoded identity ──────────────────────────────────────────────

const (
	actorID        = "https://sive.rs/d"
	actorInbox     = "https://sive.rs/d/inbox"
	actorOutbox    = "https://sive.rs/d/outbox"
	actorFollowers = "https://sive.rs/d/followers"
	keyID          = "https://sive.rs/d#main-key"
	postBase       = "https://sive.rs/d/posts/" // + tweet ID
)

// ── Signing key (loaded once at startup) ────────────────────────────

var privateKey *rsa.PrivateKey
var publicKeyPEM string

// ── Outbound delivery/signing using go-ap/client/s2s ─────────────────

var outboundTransport *clientS2S.HTTPSignatureTransport
var outboundHTTP *http.Client

// ── Inbound verification using go-ap/auth ───────────────────────────

var inboundClient *apClient
var inboundVerifier auth.ActorVerifier

// ── Database row types ──────────────────────────────────────────────

type Tweet struct {
	ID      int
	Time    time.Time
	Message string
}

type Follower struct {
	ID     int
	Actor  string
	Inbox  string
	PubKey string
}

type Mention struct {
	ID      int
	Time    time.Time
	RefsID  *int
	UserID  string
	Message string
	APub    string
}

// ── Static profile JSON (served as-is for AP clients) ───────────────

var profileJSON = []byte(`{"@context":["https://www.w3.org/ns/activitystreams","https://w3id.org/security/v1"],"type":"Person","id":"https://sive.rs/d","name":"Derek Sivers","url":"https://sive.rs","preferredUsername":"d","summary":"author of Useful Not True, How to Live, Hell Yeah Or No, Anything You Want, and more","inbox":"https://sive.rs/d/inbox","outbox":"https://sive.rs/d/outbox","followers":"https://sive.rs/d/followers","endpoints":{"sharedInbox":"https://sive.rs/d/inbox"},"icon":{"type":"Image","mediaType":"image/jpeg","url":"https://sive.rs/images/avatar.jpg"},"publicKey":{"id":"https://sive.rs/d#main-key","owner":"https://sive.rs/d","publicKeyPem":"-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwGSYvTyaSY2fy0BvHRAV\n+7rbE5yGRLz0O9WoAIWZNDQmXBt8+XC7MEuVlYxprVOAGJOongQb9bmkMuT+mUwF\ncwvpiITRbiJkw7UEe0i9gVEe0TFhMLvgZDRNLweP1x5VzyMQOMe4AyoLiJP3i/aZ\nMISZJV0vn7+4hycXwU9WePVBg3qb/oVFEvxwN462CE0CNs8eta58tIBQUQYVKUFS\nYlQO1rCG6oW941osLlfnSeXvLl0h2kuWhUU0xjM5aiNqgTbwk0izX8A0BOqmpLrc\nYqVQ5jmJmj44XusOJefltdvvesOw81W3wtbfCFJqL/30QZohJzQGyf+a8Hrq/evb\npwIDAQAB\n-----END PUBLIC KEY-----"}}`)

// ── Startup: load RSA private key ───────────────────────────────────

func loadKeys() error {
	// Private key
	data, err := os.ReadFile("/etc/ssl/fed_private.pem")
	if err != nil {
		return fmt.Errorf("read private key: %w", err)
	}
	block, _ := pem.Decode(data)
	if block == nil {
		return fmt.Errorf("no PEM block in private key file")
	}
	// Try PKCS#1 first (RSA PRIVATE KEY), then PKCS#8 (PRIVATE KEY)
	if key, err := x509.ParsePKCS1PrivateKey(block.Bytes); err == nil {
		privateKey = key
	} else {
		parsed, err := x509.ParsePKCS8PrivateKey(block.Bytes)
		if err != nil {
			return fmt.Errorf("parse private key: %w", err)
		}
		key, ok := parsed.(*rsa.PrivateKey)
		if !ok {
			return fmt.Errorf("private key is not RSA")
		}
		privateKey = key
	}

	// Public key PEM (served in the actor profile, and used for signing setup)
	pub, err := os.ReadFile("/etc/ssl/fed_public.pem")
	if err != nil {
		return fmt.Errorf("read public key: %w", err)
	}
	publicKeyPEM = strings.TrimSpace(string(pub))

	return nil
}

// ── Content negotiation ─────────────────────────────────────────────

func wantsJSON(r *http.Request) bool {
	accept := r.Header.Get("Accept")
	return strings.Contains(accept, "application/activity+json") ||
		strings.Contains(accept, "application/ld+json")
}

type apClient struct {
	hc *http.Client
}

func (c *apClient) CtxGet(ctx context.Context, url string) (*http.Response, error) {
	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/activity+json")
	return c.hc.Do(req)
}

func (c *apClient) CtxLoadIRI(ctx context.Context, iri vocab.IRI) (vocab.Item, error) {
	resp, err := c.CtxGet(ctx, iri.String())
	if err != nil {
		return nil, err
	}
	if resp == nil {
		return nil, fmt.Errorf("nil response loading %s", iri)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("load %s: status %d: %s", iri, resp.StatusCode, strings.TrimSpace(string(b)))
	}
	b, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	var it vocab.Item
	if err := jsonld.Unmarshal(b, &it); err != nil {
		return nil, err
	}
	return it, nil
}

// followerStore gives go-ap/auth a "local" cache for remote actors' public keys, backed by our followers table.
// It implements auth's oauthStore interface (readStore + LoadAccess).
type followerStore struct{}

func (s followerStore) Load(iri vocab.IRI, _ ...filters.Check) (vocab.Item, error) {
	// key_loader strips fragments already, but we do it defensively too
	u, err := iri.URL()
	if err == nil && u != nil && u.Fragment != "" {
		u.Fragment = ""
		iri = vocab.IRI(u.String())
	}

	var inbox, pem string
	err = xx.DB.QueryRow("select inbox, pubkey from followers where actor = $1", iri.String()).Scan(&inbox, &pem)
	if err != nil {
		return nil, err
	}
	act := vocab.Actor{
		ID:    vocab.IRI(iri.String()),
		Type:  vocab.ActorType,
		Inbox: vocab.IRI(inbox),
		PublicKey: vocab.PublicKey{
			ID:           vocab.IRI(iri.String() + "#main-key"),
			Owner:        vocab.IRI(iri.String()),
			PublicKeyPem: pem,
		},
	}
	return act, nil
}

func (s followerStore) LoadAccess(token string) (*osin.AccessData, error) {
	// We don't support OAuth2 bearer auth here; return nil so auth treats it as not found.
	return nil, nil
}

func itemRefEquals(it vocab.Item, want string) bool {
	if vocab.IsNil(it) {
		return false
	}
	switch v := it.(type) {
	case vocab.IRI:
		return v.String() == want
	case *vocab.IRI:
		return v != nil && v.String() == want
	case vocab.Link:
		if v.Href.String() != "" {
			return v.Href.String() == want
		}
		return v.ID.String() == want
	case *vocab.Link:
		if v == nil {
			return false
		}
		if v.Href.String() != "" {
			return v.Href.String() == want
		}
		return v.ID.String() == want
	default:
		// fallback to GetLink()
		return it.GetLink().String() == want
	}
}

func itemToString(it vocab.Item) string {
	if vocab.IsNil(it) {
		return ""
	}
	switch v := it.(type) {
	case vocab.IRI:
		return v.String()
	case *vocab.IRI:
		if v == nil {
			return ""
		}
		return v.String()
	case vocab.Link:
		if v.Href.String() != "" {
			return v.Href.String()
		}
		return v.ID.String()
	case *vocab.Link:
		if v == nil {
			return ""
		}
		if v.Href.String() != "" {
			return v.Href.String()
		}
		return v.ID.String()
	default:
		return it.GetLink().String()
	}
}

func objectIDString(it vocab.Item) string {
	if vocab.IsNil(it) {
		return ""
	}
	if vocab.IsObject(it) {
		return it.GetLink().String()
	}
	return itemToString(it)
}

// ── Remote actor fetch ───────────────────────────────────────────────

func fetchActor(actorURL string) (*vocab.Actor, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	it, err := inboundClient.CtxLoadIRI(ctx, vocab.IRI(actorURL))
	if err != nil {
		return nil, err
	}
	var act *vocab.Actor
	if err := vocab.OnActor(it, func(a *vocab.Actor) error {
		act = a
		return nil
	}); err != nil {
		return nil, err
	}
	if act == nil {
		return nil, fmt.Errorf("actor %s: not an actor", actorURL)
	}
	return act, nil
}

// ── Crypto helper ───────────────────────────────────────────────────

// ── Signed outbound POST using go-ap/httpsig ────────────────────────

func signedPost(inboxURL string, body []byte) error {
	req, err := http.NewRequest("POST", inboxURL, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/activity+json")
	req.Header.Set("Accept", "application/activity+json")

	// Most servers expect a Digest header on inbox deliveries.
	sum := sha256.Sum256(body)
	req.Header.Set("Digest", "SHA-256="+base64.StdEncoding.EncodeToString(sum[:]))

	// go-ap/client/s2s signs (request-target), host, date by default. We make
	// sure they exist. (Host comes from req.URL but we set it explicitly to be
	// safe with proxies.)
	req.Header.Set("Date", time.Now().UTC().Format(http.TimeFormat))
	req.Header.Set("Host", req.URL.Host)

	resp, err := outboundHTTP.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 4<<10))
		return fmt.Errorf("deliver %s: status %d: %s", inboxURL, resp.StatusCode, strings.TrimSpace(string(b)))
	}
	return nil
}

// ── Mention helpers ─────────────────────────────────────────────────

// mentionsMe checks if to, cc, or tag contains actorID.
func mentionsMe(note *vocab.Object) bool {
	if note == nil {
		return false
	}
	me := strings.TrimSpace(actorID)

	checkColl := func(col vocab.ItemCollection) bool {
		for _, it := range col {
			if itemRefEquals(it, me) {
				return true
			}
		}
		return false
	}
	if checkColl(note.To) || checkColl(note.CC) {
		return true
	}

	for _, it := range note.Tag {
		if itemRefEquals(it, me) {
			return true
		}
		if vocab.IsLink(it) {
			lnk, err := vocab.ToLink(it)
			if err == nil && (lnk.Href.String() == me || lnk.ID.String() == me) {
				return true
			}
		}
	}
	return false
}

var postIDRe = regexp.MustCompile(`sive\.rs/d/posts/(\d+)`)

// matchPostID extracts a tweet ID from a sive.rs/d/posts/{id} URL.
func matchPostID(url string) *int {
	m := postIDRe.FindStringSubmatch(url)
	if m == nil {
		return nil
	}
	id, err := strconv.Atoi(m[1])
	if err != nil {
		return nil
	}
	return &id
}

// ── AP object builders using go-ap/activitypub vocab types ──────────

func noteObject(tw Tweet) vocab.Object {
	id := vocab.IRI(fmt.Sprintf("%s%d", postBase, tw.ID))
	return vocab.Object{
		Type:         vocab.NoteType,
		ID:           id,
		URL:          id,
		AttributedTo: vocab.IRI(actorID),
		// NaturalLanguageValues is a map keyed by language reference.
		// Use NilLangRef for "no language".
		Content: vocab.NaturalLanguageValues{
			vocab.NilLangRef: vocab.Content(tw.Message),
		},
		Published: tw.Time.UTC(),
		To: vocab.ItemCollection{
			vocab.IRI("https://www.w3.org/ns/activitystreams#Public"),
		},
		CC: vocab.ItemCollection{
			vocab.IRI(actorFollowers),
		},
	}
}

func wrapCreate(tw Tweet) vocab.Activity {
	note := noteObject(tw)
	return vocab.Activity{
		Type:      vocab.CreateType,
		ID:        vocab.IRI(fmt.Sprintf("%s%d#create", postBase, tw.ID)),
		Actor:     vocab.IRI(actorID),
		Published: tw.Time.UTC(),
		To:        note.To,
		CC:        note.CC,
		Object:    note,
	}
}

// ── Main ────────────────────────────────────────────────────────────

func main() {
	if err := xx.InitDB(); err != nil {
		log.Fatal(err)
	}
	if err := loadKeys(); err != nil {
		log.Fatal(err)
	}

	// Initialize go-ap/httpsig signer for outbound signed POSTs
	// Configure signing headers for S2S deliveries.
	// go-ap/httpsig does not expose a RequestTarget constant; the HTTP Signature pseudo-header
	// is spelled exactly as "(request-target)".
	clientS2S.HeadersToSign = []string{"(request-target)", "host", "date", "digest", "content-type"}

	act := new(vocab.Actor)
	act.ID = vocab.IRI(actorID)
	act.PublicKey = vocab.PublicKey{
		ID:           vocab.IRI(keyID),
		Owner:        vocab.IRI(actorID),
		PublicKeyPem: publicKeyPEM,
	}

	outboundTransport = clientS2S.New(
		clientS2S.WithTransport(http.DefaultTransport),
		clientS2S.WithActor(act, privateKey),
	)
	outboundHTTP = &http.Client{Transport: outboundTransport, Timeout: 15 * time.Second}

	// Inbound verification using go-ap/auth
	inboundClient = &apClient{hc: &http.Client{Timeout: 10 * time.Second}}
	inboundVerifier = auth.HTTPSignatureResolver(inboundClient,
		auth.SolverWithStorage(followerStore{}),
	)

	mux := http.NewServeMux()

	mux.HandleFunc("GET /d", func(w http.ResponseWriter, r *http.Request) {
		if wantsJSON(r) {
			w.Header().Set("Content-Type", "application/activity+json")
			w.Write(profileJSON)
			return
		}
		rows, err := xx.DB.Query("select message, time from tweets order by time desc")
		if err != nil {
			http.Error(w, "db error", 500)
			return
		}
		defer rows.Close()
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprint(w, "<ul>\n")
		for rows.Next() {
			var msg string
			var t time.Time
			if err := rows.Scan(&msg, &t); err != nil {
				continue
			}
			fmt.Fprintf(w, "<li>%s — %s</li>\n", msg, t.Format("2006-01-02 15:04"))
		}
		fmt.Fprint(w, "</ul>\n")
	})

	mux.HandleFunc("GET /d/outbox", func(w http.ResponseWriter, r *http.Request) {
		if !wantsJSON(r) {
			http.Redirect(w, r, "/d", http.StatusSeeOther)
			return
		}
		w.Header().Set("Content-Type", "application/activity+json")
		if r.URL.Query().Get("page") != "true" {
			var count int
			xx.DB.QueryRow("select count(*) from tweets").Scan(&count)
			col := vocab.OrderedCollection{
				Type:       vocab.OrderedCollectionType,
				ID:         vocab.IRI(actorOutbox),
				TotalItems: uint(count),
				First:      vocab.IRI(actorOutbox + "?page=true"),
			}
			data, _ := json.Marshal(col)
			w.Write(data)
			return
		}
		rows, err := xx.DB.Query("select id, time, message from tweets order by time desc")
		if err != nil {
			http.Error(w, "db error", 500)
			return
		}
		defer rows.Close()
		var items vocab.ItemCollection
		for rows.Next() {
			var tw Tweet
			if err := rows.Scan(&tw.ID, &tw.Time, &tw.Message); err != nil {
				continue
			}
			items = append(items, wrapCreate(tw))
		}
		page := vocab.OrderedCollectionPage{
			Type:         vocab.OrderedCollectionPageType,
			ID:           vocab.IRI(actorOutbox + "?page=true"),
			PartOf:       vocab.IRI(actorOutbox),
			OrderedItems: items,
		}
		data, _ := json.Marshal(page)
		w.Write(data)
	})

	mux.HandleFunc("GET /d/followers", func(w http.ResponseWriter, r *http.Request) {
		if !wantsJSON(r) {
			http.Redirect(w, r, "/d", http.StatusSeeOther)
			return
		}
		var count int
		xx.DB.QueryRow("select count(*) from followers").Scan(&count)
		w.Header().Set("Content-Type", "application/activity+json")
		col := vocab.OrderedCollection{
			Type:       vocab.OrderedCollectionType,
			ID:         vocab.IRI(actorFollowers),
			TotalItems: uint(count),
		}
		data, _ := json.Marshal(col)
		w.Write(data)
	})

	mux.HandleFunc("GET /d/posts/{id}", func(w http.ResponseWriter, r *http.Request) {
		if !wantsJSON(r) {
			http.Redirect(w, r, "/d", http.StatusSeeOther)
			return
		}
		id, err := strconv.Atoi(r.PathValue("id"))
		if err != nil {
			http.NotFound(w, r)
			return
		}
		var tw Tweet
		err = xx.DB.QueryRow("select id, time, message from tweets where id = $1", id).Scan(&tw.ID, &tw.Time, &tw.Message)
		if err != nil {
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "application/activity+json")
		note := noteObject(tw)
		data, _ := json.Marshal(note)
		w.Write(data)
	})

	mux.HandleFunc("POST /d/inbox", func(w http.ResponseWriter, r *http.Request) {
		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "bad request", 400)
			return
		}
		// Replace body so the verifier can read it (digest verification)
		r.Body = io.NopCloser(bytes.NewReader(body))

		// ── Verify inbound request using go-ap/auth (HTTP Signatures) ──
		remoteActor, err := inboundVerifier.Verify(r)
		if err != nil || remoteActor.ID == vocab.PublicNS {
			log.Printf("inbox: auth verify: %v", err)
			http.Error(w, "signature verification failed", http.StatusUnauthorized)
			return
		}
		actorURL := remoteActor.ID.String()

		// ── Parse activity using go-ap/jsonld + go-ap/activitypub ──
		var it vocab.Item
		if err := jsonld.Unmarshal(body, &it); err != nil {
			http.Error(w, "bad json", http.StatusBadRequest)
			return
		}

		var act *vocab.Activity
		if err := vocab.OnActivity(it, func(a *vocab.Activity) error {
			act = a
			return nil
		}); err != nil || act == nil {
			http.Error(w, "not an activity", http.StatusBadRequest)
			return
		}

		switch {
		case act.Match(vocab.FollowType):
			remoteInbox := itemToString(remoteActor.Inbox)
			remotePEM := remoteActor.PublicKey.PublicKeyPem
			if remoteInbox == "" || remotePEM == "" {
				// Fallback: dereference actor if the signature key owner wasn't fully expanded
				a, err := fetchActor(actorURL)
				if err != nil {
					log.Printf("inbox: follow fetch %s: %v", actorURL, err)
					http.Error(w, "cannot fetch actor", http.StatusBadGateway)
					return
				}
				remoteInbox = itemToString(a.Inbox)
				remotePEM = a.PublicKey.PublicKeyPem
			}

			_, err := xx.DB.Exec(
				"insert into followers (actor, inbox, pubkey) values ($1, $2, $3) on conflict (actor) do update set inbox = $2, pubkey = $3",
				actorURL, remoteInbox, remotePEM,
			)
			if err != nil {
				log.Printf("inbox: save follower %s: %v", actorURL, err)
				http.Error(w, "db error", http.StatusInternalServerError)
				return
			}

			accept := vocab.Activity{
				Type:   vocab.AcceptType,
				ID:     vocab.IRI(fmt.Sprintf("%s#accept-%d", actorID, time.Now().UnixNano())),
				Actor:  vocab.IRI(actorID),
				Object: vocab.IRI(act.ID.String()),
			}
			acceptJSON, _ := json.Marshal(accept)
			if err := signedPost(remoteInbox, acceptJSON); err != nil {
				log.Printf("inbox: accept to %s: %v", remoteInbox, err)
			}
			w.WriteHeader(http.StatusAccepted)

		case act.Match(vocab.UndoType):
			// Undo(Follow) => delete follower
			var wasFollow bool
			_ = vocab.OnActivity(act.Object, func(a *vocab.Activity) error {
				if a.Match(vocab.FollowType) {
					wasFollow = true
				}
				return nil
			})
			if wasFollow {
				xx.DB.Exec("delete from followers where actor = $1", actorURL)
				log.Printf("inbox: unfollowed by %s", actorURL)
			}
			w.WriteHeader(http.StatusOK)

		case act.Match(vocab.CreateType):
			// Create(Note) that mentions us => store mention
			var note *vocab.Object
			if err := vocab.OnObject(act.Object, func(o *vocab.Object) error {
				note = o
				return nil
			}); err != nil || note == nil {
				w.WriteHeader(http.StatusOK)
				return
			}
			if !note.Match(vocab.NoteType) {
				w.WriteHeader(http.StatusOK)
				return
			}
			if !mentionsMe(note) {
				w.WriteHeader(http.StatusOK)
				return
			}

			noteID := objectIDString(note)
			content := vocab.ContentOf(*note)
			if noteID == "" || content == "" {
				w.WriteHeader(http.StatusOK)
				return
			}

			var refsID *int
			if inReplyTo := objectIDString(note.InReplyTo); inReplyTo != "" {
				refsID = matchPostID(inReplyTo)
			}

			_, err := xx.DB.Exec(
				"insert into mentions (refs_id, userid, message, apub) values ($1, $2, $3, $4) on conflict (apub) do nothing",
				refsID, actorURL, content, noteID,
			)
			if err != nil {
				log.Printf("inbox: save mention from %s: %v", actorURL, err)
			}
			w.WriteHeader(http.StatusOK)

		default:
			w.WriteHeader(http.StatusOK)
		}
	})

	// ── Catch-all: redirect browsers, 404 for unknown AP requests ──
	mux.HandleFunc("GET /d/", func(w http.ResponseWriter, r *http.Request) {
		if !wantsJSON(r) {
			http.Redirect(w, r, "/d", http.StatusSeeOther)
			return
		}
		http.NotFound(w, r)
	})

	go listenNewTweets()

	log.Printf("fed listening on :2407")
	log.Fatal(http.ListenAndServe(":2407", mux))
}

func listenNewTweets() {
	listener := pq.NewListener(xx.DSN, 10*time.Second, time.Minute, func(ev pq.ListenerEventType, err error) {
		if err != nil {
			log.Fatalf("newtweet listener: %v", err)
		}
	})
	if err := listener.Listen("newtweet"); err != nil {
		log.Fatalf("newtweet listen: %v", err)
	}
	log.Println("newtweet listener: started")
	for n := range listener.Notify {
		if n == nil {
			continue // reconnect event
		}
		id, err := strconv.Atoi(n.Extra)
		if err != nil {
			log.Printf("newtweet: bad id %q", n.Extra)
			continue
		}
		var tw Tweet
		err = xx.DB.QueryRow("select id, time, message from tweets where id = $1", id).Scan(&tw.ID, &tw.Time, &tw.Message)
		if err != nil {
			log.Printf("newtweet: select %d: %v", id, err)
			continue
		}
		go broadcast(tw)
	}
	log.Fatal("newtweet listener: channel closed")
}

func broadcast(tw Tweet) {
	// Build Create(Note) using go-ap/activitypub vocab types
	create := wrapCreate(tw)
	body, err := json.Marshal(create)
	if err != nil {
		log.Printf("broadcast: marshal %d: %v", tw.ID, err)
		return
	}
	rows, err := xx.DB.Query("select inbox from followers")
	if err != nil {
		log.Printf("broadcast: query followers: %v", err)
		return
	}
	defer rows.Close()
	for rows.Next() {
		var inbox string
		if err := rows.Scan(&inbox); err != nil {
			continue
		}
		if err := signedPost(inbox, body); err != nil {
			log.Printf("broadcast: post %d to %s: %v", tw.ID, inbox, err)
		}
	}
	log.Printf("broadcast: delivered post %d", tw.ID)
}
