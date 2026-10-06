# Changelog

All notable changes to rogeriosbf CORE Skills are documented here.

The project follows semantic versioning for tagged releases.

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
