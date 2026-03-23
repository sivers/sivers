-- URIs of presentations that are ready to post.
-- (Yeah just here for consistency despite having no 'where' filters.)

create function me.presentation_uris() returns setof text as $$
	select uri from presentations
$$ language sql;
