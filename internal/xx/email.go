package xx

import (
	"fmt"
	"log"
	"net/smtp"
	"os"
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
		return fmt.Errorf("InitDB: %w", err)
	}

	_ = DB.QueryRow("select o.config('smtp_server')").Scan(&SMTPHOST)
	_ = DB.QueryRow("select o.config('smtp_user')").Scan(&SMTPUSER)
	_ = DB.QueryRow("select o.config('smtp_pass')").Scan(&SMTPPASS)
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
	err := DB.QueryRow("select mailfrom, rcptto, msg from o.emailsmtp($1)", eid).Scan(&mailfrom, &rcptto, &msg)
	if err != nil {
		log.Printf("DB failed to get %d: %v", eid, err)
		return fmt.Errorf("o.emailsmtp: %w", err)
	}

	// TODO: a function to say which SMTP server to use: trusted or untrusted
	// Based on whether this email has a reference_id and that emails.id has message_id not ending in @sive.rs
	// (so it means I'm replying to an email they sent from their server)

	// send it
	if err = SMTPMail(msg, mailfrom, rcptto); err != nil {
		log.Printf("DB failed to send %d: %v", eid, err)
		return fmt.Errorf("In DBMail: %w", err)
	}
	log.Printf("DB sent %d", eid)

	// update as sent
	if _, err = DB.Exec("select o.emailsent($1)", eid); err != nil {
		return fmt.Errorf("o.emailsent: %w", err)
	}
	return nil
}
