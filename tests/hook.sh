#!/usr/bin/env bash
# Fixture test for plugins/logbook/hooks/logbook.sh: feed it PostToolUse payloads
# and check whether it fires (prints the entry reminder) or stays silent.
#
#   bash tests/hook.sh
#
# Needs jq. Exits non-zero when any case disagrees with its expectation. The cases
# are deliberately literal: the commit regex is subtle, and a change that breaks
# one shape of `git commit` breaks it silently in every session.

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
hook="$here/../plugins/logbook/hooks/logbook.sh"
failed=0
ran=0

# check <fire|skip> <command> [tool name] [tool_response as JSON]
check() {
  local want="$1" cmd="$2" tool="${3:-Bash}"
  local response="${4:-}"
  [[ -n "$response" ]] || response='{"stdout":"[main abc1234] x","stderr":""}'
  local payload out got
  payload="$(jq -nc --arg c "$cmd" --arg t "$tool" --argjson r "$response" \
    '{tool_name: $t, tool_input: {command: $c}, tool_response: $r}')"
  out="$(bash "$hook" <<<"$payload")"
  got=skip
  if [[ -n "$out" ]]; then
    if jq -e '.hookSpecificOutput.hookEventName == "PostToolUse"' >/dev/null 2>&1 <<<"$out"; then
      got=fire
    else
      got="invalid-json"
    fi
  fi
  ran=$((ran + 1))
  if [[ "$got" == "$want" ]]; then
    printf 'ok    %-5s %-10s %q\n' "$want" "$tool" "$cmd"
  else
    printf 'FAIL  want %s, got %s [%s]: %q\n' "$want" "$got" "$tool" "$cmd"
    failed=$((failed + 1))
  fi
}

# Shapes of a real commit.
check fire 'git commit -m x'
check fire 'git add -A && git commit -m "a b"'
check fire 'git -C "/a b" commit -m x'
check fire "git -C 'C:\\Users\\First Last\\repo' commit -m x"
check fire 'git -c user.name="A B" commit -m x'
check fire 'git --git-dir=/x/.git commit -m x'
check fire 'git --git-dir /x/.git commit -m x'
check fire 'git --no-pager -C x commit'
check fire 'git commit --amend --no-edit'
check fire 'GIT_DIR=x git commit -m y'
check fire 'cd repo; git commit -m y'
check fire $'git add .\ngit commit -m y'
check fire 'git commit -m x' PowerShell
# A --dry-run elsewhere in the chain does not silence the commit.
check fire 'git push --dry-run && git commit -m x'
check fire 'git commit -m x && git push --dry-run'

# Not a commit, or a commit that writes nothing.
check skip 'git status'
check skip 'git commit-tree abc'
check skip 'echo committed'
check skip 'git commit --dry-run'
check skip 'git commit -m x --dry-run'
check skip 'git commit -m x' Read
check skip 'git commit -m x' Bash '"On branch main\nnothing to commit, working tree clean"'
check skip 'git commit -m x' Bash '{"stdout":"On branch main\nnothing to commit, working tree clean","stderr":""}'

# Garbage in: silent, exit 0, never invalid output.
for junk in 'not json' '' '{"tool_name":"Bash"}' '{"tool_name":"Bash","tool_input":{"command":"git commit"}'; do
  ran=$((ran + 1))
  out="$(bash "$hook" <<<"$junk")"; rc=$?
  if [[ $rc -eq 0 && -z "$out" ]]; then
    printf 'ok    junk  %s\n' "$junk"
  else
    printf 'FAIL  junk input gave rc=%s output=%q: %s\n' "$rc" "$out" "$junk"
    failed=$((failed + 1))
  fi
done

echo "$((ran - failed))/$ran passed"
[[ $failed -eq 0 ]]
