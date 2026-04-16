# Rule: Task discipline

## 1. Never autocompact

Do not trigger or consent to context compaction mid-task.  If the context is
approaching its limit, stop, summarise the current TODO state in your reply, and
ask the user how to proceed.  Compaction silently discards reasoning context and
causes subtle continuity errors.

## 2. Always open a TODO at the start of a task

Before writing any code or making any changes, create a TODO list with
`TodoWrite` that covers every step you plan to take.

Format each item as:

```
[ ] short description of the step
```

As each step is completed, update the item to record what was actually done:

```
[x] short description — <one-sentence note on what changed / any decision made>
```

The note does not need to be long — its purpose is to give enough context for
a future "continue" prompt to pick up cleanly without re-reading diffs.

If a step turns out to require sub-steps, expand the TODO item in place before
starting it.

## 3. When asked to "continue", consult the TODO first

When the user says "continue", "keep going", "next", or similar:

1. Read the current TODO.
2. Identify the first unchecked item.
3. State which item you are about to work on (one line).
4. Proceed.

Do not re-plan, do not ask clarifying questions unless genuinely blocked, and do
not re-summarise completed items.  The TODO is the ground truth — trust it.
