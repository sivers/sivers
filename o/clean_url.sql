create function o.clean_url(_url text, out url text) as $$
begin
	-- remove all whitespace
	url = regexp_replace($1, '\s', '', 'g');
	-- add https:// if no http
	if url !~ '^https?://' then
		url = 'https://' || url;
	end if;
	-- strip trailing "." often found in email body
	-- ("My website is sivers.com. Check it out.")
	if right(url, 1) = '.' then
		url = left(url, length(url) - 1);
	end if;
end
$$ language plpgsql immutable strict parallel safe;

