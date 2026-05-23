## What changed

Brief description.

## Type of change

- [ ] Bug fix in an existing skill
- [ ] New mode / decision-tree refinement
- [ ] New reference file
- [ ] New skill
- [ ] Doc / cookbook update
- [ ] CI / infra
- [ ] Breaking change (renames, removes, trigger swaps — needs major bump)

## Checklist

- [ ] Frontmatter intact (`version`, `name`, `description: |`, `argument-hint`, `allowed-tools`)
- [ ] SKILL.md is ≤ 300 lines (moved excess to `references/`)
- [ ] Self-contained — no `../` cross-skill references
- [ ] All `references/...` links resolve, no orphans
- [ ] Brand-rule check passes (CI hard-fails on any non-Kolbo brand names)
- [ ] If new skill: registered in `.claude-plugin/marketplace.json`'s `plugins[0].skills` array, listed in `README.md` table
- [ ] Tested in at least one agent (Claude Code / Cursor / Codex)

## Cookbook entry (optional)

If this changes a user-facing flow, paste the new recipe in `COOKBOOK.md`.
