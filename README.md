# logbook-plugin

Claude Code plugins for [Logbook](https://github.com/logbook-md) vaults, published as a
plugin marketplace.

| Plugin | What it does |
| --- | --- |
| `logbook` | Captures work as immutable notes, synthesizes them into a cross-linked wiki, authors guides, runbooks, documents and code walkthroughs, and keeps a per-repo board of pending work — all through the vault's MCP server. |

## Install

```sh
claude plugin marketplace add logbook-md/logbook-plugin
claude plugin install logbook@logbook
```

The plugin registers the vault's MCP server itself, as `logbook-mcp`, from three environment
variables.
Set them where Claude Code will see them (a shell profile, or `env` in
`~/.claude/settings.json`) before starting a session:

| Variable | Value |
| --- | --- |
| `LOGBOOK_MCP_URL` | The server's MCP endpoint, e.g. `https://logbook.example.com/mcp` |
| `LOGBOOK_CF_ACCESS_CLIENT_ID` | Cloudflare Access service-token id, when the server sits behind Access |
| `LOGBOOK_CF_ACCESS_CLIENT_SECRET` | Its secret |

The two Access variables may be left unset for a server that is not behind Access. Without
`LOGBOOK_MCP_URL` the server fails to connect and every skill stops and says so — none of them
writes anywhere else.

Updates arrive with `claude plugin marketplace update logbook`.

## Moving from the `logmd` marketplace

Every install before 0.14 is registered under the marketplace `logmd` and reads `LOGMD_*`
variables. From 0.14 both are `logbook`, the old names are no longer read, and such an install
does not follow on its own:

1. Export the new names **beside** the old ones, with the same values: `LOGBOOK_MCP_URL`,
   `LOGBOOK_CF_ACCESS_CLIENT_ID` and `LOGBOOK_CF_ACCESS_CLIENT_SECRET`. The installed copy
   keeps reading `LOGMD_*` until it is replaced, and 0.14 reads only `LOGBOOK_*` — with only
   the old names set it cannot reach the server, and with only `LOGBOOK_MCP_URL` renamed it
   sends empty Access headers.
2. Swap the marketplace:

   ```sh
   claude plugin uninstall logbook@logmd
   claude plugin marketplace remove logmd
   claude plugin marketplace add logbook-md/logbook-plugin
   claude plugin install logbook@logbook
   ```

3. Remove any `logbook@logmd` left in `enabledPlugins`, and any `logmd` in
   `extraKnownMarketplaces`, from `~/.claude/settings.json` and from a project's
   `.claude/settings.json` or `.claude/settings.local.json` — either one brings the old copy
   back.
4. Drop the `LOGMD_*` exports.

An install on 0.12 or earlier has one more step. Up to 0.12 the server was registered as
`logmd`; from 0.13 its tools are `mcp__logbook-mcp__*`, so a permission rule or instruction
that names `mcp__logmd__*` needs the new prefix.

## What is in `logbook`

Invoked as `/logbook:<skill>`:

| Skill | Writes to | Job |
| --- | --- | --- |
| `entry` | `entries/` | One immutable note per unit of work. A `PostToolUse` hook suggests it after every `git commit`. |
| `task` | `tasks/<repo>` | Capture, list and close pending work, anchored to the code it is about. |
| `ingest` | `wiki/` | Synthesize new notes into cross-linked pages. |
| `query` | — | Answer from the wiki, filing what is worth keeping. |
| `lint` | — | Report rot: conformance, dead links, orphans, contradictions. |
| `guide` | `guides/` | A reference built from the tool itself. |
| `runbook` | `runbooks/` | An ordered procedure with verification and undo. |
| `document` | `docs/` | The long form: design, architecture, analysis. |
| `walkthrough` | `flows/` | One process traced through the code, every diagram node anchored to `file:line`. |
| `template` | `<folder>/.ok/templates/` | A reusable note shape — or a whole project's, with stages — from the vault's conventions and how the practice does that kind of note. |
| `run` | The note it runs | Do the job a note describes (a feature or PR review from a template), recording each run back in the note. |
| `okf` | — | The Open Knowledge Format rules the others write to. |

`ENGINE.md` and `AUTHORING.md` at the plugin root are the specs the skills share. The vault's
own `wiki/CLAUDE.md` outranks both.
