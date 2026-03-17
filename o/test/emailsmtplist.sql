insert into people (id, name) values (1, '沈思问');
insert into people (id, name) values (2, 'Σοφία Κατερίνα');
insert into ats (person_id, email) values (1, 's@sw.cn');
insert into ats (person_id, email) values (1, 'sw@s.cn');
insert into ats (person_id, email) values (2, 's@k.gr');

insert into lists (id) values (1);
insert into listpeople (list_id, id, email, subject, body) values (1, '1.1@sive.rs', 'sw@s.cn', '☺', 'Hi 沈思问');
insert into listpeople (list_id, id, email, subject, body) values (1, '2.2@sive.rs', 's@k.gr', '☺', 'Hi Σοφία Κατερίνα');

select plan(20);

select is(mailfrom, 'd@sive.rs'),
	is(rcptto, 'sw@s.cn'),
	is((string_to_array(msg, e'\r\n'))[1], 'From: Derek Sivers <d@sive.rs>'),
	is((string_to_array(msg, e'\r\n'))[2], 'To: =?UTF-8?B?5rKI5oCd6Zeu?= <sw@s.cn>'),
	is((string_to_array(msg, e'\r\n'))[3], 'Subject: =?UTF-8?B?4pi6?='),
	-- line 4 is date, changes every time, nevermind testing
	is((string_to_array(msg, e'\r\n'))[5], 'Message-ID: <1.1@sive.rs>'),
	is((string_to_array(msg, e'\r\n'))[6], 'MIME-Version: 1.0'),
	is((string_to_array(msg, e'\r\n'))[7], 'Content-Type: text/plain; charset=UTF-8'),
	is((string_to_array(msg, e'\r\n'))[8], 'Content-Transfer-Encoding: 8bit'),
	is(substring(msg from (position('Hi' in msg))), e'Hi 沈思问\r\n')
from o.emailsmtplist('1.1@sive.rs');

select is(mailfrom, 'd@sive.rs'),
	is(rcptto, 's@k.gr'),
	is((string_to_array(msg, e'\r\n'))[1], 'From: Derek Sivers <d@sive.rs>'),
	is((string_to_array(msg, e'\r\n'))[2], 'To: =?UTF-8?B?zqPOv8+Gzq/OsSDOms6xz4TOtc+Bzq/Ovc6x?= <s@k.gr>'),
	is((string_to_array(msg, e'\r\n'))[3], 'Subject: =?UTF-8?B?4pi6?='),
	is((string_to_array(msg, e'\r\n'))[5], 'Message-ID: <2.2@sive.rs>'),
	is((string_to_array(msg, e'\r\n'))[6], 'MIME-Version: 1.0'),
	is((string_to_array(msg, e'\r\n'))[7], 'Content-Type: text/plain; charset=UTF-8'),
	is((string_to_array(msg, e'\r\n'))[8], 'Content-Transfer-Encoding: 8bit'),
	is(substring(msg from (position('Hi' in msg))), e'Hi Σοφία Κατερίνα\r\n')
from o.emailsmtplist('2.2@sive.rs');

