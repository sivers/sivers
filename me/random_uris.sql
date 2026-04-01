-- all uris for sive.rs/random
create function me.random_uris() returns table(uri text) as $$
	select uri from me.article_uris()
	union all
	select concat('book/', uri) from me.book_uris()
	union all
	select uri from me.interview_uris()
	union all
	select uri from me.presentation_uris()
	union all
	select concat('met/', id) as uri from me.met1_ids()
	union all
	select concat('met/at-', id) as uri from me.metat_ids()
$$ language sql;
