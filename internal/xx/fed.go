package xx

import (
	"bytes"
	"context"
	"crypto"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/subtle"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

// minimal fields needed from a remote ActivityPub actor
type Actor struct {
	ID        string `json:"id"`
	PublicKey struct {
		ID           string `json:"id"`
		Owner        string `json:"owner"`
		PublicKeyPem string `json:"publicKeyPem"`
	} `json:"publicKey"`
}

// post-verification info
type VerifiedRequestInfo struct {
	KeyID   string
	ActorID string // actor field from the activity body
	OwnerID string // publicKey.owner from the actor document
}

// maximum clock skew when checking the Date header
const maxClockSkew = 5 * time.Minute

// ONLY PUBLIC FUNCTION
// - body read and Digest verification
// - HTTP Signature header parsing and verification
// - Date header freshness check
// - actor vs publicKey.owner consistency check
// returns raw body and verified actor & key info
func VerifyActivityPubRequest(r *http.Request) ([]byte, *VerifiedRequestInfo, error) {
	// Read and buffer the body so we can hash it and also hand it to callers.
	body, err := io.ReadAll(r.Body)
	if err != nil {
		return nil, nil, fmt.Errorf("read body: %w", err)
	}
	r.Body.Close()
	r.Body = io.NopCloser(bytes.NewReader(body))

	// Verify Digest header for requests with a body.
	if err := verifyDigestHeader(r.Header, body); err != nil {
		return nil, nil, err
	}

	sigHeader := r.Header.Get("Signature")
	if sigHeader == "" {
		return nil, nil, errors.New("missing Signature header")
	}

	sigParams, err := parseSignatureHeader(sigHeader)
	if err != nil {
		return nil, nil, fmt.Errorf("parse Signature header: %w", err)
	}

	keyID := sigParams["keyId"]
	if keyID == "" {
		return nil, nil, errors.New("Signature missing keyId")
	}

	sigB64 := sigParams["signature"]
	if sigB64 == "" {
		return nil, nil, errors.New("Signature missing signature value")
	}

	// reject algorithm unless "rsa-sha256" or "hs2019"
	alg := strings.ToLower(sigParams["algorithm"])
	switch alg {
	case "", "rsa-sha256", "hs2019":
		// treat all as RSA with SHA-256
	default:
		return nil, nil, fmt.Errorf("unsupported signature algorithm %q", alg)
	}

	headerList, err := parseSignatureHeadersList(sigParams["headers"])
	if err != nil {
		return nil, nil, err
	}

	required := []string{"(request-target)", "date"}
	if len(body) > 0 {
		required = append(required, "digest")
	}
	if err := ensureHeadersSigned(headerList, required); err != nil {
		return nil, nil, err
	}

	signingString, err := buildSigningString(r, headerList)
	if err != nil {
		return nil, nil, fmt.Errorf("build signing string: %w", err)
	}

	actor, pubKey, err := fetchActorAndKey(r.Context(), keyID)
	if err != nil {
		return nil, nil, err
	}

	// verify RSA signature over the signing string
	sigBytes, err := base64.StdEncoding.DecodeString(sigB64)
	if err != nil {
		return nil, nil, fmt.Errorf("decode signature: %w", err)
	}

	hashed := sha256.Sum256([]byte(signingString))
	if err := rsa.VerifyPKCS1v15(pubKey, crypto.SHA256, hashed[:], sigBytes); err != nil {
		return nil, nil, fmt.Errorf("signature verification failed: %w", err)
	}

	// Now that Date header covered by the signature,
	// enforce a freshness window to prevent replays
	if err := verifyDateHeader(r.Header); err != nil {
		return nil, nil, err
	}

	// extract actor field from the activity body and make sure it
	// matches the publicKey.owner from the actor document
	actorID, err := extractActivityActor(body)
	if err != nil {
		return nil, nil, err
	}

	if actor.PublicKey.Owner == "" {
		return nil, nil, errors.New("actor document missing publicKey.owner")
	}

	if actorID != actor.PublicKey.Owner {
		return nil, nil, fmt.Errorf("activity actor %q does not match key owner %q", actorID, actor.PublicKey.Owner)
	}

	info := &VerifiedRequestInfo{
		KeyID:   keyID,
		ActorID: actorID,
		OwnerID: actor.PublicKey.Owner,
	}

	return body, info, nil
}

// checks Digest header against the body for SHA-256
// if no body, Digest is optional. if body, Digest is required
func verifyDigestHeader(h http.Header, body []byte) error {
	digestHeader := h.Get("Digest")
	if len(body) == 0 {
		// No body: we tolerate missing Digest.
		if digestHeader == "" {
			return nil
		}
	} else {
		if digestHeader == "" {
			return errors.New("missing Digest header")
		}
	}

	if digestHeader == "" {
		return nil
	}

	// multiple algorithms separated by commas, so look for SHA-256
	var b64 string
	segments := strings.Split(digestHeader, ",")
	for _, seg := range segments {
		seg = strings.TrimSpace(seg)
		if seg == "" {
			continue
		}
		parts := strings.SplitN(seg, "=", 2)
		if len(parts) != 2 {
			continue
		}
		algo := strings.TrimSpace(parts[0])
		val := strings.TrimSpace(parts[1])
		if strings.EqualFold(algo, "SHA-256") {
			b64 = strings.Trim(val, "\"")
			break
		}
	}

	if b64 == "" {
		return fmt.Errorf("no SHA-256 entry in Digest header: %q", digestHeader)
	}

	expected, err := base64.StdEncoding.DecodeString(b64)
	if err != nil {
		return fmt.Errorf("invalid base64 in Digest header: %w", err)
	}

	sum := sha256.Sum256(body)
	if len(expected) != len(sum) || subtle.ConstantTimeCompare(sum[:], expected) != 1 {
		return errors.New("Digest mismatch")
	}

	return nil
}

// parse Signature header into a map of key -> value
func parseSignatureHeader(header string) (map[string]string, error) {
	params := make(map[string]string)
	s := header
	i := 0
	for i < len(s) {
		// skip whitespace and commas
		for i < len(s) && (s[i] == ' ' || s[i] == '\t' || s[i] == ',') {
			i++
		}
		if i >= len(s) {
			break
		}

		// parse key
		startKey := i
		for i < len(s) && s[i] != '=' && s[i] != ' ' && s[i] != '\t' {
			i++
		}
		if i >= len(s) || s[i] != '=' {
			return nil, fmt.Errorf("malformed Signature param at pos %d", startKey)
		}
		key := s[startKey:i]
		i++ // skip '='
		if i >= len(s) {
			return nil, fmt.Errorf("missing value for Signature param %q", key)
		}

		// parse value (quoted-string or bare token until comma)
		var val string
		if s[i] == '"' {
			i++
			startVal := i
			for i < len(s) && s[i] != '"' {
				i++
			}
			if i >= len(s) {
				return nil, fmt.Errorf("unterminated quoted value for %q", key)
			}
			val = s[startVal:i]
			i++ // skip closing quote
		} else {
			startVal := i
			for i < len(s) && s[i] != ',' {
				i++
			}
			val = strings.TrimSpace(s[startVal:i])
		}

		if key != "" {
			params[key] = val
		}
	}

	if len(params) == 0 {
		return nil, errors.New("empty Signature header")
	}

	return params, nil
}

// parse headers="..." value into a list of lowercased header names
func parseSignatureHeadersList(s string) ([]string, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return nil, errors.New("Signature headers parameter is empty")
	}
	fields := strings.Fields(strings.ToLower(s))
	if len(fields) == 0 {
		return nil, errors.New("Signature headers parameter has no entries")
	}
	return fields, nil
}

// check that all required headers are listed in the headers= parameter
func ensureHeadersSigned(actual []string, required []string) error {
	for _, req := range required {
		found := false
		for _, h := range actual {
			if strings.EqualFold(h, req) {
				found = true
				break
			}
		}
		if !found {
			return fmt.Errorf("signature does not cover required header %q", req)
		}
	}
	return nil
}

// reconstruct the string that was signed, based on the request and headers= list
func buildSigningString(r *http.Request, headers []string) (string, error) {
	var lines []string

	for _, name := range headers {
		lower := strings.ToLower(strings.TrimSpace(name))
		if lower == "(request-target)" {
			// e.g. "post /d/inbox"
			target := strings.ToLower(r.Method) + " " + r.URL.RequestURI()
			lines = append(lines, "(request-target): "+target)
			continue
		}

		canonical := http.CanonicalHeaderKey(lower)
		values, ok := r.Header[canonical]
		if !ok || len(values) == 0 {
			return "", fmt.Errorf("missing required signed header %q", lower)
		}
		// join multiple values with comma+space,
		// to match how net/http formats headers when sending
		joined := strings.Join(values, ", ")
		lines = append(lines, lower+": "+joined)
	}

	return strings.Join(lines, "\n"), nil
}

// resolve the keyId to an ActivityPub actor document and
// parse the RSA public key from publicKey.publicKeyPem
func fetchActorAndKey(ctx context.Context, keyID string) (*Actor, *rsa.PublicKey, error) {
	u, err := url.Parse(keyID)
	if err != nil {
		return nil, nil, fmt.Errorf("invalid keyId %q: %w", keyID, err)
	}

	if u.Scheme != "https" {
		return nil, nil, fmt.Errorf("refusing to fetch key over non-https scheme %q", u.Scheme)
	}

	// drop fragment to get the actor URL. Example:
	// https://example/users/alice#main-key -> https://example/users/alice
	u.Fragment = ""
	actorURL := u.String()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, actorURL, nil)
	if err != nil {
		return nil, nil, err
	}

	req.Header.Set("Accept", `application/activity+json, application/ld+json; profile="https://www.w3.org/ns/activitystreams"`)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, nil, fmt.Errorf("fetch actor %q: %w", actorURL, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, nil, fmt.Errorf("fetch actor %q: unexpected status %s", actorURL, resp.Status)
	}

	var actor Actor
	if err := json.NewDecoder(resp.Body).Decode(&actor); err != nil {
		return nil, nil, fmt.Errorf("decode actor: %w", err)
	}

	if actor.PublicKey.ID == "" || actor.PublicKey.PublicKeyPem == "" {
		return nil, nil, errors.New("actor document missing publicKey fields")
	}

	if actor.PublicKey.ID != keyID {
		return nil, nil, fmt.Errorf("actor publicKey.id %q does not match keyId %q", actor.PublicKey.ID, keyID)
	}

	pubKey, err := parseRSAPublicKeyFromPEM(actor.PublicKey.PublicKeyPem)
	if err != nil {
		return nil, nil, err
	}

	return &actor, pubKey, nil
}

// parse an RSA public key from a PEM string
func parseRSAPublicKeyFromPEM(pemStr string) (*rsa.PublicKey, error) {
	block, _ := pem.Decode([]byte(pemStr))
	if block == nil {
		return nil, errors.New("failed to decode PEM public key")
	}

	// first try PKIX (SubjectPublicKeyInfo) - common for Mastodon.
	if pub, err := x509.ParsePKIXPublicKey(block.Bytes); err == nil {
		if rsaPub, ok := pub.(*rsa.PublicKey); ok {
			return rsaPub, nil
		}
		return nil, errors.New("public key is not RSA")
	}

	// fallback to PKCS1
	if rsaPub, err := x509.ParsePKCS1PublicKey(block.Bytes); err == nil {
		return rsaPub, nil
	}

	return nil, errors.New("failed to parse RSA public key from PEM")
}

// ensure Date header is present and recent to mitigate replay attacks
func verifyDateHeader(h http.Header) error {
	dateStr := h.Get("Date")
	if dateStr == "" {
		return errors.New("missing Date header")
	}

	t, err := time.Parse(http.TimeFormat, dateStr)
	if err != nil {
		return fmt.Errorf("invalid Date header: %w", err)
	}

	now := time.Now().UTC()
	skew := now.Sub(t)
	if skew < 0 {
		skew = -skew
	}

	if skew > maxClockSkew {
		return fmt.Errorf("Date header too far from current time (skew=%s)", skew)
	}

	return nil
}

// pull out the "actor" field from the incoming ActivityPub JSON
func extractActivityActor(body []byte) (string, error) {
	var tmp struct {
		Actor string `json:"actor"`
	}
	if err := json.Unmarshal(body, &tmp); err != nil {
		return "", fmt.Errorf("decode activity: %w", err)
	}
	if tmp.Actor == "" {
		return "", errors.New("activity missing actor field")
	}
	return tmp.Actor, nil
}
