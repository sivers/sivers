-- Triggers can't be in table definitions because they rely on functions.
-- Keep triggers with function definitions.
-- 
-- More trigger definitions in app function directories.
-- 
-- Keep "or replace" in create statement so it replaces old f functions.
--
-- NOTE: notify triggers are in /ding/ since that's where listeners are.

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

---------------
------ BLOG/ME:
---------------

-- when blog comments change, that page needs to be regenerated
create function o.comments_changed() returns trigger as $$
declare
	u text;
begin
	if (tg_op = 'INSERT' or tg_op = 'UPDATE') then
		u = new.uri;
	else
		u = old.uri;
	end if;
	perform pg_notify('comments_changed', u);
	return old;
end;
$$ language plpgsql;
create or replace trigger comments_changed
after insert or update or delete on comments
for each row execute procedure o.comments_changed();

