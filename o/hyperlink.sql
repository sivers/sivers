-- * input: 'Look: https://example.com/ I like it!'
-- * output: 'Look: <a href="https://example.com/">example.com/</a> I like it!'
create function o.hyperlink(text) returns text as $$
	select regexp_replace(o.escape_html($1),
        $regex$
            (?<![a-z0-9_@./-])      # Do not start inside a domain or email
            (                       # Group 1: original visible URL
                (?:https?://)?      # Optional existing scheme
                (                   # Group 2: domain and path, without scheme
                    (?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+
                    [a-z]{2,63}     # Alphabetic top-level domain
                    (?:/
                        (?:[a-z0-9._~%/-]*[a-z0-9_~%/-])?
                    )?              # Optional path, not ending in a period
                )
            )
            (?![a-z0-9_@-]|\.[a-z0-9_-])
        $regex$,
        $html$<a href="https://\2">\2</a>$html$,
	'gix');
$$ language sql immutable strict parallel safe;

