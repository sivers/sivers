-- Triggers can't be in table definitions because they rely on functions.
-- Keep triggers with function definitions.
-- More trigger definitions in app function directories.
-- Keep "or replace" in create statement so it replaces old f functions.


-- when a new email is inserted into emails, ONLY if outgoing is null,
-- that means it's queued to send, so notifies scripts/listener.go with
-- emails.id which that uses to get and SMTP-send the email, then it updates
-- that emails.outgoing = true (some day soon switch to email.state enum)
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


-- clean people.name
create function o.trig_name_clean() returns trigger as $$
begin
	new.name = o.clean_name(new.name);
	return new;
end;
$$ language plpgsql;
create or replace trigger trig_name_clean
before insert or update of name on people
for each row execute function o.trig_name_clean();


-- clean (trim, lowercase) email addresses in ats.email
create function o.trig_email_clean() returns trigger as $$
begin
	new.email = o.clean_email(new.email);
	return new;
end;
$$ language plpgsql;
create or replace trigger trig_email_clean
before insert or update of email on ats
for each row execute function o.trig_email_clean();


-- clean URLs in urls.url
create function o.trig_url_clean() returns trigger as $$
begin
	new.url = o.clean_url(new.url);
	return new;
end;
$$ language plpgsql;
create or replace trigger trig_url_clean
before insert or update of url on urls
for each row execute function o.trig_url_clean();


-- clean tags in utags.tag
create function o.trig_utag_clean() returns trigger as $$
begin
	new.tag = o.clean_code(new.tag);
	return new;
end;
$$ language plpgsql;
create or replace trigger trig_utag_clean
before insert or update of tag on utags
for each row execute function o.trig_utag_clean();

---------------
-------- STORE:
---------------

-- recalculate prices in invoice when invoice changes
create function o.trig_invoice_recalc() returns trigger as $$
begin
	perform o.invoice_reprice(new.id);
	return new;
end;
$$ language plpgsql;
create or replace trigger trig_invoice_recalc
after update of currency, country, warehouse on invoices
for each row execute procedure o.trig_invoice_recalc();

-- recalculate prices in invoice when lineitems change
create function o.trig_lineitems_recalc() returns trigger as $$
begin
	if (TG_OP = 'DELETE') then
		perform o.invoice_reprice(old.invoice_id);
		return old;
	else
		perform o.invoice_reprice(new.invoice_id);
		return new;
	end if;
end;
$$ language plpgsql;
create or replace trigger trig_lineitems_recalc
-- list columns so this updating of price doesn't re-trigger:
after delete or insert or update of invoice_id, item_id, quantity on lineitems
for each row execute procedure o.trig_lineitems_recalc();

-- intercept lineitem quantity changes in a smart way (explanations below)
create function o.trig_lineitem_quant() returns trigger as $$
declare
	li lineitems;
begin
	-- if this invoice_id + item_id combo exists (besides this line), then merge quantity and delete this
	select * into li from lineitems
	where invoice_id = new.invoice_id
	and item_id = new.item_id
	and id != new.id;
	if found then
		update lineitems set quantity = quantity + new.quantity
		where id = li.id;
		delete from lineitems where id = new.id;
		return null;
	end if;
	-- if quantity = 0 then delete line
	if new.quantity < 1 then
		delete from lineitems where id = new.id;
		return null;
	end if;
	-- if new.quantity > 1 and items.weight = 0 then new.quantity = 1
	if new.quantity > 1 then
		perform 1 from items where id = new.item_id and weight = 0;
		if found then
			new.quantity = 1;
		end if;
	end if;
	return new;
end;
$$ language plpgsql;
create trigger trig_lineitem_quant
-- list columns so this updating of price doesn't re-trigger:
before insert or update of invoice_id, item_id, quantity on lineitems
for each row execute procedure o.trig_lineitem_quant();

