-- why not just strip these things for display, instead of a separate
-- now_pages.short column?  because rare sites need a custom override
-- like SomeNameCapsLikeThis.com or reallllly long URLs
create function nnn.shorten() returns trigger as $$
begin
	update now_pages
	set short = regexp_replace(regexp_replace(regexp_replace(
			new.long, '/$', ''),
		'^https?://', ''),
	'^www.', '')
	where id = new.id;
	return new;
end;
$$ language plpgsql;
create trigger trig_shorten
after insert or update of long on now_pages
for each row execute procedure nnn.shorten();
