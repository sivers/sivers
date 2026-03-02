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
	log.Printf("Toot got Tweet ID=%d message=%s\n", tw.ID, tw.Message)
	create := xx.WrapCreate(tw)
	body, err := xx.MarshalAS(create)
	if err != nil {
		log.Printf("Toot marshal error: %v", err)
		return
	}
	rows, err := xx.DB.Query("select inbox from followers order by id")
	if err != nil {
		log.Printf("Toot error getting followers: %v", err)
		return
	}
	defer rows.Close()
	for rows.Next() {
		var inbox string
		if err := rows.Scan(&inbox); err == nil {
			if err := xx.SignedPost(inbox, body); err != nil {
				log.Printf("Toot FAILED to %s: %v", inbox, err)
			} else {
				log.Printf("Toot DONE to %s", inbox)
			}
		}
	}
}
