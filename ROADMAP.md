# Roadmap

This roadmap describes maintenance work, not promises or release dates.

## Near term

- Keep the package manifest current as upstream repositories move, archive, or change layout.
- Add regression fixtures for skill discovery and front-matter normalization.
- Improve Linux/macOS ergonomics so the Bash entry point does not depend as heavily on PowerShell.
- Add a compact compatibility report showing which packages are installable for each supported host.
- Review imported skill descriptions for concise trigger boundaries, especially for large Codex installations.

## Supply-chain hardening

- Evaluate optional commit pinning or lockfile support while preserving a simple update workflow.
- Record upstream revision information in install reports.
- Add optional checksum/integrity metadata where it provides real value.
- Keep upstream execution disabled by default and document every exception.

## Codex integration

- Track current OpenAI skill conventions and keep `docs/CODEX.md` aligned with official documentation.
- Explore a curated Codex profile with a smaller default set for users who do not want hundreds of discoverable skills.
- Evaluate portable plugin packaging for selected first-party workflows where plugin distribution is a better fit than local bootstrap installation.
- Add test prompts/evals for project-owned skills if the repository begins shipping first-party skills.

## Community

- Label beginner-friendly contribution opportunities.
- Document package nomination criteria with concrete examples.
- Use issues and pull requests to capture compatibility reports from real users.
- Publish release notes for changes that affect installation or security behavior.
