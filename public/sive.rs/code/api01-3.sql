-- PostgreSQL function example from Derek Sivers article: https://sive.rs/api01

select cart_add(1, 1, 3);
select * from lineitems;

select cart_add(1, 2, 4);
select * from lineitems;

select cart_set(1, 2, 1);
select * from lineitems;
