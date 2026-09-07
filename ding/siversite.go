package main

import (
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"sive.rs/sivers/internal/xx"
	"strings"
)

// write sive.rs static site
func siversite() error {
	const out = "/var/www/html/sive.rs/"
	const files = "/home/derek/code/b/public/sive.rs/"
	cmd := exec.Command("rsync", "-a", files, out)
	cmd.Stdout, cmd.Stderr = os.Stdout, os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("rsync: %w", err)
	}

	// hack to add link rel canonical to header at the moment of file-writing:
	// since writer (below) knows uri, find <title> and replace it with <link...>\n<title>
	title := regexp.MustCompile(`(?m)^<title>`)

	// clever clever: getting the output uri along with the query of contents (uri, html)
	for _, query := range []string{
		`select uri, me.article(uri) from me.article_uris()`,
		`select 'blog', me.articles()`,
		`select uri, me.topic_page(uri) from topics where uri not in (select uri from metabooks)`,
		`select 'book/' || uri, me.book(uri) from me.book_uris()`,
		`select 'book/index.html', me.books()`,
		`select 'index.html', me.home()`,
		`select uri, me.interview(uri) from me.interview_uris()`,
		`select 'i', me.interviews()`,
		`select 'met/index.html', me.met()`,
		`select 'met/' || id, me.met1(id) from me.met1_ids()`,
		`select 'met/at-' || id, me.metat(id) from me.metat_ids()`,
		`select uri, me.page(uri, pagetitle) from me.pages()`,
		`select uri, me.presentation(uri) from me.presentation_uris()`,
		`select 'presentations', me.presentations()`,
		`select 'ref', me.refs()`,
		`select 'd', me.tweets()`,
		`select 'sitemap.xml', me.sitemap()`,
	} {
		rows, err := xx.DB.Query(query)
		if err != nil {
			return fmt.Errorf("DB query: %w", err)
		}
		for rows.Next() {
			var uri, html string

			if err := rows.Scan(&uri, &html); err != nil {
				rows.Close()
				return fmt.Errorf("DB scan: %w", err)
			}

			// because sive.rs/index.html and sive.rs/book/index.html are not the canonical URL, erase that bit:
			url := strings.ReplaceAll(uri, "/index.html", "")
			html = title.ReplaceAllLiteralString(html, `<link rel="canonical" href="https://sive.rs/`+url+`">`+"\n<title>")

			if err := os.WriteFile(out+uri, []byte(html), 0644); err != nil {
				rows.Close()
				return fmt.Errorf("WriteFile %s: %w", out+uri, err)
			}

		}
		if err := rows.Err(); err != nil {
			rows.Close()
			return fmt.Errorf("DB rows: %w", err)
		}
		rows.Close()
	}
	return nil
}
