# Contributing to Kolbo Skills

Thanks for considering a contribution. This is the public-facing skills package, so changes here ship to every Claude Code / Cursor / Codex user on their next `update`. We hold a high bar for prompt quality + backward compatibility.

## Before you open a PR

1. **Read the existing skill that's closest to what you're changing** — match its frontmatter shape, bootstrap stanza, and section order.
2. **Read the [skill-authoring conventions](#skill-authoring-conventions)** at the bottom of this file — covers the 300-line rule, self-contained-skill rule, version-sync rule, chaining rule.
3. **Run validation locally** — the CI runs `.github/workflows/validate-skills.yml`; do the same checks yourself first:
   ```bash
   # Verify rebrand rule (CI enforces — see the CI workflow for the exact pattern)
   # The rule guards against any non-Kolbo brand names leaking into the skill tree.

   # Verify SKILL.md size cap
   wc -l kolbo-*/SKILL.md  # each should be ≤ 300

   # Verify VERSION sync
   cat VERSION
   grep -h "^version:" kolbo-*/SKILL.md  # all should match VERSION
   ```

## PR checklist

- [ ] Frontmatter intact: `version`, `name` (matches folder), `description: |` (multi-line with `Use when` triggers), `argument-hint`, `allowed-tools`.
- [ ] SKILL.md ≤ 300 lines. If over, move content to `references/`.
- [ ] Self-contained: no `../` references to other skills. If you need shared content, duplicate it.
- [ ] Every `references/...` link from SKILL.md resolves to a real file. No orphan files.
- [ ] Brand-rule check passes (CI hard-fails any non-Kolbo brand names — see the validate-skills workflow for the exact pattern).
- [ ] Version field in frontmatter matches `VERSION` file (don't bump by hand on feature branches — let release automation do it).
- [ ] If adding a new skill: registered in `.claude-plugin/marketplace.json` skills array, listed in `README.md` table.

## What's safe to change

- Improve a skill's prompt rules — better defaults, clearer decision trees, more examples.
- Add a new mode to an existing skill (e.g. a new product-photoshoot mode).
- Add a new reference file under `references/` of an existing skill.
- Tighten or clarify UX rules.
- Add a new entry to `COOKBOOK.md`.

## What needs a major-version bump (open an issue first)

- Renaming or removing a skill.
- Removing a mode that users may be invoking by name.
- Changing the `Use when` triggers in a way that swaps which skill fires for an existing phrase.
- Changing the `argument-hint` shape.

## What requires kolbo-mcp work first

If you want to expose a new MCP tool (e.g. a brand-kit-as-a-service endpoint), open a PR against [`@kolbo/mcp`](https://github.com/Zoharvan12/kolbo-mcp) first. Then come back here and update the skill to route to the new tool. The MCP server holds strict backward-compatibility rules (never rename or remove tools; new args must be optional with sensible defaults) — read its README before proposing breaking changes.

## Adding a new skill

1. Create `kolbo-<name>/SKILL.md` with the standard frontmatter and a Step 0 — Bootstrap stanza.
2. If complex, add `kolbo-<name>/references/` subfolder.
3. Add the skill to `.claude-plugin/marketplace.json`'s `plugins[0].skills` array.
4. Update `README.md` skills table.
5. (Optional) Add a recipe to `COOKBOOK.md`.

## Skill-authoring conventions

- **300-line rule** — each `SKILL.md` aims for ≤ 300 lines. If a section would NOT break the agent's ability to decide what to do next, move it to `references/`. CI warns if any SKILL.md exceeds 300.
- **Self-contained** — each skill folder is independent. No `../` parent-directory references. If two skills share content (e.g. both reference Visual DNA usage), duplicate it. CI enforces.
- **Version sync** — the repo-wide `VERSION` file is the source of truth. Every `kolbo-*/SKILL.md` frontmatter `version:`, plus all 4 plugin manifests, must match. CI fails if any drift.
- **Skill chaining via return values** — skills communicate via return values (`vdna_id`, brand-kit slug, image URLs), not implicit state. See the README's "Skills chain" section for the current chain map.
- **Frontmatter shape** (mandatory): `version`, `name` (matches folder), `description: |` (multi-line with `Use when:` / `Chain:` / `NOT for:` blocks), `argument-hint`, `allowed-tools`.
- **Brand-rule** — zero non-Kolbo brand names anywhere in the public surface. CI hard-fails on drift.

## Releases

- Patch (0.4.0 → 0.4.1): bug fixes, doc tweaks, no new behavior.
- Minor (0.4.0 → 0.5.0): new skill, new mode, new MCP tool wired in, new install path.
- Major (0.4.0 → 1.0.0): renamed / removed skills, breaking trigger changes.

Releases are cut from `main` after CI passes. The release automation handles the cross-file version sync.
