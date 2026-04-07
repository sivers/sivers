-- note no me-wrap: just the <ol></ol> for JS insert
create function me.comments(_uri text, out head text, out body text) as $$
begin
	body = o.template('me-comments', jsonb_build_object(
		'comments', (select jsonb_agg(r) from (
			select created_at as ymd,
			name,
			o.hyperlink(replace(comment, e'\n', e'\n<br>')) as comment
			from comments
			where uri = $1
			order by id
		) r)
	));
end;
$$ language plpgsql;

