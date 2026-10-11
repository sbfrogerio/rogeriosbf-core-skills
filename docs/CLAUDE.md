# Claude Code / Cowork Setup

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Platform claude
```

The installer writes imported skills to:

```text
%USERPROFILE%\.claude\skills
```

Each imported skill receives normalized YAML frontmatter and a unique `ucs-*` name.

Optional GSD workflows:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Platform claude -InstallGsd
```

`-InstallGsd` runs the local cloned Get Shit Done installer for Claude.

## Two distribution channels

| Channel | Reaches | Updates | Use for |
|---|---|---|---|
| `install.ps1 -Platform claude` | `~/.claude/skills` on the current machine only | Re-run with `-UpdateSources` | Claude Code on one computer; skills that need local binaries |
| `build-claude-plugin.ps1` + upload on claude.ai | Your account: Claude Code on every machine, Cowork, claude.ai web | Rebuild with `-UpdateSources` and a new `-Version`, re-upload | Skills you want everywhere |

Do not use both channels for the same skills on one machine: the copies would appear twice under different names.

### Building the plugin

```powershell
pwsh -NoProfile -File ./scripts/build-claude-plugin.ps1 -Version 1.0.0
```

Default contents: `web-design-guidelines` (vercel-agent-skills), `design-taste-frontend` and `redesign-existing-projects` (taste-skill), `playwright-cli`, and the repository-owned `design-md-reference`. Override with `-IncludePackage` and `-PluginName`.

The archive lands in `dist/` (git-ignored). Upload it on claude.ai under Customize > Plugins. Keep it private: it contains copies of third-party skills.

### Playwright CLI

The `playwright-cli` skill only works where the binary exists, so it is useful in Claude Code but not on claude.ai web. Add `-InstallPlaywrightCli` to the install command you normally run on each computer:

```powershell
pwsh -NoProfile -File ./scripts/install.ps1 -Platform claude -InstallPlaywrightCli
```

Each installer run replaces the whole managed `ucs-*` set for the selected platforms, so do not run it with a narrower `-IncludePackage` list just to get the binary. If the skills already arrive through the plugin and you only need the binary, install it directly:

```powershell
npm install -g @playwright/cli@latest
```
