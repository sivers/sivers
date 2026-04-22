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

