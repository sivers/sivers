-- PostgreSQL function example from Derek Sivers article: https://sive.rs/api01

-- update the quantity of an item in the cart
create function cart_set(inv int, item int, quant int) returns void as $$
begin
  if quant > 0 then
    update lineitems
    set quantity = quant
    where invoice_id = inv
    and item_id = item;
  else  -- quantity 0 or below? delete
    delete from lineitems
    where invoice_id = inv
    and item_id = item;
  end if;
end;
$$ language plpgsql;
