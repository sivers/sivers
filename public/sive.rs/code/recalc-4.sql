-- PostgreSQL trigger example from Derek Sivers article: https://sive.rs/recalc

-- re-calculate the total of a lineitem's invoice
create function recalc() returns trigger as $$
declare
  r record;
begin
  -- use "new" lineitems record for insert/update, or "old" if delete
  if (tg_op = 'DELETE') then
    r = old;
  else
    r = new;
  end if;
  -- update invoice using lineitems(now "r")'s invoice_id
  update invoices set total = (
    select sum(quantity * price)
    from lineitems
    join items on lineitems.item_id = items.id
    where invoice_id = r.invoice_id)
  where id = r.invoice_id;
  -- must return incoming "new" or "old" record when done
  return r;
end;
$$ language plpgsql;
-- run this function after any change to lineitems
create trigger recalc
  after insert or update or delete on lineitems
  for each row execute procedure recalc();
