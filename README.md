# 🚀 rogeriosbf CORE Skills

[![Validate](https://github.com/sbfrogerio/rogeriosbf-core-skills/actions/workflows/validate.yml/badge.svg)](https://github.com/sbfrogerio/rogeriosbf-core-skills/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Codex · Claude · Antigravity](https://img.shields.io/badge/Platform-Codex%20%C2%B7%20Claude%20%C2%B7%20Antigravity-blueviolet.svg)](#supported-platforms)

> **One command to install 20+ curated agent skill packs across OpenAI Codex, Claude Code/Cowork, and Google Antigravity.**

This project consolidates the most popular community and official agent skill packs into a single, replicable bootstrap flow. Clone it, run the installer, and your agent coding environment is fully configured — whether you're setting up a new machine or sharing your stack with a colleague.

---

## ✨ What It Installs

| Package | Type | Hype |
|---------|------|------|
| [Superpowers](https://github.com/obra/superpowers) | Workflow Pack | 🔥🔥🔥 |
| [Anthropic Agent Skills](https://github.com/anthropics/skills) | Official Skills | 🔥🔥🔥 |
| [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) | Mega Pack | 🔥🔥🔥 |
| [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | Multi-Agent Method | 🔥🔥🔥 |
| [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) | Command Framework | 🔥🔥 |
| [Vercel Skills](https://github.com/vercel-labs/skills) | Platform Skills | 🔥🔥🔥 |
| [Microsoft Skills](https://github.com/microsoft/skills) | Official Skills | 🔥🔥 |
| [Antigravity Awesome Skills](https://github.com/sebas-aikon-intelligence/antigravity-awesome-skills) | Antigravity Pack | 🔥🔥🔥 |
| [sickn33 Awesome Skills](https://github.com/sickn33/antigravity-awesome-skills) | Mega Library (1400+) | 🔥🔥🔥 |
| [Antigravity Kit](https://github.com/vudovn/antigravity-kit) | Antigravity Kit | 🔥🔥🔥 |
| [UI UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | Design Pack | 🔥🔥 |
| [Claude Skills Collection](https://github.com/alirezarezvani/claude-skills) | Skill Pack | 🔥🔥 |
| [Claude Skill Factory](https://github.com/alirezarezvani/claude-code-skill-factory) | Skill Authoring | 🔥🔥 |
| [Claude Skills Marketplace](https://github.com/mhattingpete/claude-skills-marketplace) | Marketplace | 🔥 |
| [wshobson Agents](https://github.com/wshobson/agents) | Subagent Roles | 🔥🔥 |
| [SuperAntigravity](https://github.com/derHaken/SuperAntigravity) | Antigravity Pack | 🔥 |
| [Repomix](https://github.com/yamadashy/repomix) | Context Tool | 🔥🔥 |
| [Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp) | MCP Server | 🔥🔥🔥 |
| [Get Shit Done](https://github.com/gsd-build/get-shit-done) | Workflow Engine | 🔥🔥🔥 |
| [claude-plugins](https://github.com/cblecker/claude-plugins) | Plugin Manager | 🔥 |

Plus reference-only entries for [MCP Servers](https://github.com/modelcontextprotocol/servers), [Playwright MCP](https://github.com/microsoft/playwright-mcp), [Awesome Agent Skills](https://github.com/VoltAgent/awesome-agent-skills) and [OpenClaw Skills](https://github.com/openclaw/skills).

---

## 🏃 Quick Start

### Windows (PowerShell)

```powershell
git clone https://github.com/sbfrogerio/rogeriosbf-core-skills.git
cd rogeriosbf-core-skills

# Install for Codex
.\scripts\install.ps1 -Platform codex

# Install for all platforms
.\scripts\install.ps1 -Platform all

# Dry run first (see what would be installed)
.\scripts\install.ps1 -Platform all -DryRun
```

### macOS / Linux (Bash)

```bash
git clone https://github.com/sbfrogerio/rogeriosbf-core-skills.git
cd rogeriosbf-core-skills

# Requires PowerShell 7+ (pwsh)
./scripts/install.sh -Platform codex

# Or run directly with pwsh
pwsh -NoProfile -File ./scripts/install.ps1 -Platform all
```

> **Note:** The installer requires `git` and `PowerShell 7+` (pwsh). On macOS/Linux, install pwsh via [Microsoft docs](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell).

---

## 🎯 Installation Profiles

Choose your installation scope:

```powershell
# Minimal — official packs only
.\scripts\install.ps1 -Platform codex -IncludePackage superpowers,anthropic-skills,vercel-skills,microsoft-skills

# Standard — popular community packs
.\scripts\install.ps1 -Platform all

# Maximalist — everything + GSD workflows
.\scripts\install.ps1 -Platform all -InstallGsd

# Selective — pick exactly what you want
.\scripts\install.ps1 -Platform codex -IncludePackage superpowers,bmad-method,antigravity-kit
```

---

## 🖥️ Supported Platforms

| Platform | Skill Directory | Notes |
|----------|----------------|-------|
| **OpenAI Codex** | `~/.agents/skills` + `~/.codex/skills` | Skills are explicit-only via `openai.yaml` |
| **Claude Code / Cowork** | `~/.claude/skills` | Standard SKILL.md format |
| **Google Antigravity** | `~/.gemini/antigravity/skills` | Full SKILL.md support |

---

## 📂 Repository Layout

```
rogeriosbf-core-skills/
├── manifests/
│   └── core-packages.json       # Package registry + install policy
├── scripts/
│   ├── install.ps1              # Main cross-platform installer
│   ├── install.sh               # Bash wrapper (requires pwsh)
│   ├── uninstall.ps1            # Remove managed skills
│   └── publish-github.ps1      # Push to GitHub helper
├── docs/
│   ├── ARCHITECTURE.md          # How it works
│   ├── CODEX.md                 # Codex-specific setup
│   ├── CLAUDE.md                # Claude Code setup
│   ├── ANTIGRAVITY.md           # Antigravity setup
│   └── WINDOWS.md               # Windows path gotchas
├── .github/
│   └── workflows/validate.yml  # CI pipeline
├── CONTRIBUTING.md              # How to contribute
├── SECURITY.md                  # Security policy
├── LICENSE                      # MIT
└── README.md                    # You are here
```

---

## 🔧 How It Works

1. **Clone sources** — Upstream repos are shallow-cloned into a local cache at `~/.rogeriosbf-core-skills/sources/`.
2. **Discover skills** — Each package is scanned for `SKILL.md` files.
3. **Normalize & install** — Skills are copied with standardized frontmatter and unique `ucs-*` names.
4. **Mark as managed** — A `_rogeriosbf_core_skill.json` marker tracks what was installed.
5. **Report** — An `install-summary.json` is written for reference.

On reinstall, only managed skills are replaced. Your custom skills are never touched.

---

## 🔐 Security

- The default installer **only clones repos and copies skill folders**. No upstream hooks or install scripts are executed.
- The `-InstallGsd` flag is the explicit exception: it runs the [Get Shit Done](https://github.com/gsd-build/get-shit-done) installer locally.
- Community content is treated as quarantined — review before activating.

See [SECURITY.md](SECURITY.md) for details.

---

## 🧹 Uninstall

Remove all managed skills without affecting your custom ones:

```powershell
.\scripts\uninstall.ps1 -Platform all

# Remove only from specific platform
.\scripts\uninstall.ps1 -Platform codex
```

---

## 📊 Reports

After installation, inspect what was installed:

```powershell
Get-Content "$env:USERPROFILE\.rogeriosbf-core-skills\reports\install-summary.json" | ConvertFrom-Json | Format-List
```

---

## 🤝 Contributing

Want to add a package or improve the installer? See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 📜 License

This project is [MIT licensed](LICENSE). Third-party skills retain their upstream licenses and are downloaded from their original repositories — nothing is vendored.

---

**Built by [@sbfrogerio](https://github.com/sbfrogerio)** — consolidating the best agent skill packs into one replicable setup.
]]>
