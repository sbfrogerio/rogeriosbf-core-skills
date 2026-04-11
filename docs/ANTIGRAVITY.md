# Antigravity Setup

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Platform antigravity
```

The installer writes imported skills to:

```text
%USERPROFILE%\.gemini\antigravity\skills
```

The manifest includes Antigravity-focused sources such as:

- Antigravity Awesome Skills
- sickn33 Antigravity Awesome Skills
- Antigravity Kit
- SuperAntigravity

Optional GSD workflows:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Platform antigravity -InstallGsd
```
