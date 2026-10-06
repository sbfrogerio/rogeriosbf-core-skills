# OpenAI Codex setup

This project treats Codex as a first-class target.

## Install

From the repository root:

```powershell
pwsh -NoProfile -File ./scripts/install.ps1 -Platform codex
```

On Windows PowerShell you can also use:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Platform codex
```

## Skill locations

The installer writes managed Codex skills to:

- `$HOME/.agents/skills` — primary user-skill target;
- `$HOME/.codex/skills` — compatibility mirror, enabled by default.

To disable the compatibility mirror:

```powershell
./scripts/install.ps1 -Platform codex -MirrorCodexLegacy:$false
```

## Skill metadata

Each imported skill is normalized to include a `SKILL.md` with `name` and `description`.

For Codex targets, the installer also writes:

```text
agents/openai.yaml
```

with metadata similar to:

```yaml
interface:
  display_name: "Original skill name"
  short_description: "Original or normalized description"
  default_prompt: "Use this skill explicitly when needed."
policy:
  allow_implicit_invocation: false
```

The explicit policy is intentional. A large aggregated skill library should remain discoverable without causing every imported skill to compete for automatic invocation.

## Platform filtering

Packages declare compatible hosts in `manifests/core-packages.json`.

The installer enforces those declarations. A package that does not list `codex` is not installed into a Codex target even when the user requests `-Platform all`.

## Managed names

Imported skills are renamed deterministically:

```text
ucs-<package>-<skill>-<hash>
```

Use the generated report to inspect installed names:

```text
~/.rogeriosbf-core-skills/reports/install-summary.json
```

The report and per-skill marker record the package origin. When a real upstream checkout is present, the current upstream Git revision is also recorded.

## Updating

Refresh cached upstream repositories before reinstalling:

```powershell
./scripts/install.ps1 -Platform codex -UpdateSources
```

Because this repository tracks third-party projects, review meaningful upstream changes before relying on newly imported skills in sensitive workflows.

## Uninstall

```powershell
./scripts/uninstall.ps1 -Platform codex
```

Only directories containing this project's managed marker are removed. Unmanaged custom skills are left untouched.

## Repository instructions

The repository includes a root `AGENTS.md` with concise guidance for coding agents working on this project. It documents the security invariants, validation commands, and Codex-specific assumptions maintainers should preserve.

## Validate before contributing

```powershell
pwsh -NoProfile -File ./scripts/validate.ps1
pwsh -NoProfile -File ./scripts/install.ps1 -Platform codex -IncludePackage anthropic-skills -Workspace ./tmp/ucs-dryrun -DryRun
```

For upstream reachability:

```powershell
pwsh -NoProfile -File ./scripts/check-upstreams.ps1
```

## Optional GSD workflow installation

```powershell
./scripts/install.ps1 -Platform codex -InstallGsd
```

Unlike the default copy-only behavior, this option executes the upstream Get Shit Done installer. Review `SECURITY.md` before using it.
