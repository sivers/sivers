package main

// so much of this code is just to handle the image uploading

import (
	"bytes"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/chai2010/webp"
	"sive.rs/sivers/internal/xx"
)

func main() {
	if err := xx.InitDB(); err != nil {
		log.Fatalf("InitDB %v", err)
	}
	defer xx.DB.Close()

	f, _ := os.Create("/tmp/mynow.log")
	log.SetOutput(f)

	const WEBPDIR = "/var/www/html/nownownow.com/m/"
	var (
		CDNHOST string
		CDNUSER string
		CDNPASS string
		CDNAPIK string
	)
	err = xx.DB.QueryRow("select o.config('cdn-nnn-host')").Scan(&CDNHOST)
	if err != nil {
		log.Fatal(err)
	}
	err = xx.DB.QueryRow("select o.config('cdn-nnn-user')").Scan(&CDNUSER)
	if err != nil {
		log.Fatal(err)
	}
	err = xx.DB.QueryRow("select o.config('cdn-nnn-pass')").Scan(&CDNPASS)
	if err != nil {
		log.Fatal(err)
	}
	err = xx.DB.QueryRow("select o.config('cdn-api-key')").Scan(&CDNAPIK)
	if err != nil {
		log.Fatal(err)
	}

	mux := http.NewServeMux()

	mux.HandleFunc("GET /f", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		m := r.URL.Query().Get("m")
		if err := xx.Web2(w, "mynow.authform", kk, m); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /f", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		email := r.FormValue("email")
		if err := xx.Web2(w, "mynow.authpost", kk, email); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /e", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		t := r.URL.Query().Get("t")
		if err := xx.Web2(w, "mynow.welcome", kk, t); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /e", func(w http.ResponseWriter, r *http.Request) {
		t := r.FormValue("t")
		i := r.FormValue("i")
		if err := xx.Web2(w, "mynow.login", t, i); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /z", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		if err := xx.Web2(w, "mynow.logout", kk); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		if err := xx.Web2(w, "mynow.whereru", kk); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /where", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		city := r.FormValue("city")
		state := r.FormValue("state")
		country := r.FormValue("country")
		if err := xx.Web2(w, "mynow.whereset", kk, city, state, country); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /urls", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		if err := xx.Web2(w, "mynow.urls", kk); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /urls", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		url := r.FormValue("url")
		if err := xx.Web2(w, "mynow.urladd", kk, url); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /url/{id}/main", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		id := r.PathValue("id")
		if err := xx.Web2(w, "mynow.urlmain", kk, id); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /url/{id}/delete", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		id := r.PathValue("id")
		if err := xx.Web2(w, "mynow.urldel", kk, id); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /photo", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		if err := xx.Web2(w, "mynow.photo", kk); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /profile", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		edit1 := r.URL.Query().Get("edit1")
		if err := xx.Web2(w, "mynow.profile", kk, edit1); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /profile", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		qcode := r.FormValue("qcode")
		answer := r.FormValue("answer")
		if err := xx.Web2(w, "mynow.profileset", kk, qcode, answer); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /check/{id}/{action}", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		id := r.PathValue("id")
		action := r.PathValue("action")
		if err := xx.Web2(w, "mynow.checkdone", kk, id, action); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("POST /check/{id}", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		id := r.PathValue("id")
		look4 := r.FormValue("look4")
		updatedAt := r.FormValue("updated_at")
		if err := xx.Web2(w, "mynow.checkupdate", kk, id, look4, updatedAt); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /check/{id}", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		id := r.PathValue("id")
		if err := xx.Web2(w, "mynow.checkone", kk, id); err != nil {
			xx.Oops(w, err)
		}
	})

	mux.HandleFunc("GET /check", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)
		if err := xx.Web2(w, "mynow.checknext", kk); err != nil {
			xx.Oops(w, err)
		}
	})

	// PHOTO UPLOAD
	mux.HandleFunc("POST /photo", func(w http.ResponseWriter, r *http.Request) {
		kk := xx.GetCookie(r)

		// get uploaded photo or redirect to /photo
		file, _, err := r.FormFile("photo")
		if err != nil {
			w.WriteHeader(303)
			w.Header().Set("Location", "/photo")
			return
		}
		defer file.Close()
		img, _, err := image.Decode(file)
		if err != nil {
			w.WriteHeader(303)
			w.Header().Set("Location", "/photo")
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
			Quality:  100,
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
				recover()
			}()
			uploadURL := "https://" + CDNHOST + "/now3/" + filename
			req, err := http.NewRequest("PUT", uploadURL, bytes.NewReader(buf.Bytes()))
			if err != nil {
				xx.Oops(w, err)
				return
			}
			req.Header.Set("AccessKey", CDNPASS)
			req.Header.Set("Content-Type", "image/webp")
			client := &http.Client{}
			resp, err := client.Do(req)
			if err != nil {
				xx.Oops(w, err)
				return
			}
			bodyBytes, err := io.ReadAll(resp.Body)
			resp.Body.Close()
			if err != nil {
				log.Printf("ERROR reading PUT response body: %v\n", err)
			} else {
				log.Printf("PUT %s Status: %d Body: %s\n", uploadURL, resp.StatusCode, string(bodyBytes))
			}
	
			purgeURL := "https://api.bunny.net/purge?url=https%3A%2F%2Fm.nownownow.com%2F" + filename
			req, err = http.NewRequest("POST", purgeURL, nil)
			if err != nil {
				xx.Oops(w, err)
				return
			}
			req.Header.Set("AccessKey", CDNAPIK)
			resp, err = client.Do(req)
			if err != nil {
				xx.Oops(w, err)
				return
			}
			bodyBytes, err = io.ReadAll(resp.Body)
			resp.Body.Close()
			if err != nil {
				log.Printf("ERROR reading POST/PURGE response body: %v\n", err)
			} else {
				log.Printf("POST/PURGE %s Status: %d Body: %s\n", purgeURL, resp.StatusCode, string(bodyBytes))
			}
		}()

	})

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.NotFound(w, r)
	})

	log.Println("MyNow @ :2206")
	if err := http.ListenAndServe(":2206", mux); err != nil {
		log.Fatal(err)
	}
}
