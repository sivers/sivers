-- PostgreSQL unique random defaults, by Derek Sivers. Article: https://sive.rs/rand1

-- return random string confirmed to not exist in given tablename.colname
create function unique_random(len int, _table text, _col text) returns text as $$
declare
  result text;
  numrows int;
begin
  result = random_string(len);
  loop
    execute format('select 1 from %I where %I = %L', _table, _col, result);
    get diagnostics numrows = row_count;
    if numrows = 0 then
      return result; 
    end if;
    result = random_string(len);
  end loop;
end;
$$ language plpgsql;
