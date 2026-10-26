package main

import (
	"bytes"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/chai2010/webp"
	"sive.rs/sivers/internal/xx"
)

func main() {
	f, err := os.OpenFile("/tmp/mynow.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Printf("warning: couldn't open log file: %v", err)
	} else {
		log.SetOutput(f)
		defer f.Close()
	}

	if err := xx.InitDB(true); err != nil {
		log.Fatalf("InitDB %v", err)
	}
	defer xx.DB.Close()

	const WEBPDIR = "/var/www/html/nownownow.com/m/"
	var (
		CDNHOST string
		CDNPASS string
		CDNAPIK string
	)
	_ = xx.DB.QueryRow("select o.config('cdn-nnn-host')").Scan(&CDNHOST)
	_ = xx.DB.QueryRow("select o.config('cdn-nnn-pass')").Scan(&CDNPASS)
	_ = xx.DB.QueryRow("select o.config('cdn-api-key')").Scan(&CDNAPIK)

	mux := http.NewServeMux()

	mux.HandleFunc("GET /f", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.authform", xx.GetCookie(r), r.URL.Query().Get("m"))
	})

	mux.HandleFunc("POST /f", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.authpost", xx.GetCookie(r), r.FormValue("email"))
	})

	mux.HandleFunc("GET /e", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.welcome", xx.GetCookie(r), r.URL.Query().Get("t"))
	})

	mux.HandleFunc("POST /e", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.login", r.FormValue("t"), r.FormValue("i"))
	})

	mux.HandleFunc("GET /z", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.logout", xx.GetCookie(r))
	})

	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.whereru", xx.GetCookie(r))
	})

	mux.HandleFunc("POST /where", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.whereset", xx.GetCookie(r), r.FormValue("city"), r.FormValue("state"), r.FormValue("country"))
	})

	mux.HandleFunc("GET /urls", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.urls", xx.GetCookie(r))
	})

	mux.HandleFunc("POST /urls", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.urladd", xx.GetCookie(r), r.FormValue("url"))
	})

	mux.HandleFunc("POST /url/{id}/main", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.urlmain", xx.GetCookie(r), r.PathValue("id"))
	})

	mux.HandleFunc("POST /url/{id}/delete", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.urldel", xx.GetCookie(r), r.PathValue("id"))
	})

	mux.HandleFunc("GET /photo", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.photo", xx.GetCookie(r))
	})

	mux.HandleFunc("GET /profile", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.profile", xx.GetCookie(r), r.URL.Query().Get("edit1"))
	})

	mux.HandleFunc("POST /profile", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.profileset", xx.GetCookie(r), r.FormValue("qcode"), r.FormValue("answer"))
	})

	mux.HandleFunc("POST /check/{id}/{action}", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.checkdone", xx.GetCookie(r), r.PathValue("id"), r.PathValue("action"))
	})

	mux.HandleFunc("POST /check/{id}", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.checkupdate", xx.GetCookie(r), r.PathValue("id"), r.FormValue("look4"), r.FormValue("updated_at"))
	})

	mux.HandleFunc("GET /check/{id}", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.checkone", xx.GetCookie(r), r.PathValue("id"))
	})

	mux.HandleFunc("GET /check", func(w http.ResponseWriter, r *http.Request) {
		xx.WebDB(w, r, "mynow.checknext", xx.GetCookie(r))
	})

	// PHOTO UPLOAD
	mux.HandleFunc("POST /photo", func(w http.ResponseWriter, r *http.Request) {
		// get uploaded photo or redirect to /photo
		file, _, err := r.FormFile("photo")
		if err != nil {
			http.Redirect(w, r, "/photo", 303)
			return
		}
		defer file.Close()
		img, _, err := image.Decode(file)
		if err != nil {
			http.Redirect(w, r, "/photo", 303)
			return
		}

		// get code for naming webp file
		var code string
		err = xx.DB.QueryRow("select mynow.publicid($1)", xx.GetCookie(r)).Scan(&code)
		if err != nil {
			xx.Oops(w, err)
			return
		}
		filename := code + ".webp"
		filepath := WEBPDIR + filename

		// convert their uploaded image to webp format
		var buf bytes.Buffer
		err = webp.Encode(&buf, img, &webp.Options{
			Lossless: false,
			Quality:  90,
		})
		if err != nil {
			xx.Oops(w, err)
			return
		}

		// new webp image is in buf.Bytes(). write to disk
		err = os.WriteFile(filepath, buf.Bytes(), 0644)
		if err != nil {
			xx.Oops(w, err)
			return
		}

		// update DB to say the photo is now saved
		if _, err := xx.DB.Exec("select mynow.photoset($1)", xx.GetCookie(r)); err != nil {
			xx.Oops(w, err)
			return
		}

		// in a goroutine, upload to CDN and purge old
		go func() {
			defer func() {
				if r := recover(); r != nil {
					log.Printf("panic in CDN upload: %v", r)
				}
			}()

			uploadURL := "https://" + CDNHOST + "/now3/" + filename
			req, err := http.NewRequest("PUT", uploadURL, bytes.NewReader(buf.Bytes()))
			if err != nil {
				log.Printf("ERROR creating PUT: %v\n", err)
				return
			}
			req.Header.Set("AccessKey", CDNPASS)
			req.Header.Set("Content-Type", "image/webp")
			client := &http.Client{Timeout: 30 * time.Second}
			resp, err := client.Do(req)
			if err != nil {
				log.Printf("ERROR sending PUT: %v\n", err)
				return
			}
			resp.Body.Close()
			if resp.StatusCode < 200 || resp.StatusCode >= 300 {
				return
			}

			purgeURL := "https://api.bunny.net/purge?url=https%3A%2F%2Fm.nownownow.com%2F" + filename
			req, err = http.NewRequest("POST", purgeURL, nil)
			if err != nil {
				log.Printf("ERROR creating POST: %v\n", err)
				return
			}
			req.Header.Set("AccessKey", CDNAPIK)
			resp, err = client.Do(req)
			if err != nil {
				log.Printf("ERROR sending POST: %v\n", err)
				return
			}
			resp.Body.Close()
			if resp.StatusCode < 200 || resp.StatusCode >= 300 {
				log.Printf("CDN purge failed for %s", filename)
			}
		}()

	})

	log.Println("MyNow @ :2206")
	log.Fatal(http.ListenAndServe(":2206", xx.AuthExcept(mux, "/f", "/e", "/z")))
}
