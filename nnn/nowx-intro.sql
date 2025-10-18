-- my.nownownow.com/check
create or replace function nowx.intro(out head text, out body text) as $$
begin
    body = o.template('mynow-wrap', 'nowx-intro',
        jsonb_build_object('pagetitle',
            'help check/moderate?'));
end;
$$ language plpgsql;
