package xx

import (
	"fmt"
	"log"
	"os"
	"net/smtp"
)

var (
	SMTPHOST string
	SMTPUSER string
	SMTPPASS string
	SMTPPORT int
)

func InitEmail() error {
	f, _ := os.Create("/tmp/email.log")
	log.SetOutput(f)

	if err := InitDB(); err != nil {
		log.Fatalf("InitDB %v", err)
	}

	err = DB.QueryRow("select o.config('smtp_server')").Scan(&SMTPHOST)
	if err != nil {
		log.Fatal(err)
	}
	err = DB.QueryRow("select o.config('smtp_user')").Scan(&SMTPUSER)
	if err != nil {
		log.Fatal(err)
	}
	err = DB.QueryRow("select o.config('smtp_pass')").Scan(&SMTPPASS)
	if err != nil {
		log.Fatal(err)
	}
	SMTPPORT = 587
	return nil
}

func SMTPMail(msg, mailfrom, rcptto string) error {
	addr := fmt.Sprintf("%s:%d", SMTPHOST, SMTPPORT)
	auth := smtp.PlainAuth("", SMTPUSER, SMTPPASS, SMTPHOST)

	log.Printf("befor SMTP to %s", rcptto)
	if err := smtp.SendMail(addr, auth, mailfrom, []string{rcptto}, []byte(msg)); err != nil {
		log.Printf("error SMTP to %s: %v", rcptto, err)
		return fmt.Errorf("SMTPMail: %w", err)
	}
	log.Printf("after SMTP to %s", rcptto)
	return nil
}

// given emails.id, get it, send it, and (unless error) update its status as sent
func DBMail(eid int) error {
	var (
		mailfrom string
		rcptto   string
		msg      string
	)

	// get it
	log.Printf("DB get %d", eid)
	err := DB.QueryRow("select mailfrom, rcptto, msg from o.emailsmtp($1)", eid).Scan(&mailfrom, &rcptto, &msg)
	if err != nil {
		log.Printf("DB failed to get %d: %v", eid, err)
		return fmt.Errorf("o.smtpmail: %w", err)
	}

	// send it
	if err = SMTPMail(msg, mailfrom, rcptto); err != nil {
		log.Printf("DB failed to send %d: %v", eid, err)
		return fmt.Errorf("In DBMail: %w", err)
	}
	log.Printf("DB sent %d", eid)

	// update as sent
	_, err = DB.Query("select o.emailsent($1)", eid)
	if err != nil {
		return fmt.Errorf("o.emailsent: %w", err)
	}
	return nil
}
