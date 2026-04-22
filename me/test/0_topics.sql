insert into metabooks (uri, name) values ('b', 'book');

insert into topics (uri, name, description, sortid) values ('test', 'Topic Name', 'second in list', 2);
insert into topics (uri, name, description, sortid) values ('b', 'Book Name', 'third is book topic', 3);
insert into topics (uri, name, description, sortid) values ('a', 'A Topic', 'a description of topic', 1);

select plan(12);
select is(topics #>> '{0,uri}', 'a'),
	is(topics #>> '{1,uri}', 'test'),
	is(topics #>> '{2,uri}', 'b'),
	is(topics #>> '{0,name}', 'A Topic'),
	is(topics #>> '{1,name}', 'Topic Name'),
	is(topics #>> '{2,name}', 'Book Name'),
	is(topics #>> '{0,description}', 'a description of topic'),
	is(topics #>> '{1,description}', 'second in list'),
	is(topics #>> '{2,description}', 'third is book topic'),
	is(topics #>> '{0,isbook}', null),
	is(topics #>> '{1,isbook}', null),
	is(topics #>> '{2,isbook}', 'b')
from me.topics();
