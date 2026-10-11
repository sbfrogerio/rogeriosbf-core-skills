---
name: design-md-reference
description: Fetch a ready-made DESIGN.md (Google Stitch format) for a known brand's visual language from VoltAgent/awesome-design-md and use it as the design reference for a page, site or UI. Use when the user asks for a site or UI "in the style of" a brand (Apple, Stripe, Notion, Linear, Vercel...), wants a DESIGN.md for a project, or asks for a design system starting point. Também quando pedirem um site "no estilo de" uma marca.
---

# DESIGN.md reference

The collection lives at `https://github.com/VoltAgent/awesome-design-md` (MIT). Each brand folder holds a `DESIGN.md` with theme, color roles, typography, components, layout, elevation, do's and don'ts, responsive rules and an agent prompt guide.

## Steps

1. Pick the brand folder. If unsure of the exact folder name, list them:
   `https://api.github.com/repos/VoltAgent/awesome-design-md/contents/design-md`
   Folder names are lowercase and may include the domain (for example `linear.app`, `mistral.ai`, `x.ai`).
2. Fetch the file:
   `https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/<brand>/DESIGN.md`
3. If working in a project, save it as `DESIGN.md` in the project root (ask first if one already exists). Otherwise keep it in context.
4. Build the UI following its color roles, type scale, spacing and component rules. Treat the "Do's and Don'ts" section as hard constraints.

## Guardrails

- Use a brand DESIGN.md as inspiration for structure, rhythm and quality, not to clone a third party's identity. For client or production work, swap in the client's own colors, typography, logo and copy; copying another company's trade dress can create legal risk.
- Proprietary fonts named in a DESIGN.md (for example SF Pro or SöhneBreit) are usually not licensed for reuse; substitute a close open font and say so.
- If the fetch fails, say so and continue with general design judgment rather than inventing tokens.
