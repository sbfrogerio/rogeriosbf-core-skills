# Repository guidance for coding agents

## Purpose

This repository maintains a small, auditable bootstrap layer for installing curated third-party agent skills across OpenAI Codex, Claude Code/Cowork, and Google Antigravity.

Keep the repository itself lightweight. Upstream skill packs belong in their original repositories and must not be vendored here.

## Source of truth

- `manifests/core-packages.json` defines upstream packages and install policy.
- `scripts/install.ps1` defines installation behavior.
- `scripts/uninstall.ps1` defines managed cleanup behavior.
- `scripts/validate.ps1` validates repository invariants.
- `SECURITY.md` defines the security boundary.
- `docs/ARCHITECTURE.md` explains the design.

Read only the files relevant to the task. Do not load the entire manifest or all docs for a small edit.

## Required checks

Before completing a change:

```powershell
pwsh -NoProfile -File ./scripts/validate.ps1
pwsh -NoProfile -File ./scripts/install.ps1 -Platform codex -IncludePackage anthropic-skills -Workspace ./tmp/ucs-dryrun -DryRun
```

If installation behavior changes, also verify the uninstaller still removes only directories containing a rogeriosbf CORE Skills marker.

## Safety invariants

- Never execute upstream install scripts, hooks, package managers, or binaries by default.
- The only current execution exception is the explicit `-InstallGsd` opt-in described in `SECURITY.md`.
- Never delete or overwrite an unmanaged user skill.
- Do not add private repositories, embedded credentials, tokens, or authenticated clone URLs to the manifest.
- New installable packages must be public, useful for agent workflows, and expose a discoverable skill root.
- Preserve third-party licensing. This repository's MIT license does not relicense upstream content.
- For Codex, treat `$HOME/.agents/skills` as the primary user skill location. The `$HOME/.codex/skills` mirror is compatibility-only.

## Codex-specific guidance

Agent skills use `SKILL.md` with YAML front matter containing `name` and `description`. The installer normalizes these fields and writes optional `agents/openai.yaml` metadata.

Keep imported Codex skills explicit by default (`allow_implicit_invocation: false`) because this project can install a large skill set. Avoid adding broad always-on instructions that increase prompt noise.

When changing assumptions about Codex, verify them against current official OpenAI documentation before editing behavior or docs.

## Change discipline

- Keep commits focused.
- Update `CHANGELOG.md` for user-visible behavior.
- Update `docs/CODEX.md` when Codex paths, invocation, or skill metadata behavior changes.
- Update `docs/ARCHITECTURE.md` when repository structure or data flow changes.
- Prefer deterministic validation over prose-only policy.
