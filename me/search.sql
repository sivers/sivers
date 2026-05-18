-- $1 = search term
-- $2 = optional limiting to interviews, articles, books (ebooks)
-- this makes for messy conditionals, but better than separate functions

-- NOTE: WHY CREATE INDEXES HERE?
-- 1. tables.sql comes before functions, and this needs o.clean4search(text)
-- 2. If not here, then I'd have to do it in some separate file just for that.
-- 3. Here I can reference the columns searched below, and index those, in order.
-- 4. This file requires o.clean4search(text) to be loaded first anyway.

-- just the tables with enough stuff to need an index:
create index if not exists xxs01 on articles using gin(o.clean4search(title) gin_trgm_ops);
create index if not exists xxs02 on interviews using gin(o.clean4search(name) gin_trgm_ops);
create index if not exists xxs03 on interviews using gin(o.clean4search(host) gin_trgm_ops);
create index if not exists xxs04 on people using gin(o.clean4search(name) gin_trgm_ops);  -- too big?
create index if not exists xxs05 on sentences using gin(o.clean4search(sentence) gin_trgm_ops);
create index if not exists xxs06 on utterances using gin(o.clean4search(content) gin_trgm_ops);
create index if not exists xxs07 on ebooks using gin(o.clean4search(title) gin_trgm_ops);
create index if not exists xxs08 on ebooks using gin(o.clean4search(summary) gin_trgm_ops);
create index if not exists xxs09 on ebooknotes using gin(o.clean4search(note) gin_trgm_ops);

create function me.search(_query text, _just text,
	out head text, out body text) as $$
declare
	q text;
	just text;
	res jsonb;
begin
	q = btrim(o.clean4search($1));
	if length(q) < 3 or length(q) > 20 then
		body = o.template('me-wrap', 'me-search', jsonb_build_object(
			'pagetitle', 'search Derek Sivers site'
		));
		return;
	end if;
	if $2 = 'interviews' or $2 = 'articles' or $2 = 'books' then
		just = $2;
	end if;

	res = '[]';

	-- book title
	if just is null then
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(o.clean4search(name), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from metabooks
			where o.clean4search(name) like '%' || q || '%'
		) r), '[]'::jsonb);
	end if;

	-- articles title
	if just is null or just = 'articles' then
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(o.clean4search(title), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from articles
			where o.clean4search(title) like '%' || q || '%'
		) r), '[]'::jsonb);
	end if;

	-- interviews name
	if just is null or just = 'interviews' then
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(o.clean4search(name), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from interviews
			where o.clean4search(name) like '%' || q || '%'
		) r), '[]'::jsonb);

		-- interviews host
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(o.clean4search(host), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from interviews
			where o.clean4search(host) like '%' || q || '%'
		) r), '[]'::jsonb);
	end if;

	if just is null then
		-- presentations title
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(o.clean4search(title), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from presentations
			where o.clean4search(title) like '%' || q || '%'
		) r), '[]'::jsonb);

		-- meetwheres display (place name)
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('met/at-', id) as uri,
			regexp_replace(o.clean4search(display), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from meetwheres
			where o.clean4search(display) like '%' || q || '%'
		) r), '[]'::jsonb);

		-- meetwheres person name
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('met/', meetings.id) as uri,
			regexp_replace(o.clean4search(people.name), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from meetings
			join people on meetings.person_id = people.id
			where o.clean4search(people.name) like '%' || q || '%'
		) r), '[]'::jsonb);
	end if;

	-- articles sentences
	if just is null or just = 'articles' then
		res = res || coalesce((select jsonb_agg(r) from (
			select articles.uri,
			regexp_replace(o.clean4search(sentence), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from sentences
			join articles on sentences.article_id = articles.id
			where o.clean4search(sentence) like '%' || q || '%'
			and sentences.sortid is not null
		) r), '[]'::jsonb);
	end if;

	if just is null then
		-- presentations description
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(o.clean4search(description), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from presentations
			where o.clean4search(description) like '%' || q || '%'
		) r), '[]'::jsonb);

		-- presentations transcript
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(o.clean4search(line), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from (
				select uri, regexp_split_to_table(transcript, e'\n') as line
				from presentations
				where o.clean4search(transcript) like '%' || q || '%'
			)
			where o.clean4search(line) like '%' || q || '%'
		) r), '[]'::jsonb);

		-- meetwheres thoughts
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('met/at-', id) as uri,
			regexp_replace(o.clean4search(thoughts), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from meetwheres
			where o.clean4search(thoughts) like '%' || q || '%'
		) r), '[]'::jsonb);

		-- meetings topics
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('met/at-', id) as uri,
			regexp_replace(o.clean4search(topics), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from meetings
			where o.clean4search(topics) like '%' || q || '%'
		) r), '[]'::jsonb);

		-- meetings notes
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('met/', id) as uri,
			regexp_replace(o.clean4search(line), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from (
				select id, regexp_split_to_table(notes, e'\n') as line
				from meetings
				where o.clean4search(notes) like '%' || q || '%'
			)
			where o.clean4search(line) like '%' || q || '%'
		) r), '[]'::jsonb);
	end if;

	-- interviews utterances
	if just is null or just = 'interviews' then
		res = res || coalesce((select jsonb_agg(r) from (
			select interviews.uri,
			regexp_replace(o.clean4search(utterances.content), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from utterances
			join interviews on utterances.interview_id = interviews.id
			where o.clean4search(utterances.content) like '%' || q || '%'
			and utterances.speaker = 'sivers'
		) r), '[]'::jsonb);
	end if;

	if just is null or just = 'books' then
		-- ebooks title
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('book/', code) as uri,
			regexp_replace(o.clean4search(title), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from ebooks
			where o.clean4search(title) like '%' || q || '%'
			and read is not null and rating is not null and summary is not null
		) r), '[]'::jsonb);

		-- ebooks author
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('book/', code) as uri,
			regexp_replace(o.clean4search(author), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from ebooks
			where o.clean4search(author) like '%' || q || '%'
			and read is not null and rating is not null and summary is not null
		) r), '[]'::jsonb);

		-- ebooks summary
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('book/', code) as uri,
			regexp_replace(o.clean4search(summary), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from ebooks
			where o.clean4search(summary) like '%' || q || '%'
			and read is not null and rating is not null and summary is not null
		) r), '[]'::jsonb);

		-- ebooks notes
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('book/', ebooks.code) as uri,
			regexp_replace(o.clean4search(ebooknotes.note), '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from ebooknotes
			join ebooks on ebooknotes.ebook_code = ebooks.code
			where o.clean4search(ebooknotes.note) like '%' || q || '%'
			and read is not null and rating is not null and summary is not null
		) r), '[]'::jsonb);
	end if;

	body = o.template('me-wrap', 'me-search', jsonb_build_object(
		'pagetitle', 'search Derek Sivers site',
		'term', q,
		'just', just,
		'results', res
	));
end;
$$ language plpgsql;

