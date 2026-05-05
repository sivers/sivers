-- after article has title and original, chop it into sentences
-- then update with template and title_code
-- sentences must start with TAB ("\t")
create function me.article_chop(_id integer) returns void as $$
declare
	titlecode char(8);
	sortnum smallint;
	line text;
	new_template text;
	acode char(8);
begin
	-- title sentences.sortid is null
	insert into sentences (article_id, sentence)
	select id, title from articles where id = $1
	returning code into titlecode;

	sortnum = 1;
	new_template = '';
	-- original strip \r, trim beginning and end, then split \n loop
	for line in select string_to_table(
		btrim(replace(original, e'\r', ''), e' \n\t'), e'\n'
	) from articles where id = $1
	loop
		-- if it starts with a tab, add to sentences
		if line ^@ e'\t' then
			insert into sentences(article_id, sortid, sentence)
			values ($1, sortnum, btrim(line, e'\t'))
			returning code into acode;
			-- put the generated code into the template
			new_template = new_template || '{' || acode || e'}\n';
			sortnum = sortnum + 1;
		else -- ... no tab? add to template as-is
			new_template = new_template || line || e'\n';
		end if;
	end loop;

	update articles
	set title_code = titlecode,
	template = rtrim(new_template, e'\n')
	where id = $1;
end;
$$ language plpgsql;
