-- Despite my usual format of one _.sql file per function, all NOTIFY triggers here
-- 
-- Testing is different, too, since pgTAP can't test a listener

create function ding.notify_mysite() returns trigger as $$
begin
	if new.code like 'me-%' then
		perform pg_notify('mysite');
	end if;
	return new;
end;
$$ language plpgsql;

-- for any table with primary key "id"
create function ding.notify_id() returns trigger as $$
begin
	perform pg_notify(TG_ARGV[0], new.id::text);
	return new;
end;
$$ language plpgsql;

-- for any table with primary key "code"
create function ding.notify_code() returns trigger as $$
begin
	perform pg_notify(TG_ARGV[0], new.code::text);
	return new;
end;
$$ language plpgsql;

-- Notice the slight variations in conditions of when to trigger:
-- 
-- * tweets and now_pages only when first inserted
-- * audios, articles, interviews might be inserted earlier, then updated later with bytes, a date-posted, or a public uri, a clue they're ready to post
-- * emails.outgoing = null is a special status meaning it's queued to send
--
-- The listener needs to check for itself, too, but better to filter here - to not trigger unless probably needed.
--
-- Though a trigger doesn't necessarily mean the listener will act. I might update an old article or interview that's not in the XML feed.

create trigger t_mysite
after insert or update on templates
for each row execute function ding.notify_mysite();

create trigger t_tweet
after insert on tweets
for each row execute function ding.notify_id('tweet');

create trigger t_now_page
after insert on now_pages
for each row execute function ding.notify_id('now_page');

create trigger t_audio
after insert or update on audios
for each row when (new.bytes is not null) execute function ding.notify_id('audio');

create trigger t_article
after insert or update on articles
for each row when (new.posted is not null) execute function ding.notify_id('article');

create trigger t_interview
after insert or update on interviews
for each row when (new.uri is not null) execute function ding.notify_id('interview');

create trigger t_email
after insert on emails
for each row when (new.outgoing is null) execute function ding.notify_id('email');

create trigger t_ebook
after insert or update on ebooks
for each row when (new.summary is not null) execute function ding.notify_code('ebook');

