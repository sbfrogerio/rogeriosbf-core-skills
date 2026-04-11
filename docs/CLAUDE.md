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
