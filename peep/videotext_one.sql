-- words: next 20 words not in videotext.kind = 'phrase' - FOR THIS VIDEO
-- phrases: all phrases FOR THIS VIDEO, in order
-- HTML shows the phrases with button to delete
-- HTML form words showing from id1 to id2 to choose grouping of new phrase
create function peep.videotext_one(_videoid integer,
	out head text, out body text) as $$
declare
	phrases jsonb;
	words jsonb;
begin
	-- phrases keys: id, startime, stoptime, style, word
	phrases = coalesce((select json_agg(r) from (
		select id, startime, stoptime, style, word
		from videotext
		where kind = 'phrase'
		and video_id = $1
		order by startime asc
	) r), '[]');

	-- words keys: id, sentence_code, startime, stoptime, word, start_id, totaltext
	words = coalesce((select json_agg(r) from (
		select id, sentence_code, startime, stoptime, word,
		case
			when sentence_code is not distinct from first_value(sentence_code) over (order by id)
			then first_value(id) over (order by id)
			else null
		end as start_id,
		case
			when sentence_code is not distinct from first_value(sentence_code) over (order by id)
			then string_agg(word, ' ') over (
				order by id 
				rows between unbounded preceding and current row
			)
			else null
		end as totaltext
		from
		videotext w
		where w.kind = 'word'
		and w.video_id = $1
		and not exists (
			select 1
			from videotext p
			where p.kind = 'phrase'
			and p.video_id = w.video_id
			and p.sentence_code is not distinct from w.sentence_code
			and w.startime >= p.startime
			and w.stoptime <= p.stoptime
		)
		order by w.id asc limit 20
	) r), '[]');

	body = o.template('peep-wrap', 'peep-videotext1', jsonb_build_object(
		'phrases', phrases, 'words', words
	));
end;
$$ language plpgsql;

