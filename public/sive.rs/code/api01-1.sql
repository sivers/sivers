-- PostgreSQL function example from Derek Sivers article: https://sive.rs/api01

create function cart_add(inv int, item int, quant int) returns void as $$
begin
  -- does this invoice + item combination already exist?
  perform 1 from lineitems
  where invoice_id = inv
  and item_id = item;
  if found then  -- yes? add this quantity
    update lineitems
    set quantity = quantity + quant
    where invoice_id = inv
    and item_id = item;
  else  -- no? insert
    insert into lineitems values (inv, item, quant);
  end if;
end;
$$ language plpgsql;
