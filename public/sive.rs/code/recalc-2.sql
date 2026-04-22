-- PostgreSQL trigger example from Derek Sivers article: https://sive.rs/recalc

-- re-calculate the total of a lineitem's invoice
create function recalc() returns trigger as $$
begin
  -- update invoice using lineitems's invoice_id
  update invoices set total = (
    select sum(quantity * price)
    from lineitems
    join items on lineitems.item_id = items.id
    where invoice_id = new.invoice_id)
  where id = new.invoice_id;
  return new;
end;
$$ language plpgsql;
-- run this function after any change to lineitems
create trigger recalc
  after insert or update or delete on lineitems
  for each row execute procedure recalc();
