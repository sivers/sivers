-- recalculate prices in invoice when invoice changes
create function store.trig_invoice_recalc() returns trigger as $$
begin
	perform store.invoice_reprice(new.id);
	return new;
end;
$$ language plpgsql;
create or replace trigger trig_invoice_recalc
after update of currency, country, warehouse on invoices
for each row execute procedure store.trig_invoice_recalc();

-- recalculate prices in invoice when lineitems change
create function store.trig_lineitems_recalc() returns trigger as $$
begin
	if (TG_OP = 'DELETE') then
		perform store.invoice_reprice(old.invoice_id);
		return old;
	else
		perform store.invoice_reprice(new.invoice_id);
		return new;
	end if;
end;
$$ language plpgsql;
create or replace trigger trig_lineitems_recalc
-- list columns so this updating of price doesn't re-trigger:
after delete or insert or update of invoice_id, item_id, quantity on lineitems
for each row execute procedure store.trig_lineitems_recalc();

-- intercept lineitem quantity changes in a smart way (explanations below)
create function store.trig_lineitem_quant() returns trigger as $$
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
for each row execute procedure store.trig_lineitem_quant();

