-- When a new email is inserted into emails, ONLY if outgoing is null,
-- that means it's queued to send.
--
-- Notify blast listener with emails.id
--
-- which that uses to get and SMTP-send the email, then it updates
-- that emails.outgoing = true (some day switch to email.state enum)
create function o.email2send() returns trigger as $$
begin
        perform pg_notify('email2send', new.id::text);
        return null;
end;
$$ language plpgsql;

create or replace trigger trig_email2send
after insert on emails
for each row
when (new.outgoing is null)
execute procedure o.email2send();


