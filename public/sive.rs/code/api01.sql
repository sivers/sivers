-- PostgreSQL function example from Derek Sivers article: https://sive.rs/api01

create table items (
  id serial primary key,
  price int not null check (price > 0)
);

create table invoices (
  id serial primary key,
  total int
);

create table lineitems (
  invoice_id int not null references invoices(id),
  item_id int not null references items(id),
  quantity int not null check (quantity > 0),
  primary key (invoice_id, item_id)
);

-- example data:
insert into items (price) values (5);
insert into items (price) values (9);
insert into invoices (total) values (0);

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

select cart_add(1, 1, 3);
select * from lineitems;

select cart_add(1, 2, 4);
select * from lineitems;

select cart_set(1, 2, 1);
select * from lineitems;

