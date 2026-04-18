---
name: plan-review-delivery
description: Use for long, non-trivial specs or broad "go fix this" implementation requests that require multiple steps, meaningful design choices, cross-file changes, risk management, commits, or a pull request. Requires an explicit user-reviewed plan before edits, an active TODO list during execution, task-by-task completion summaries, per-task commits on a separate branch, and a final pull request URL.
---

# Plan Review Delivery

Use this workflow for broad implementation work where jumping straight into edits would hide important choices from the user.

## 1. Start With A Plan

Do not edit files first.

1. Restate the goal in one sentence.
2. Identify the task boundaries and likely risks.
3. Break the work into reviewable tasks.
4. Include the branch, commit, validation, and PR strategy.
5. Ask the user to review and approve the plan.

Proceed only after explicit approval. If the user changes the plan, revise it and ask again.

## 2. Maintain The TODO List

After the plan is approved, create an active TODO list from the approved tasks.

For each TODO item:

1. Mark it in progress before starting.
2. Complete the implementation and focused validation for that task.
3. Mark it complete immediately.
4. Add a one-sentence summary of what changed and any important decision made.

Keep the TODO list accurate enough that a future continuation can resume without reconstructing the whole task from scratch.

## 3. Work On A Separate Branch

Create or switch to a dedicated task branch before making implementation commits.

Use a concise branch name that reflects the approved plan. Sync with the base branch first when repo policy or user instructions require it.

## 4. Commit Each Completed Task

After each TODO item is completed and validated:

1. Review the diff for that task.
2. Commit only the files that belong to that task.
3. Use a clear commit message tied to the completed TODO item.
4. Continue to the next approved TODO item.

If unrelated user changes are present, do not include or revert them.

## 5. Submit The Pull Request

When all approved tasks are done:

1. Run the repo's expected final validation.
2. Push the task branch.
3. Open a pull request.
4. Give the user the PR URL.

The final response must include the branch name, PR URL, completed task summary, and validation commands with pass/fail status.

## Exceptions

For small, obvious edits, normal task discipline is enough. If the task grows in scope or starts requiring multiple design decisions, pause and switch to this workflow before continuing.
