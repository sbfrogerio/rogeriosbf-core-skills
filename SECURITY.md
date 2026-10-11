# Security Policy

## Default Behavior

The installer **only** performs these operations:
- Shallow-clones upstream repositories into a local cache.
- Copies `SKILL.md` directories into platform skill roots.
- Writes JSON marker files to track managed installations.

It does **not** execute any upstream hooks, install scripts, package managers, or binary tools.

## Explicit Exception: `-InstallGsd`

The `-InstallGsd` flag intentionally runs the [Get Shit Done](https://github.com/gsd-build/get-shit-done) installer after cloning it locally. This generates Codex/Claude/Antigravity workflow integrations from GSD's command and agent files.

**Only use this flag after inspecting the GSD installer code.**

## Explicit Exception: `-InstallPlaywrightCli`

The `-InstallPlaywrightCli` flag runs `npm install -g @playwright/cli@latest` from the public npm registry. The `playwright-cli` skill only works when this binary is present on the machine. Nothing from the cloned `microsoft/playwright-cli` repository is executed.

## Claude plugin builds

`scripts/build-claude-plugin.ps1` copies selected upstream skill folders, plus the repository-owned skills in `claude-plugin/skills/`, into a local archive under `dist/` for personal upload to claude.ai. It executes nothing from upstream. `dist/` is git-ignored: never commit or publish these archives, because upstream licenses still apply and some upstreams (for example `vercel-labs/agent-skills`) declare no license.

## Third-Party Content

All cloned repositories are treated as quarantined third-party content:
- Skills are read-only until explicitly activated.
- No upstream `package.json` scripts, hooks, or setup commands are executed.
- The `sparse_paths` manifest field limits what is even checked out for large repositories.

## Reporting Vulnerabilities

If you discover a security issue in this installer or its packaging logic, please report it privately through the [GitHub repository's security tab](https://github.com/sbfrogerio/rogeriosbf-core-skills/security) or contact the repository owner directly.

Do not report upstream skill pack vulnerabilities here — report them to the respective upstream maintainers.
