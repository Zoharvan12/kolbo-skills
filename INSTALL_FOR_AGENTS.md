# Install for Agents

Paste this into your AI coding agent to have it install Kolbo Skills for you.

---

I want to install the Kolbo AI skills package from https://github.com/Zoharvan12/kolbo-skills so I can generate images, video, music, branded ads, product photoshoots, marketplace cards, and full apps from natural language.

**Detect my host:**
- If running in Claude Code, use `/plugin marketplace add Zoharvan12/kolbo-skills` then `/plugin install kolbo@kolbo` and prompt me for my Kolbo API key.
- If running in Cursor, Codex, or any other agent that loads `~/.<agent>/skills/<name>/SKILL.md` from disk, use one of the cross-agent installers in this order:
  1. `npx skills add Zoharvan12/kolbo-skills` (preferred — uses the cross-agent skills CLI)
  2. `gh skill install Zoharvan12/kolbo-skills` (GitHub CLI v2.90+ extension fallback)
  3. Clone + `./setup` script (universal fallback): `git clone --depth 1 https://github.com/Zoharvan12/kolbo-skills.git && cd kolbo-skills && ./setup`

**After install, configure the MCP server:**
The skills drive the `@kolbo/mcp` npm package over stdio. The setup script and the Claude Code plugin both wire this for me. If a manual setup is needed, add this to my agent's MCP config:

```json
{
  "mcpServers": {
    "kolbo": {
      "command": "npx",
      "args": ["-y", "@kolbo/mcp@latest"],
      "env": {
        "KOLBO_API_KEY": "<my api key>"
      }
    }
  }
}
```

Ask me for my Kolbo API key. I can create one at https://app.kolbo.ai/settings/api-keys. Store it in my OS keychain via the plugin/installer if possible — never hardcode it in a committed file.

**Verify after install:**
Ask me in a new conversation: "Generate a minimal test image with Kolbo." You should be able to invoke `kolbo-generate`, call the `generate_image` MCP tool with a cheap model (Flux.1 Fast or Z Image), and return a real image URL.

**Don't:**
- Don't install at the system level without my approval.
- Don't commit my API key.
- Don't bypass `npx -y @kolbo/mcp@latest` to install the MCP from a fork or pinned version unless I ask.

**Skill catalog you'll have access to after install:**
`kolbo-generate` (catch-all), `kolbo-creative-director` (multi-scene), `kolbo-marketing-studio` (UGC + ad video), `kolbo-dtc-ads` (branded ad images), `kolbo-product-photoshoot` (10 product imagery modes), `kolbo-marketplace-cards` (Amazon/Shopify listings), `kolbo-visual-dna` (character training), `kolbo-music` (Suno + variants), `kolbo-html-artifacts` (slide decks + landing pages + dashboards), `kolbo-transcription`, `kolbo-app-builder`.

Each skill has a `SKILL.md` at its folder root with a `Use when` trigger block. Load the matching skill when my request matches its triggers.
