#!/usr/bin/env bash
# Every plugins/<plugin>/skills/<skill>/SKILL.md opens with a frontmatter block
# whose `name` is its folder's name and whose `description` is not empty. A skill
# without a description is never offered to the model, and one whose name drifts
# from its folder is invoked under a name nobody documented — neither errors.
#
#   bash tests/skills.sh

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failed=0
count=0

for skill in "$here"/../plugins/*/skills/*/SKILL.md; do
  [[ -f "$skill" ]] || { echo "FAIL  no SKILL.md found under plugins/*/skills/"; exit 1; }
  count=$((count + 1))
  dir="$(basename "$(dirname "$skill")")"
  rel="${skill#"$here"/../}"

  # The block between the first two `---` lines, and only if the file opens with one.
  front="$(awk 'NR == 1 { if ($0 != "---") exit; next } $0 == "---" { closed = 1; exit } { print } END { if (!closed) print "\001unclosed" }' "$skill")"
  if [[ -z "$front" || "$front" == *$'\001unclosed'* ]]; then
    echo "FAIL  $rel: no frontmatter block (--- on line 1, closed by a second ---)"
    failed=$((failed + 1))
    continue
  fi

  name="$(sed -n 's/^name:[[:space:]]*//p' <<<"$front" | head -n 1)"
  desc="$(sed -n 's/^description:[[:space:]]*//p' <<<"$front" | head -n 1)"

  if [[ "$name" != "$dir" ]]; then
    echo "FAIL  $rel: name '$name' does not match its folder '$dir'"
    failed=$((failed + 1))
  elif [[ -z "$desc" ]]; then
    echo "FAIL  $rel: empty or missing description"
    failed=$((failed + 1))
  else
    echo "ok    $rel"
  fi
done

echo "$((count - failed))/$count skills passed"
[[ $failed -eq 0 ]]
