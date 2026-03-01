-- # Given emails.id, create outgoing email message transaction: RFC5322
--
-- whatsmtp = "good" or "grey".
-- If "good", send using personal SMTP server.
-- If "grey", send using outside SMTP service.
-- 
-- mailfrom and rcptto needed by SMTP envelope
--
-- msg is the entire email, including headers and body
--
-- Headers returned in this order:
--
-- * From
-- * To
-- * Subject
-- * Date
-- * Message-ID
-- * In-Reply-To
-- * References
-- * MIME-Version
-- * Content-Type
create function o.emailsmtp(_emailid integer,
	out whatsmtp text, out mailfrom text, out rcptto text, out msg text) as $$
declare
	r record;
begin
	-- Given emails.id, get and build email info and message.
	--
	-- If it's a reply to another (e.reference_id) then quote e2.body 
	--
	-- If e.outgoing is anything but null then it's been sent already so quit early
	select e.id, e.their_email, e.their_name, e.subject, e.body,
	e.message_id, e2.message_id as ref,
	regexp_replace(e2.body, '^', '> ', 'gn') as quoted
	into r
	from emails e
	left join emails e2 on e.reference_id = e2.id
	where e.id = $1
	and e.outgoing is null;
	if r is null then
		return;
	end if;

	-- If it's a reply to their email, and that email Message-ID is not '*@sive.rs',
	-- that means it's a high chance their mailserver will recognize and trust mine,
	-- and not put it in spam, so use my personal SMTP server: "good". Else? "grey"
	if r.ref is null or r.ref like '%@sive.rs' then
		whatsmtp = 'grey';
	else
		whatsmtp = 'good';
	end if;

	-- SMTP envelope needs these:
	mailfrom = 'd@sive.rs';
	rcptto = r.their_email;

	-- build the message, which starts with the headers
	msg = e'From: Derek Sivers <d@sive.rs>\r\nTo: ';

	-- Their name has non-ASCII characters? Convert to RFC 2047 encoded-word syntax
	if r.their_name ~ '[^\u0000-\u007f]' then
		msg = msg || '=?UTF-8?B?' ||
		replace(encode(convert_to(r.their_name, 'UTF8'), 'base64'), e'\n', '')
		|| '?=';
	else
		msg = msg || r.their_name;
	end if;
	msg = msg || ' <' || r.their_email || e'>\r\n';

	-- Subject has non-ASCII characters? Convert to RFC 2047 encoded-word syntax
	if r.subject ~ '[^\u0000-\u007f]' then
		msg = msg || 'Subject: =?UTF-8?B?' ||
		replace(encode(convert_to(r.subject, 'UTF8'), 'base64'), e'\n', '')
		|| e'?=\r\n';
	else
		msg = msg || 'Subject: ' || r.subject || e'\r\n';
	end if;

	-- Date and Message-ID are no-brainers
	msg = msg || 'Date: ' || to_char(now(), 'Dy, DD Mon YYYY HH24:MI:SS TZHTZM') || e'\r\n';
	msg = msg || 'Message-ID: <' || r.message_id || e'>\r\n';

	-- If this is a reply to their email, include that email's Message-ID
	if r.ref is not null then
		msg = msg || 'In-Reply-To: <' || r.ref || e'>\r\n';
		msg = msg || 'References: <' || r.ref || e'>\r\n';
	end if;

	-- Finish headers, with empty line between headers and body
	msg = msg || e'MIME-Version: 1.0\r\n';
	msg = msg || e'Content-Type: text/plain; charset=UTF-8\r\n';
	msg = msg || e'Content-Transfer-Encoding: 8bit\r\n';
	msg = msg || e'\r\n';

	-- Body has to be \r\n everywhere, so erase all \r, then add \r to every \n
	msg = msg || replace(replace(r.body, e'\r', ''), e'\n', e'\r\n') || e'\r\n';

	-- If this is a reply, add their previous message, also with \n converted to \r\n
	if r.ref is not null then
		msg = msg || e'\r\n' || replace(replace(r.quoted, e'\r', ''), e'\n', e'\r\n');
	end if;

	-- Body has to end with one last empty line
	msg = msg || e'\r\n';
end;
$$ language plpgsql;

