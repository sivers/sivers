# teleme

Authorize a saved Telegram session, or post a message using TDLib.

Credentials come first from `TELEGRAM_API_ID` and `TELEGRAM_API_HASH`.
When both are nonempty, the command uses them without connecting to PostgreSQL.
An invalid environment API ID returns an error.

If either variable is missing or blank, the command reads both credentials from
PostgreSQL's `o.config('telegram_api_id')` and `o.config('telegram_api_hash')`,
using `xx.DSN`, with a five-second timeout. Credentials from the two sources are
never mixed. A canceled command stops without loading credentials.

On a server without PostgreSQL:

```sh
TELEGRAM_API_ID=12345 TELEGRAM_API_HASH='your-api-hash' ./teleme
```

The ID must be a positive int32 and the hash must be nonempty. Without a message
argument, the command authorizes or verifies the saved session and exits without
posting. Supplying message text explicitly sends it to `TELEGRAM_CHANNEL`
(default `dereksivers`).

`TELEGRAM_DB_DIR` defaults to `/var/telegram`. Stop `ding` before using the same
session directory in this utility. Run `./teleme --help` for usage.

From the repository root, build with `go build -o /tmp/teleme ./cmd/teleme`
and test with `go test ./cmd/teleme`. The TDLib development headers and shared
library are required to build; the shared library is also required to run.
