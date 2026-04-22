-- PostgreSQL trigger example from Derek Sivers article: https://sive.rs/recalc

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

-- TEST:
insert into lineitems (invoice_id, item_id, quantity) values (1, 1, 1);
insert into lineitems (invoice_id, item_id, quantity) values (1, 2, 1);
select * from lineitems; select * from invoices;

select 'new total when you update quantity:' look;
update lineitems set quantity = 5 where invoice_id = 1 and item_id = 2;
select * from lineitems; select * from invoices;

select 'new total when you delete:' look;
delete from lineitems where invoice_id = 1 and item_id = 2;
select * from lineitems; select * from invoices;

