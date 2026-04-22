-- PostgreSQL triggers for cleaning, by Derek Sivers. Article: https://sive.rs/clean1

create function clean_people() returns trigger as $$
begin
  new.name = no_extra_space(new.name);
  new.code = lower_no_space(new.code);
  return new;
end;
$$ language plpgsql;
create trigger clean_people
before insert or update on people
for each row execute procedure clean_people();

create function clean_emails() returns trigger as $$
begin
  new.email = lower_no_space(new.email);
  return new;
end;
$$ language plpgsql;
create trigger clean_emails
before insert or update on emails
for each row execute procedure clean_emails();
