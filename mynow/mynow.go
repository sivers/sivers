package main

// so much of this code is just to handle the image uploading

import (
	"bytes"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"log"
	"net/http"
	"os"

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
		kk := xx.GetCookie(r)
		m := r.URL.Query().Get("m")
		xx.WebDB(w, r, "mynow.authform", kk, m)
	})

	mux.HandleFunc("POST /f", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		email := r.FormValue("email")
		xx.WebDB(w, r, "mynow.authpost", kk, email)
	})

	mux.HandleFunc("GET /e", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		t := r.URL.Query().Get("t")
		xx.WebDB(w, r, "mynow.welcome", kk, t)
	})

	mux.HandleFunc("POST /e", func(w http.ResponseWriter, r *http.Request) {
		t := r.FormValue("t")
		i := r.FormValue("i")
		xx.WebDB(w, r, "mynow.login", t, i)
	})

	mux.HandleFunc("GET /z", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		xx.WebDB(w, r, "mynow.logout", kk)
	})

	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		xx.WebDB(w, r, "mynow.whereru", kk)
	})

	mux.HandleFunc("POST /where", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		city := r.FormValue("city")
		state := r.FormValue("state")
		country := r.FormValue("country")
		xx.WebDB(w, r, "mynow.whereset", kk, city, state, country)
	})

	mux.HandleFunc("GET /urls", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		xx.WebDB(w, r, "mynow.urls", kk)
	})

	mux.HandleFunc("POST /urls", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		url := r.FormValue("url")
		xx.WebDB(w, r, "mynow.urladd", kk, url)
	})

	mux.HandleFunc("POST /url/{id}/main", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		id := r.PathValue("id")
		xx.WebDB(w, r, "mynow.urlmain", kk, id)
	})

	mux.HandleFunc("POST /url/{id}/delete", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		id := r.PathValue("id")
		xx.WebDB(w, r, "mynow.urldel", kk, id)
	})

	mux.HandleFunc("GET /photo", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		xx.WebDB(w, r, "mynow.photo", kk)
	})

	mux.HandleFunc("GET /profile", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		edit1 := r.URL.Query().Get("edit1")
		xx.WebDB(w, r, "mynow.profile", kk, edit1)
	})

	mux.HandleFunc("POST /profile", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		qcode := r.FormValue("qcode")
		answer := r.FormValue("answer")
		xx.WebDB(w, r, "mynow.profileset", kk, qcode, answer)
	})

	mux.HandleFunc("POST /check/{id}/{action}", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		id := r.PathValue("id")
		action := r.PathValue("action")
		xx.WebDB(w, r, "mynow.checkdone", kk, id, action)
	})

	mux.HandleFunc("POST /check/{id}", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		id := r.PathValue("id")
		look4 := r.FormValue("look4")
		updatedAt := r.FormValue("updated_at")
		xx.WebDB(w, r, "mynow.checkupdate", kk, id, look4, updatedAt)
	})

	mux.HandleFunc("GET /check/{id}", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		id := r.PathValue("id")
		xx.WebDB(w, r, "mynow.checkone", kk, id)
	})

	mux.HandleFunc("GET /check", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		xx.WebDB(w, r, "mynow.checknext", kk)
	})

	// PHOTO UPLOAD
	mux.HandleFunc("POST /photo", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)

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
		err = xx.DB.QueryRow("select code from mynow.photoset($1)", kk).Scan(&code)
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
			client := &http.Client{Timeout: 30000000000} // 30 seconds in nanoseconds
			resp, err := client.Do(req)
			if err != nil {
				log.Printf("ERROR sending PUT: %v\n", err)
				return
			}
			resp.Body.Close()
			log.Printf("PUT %s Status: %d\n", uploadURL, resp.StatusCode)
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
			log.Printf("POST/PURGE %s Status: %d\n", purgeURL, resp.StatusCode)
			if resp.StatusCode < 200 || resp.StatusCode >= 300 {
				log.Printf("CDN purge failed for %s", filename)
			}
		}()

	})

	log.Println("MyNow @ :2206")
	log.Fatal(http.ListenAndServe(":2206", xx.AuthExcept(mux, "/f", "/e", "/z")))
}
