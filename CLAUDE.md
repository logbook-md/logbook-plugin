# CLAUDE.md

A plugin marketplace (`.claude-plugin/marketplace.json`) with its plugins under `plugins/`.
**The repo is public**: no vault URLs, hostnames, tokens or Access ids in anything committed —
the MCP server is configured from environment variables (`plugins/logbook/.mcp.json`).

## Releasing a change

Bump `version` in **both** `plugins/<name>/.claude-plugin/plugin.json` and that plugin's entry
in `.claude-plugin/marketplace.json`. CI refuses a mismatch: the marketplace entry is what an
installed copy compares against, so a bump in only one place is an update nobody is offered.

## Trying it without installing

```sh
claude --plugin-dir ./plugins/logbook
```

loads the working tree as the plugin for one session.

## Checks

CI (`.github/workflows/lint.yml`) runs two scripts that also run locally, and need only `jq`:

```sh
bash tests/hook.sh     # the commit hook fires, or stays silent, on each fixture command
bash tests/skills.sh   # every SKILL.md has a name matching its folder and a description
```

A change to the hook's regex gets a fixture for the shape it is meant to catch.
