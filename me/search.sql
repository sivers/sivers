-- $1 = search term
-- $2 = optional limiting to interviews, articles, books (ebooks)
-- this makes for messy conditionals, but better than separate functions
create function me.search(_query text, _just text,
	out head text, out body text) as $$
declare
	q text;
	just text;
	res jsonb;
begin
	-- 1: remove tags
	-- 2: remove everything but A-Za-z and space
	-- 3: trim outer space
-- (TODO: leave dash and apostrophe)
-- (TODO: ilike search term cleaned because of my curly ’)
	q = btrim(regexp_replace(regexp_replace($1, '</?[^>]+?>', '', 'g'), '[^A-Za-z ]+', '', 'g'));
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
			regexp_replace(name, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from metabooks
			where name ilike '%' || q || '%'
		) r), '[]'::jsonb);
	end if;

	-- articles title
	if just is null or just = 'articles' then
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(title, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from articles
			where title ilike '%' || q || '%'
		) r), '[]'::jsonb);
	end if;

	-- interviews name
	if just is null or just = 'interviews' then
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(name, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from interviews
			where name ilike '%' || q || '%'
		) r), '[]'::jsonb);

		-- interviews host
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(host, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from interviews
			where host ilike '%' || q || '%'
		) r), '[]'::jsonb);
	end if;

	if just is null then
		-- presentations title
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(title, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from presentations
			where title ilike '%' || q || '%'
		) r), '[]'::jsonb);

		-- meetwheres display (place name)
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('met/at-', id) as uri,
			regexp_replace(display, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from meetwheres
			where display ilike '%' || q || '%'
		) r), '[]'::jsonb);

		-- meetwheres person name
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('met/', meetings.id) as uri,
			regexp_replace(people.name, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from meetings
			join people on meetings.person_id = people.id
			where people.name ilike '%' || q || '%'
		) r), '[]'::jsonb);
	end if;

	-- articles sentences
	if just is null or just = 'articles' then
		res = res || coalesce((select jsonb_agg(r) from (
			select articles.uri,
			regexp_replace(sentence, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from sentences
			join articles on sentences.article_id = articles.id
			where sentence ilike '%' || q || '%'
			and sentences.sortid is not null
		) r), '[]'::jsonb);
	end if;

	if just is null then
		-- presentations description
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(description, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from presentations
			where description ilike '%' || q || '%'
		) r), '[]'::jsonb);

		-- presentations transcript
		res = res || coalesce((select jsonb_agg(r) from (
			select uri,
			regexp_replace(line, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from (
				select uri, regexp_split_to_table(transcript, e'\n') as line
				from presentations
				where transcript ilike '%' || q || '%'
			)
			where line ilike '%' || q || '%'
		) r), '[]'::jsonb);

		-- meetwheres thoughts
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('met/at-', id) as uri,
			regexp_replace(thoughts, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from meetwheres
			where thoughts ilike '%' || q || '%'
		) r), '[]'::jsonb);

		-- meetings topics
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('met/at-', id) as uri,
			regexp_replace(topics, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from meetings
			where topics ilike '%' || q || '%'
		) r), '[]'::jsonb);

		-- meetings notes
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('met/', id) as uri,
			regexp_replace(line, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from (
				select id, regexp_split_to_table(notes, e'\n') as line
				from meetings
				where notes ilike '%' || q || '%'
			)
			where line ilike '%' || q || '%'
		) r), '[]'::jsonb);
	end if;

	-- interviews utterances
	if just is null or just = 'interviews' then
		res = res || coalesce((select jsonb_agg(r) from (
			select interviews.uri,
			regexp_replace(utterances.content, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from utterances
			join interviews on utterances.interview_id = interviews.id
			where utterances.content ilike '%' || q || '%'
			and utterances.speaker = 'sivers'
		) r), '[]'::jsonb);
	end if;

	if just is null or just = 'books' then
		-- ebooks title
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('book/', code) as uri,
			regexp_replace(title, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from ebooks
			where title ilike '%' || q || '%'
			and read is not null and rating is not null and summary is not null
		) r), '[]'::jsonb);

		-- ebooks author
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('book/', code) as uri,
			regexp_replace(author, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from ebooks
			where author ilike '%' || q || '%'
			and read is not null and rating is not null and summary is not null
		) r), '[]'::jsonb);

		-- ebooks summary
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('book/', code) as uri,
			regexp_replace(summary, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from ebooks
			where summary ilike '%' || q || '%'
			and read is not null and rating is not null and summary is not null
		) r), '[]'::jsonb);

		-- ebooks notes
		res = res || coalesce((select jsonb_agg(r) from (
			select concat('book/', ebooks.code) as uri,
			regexp_replace(ebooknotes.note, '(' || q || ')', '<strong>\1</strong>', 'ig') as show
			from ebooknotes
			join ebooks on ebooknotes.ebook_code = ebooks.code
			where ebooknotes.note ilike '%' || q || '%'
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

