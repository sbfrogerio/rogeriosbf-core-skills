# rogeriosbf CORE Skills

[![Validate](https://github.com/sbfrogerio/rogeriosbf-core-skills/actions/workflows/validate.yml/badge.svg)](https://github.com/sbfrogerio/rogeriosbf-core-skills/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Codex · Claude · Antigravity](https://img.shields.io/badge/Platform-Codex%20%C2%B7%20Claude%20%C2%B7%20Antigravity-blueviolet.svg)](#supported-platforms)

> Reproducible bootstrap and interoperability layer for curated agent skills across OpenAI Codex, Claude Code/Cowork, and Google Antigravity.

The project keeps the orchestration layer small and auditable: it does not vendor third-party skill packs. Instead, a manifest describes upstream repositories, supported hosts, install policy, and skill roots. The installer shallow-clones those sources, discovers `SKILL.md` assets, normalizes metadata, installs only to compatible platforms, and tracks every managed skill so it can be removed safely.

## Why this exists

Agent skill ecosystems evolve quickly and use slightly different local layouts and conventions. Rebuilding the same working setup on a new machine—or sharing it with another developer—should not require manually cloning and adapting many repositories.

rogeriosbf CORE Skills provides:

- one manifest for curated upstream agent packages;
- one repeatable install flow for Codex, Claude Code/Cowork, and Antigravity;
- Codex-specific metadata with explicit invocation by default;
- managed uninstall that leaves custom user skills untouched;
- install reports including upstream revision information;
- CI validation on Windows and Linux;
- scheduled upstream health checks;
- documented security boundaries for third-party content.

## Current manifest

The repository currently tracks 24 upstream packages. Of those, 22 declare Codex compatibility and 17 are installable as Codex skill sources; the remainder are reference-only or host-specific.

The manifest is the source of truth: [`manifests/core-packages.json`](manifests/core-packages.json).

## Quick start

### Windows

```powershell
git clone https://github.com/sbfrogerio/rogeriosbf-core-skills.git
cd rogeriosbf-core-skills

# Codex
.\scripts\install.ps1 -Platform codex

# Preview package selection without writing skills
.\scripts\install.ps1 -Platform codex -IncludePackage anthropic-skills -DryRun
```

### macOS / Linux

```bash
git clone https://github.com/sbfrogerio/rogeriosbf-core-skills.git
cd rogeriosbf-core-skills

# Requires PowerShell 7+ (pwsh)
./scripts/install.sh -Platform codex
```

## Supported platforms

| Host | Managed skill target | Notes |
|---|---|---|
| OpenAI Codex | `~/.agents/skills` | Primary Codex user-skill location |
| OpenAI Codex compatibility mirror | `~/.codex/skills` | Enabled by default for compatibility; can be disabled |
| Claude Code / Cowork | `~/.claude/skills` | Standard `SKILL.md` assets |
| Google Antigravity | `~/.gemini/antigravity/skills` | Standard `SKILL.md` assets |

See [Codex setup](docs/CODEX.md) for the Codex-specific behavior.

## Installation profiles

```powershell
# Curated selection
.\scripts\install.ps1 -Platform codex -IncludePackage superpowers,anthropic-skills,vercel-skills,microsoft-skills

# All compatible packages for all supported hosts
.\scripts\install.ps1 -Platform all

# Exclude a package
.\scripts\install.ps1 -Platform codex -ExcludePackage everything-claude-code

# Refresh cached upstream repositories
.\scripts\install.ps1 -Platform codex -UpdateSources

# Optional upstream GSD installer
.\scripts\install.ps1 -Platform codex -InstallGsd
```

The installer now respects each package's declared `platforms` field. A Claude-only package is not copied into a Codex target merely because `-Platform all` was requested.

## How it works

1. Read `manifests/core-packages.json`.
2. Select packages according to include/exclude filters.
3. Shallow-clone or update upstream sources under `~/.rogeriosbf-core-skills/sources/`.
4. Discover declared `SKILL.md` roots.
5. Normalize front matter and generate unique managed names.
6. Install only to platform-compatible targets.
7. For Codex, write `agents/openai.yaml` with explicit invocation by default.
8. Write a managed marker containing package origin and upstream revision.
9. Emit `install-summary.json`.

Imported names follow:

```text
ucs-<package>-<skill>-<hash>
```

## Security model

The default installer:

- clones public GitHub repositories;
- reads and copies skill folders;
- writes managed marker/report files;
- does **not** execute upstream hooks, package managers, setup scripts, or binaries.

The explicit `-InstallGsd` option is the documented exception and should be used only after reviewing the upstream installer.

See [SECURITY.md](SECURITY.md).

## Validation and maintenance

Run the same structural checks used by CI:

```powershell
pwsh -NoProfile -File ./scripts/validate.ps1
```

Check whether all upstream repositories in the manifest are reachable:

```powershell
pwsh -NoProfile -File ./scripts/check-upstreams.ps1
```

GitHub Actions validates pull requests on Windows and Linux and runs a scheduled upstream health check.

## Repository layout

```text
rogeriosbf-core-skills/
├── AGENTS.md
├── CHANGELOG.md
├── ROADMAP.md
├── manifests/
│   └── core-packages.json
├── scripts/
│   ├── install.ps1
│   ├── install.sh
│   ├── uninstall.ps1
│   ├── validate.ps1
│   └── check-upstreams.ps1
├── docs/
│   ├── ARCHITECTURE.md
│   ├── CODEX.md
│   ├── CLAUDE.md
│   ├── ANTIGRAVITY.md
│   └── WINDOWS.md
├── .github/workflows/
│   ├── validate.yml
│   └── upstream-health.yml
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md). Package additions should have a public repository, an appropriate license, clear utility for agent-assisted workflows, and a safe installation path.

## Roadmap

See [ROADMAP.md](ROADMAP.md) for maintenance priorities, including supply-chain hardening, compatibility reporting, and additional Codex-focused regression testing.

## License

This repository is MIT licensed. Third-party repositories retain their own licenses; this project downloads them from their original sources and does not relicense them.

Built by [@sbfrogerio](https://github.com/sbfrogerio).
