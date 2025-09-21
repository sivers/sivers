-- inside-out:
-- & → &amp;
-- ' → &#39;
-- " → &quot;
-- < → &lt;
-- > → &gt;
create function o.escape_html(text) returns text as $$
	select replace(replace(replace(replace(replace($1, '&', '&amp;'), '''', '&#39;'), '"', '&quot;'), '<', '&lt;'), '>', '&gt;');
$$ language sql immutable strict parallel safe;

