-- Triggers can't be in table definitions because they rely on functions.
-- Keep triggers with function definitions.
-- More trigger definitions in app function directories.
-- Keep "or replace" in create statement so it replaces old f functions.


-- when a new email is inserted into emails, ONLY if outgoing is null,
-- that means it's queued to send, so notifies scripts/listener.go with
-- emails.id which that uses to get and SMTP-send the email, then it updates
-- that emails.outgoing = true (some day soon switch to email.state enum)
create function o.email2send() returns trigger as $$
begin
        perform pg_notify('email2send', new.id::text);
        return null;
end;
$$ language plpgsql;
create or replace trigger trig_email2send
after insert on emails
for each row
when (new.outgoing is null)
execute procedure o.email2send();


-- clean people.name
create function o.trig_name_clean() returns trigger as $$
begin
	new.name = o.clean_name(new.name);
	return new;
end;
$$ language plpgsql;
create or replace trigger trig_name_clean
before insert or update of name on people
for each row execute function o.trig_name_clean();


-- clean (trim, lowercase) email addresses in ats.email
create function o.trig_email_clean() returns trigger as $$
begin
	new.email = o.clean_email(new.email);
	return new;
end;
$$ language plpgsql;
create or replace trigger trig_email_clean
before insert or update of email on ats
for each row execute function o.trig_email_clean();


-- clean URLs in urls.url
create function o.trig_url_clean() returns trigger as $$
begin
	new.url = o.clean_url(new.url);
	return new;
end;
$$ language plpgsql;
create or replace trigger trig_url_clean
before insert or update of url on urls
for each row execute function o.trig_url_clean();


-- clean tags in utags.tag
create function o.trig_utag_clean() returns trigger as $$
begin
	new.tag = o.clean_code(new.tag);
	return new;
end;
$$ language plpgsql;
create or replace trigger trig_utag_clean
before insert or update of tag on utags
for each row execute function o.trig_utag_clean();

