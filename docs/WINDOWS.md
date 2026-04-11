# Windows Notes

Some community repositories contain very deep paths or benchmark artifacts that exceed default Windows path limits.

This project handles the known cases by using sparse checkout for the installable catalog:

- `sickn33/antigravity-awesome-skills`: installs the root `skills/` catalog and excludes duplicate plugin bundles plus deep benchmark artifacts.
- `openclaw/skills`: kept as reference-only because upstream filenames are not safe to materialize on NTFS by default.

If a clone fails with `Filename too long`, update the package manifest to use `sparse_paths` and include only the skill catalog you actually want to install.
