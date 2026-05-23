# Install Kolbo Skills

11 skills ship in this repo:

- **`kolbo-generate`** — catch-all image / video / music / TTS / sound / 3D generation across 100+ Kolbo models
- **`kolbo-creative-director`** — 2–8 related outputs from one brief (storyboards, ad campaigns, character lookbooks)
- **`kolbo-marketing-studio`** — branded ad video (9 modes — UGC, unboxing, TV spot, product review, …)
- **`kolbo-dtc-ads`** — composed brand ad images (brand kit + ad format + avatar + product)
- **`kolbo-product-photoshoot`** — brand product imagery (10 modes — studio, lifestyle, Pinterest pin, hero banner, ad pack, …)
- **`kolbo-marketplace-cards`** — Amazon/Shopify listing visuals (main + secondary + A+ content)
- **`kolbo-visual-dna`** — train a face-faithful identity, returns `vdna_id`
- **`kolbo-music`** — Suno + variants — songs, lyrics, instrumentals, jingles, scores
- **`kolbo-html-artifacts`** — presentations, landing pages, dashboards, mini-games — publishable to `sites.kolbo.ai`
- **`kolbo-transcription`** — SRT + word-by-word + multimodal A/V analysis routing
- **`kolbo-app-builder`** — full React app gen with GitHub + Supabase + live deployment

They chain via return values (no implicit state): `kolbo-visual-dna` returns `vdna_id` → other skills consume it via `visual_dna_ids`. Marketing/research skills persist brand kits at `.kolbo/brand-kits/<slug>.md` → other skills `Read` them.

## Prerequisites

A Kolbo account. Create one at [app.kolbo.ai](https://app.kolbo.ai). Free tier works for testing; some video / 3D / virality models require Basic+.

The skills drive the `@kolbo/mcp` server, which is auto-installed via `npx -y @kolbo/mcp` by every install method below — you don't install it separately.

## Option 1 — Claude Code marketplace (recommended for Claude Code users)

Inside Claude Code:

```
/plugin marketplace add Zoharvan12/kolbo-skills
/plugin install kolbo@kolbo
```

Pulls the plugin manifest from `.claude-plugin/marketplace.json` and registers all 11 skills as `/kolbo:generate`, `/kolbo:marketing-studio`, etc. You'll be prompted for your **Kolbo API key** once and it's stored in your OS keychain.

## Option 2 — `npx skills` (cross-agent)

Works with Claude Code, Cursor, Codex, and any agent that picks up `~/.<agent>/skills/<name>/SKILL.md`. Requires Node.js.

```bash
npx skills add Zoharvan12/kolbo-skills
```

Installs all 11 skills. The `skills` CLI auto-detects the host agent and writes each skill to the right path. Set `KOLBO_API_KEY` env var (or follow the prompt).

## Option 3 — `gh skill install` (cross-agent)

GitHub CLI v2.90+ extension. Same coverage as `npx skills`.

```bash
gh skill install Zoharvan12/kolbo-skills
```

## Option 4 — Setup script

Universal fallback. Clones the repo locally and symlinks each skill into the agent's expected directory.

```bash
git clone --depth 1 https://github.com/Zoharvan12/kolbo-skills.git
cd kolbo-skills
./setup
```

The script auto-detects Claude Code / Cursor / Codex (override with `--host <agent>`), prompts for your Kolbo API key, writes a per-agent MCP config pointing at `npx -y @kolbo/mcp`, and symlinks each skill subdirectory into place. Idempotent.

## Option 5 — Manual MCP wiring (Claude Desktop, Cursor, raw Claude Code)

Add to your agent's MCP config (`~/.claude_desktop_config.json`, Cursor settings → MCP, etc.):

```json
{
  "mcpServers": {
    "kolbo": {
      "command": "npx",
      "args": ["-y", "@kolbo/mcp@latest"],
      "env": {
        "KOLBO_API_KEY": "kolbo_live_..."
      }
    }
  }
}
```

Then copy the skill folders you want into your agent's skill directory:

```bash
git clone --depth 1 https://github.com/Zoharvan12/kolbo-skills.git
mkdir -p ~/.claude/skills/   # adjust path for your agent
cp -R kolbo-skills/kolbo-* ~/.claude/skills/
```

## Verify

In your agent, ask:

> "Generate a minimal test image with Kolbo."

The agent should invoke `kolbo-generate`, call the `generate_image` MCP tool with a cheap model (Flux.1 Fast or Z Image), and deliver the URL.

If nothing happens:
1. Check `check_credits` works (auth wired correctly).
2. Check `list_models` returns models (MCP server reachable).
3. See [troubleshooting](https://docs.kolbo.ai/kolbo-code/troubleshooting).

## Updating

| Method | Update command |
|---|---|
| Claude Code marketplace | `/plugin update kolbo@kolbo` |
| `npx skills` | re-run `npx skills add Zoharvan12/kolbo-skills` |
| `gh skill install` | `gh skill update Zoharvan12/kolbo-skills` |
| Setup script | `cd kolbo-skills && git pull && ./setup` |
| Manual | `git pull` in the cloned repo |

The `@kolbo/mcp` server auto-updates on every `npx -y` invocation — the skill files (this repo) are the only thing pinned per install.
