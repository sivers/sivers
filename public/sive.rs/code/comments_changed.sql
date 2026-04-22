-- static HTML comments, by Derek Sivers. Article: https://sive.rs/shc

create function comments_changed() returns trigger as $$
begin
  perform pg_notify('comments_changed', new.uri);
  return new;
end;
$$ language plpgsql;
create trigger comments_changed after insert or update on comments
for each row execute procedure comments_changed();
