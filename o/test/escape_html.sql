select plan(1);

select is(o.escape_html('<a "thing">me & you</a>'), '&lt;a &quot;thing&quot;&gt;me &amp; you&lt;/a&gt;');

