package main

import (
	"crypto/tls"
	"fmt"
	"log"
	"net/smtp"
	"sive.rs/sivers/internal/xx"
)

type SMTPConfig struct {
	Host string
	User string
	Pass string
	Port int
}

var (
	good SMTPConfig
	grey SMTPConfig
)

// Two different SMTP servers:
//
// 1. "grey" = 3rd-party bulk server for when I don't know if the recipient will mark it as spam
// 2. "good" = personal server with pristine reputation for when I'm quite sure the recipient will not mark it as spam (replying to email they sent me)
//
// InitEmail loads up these servers' info from configs.
//
// PostgreSQL o.emailsmtp(id) returns a "whatsmtp" string column "good" or "grey", so it selects.
func InitEmail() error {
	err := xx.DB.QueryRow(`select
		max(v) filter (where k = 'smtp-bulk-server') as host,
		max(v) filter (where k = 'smtp-bulk-user') as user,
		max(v) filter (where k = 'smtp-bulk-pass') as pass,
		587 as port
		from configs
		where k in ('smtp-bulk-server', 'smtp-bulk-user', 'smtp-bulk-pass')
	`).Scan(&grey.Host, &grey.User, &grey.Pass, &grey.Port)
	if err != nil {
		return fmt.Errorf("init grey: %w", err)
	}

	err = xx.DB.QueryRow(`select
		max(v) filter (where k = 'smtp1serv') as host,
		max(v) filter (where k = 'smtp1user') as user,
		max(v) filter (where k = 'smtp1pass') as pass,
		465 as port
		from configs
		where k in ('smtp1serv', 'smtp1user', 'smtp1pass')
	`).Scan(&good.Host, &good.User, &good.Pass, &good.Port)
	if err != nil {
		return fmt.Errorf("init good: %w", err)
	}
	return nil
}

func SMTPS(c SMTPConfig, msg, mailfrom, rcptto string) error {
	log.Printf("SMTPS to %s - START", rcptto)
	addr := fmt.Sprintf("%s:%d", c.Host, 465) // SMTPS is always port 465

	// SMTPS needs TLS connection first:
	tlsConfig := &tls.Config{
		InsecureSkipVerify: false,
		ServerName: c.Host,
	}
	conn, err := tls.Dial("tcp", addr, tlsConfig)
	if err != nil {
		return err
	}
	defer conn.Close()

	// SMTP client uses that TLS connection
	client, err := smtp.NewClient(conn, c.Host)
	if err != nil {
		return err
	}
	defer client.Quit()

	// now authenticate
	auth := smtp.PlainAuth("", c.User, c.Pass, c.Host)
	if err = client.Auth(auth); err != nil {
		return err
	}
	
	// set sender then recipient then body
	if err = client.Mail(mailfrom); err != nil {
		return err
	}
	if err = client.Rcpt(rcptto); err != nil {
		return err
	}
	w, err := client.Data()
	if err != nil {
		return err
	}
	_, err = w.Write([]byte(msg))
	if err != nil {
		return err
	}
	log.Printf("SMTPS to %s - SENT", rcptto)
	return w.Close()
}

func SMTPMail(c SMTPConfig, msg, mailfrom, rcptto string) error {
	addr := fmt.Sprintf("%s:%d", c.Host, c.Port)
	auth := smtp.PlainAuth("", c.User, c.Pass, c.Host)
	log.Printf("before SMTP to %s", rcptto)
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
		whatsmtp string
		mailfrom string
		rcptto   string
		msg      string
		c        SMTPConfig
	)

	// get it and select SMTPConfig that was loaded in InitEmail()
	err := xx.DB.QueryRow(`
		select whatsmtp, mailfrom, rcptto, msg from o.emailsmtp($1)
	`, eid).Scan(&whatsmtp, &mailfrom, &rcptto, &msg)
	if err != nil {
		log.Printf("xx.DB failed to get %d: %v", eid, err)
		return fmt.Errorf("o.emailsmtp: %w", err)
	}
	if whatsmtp == "grey" {
		c = grey
	} else {
		c = good
	}

	// send it
	if err = SMTPS(c, msg, mailfrom, rcptto); err != nil {
		log.Printf("xx.DB failed to send %d: %v", eid, err)
		return fmt.Errorf("In xx.DBMail: %w", err)
	}
	log.Printf("xx.DBMail sent %d", eid)

	// update as sent
	if _, err = xx.DB.Exec("select o.emailsent($1)", eid); err != nil {
		return fmt.Errorf("o.emailsent: %w", err)
	}
	return nil
}
