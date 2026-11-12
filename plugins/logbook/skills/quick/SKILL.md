---
name: quick
description: Read and change the quick notes, the one scratch pad the person keeps in the Logbook app's floating window for the day's to-dos and passing thoughts, through the quick_notes and quick_notes_edit tools. Use when the user says "quick note", "nota rápida", "apunta rápido", "recuérdame", "remind me to", "add to my to-dos", "agrega a mis pendientes de hoy", "qué tengo pendiente hoy", "check off", "/logbook:quick", or wants something jotted down that needs no note of its own.
---

# logbook · quick

Deliberately **self-contained**, and the smallest skill in the plugin: the pad is
for what does not deserve planning, and neither does writing to it.

**The quick notes are one pad, not a document.** The person sees it in a floating
window of the Logbook app and types in it all day; what you write appears there at
once, and what they type is what you read. It is kept in the vault as
`.ok/quick.md`, outside the documents: `search`, the tree, the graph and `lint`
never see it, and `write`, `edit` and `exec` do not reach it. Two tools of the
`logbook-mcp` MCP do:

| You want to | You call |
|---|---|
| See what is on the pad | `quick_notes` |
| Add, check off, reword or sweep | `quick_notes_edit` |

| You type | What happens |
|---|---|
| `/logbook:quick <whatever it is>` | It is added to the pad |
| `/logbook:quick` or `/logbook:quick list` | What is open, read back |
| `/logbook:quick done <which>` | That task is checked off |
| `/logbook:quick clear` | The checked tasks are swept |

## Pad or board?

- **The pad** is the person's own short-term memory: call the bank, buy coffee, the
  wifi password someone read out, "look at this later". One line, their words, no
  context needed because they are the one who will read it, today or tomorrow.
- **A task that has to be picked up cold** (by them in three weeks, or by an agent)
  needs where, why and origin: that is `/logbook:task`, on the repo's board.
- **Anything with a title, links or sections** is a note, and goes through the
  skill that writes that kind of note.

When it could be either, the pad is the cheap answer: put it there and say that it
can be promoted to the board. Do not ask.

## Adding

One `quick_notes_edit` call, no read first:

- Something to do is a task: `tasks: ["call the bank about the transfer"]`. Each
  becomes an open `- [ ]` line. Several things said at once are several tasks in
  the same call.
- Something to keep that is not to do (a number, a name, a thought) is `append`,
  as the Markdown it should read as.
- **Their words, shortened only to fit a line.** No bold title, no date, no
  sub-bullets, no "Why it matters": the pad is theirs, and a line they did not
  write the way they would have is a line they stop trusting.
- Write in the language they said it in.
- Pass `summary` when the call does more than its arguments say on their face
  ("the three follow-ups from the call with Laura").

## Reading

`quick_notes` returns the pad as it reads now, with `open` and `done` counts. When
asked what is pending, answer with the open tasks as they are written, in order,
and nothing else unless asked: not the done ones, not a commentary.

## Checking off, rewording, sweeping

- `done: ["bank"]` checks off the open task whose text contains that; `undone`
  reopens one. The text must name **one** task: if the tool answers that it
  matches several or none, call `quick_notes`, pick the line from what it shows,
  and call again with more of its text. Never guess between two.
- `edits: [{find, replace}]` rewords a line or, with an empty `replace`, removes
  what `find` matched (give it the whole line to remove the line). Each `find`
  must occur exactly once. Use it only on what the person asked to change.
- `clear_done: true` removes every checked task. **Only when asked to**: a checked
  task is the record that the day happened, and the person sweeps it when they
  want the space.
- Everything in one call is one write, and nothing is written if any part of it
  misses.

## What not to do

- **Do not tidy.** No reordering, regrouping under headings, fixing their
  spelling or merging near-duplicates unless asked. Someone is typing in that
  window while you write.
- **Do not replace the pad.** There is no tool for it on purpose: every change
  names the lines it touches, so a line typed a second ago is never overwritten.
- **MCP down, or the tools are not there** (a server older than the quick notes
  has no `quick_notes`): say so and stop. Do not write the reminder to a note or a
  local file instead, which is a place they will not look.

## Report

One line: what was added or checked off, as it now reads. No link: the pad is
not a document, and the window already shows it.
