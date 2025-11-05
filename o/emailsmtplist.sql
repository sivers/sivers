-- NOTE: EXACT SAME AS emailsmtp.sql BUT FOR listpeople TABLE
-- OUTGOING EMAIL MESSAGE TRANSACTION: RFC 5322 - from emails.id
-- MAIL FROM and RCPT TO needed by SMTP envelope
-- headers should be in this order:
-- From
-- To
-- Subject
-- Date
-- Message-ID
-- In-Reply-To:
-- References:
-- MIME-Version
-- Content-Type
create function o.emailsmtplist(_id text, -- message-id, remember
	out mailfrom text, out rcptto text, out msg text) as $$
declare
	r record;
begin
	select e.id, e.email as their_email, people.name as their_name,
		e.subject, e.body, e.id as message_id
	into r
	from listpeople e
	join ats on e.email = ats.email
	join people on ats.person_id = people.id
	where e.id = $1
	and e.emailed is null; -- will not return email already sent
	if r is null then
		return;
	end if;
	mailfrom = 'd@sive.rs';
	rcptto = r.their_email;
	msg = e'From: Derek Sivers <d@sive.rs>\r\nTo: ';
	if r.their_name ~ '[^\u0000-\u007f]' then -- if non-ASCII characters...
		msg = msg || '=?UTF-8?B?' || -- ... convert name to RFC 2047 encoded-word syntax
		replace(encode(convert_to(r.their_name, 'UTF8'), 'base64'), e'\n', '')
		|| '?=';
	else
		msg = msg || r.their_name;
	end if;
	msg = msg || ' <' || r.their_email || e'>\r\n';
	if r.subject ~ '[^\u0000-\u007f]' then -- if non-ASCII characters...
		msg = msg || 'Subject: =?UTF-8?B?' || -- ... subject to RFC 2047 encoded-word
		replace(encode(convert_to(r.subject, 'UTF8'), 'base64'), e'\n', '')
		|| e'?=\r\n';
	else
		msg = msg || 'Subject: ' || r.subject || e'\r\n';
	end if;
	msg = msg || 'Date: ' || to_char(now(), 'Dy, DD Mon YYYY HH24:MI:SS TZHTZM') || e'\r\n';
	msg = msg || 'Message-ID: <' || r.message_id || e'>\r\n';
	msg = msg || e'MIME-Version: 1.0\r\n';
	msg = msg || e'Content-Type: text/plain; charset=UTF-8\r\n';
	msg = msg || e'Content-Transfer-Encoding: 8bit\r\n';
	-- empty line between headers and body
	msg = msg || e'\r\n';
	-- body has to be \r\n everywhere, so erase all \r, then add \r to every \n
	msg = msg || replace(replace(r.body, e'\r', ''), e'\n', e'\r\n');
	-- body has to end with one last empty line
	msg = msg || e'\r\n';
end;
$$ language plpgsql;

