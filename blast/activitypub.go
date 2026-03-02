// ## ActivityPub (Mastodon, etc)
//
// Followers came in through HTTP server at /fed/fed.go - not here.
//
// So now when I have an outgoing tweet, this loops through followers table,
// getting their inbox URL, and posts the signed tweet to their inbox.

package main

import (
	"log"
	"sive.rs/sivers/internal/xx"
)

func Toot(tw xx.Tweet) {
	create := xx.WrapCreate(tw)
	body, err := xx.MarshalAS(create)
	if err != nil {
		log.Printf("broadcast marshal error: %v", err)
		return
	}
	rows, err := xx.DB.Query("select inbox from followers")
	if err != nil {
		return
	}
	defer rows.Close()
	for rows.Next() {
		var inbox string
		if err := rows.Scan(&inbox); err == nil {
			xx.SignedPost(inbox, body)
		}
	}
}
