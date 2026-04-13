# Codex Setup

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Platform codex
```

The installer writes explicit imported skills to:

- `%USERPROFILE%\.agents\skills`
- `%USERPROFILE%\.codex\skills`

Codex receives an `agents/openai.yaml` file inside every imported skill:

```yaml
policy:
  allow_implicit_invocation: false
```

This keeps thousands of community skills available without making every session noisy.

To invoke one directly, mention its installed name:

```text
$ucs-antigravity-awesome-skil-agent-orchestrator-...
```

Use the install summary to search installed names:

```text
%USERPROFILE%\.rogeriosbf-core-skills\reports\install-summary.json
```

Optional GSD workflows:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Platform codex -InstallGsd
```

That enables `gsd-*` workflows through the upstream Get Shit Done installer.
