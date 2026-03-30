# Shared Agent Conventions

This directory is reserved for tool-agnostic, cross-agent coordination.

- Put shared agent roles, handoff formats, and modality guidance here.
- Keep canonical rules in `../rules/`.
- Keep reusable cross-tool skills in `../skills/`.
- Keep tool-specific state, auth, memory, and caches in each tool's local config directory.

For Codex, that means:

- Shared source of truth: `~/.llms/`
- Local working memory/state: `~/.codex/`
