---
name: code-workflow
description: Cross-tool coding execution workflow for commands like `/code <project_name> "<description>"` across OpenClaw, Codex, and Claude. Use when the user asks to pick a project task from 2nd brain `_tasks.md`, map it to a repo, create a task branch, implement with tests, run local validation, then push and share branch/PR links.
---

# Code Workflow

Parse command intent from patterns like:

- `/code project-name "description"`
- `code project-name description`

Treat `description` as the task objective.

## 1) Always run planning mode first (mandatory)

Do not edit code immediately.

1. Restate goal in one sentence.
2. Locate project task metadata in 2nd brain first.
3. Propose implementation + test plan.
4. Ask focused clarifying questions if blockers remain.
5. Wait for explicit confirmation before execution.

Keep planning conversational and iterative until confident.

## 2) Resolve project → repo from 2nd brain

Use 2nd brain `_tasks.md` files as source of truth.

1. Find `_tasks.md` matching `project_name` under the vault.
2. Read YAML frontmatter first.
3. Resolve repo path using this order:
   - `machine-paths.<current-machine>` (preferred)
   - `repo-name` mapped to `~/repo/<repo-name>`
   - If unresolved, ask user to confirm repo path.
4. Read sibling `_context.md` if present for project constraints.
5. Follow `agent-hint` instructions.

## 3) Create branch name

Branch format:

- `claw_task_<slug>`

Where `<slug>` is a short meaningful kebab-case summary from `description`:

- max ~40 chars
- lowercase letters, numbers, hyphens
- remove filler words and punctuation

Example:

- description: `"add jwt refresh token rotation"`
- branch: `claw_task_jwt-refresh-rotation`

## 4) Execute implementation workflow

Inside resolved repo:

1. Sync main branch (`git fetch`, rebase/pull as appropriate).
2. Create/switch to task branch.
3. Implement smallest complete change for requested task.
4. Add/adjust tests first-class (unit/integration/e2e as repo expects).
5. Run local test and lint/typecheck commands per repo conventions.
6. Fix failures before committing.
7. Summarize validation results with exact commands run.

## 5) Respect local repo rules

Before finalizing:

1. Check for repo instructions in this order:
   - `AGENTS.md`
   - `CLAUDE.md`
   - `README.md` / `CONTRIBUTING.md`
   - package/tool config scripts (Makefile, package.json, justfile, tox.ini, etc.)
2. Follow their test/lint/PR conventions.
3. Do not skip tests unless user explicitly approves.

## 6) Commit, push, and share URL

1. Commit with clear message scoped to task.
2. Push branch to origin.
3. Return branch URL.
4. If requested (or default in that repo), open PR and return PR URL.

Final update must include:

- repo path
- branch name
- files changed (high level)
- tests/checks run + pass/fail
- branch URL and PR URL (if created)

## 7) Failure handling

If blocked (missing repo mapping, failing tests, missing perms):

1. Stop and report concrete blocker.
2. Provide minimal next action options.
3. Keep branch/worktree state intact unless user asks to clean up.
