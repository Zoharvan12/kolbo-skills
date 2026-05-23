---
name: Bug report
about: Something in a skill misroutes, fails, or produces bad results
title: '[bug] '
labels: bug
---

**Which skill?**
e.g. `kolbo-marketing-studio`, `kolbo-product-photoshoot`

**What did you ask the agent?**
The exact prompt that triggered the bug.

**What did the agent do?**
The exact tool call(s) it fired, OR what it asked you, OR the URL it returned.

**What did you expect instead?**
What should the correct routing / output have been?

**Agent + version**
- Host: Claude Code / Cursor / Codex / other
- Skills version: (run `cat ~/.<agent>/skills/kolbo-generate/VERSION` if installed via setup; or check the plugin manager)
- `@kolbo/mcp` version: (run `npm view @kolbo/mcp version`)

**Anything else?**
Logs, screenshots, related issues.
