-- My newest 100 tweets as an Atom feed.
--
-- o.template function is escaping HTML
--
-- HOW TO MAKE A TITLE FOR EACH TWEET?
-- I don't want to hand-make a separate title for each tweet message.
-- But I noticed my tweets.message are usually in this format:
-- "Some intro text here: sometimes further point here. https://sive.rs/usually-a-link"
-- So first I can strip everything after 'https'.
-- But also, notice my frequent use of the colon?
-- So I split_part twice, and the TITLE becomes:
-- 1. Get message before 'https'
-- 2. Get what's before any remaining ':'
-- 3. Trim what's left

create function ding.xml_tweets(out xml text) as $$
	select o.template('atom', (select to_jsonb(r) from (
		select ('https://' || f.uri) as id,
		f.title,
		f.description as subtitle,
		(select o.rfc3339(max(time)) from tweets) as updated,
		('https://' || f.link) as link,
		coalesce((select json_agg(r1) from (
			select ('https://sive.rs/d/' || i.id) as id,
			trim(split_part(split_part(message, 'https', 1), ':', 1)) as title,
			o.rfc3339(time) as published,
			o.rfc3339(time) as updated,
			'https://sive.rs/d' as link,
			message as summary,
			('<p>' || o.hyperlink(message) || '</p>') as content
			from tweets i
			order by i.id desc
			limit 100
		) r1), '[]') as items
		from feeds f
		where f.uri = 'sive.rs/d.xml'
	) r));
$$ language sql;

