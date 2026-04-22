-- PostgreSQL trigger example from Derek Sivers article: https://sive.rs/recalc

insert into lineitems (invoice_id, item_id, quantity) values (1, 2, 1);
select * from lineitems; select * from invoices;

select 'Notice new total when you update quantity:' look;
update lineitems set quantity = 5 where invoice_id = 1 and item_id = 2;
select * from lineitems; select * from invoices;

select 'Notice new total when you delete:' look;
delete from lineitems where invoice_id = 1 and item_id = 2;
select * from lineitems; select * from invoices;

