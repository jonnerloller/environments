---
name: openclaw automation commands
description: How homelab slash commands (/addflight, /addword, /translate, /torrent, /journal) route deterministically to scripts via the homelab-automation tool plugin + command-dispatch skills.
type: reference
---

Homelab chat commands are split into two deterministic layers so the model
never "reinterprets" a structured command.

## Layers

1. **Tool plugin** `homelab-automation` — a `defineToolPlugin` package that
   exposes one agent tool per automation. Each tool tokenizes a raw arg string
   (quote-aware) and runs the matching script via `execFile` (no shell, so no
   injection). Tools: `flight_add`, `word_add`, `translate_add` (prepends the
   `translate` kind), `lookup_add`, `torrent_add`, `journal_add`.
   - Source: `~/repo/environments/openclaw-plugins/homelab-automation/` (TS).
   - Installed copy: `~/.openclaw/extensions/homelab-automation/`.
   - Scripts it calls: `~/repo/environments/scripts/automation/*.sh|*.py`
     (override dir via plugin config `scriptsDir`).
   - Build/update: `npm run build && openclaw plugins build --entry ./dist/index.js`
     then `openclaw plugins install ./homelab-automation --force` and restart.

2. **Command skills** — one `SKILL.md` per command under
   `~/.openclaw/workspace/skills/<name>/`, each with frontmatter:
   `command-dispatch: tool`, `command-tool: <the tool>`, `command-arg-mode: raw`,
   `user-invocable: true`. This makes the typed slash command bypass the model
   (Path A). The skill body doubles as the model's manifest so inferred English
   is formatted into the same tool (Path B). Off-topic messages just get a normal
   answer (Path C). Skills: addflight, addword, translate, torrent, journal.

## Gotchas that cost time

- **Agent skills allowlist.** The `coder` agent (`agents.list[0].skills` in
  `~/.openclaw/openclaw.json`) is an explicit allowlist. A skill not listed there
  shows `blockedByAgentFilter: true` and is neither model- nor command-visible.
  New command skills MUST be added to that array.
  Check with: `openclaw skills list --json` → `modelVisible`/`commandVisible`.
- **`plugins.allow` is an exclusive allowlist.** Setting it disables every
  plugin not listed (including the bundled `telegram` channel). Leave it unset;
  local plugins auto-load with a harmless warning.
- **Plugin/core version lockstep.** `@openclaw/codex` requires core
  `>=2026.6.11`; a mismatch throws `Cannot find module .../exec-approvals-runtime`
  on every invocation and destabilizes the model path. Keep core ≥ the plugin.
- Native command menu registration is per-scope; `getMyCommands` confirms which
  commands Telegram exposes.

## Adding a new command

1. Write a documented `*.sh` (safe `-h/--help`, validate before side effects).
2. Add a tool to the plugin `SPECS` (set `prefixArgs` if a fixed kind is needed).
3. Rebuild + reinstall the plugin, restart the gateway.
4. Add a `SKILL.md` with the `command-dispatch: tool` frontmatter.
5. Add the skill name to `agents.list[0].skills`, restart, verify visibility.
