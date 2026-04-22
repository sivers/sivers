-- static HTML comments, by Derek Sivers. Article: https://sive.rs/shc

create or replace function comments_changed() returns trigger as $$
declare
  uri text;
begin
  if tg_op = 'DELETE' then
    uri = old.uri;
  else
    uri = new.uri;
  end if;
  perform pg_notify('comments_changed', uri);
  return old;
end;
$$ language plpgsql;
create trigger comments_changed after insert or update or delete on comments
for each row execute procedure comments_changed();
