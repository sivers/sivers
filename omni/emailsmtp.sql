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
create function o.emailsmtp(_emailid integer,
	out mailfrom text, out rcptto text, out msg text) as $$
declare
	r record;
begin
	select e.id, e.their_email, e.their_name, e.subject, e.body,
	e.message_id, e2.message_id as ref, -- and if ref then quote it, indented:
	regexp_replace(e2.body, '^', '> ', 'gn') as quoted
	into r
	from emails e
	left join emails e2 on e.reference_id = e2.id
	where e.id = $1
	and e.outgoing is null; -- will not return email already sent
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
	if r.ref is not null then
		msg = msg || 'In-Reply-To: <' || r.ref || e'>\r\n';
		msg = msg || 'References: <' || r.ref || e'>\r\n';
	end if;
	msg = msg || e'MIME-Version: 1.0\r\n';
	msg = msg || e'Content-Type: text/plain; charset=UTF-8\r\n';
	msg = msg || e'Content-Transfer-Encoding: 8bit\r\n';
	-- empty line between headers and body
	msg = msg || e'\r\n';
	-- body has to be \r\n everywhere, so erase all \r, then add \r to every \n
	msg = msg || replace(replace(r.body, e'\r', ''), e'\n', e'\r\n') || e'\r\n';
	-- if it's a reply, include their previous message, indented (in original select)
	if r.ref is not null then
		-- body has to be \r\n everywhere, so erase all \r, then add \r to every \n
		msg = msg || e'\r\n' || replace(replace(r.quoted, e'\r', ''), e'\n', e'\r\n');
	end if;
	-- body has to end with one last empty line
	msg = msg || e'\r\n';
end;
$$ language plpgsql;

