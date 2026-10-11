# Changelog

All notable changes to rogeriosbf CORE Skills are documented here.

The project follows semantic versioning for tagged releases.

## [1.2.0] - 2026-10-11

### Added
- Packages `vercel-agent-skills` (web-design-guidelines only), `taste-skill` (design-taste-frontend and redesign-skill only), `playwright-cli`, and reference-only `awesome-design-md`.
- `-InstallPlaywrightCli` opt-in that installs the `@playwright/cli` npm package required by the playwright-cli skill.
- `scripts/build-claude-plugin.ps1`, which bundles selected packages into a claude.ai plugin archive so skills sync to Claude Code on every machine, Cowork and the web.
- Repository-owned `design-md-reference` skill that fetches a brand DESIGN.md on demand.

### Security
- Plugin archives are written to git-ignored `dist/` and documented as personal-use builds.

## [1.1.0] - 2026-10-06

### Added
- Root `AGENTS.md` with concise repository guidance for Codex and other coding agents.
- Deterministic manifest/repository validator in `scripts/validate.ps1`.
- Upstream repository health checker in `scripts/check-upstreams.ps1`.
- Weekly/manual upstream health checks in GitHub Actions.
- Maintenance roadmap and clearer Codex compatibility documentation.

### Changed
- README now describes the project as a cross-agent interoperability/bootstrap layer rather than only a package list.
- Codex documentation now distinguishes the official `$HOME/.agents/skills` location from the legacy compatibility mirror.
- CI uses the same validation script locally and in GitHub Actions.

### Security
- Validation now rejects duplicate package IDs, non-HTTPS/non-GitHub upstream URLs, unknown platform identifiers, installable packages without skill roots, and contradictory install/reference flags.

## [1.0.0] - 2026-04-13

### Added
- Public cross-platform installer for curated skill packs.
- Codex, Claude Code/Cowork, and Antigravity targets.
- Managed uninstall support.
- CI validation on Windows and Linux.
- MIT license, contribution guide, architecture documentation, and security policy.
