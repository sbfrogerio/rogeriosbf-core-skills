# Contributing to rogeriosbf CORE Skills

Thank you for your interest in contributing! This project is designed to be a community-maintained, curated agent skill stack.

## How to Add a New Package

1. **Fork this repository** and create a feature branch.

2. **Edit `manifests/core-packages.json`** and add your package entry:

```json
{
  "id": "your-package-id",
  "name": "Your Package Name",
  "hype": "high",
  "type": "skill-pack",
  "repo": "https://github.com/owner/repo.git",
  "platforms": ["codex", "claude-code", "antigravity"],
  "skill_roots": ["skills"],
  "sparse_paths": [],
  "install_skills": true,
  "reference_only": false,
  "notes": "Brief description of what it provides."
}
```

3. **Test the installation** with a dry run:

```powershell
.\scripts\install.ps1 -Platform codex -IncludePackage your-package-id -DryRun
```

4. **Submit a pull request** with:
   - A description of the package and why it's valuable.
   - Confirmation that you've tested it locally.
   - Any platform-specific notes (e.g., Windows path issues).

## Package Criteria

We accept packages that:

- Provide genuine value for agent-assisted development workflows.
- Have a public GitHub repository with an open-source license.
- Contain well-structured `SKILL.md` files or agent configurations.
- Are actively maintained (or stable enough to be useful).

We generally exclude:

- Packages that require paid API keys to function.
- Packages with unsafe install hooks that cannot be bypassed.
- Very niche tools that only work on a single, obscure platform.

## Safety Requirements

- Packages must not require running upstream install scripts by default.
- If a package has an installer, it should be opt-in (like `-InstallGsd`).
- Windows path safety should be considered (mark unsafe repos as `reference_only` or use `sparse_paths`).

## Code Style

- PowerShell scripts use standard `PascalCase` for functions and parameters.
- All file writes use UTF-8 without BOM.
- JSON files use standard indentation (2 or 4 spaces).

## Reporting Issues

If you encounter problems:

1. Check the [install-summary.json](docs/ARCHITECTURE.md) for error details.
2. Open an issue with your OS, PowerShell version, and the error output.
3. Include the package ID and platform you were installing for.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
