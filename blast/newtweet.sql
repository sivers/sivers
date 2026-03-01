create function fed.notify_new_tweet() returns trigger as $$
begin
    perform pg_notify('newtweet', NEW.id::text);
    return NEW;
end;
$$ language plpgsql;

create trigger tweet_notify_trigger
after insert on tweets
for each row execute function fed.notify_new_tweet();
