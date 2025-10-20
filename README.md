I'm Derek Sivers @ https://sive.rs/

This is my database and the web apps that use it.
My data is private but code is public.  See LICENSE.

Master code repository is on my private server, but mirrors to:

* <https://github.com/sivers/sivers>
* <https://gitlab.com/sivers/sivers>
* <https://codeberg.org/sivers/sivers>

**These are only mirrors. I don't monitor these sites or take pull requests.**


tables.sql
============
This is the heart of it. Start there. Read that.


table-refs.sql
============
`tables.sql` has circular references, so foreign keys added after data is loaded.


scripts/reset.sh
============
All functions - (except for a few at the top of tables.sql) - are in schemas.  
Schemas can be dropped and reloaded without losing the data in the tables.  
Run `scripts/reset.sh` every time a function has changed, to reload them all.  
This also creates a database for testing.  More on that, below.


omni/\*.sql
============
Functions used by multiple web apps.  Schema name: `o`.  
One file per function except `TRIGGERS.sql`


\*/test/\*.sql
============
For each function, tests in the test/ directory, in a file with the same name.  
Tests use pgTAP. See <https://pgtap.org/>  
Tests are run on the test database (`siverstest`) a clone of the live database.  
Minimal data is inserted for testing just this function.  
This makes it easier to understand without keeping anything else in mind.  
To run a test, boilerplate and psql env vars are in a script called `tap`.  
It's in `scripts/tap` here, but put it in your $PATH so you can always do ...  
`tap thatfile.sql`  
... to run that file's tests with nice output and rollback.  
Or to run all tests:  
`for f in *.sql ; do tap $f ; done`


scripts/
============
Hands-on or cron, shell scripts are here.


templates/
============
HTML templates to be loaded into templates table, where code = file name.  
Never used on disk, only in the database, but put here for easy editing.  
Mustache parser inside PostgreSQL - see `omni/template.sql`


HTML in PostgreSQL?
============
Typical db-driven web apps get values from db, then merge into HTML templates.  
Aiming for simplicity - less coupling - I do that step directly in PostgreSQL.  
Router calls PostgreSQL functions and gets a full HTML response.  
Pass it directly to HTTP or write it to disk.


HTTP headers in PostgreSQL?
============
What about when I need a value to be handled outside of the HTML body?  
It usually results in an HTTP header: 404, Set-Cookie then 303 redirect, etc.  
So the function creates the HTTP headers when needed to override the default.  
Now all PostgreSQL web functions return just two values: head text, body text.  
head is null? Stick with defaults. (Status 200, text/html, etc.)  
head first line is 3 digits? Use that to override HTTP status. (404, 303)  
head lines otherwise should override defaults.


web functions
============
These two PostgreSQL web app return values (head text, body text) are unified,  
so we can make the handling code shorter with two sugar functions:  
Call handler gets row 0 of `select head, body from {schema}.{function}(params)`  
Response handler converts that PostgreSQL row to an HTTP response.


io-rb/
============
Ruby HTTP servers to parse requests, send to PostgreSQL, and return responses


app schemas
============
Directories keep the functions and tests related to different web apps:

| dir     |site|
|---------|----|
| `blog/` | sive.rs |
| `inch/` | inchword.com |
| `peep/` | people / email |
| `nnn/`  | nownownow.com |
| `shop/` | sivers.com |


questions? comments?
============
I love talking about programming. Email me any time. I reply to every one.  
Contact me here: <https://sive.rs/contact>

 — Derek

