---
name: New skill request
about: Propose a brand-new kolbo-* skill folder
title: '[new skill] '
labels: new skill
---

**Proposed skill name**
e.g. `kolbo-3d-printing` (must start with `kolbo-`, single token, lowercase)

**One-line description**
What does this skill do? When should the agent invoke it?

**`Use when` triggers**
List the natural-language phrases that should fire this skill:
- "..."
- "..."
- "..."

**`NOT for` boundaries**
What should NOT invoke this skill (vs. an existing one)?
- "..." → should fire existing skill X
- "..." → should fire existing skill Y

**MCP tools this skill would route to**
Which `@kolbo/mcp` tools does the skill call? Are they all already supported, or would we need new MCP work first?

**Chain points**
Does this skill produce a return value (e.g. an id) that other skills can consume? Does it consume anything from existing skills?

**Why this doesn't fit an existing skill**
Why not extend one of the 11 existing skills instead?
