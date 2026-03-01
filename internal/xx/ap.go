package xx

// ActivityPub stuff shared by
// fed/fed.go which runs the HTTP listening server at https://sive.rs/d
// and
// blast/activitypub.go which sends outgoing posts

import (
	"bytes"
	"crypto/rsa"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	vocab "github.com/go-ap/activitypub"
	"github.com/go-ap/httpsig"
)

// ── Hardcoded identity ──────────────────────────────────────────────

const (
	ActorID        = "https://sive.rs/d"
	ActorInbox     = "https://sive.rs/d/inbox"
	ActorOutbox    = "https://sive.rs/d/outbox"
	ActorFollowers = "https://sive.rs/d/followers"
	KeyID          = "https://sive.rs/d#main-key"
	PostBase       = "https://sive.rs/d/posts/" // + Tweet.ID
)

var (
	PrivateKey   *rsa.PrivateKey
	OutboundHTTP *http.Client
)

// ── Database row type ──────────────────────────────────────────────

type Tweet struct {
	ID      int
	Time    time.Time
	Message string
}

// ── Marshal helper ──────────────────────────────────────────────────

var (
	asContext    = []string{"https://www.w3.org/ns/activitystreams"}
	asSecContext = []string{"https://www.w3.org/ns/activitystreams", "https://w3id.org/security/v1"}
)

func marshalWithContext(ctx any, v any) ([]byte, error) {
	b, err := json.Marshal(v)
	if err != nil {
		return nil, err
	}

	var m map[string]any
	if err := json.Unmarshal(b, &m); err != nil {
		return nil, err
	}

	m["@context"] = ctx
	return json.Marshal(m)
}

func MarshalAS(v any) ([]byte, error) {
	return marshalWithContext(asContext, v)
}

func MarshalASSec(v any) ([]byte, error) {
	return marshalWithContext(asSecContext, v)
}

// ── Object builders ──────────────────────────────────────────────

func NoteObject(tw Tweet) vocab.Object {
	id := vocab.IRI(fmt.Sprintf("%s%d", PostBase, tw.ID))
	return vocab.Object{
		Type:         vocab.NoteType,
		ID:           id,
		URL:          id,
		AttributedTo: vocab.IRI(ActorID),
		Content: vocab.NaturalLanguageValues{
			vocab.NilLangRef: vocab.Content(tw.Message),
		},
		Published: tw.Time.UTC(),
		To: vocab.ItemCollection{
			vocab.IRI("https://www.w3.org/ns/activitystreams#Public"),
		},
		CC: vocab.ItemCollection{
			vocab.IRI(ActorFollowers),
		},
	}
}

func WrapCreate(tw Tweet) vocab.Activity {
	note := NoteObject(tw)
	return vocab.Activity{
		Type:      vocab.CreateType,
		ID:        vocab.IRI(fmt.Sprintf("%s%d#create", PostBase, tw.ID)),
		Actor:     vocab.IRI(ActorID),
		Published: tw.Time.UTC(),
		To:        note.To,
		CC:        note.CC,
		Object:    note,
	}
}

// ── Sign outbound POST ──────────────────────────────────────────────

func SignedPost(inboxURL string, body []byte) error {
	req, err := http.NewRequest("POST", inboxURL, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/activity+json")
	req.Header.Set("Accept", "application/activity+json")

	sum := sha256.Sum256(body)
	req.Header.Set("Digest", "sha-256="+base64.StdEncoding.EncodeToString(sum[:]))
	req.Header.Set("Date", time.Now().UTC().Format(http.TimeFormat))
	req.Host = req.URL.Host
	req.Header.Set("Host", req.URL.Host)

	headersToSign := []string{"(request-target)", "host", "date", "digest"}
	signer := httpsig.NewSigner(KeyID, PrivateKey, httpsig.RSASHA256, headersToSign)
	if err := signer.Sign(req); err != nil {
		return fmt.Errorf("failed to sign request: %w", err)
	}

	resp, err := OutboundHTTP.Do(req)
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

