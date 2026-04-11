# Unlimited CORE Skills

Replicable installer for the agent skill stack used in Roger's Codex setup.

The project consolidates popular community and official agent skill packs into a single bootstrap flow for:

- OpenAI Codex
- Claude Code / Claude Cowork
- Google Antigravity / Gemini-style skill roots

It does not vendor thousands of third-party files into this repository. Instead, it keeps a reviewed package manifest and installs from upstream GitHub repositories into each user's local agent directories.

## What It Installs

The default manifest includes packages such as:

- Superpowers
- Anthropic Agent Skills
- Everything Claude Code
- Antigravity Awesome Skills
- sickn33 Antigravity Awesome Skills
- Antigravity Kit
- BMAD Method
- SuperClaude Framework
- Microsoft Skills
- Vercel Skills
- Claude Skills collections
- Get Shit Done, as an optional explicit installer

Mega packs are installed as explicit skills, using the `ucs-*` prefix, so they do not flood normal agent invocation. Codex installs also receive `agents/openai.yaml` with `allow_implicit_invocation: false`.

## Quick Start

Clone the repo and run the installer:

```powershell
git clone https://github.com/YOUR_GITHUB_USER/unlimited-core-skills.git
cd unlimited-core-skills
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Platform codex
```

Install for every supported local agent root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Platform all
```

Install only selected packages:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 `
  -Platform codex `
  -IncludePackage superpowers,anthropic-skills,antigravity-awesome-skills-sickn33
```

Install Get Shit Done workflows and agents too:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Platform codex -InstallGsd
```

`-InstallGsd` intentionally runs the upstream Get Shit Done installer after cloning it locally. Leave it off if you want a no-third-party-installer mode.

## Target Directories

Codex:

- Official skill root: `%USERPROFILE%\.agents\skills`
- Legacy app fallback: `%USERPROFILE%\.codex\skills`

Claude Code / Cowork:

- `%USERPROFILE%\.claude\skills`

Antigravity:

- `%USERPROFILE%\.gemini\antigravity\skills`

The installer keeps its cloned source cache and reports under:

```text
%USERPROFILE%\.unlimited-core-skills
```

## Design Rules

- Third-party repositories are cloned into a local source cache.
- Existing installs managed by this project are removed before reinstalling.
- Unmanaged user skills are left alone.
- Imported skills receive unique names with a `ucs-*` prefix.
- Codex imported mega-pack skills are explicit-only.
- Repositories with Windows path issues use sparse checkout where possible.
- Reference-only MCP/tool repositories are kept in the manifest but not installed as skills.

## Reports

After installation, inspect:

```text
%USERPROFILE%\.unlimited-core-skills\reports\install-summary.json
```

## Safety Notes

The normal installer copies `SKILL.md` folders and metadata. It does not run upstream hooks or package install scripts.

The exception is `-InstallGsd`, which runs the Get Shit Done installer because that project generates Codex/Claude/Antigravity workflow integrations from its own command and agent files.

## Repository Layout

```text
manifests/core-packages.json  Package registry and install policy
scripts/install.ps1          Main installer
docs/                        Platform-specific notes
```

## License

This project is MIT licensed. Third-party skills retain their upstream licenses and are downloaded from their original repositories.
