# Kolbo AI Skills

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-0.4.0-green.svg)](./VERSION)
[![Skills](https://img.shields.io/badge/skills-11-blueviolet.svg)](#skills)

AI agent skills for **image / video / music / 3D / branded ads / product photography / marketplace listings / full apps** via [Kolbo AI](https://kolbo.ai). Works with Claude Code, Cursor, Codex, and any other AI coding agent that loads Markdown-based skills.

100+ models behind Smart Select routing (Nano Banana, GPT Image 2, Seedance 2, Veo 3.1, Kling, Flux, Suno, ElevenLabs, …), Visual DNA for face-faithful identity, Marketing Studio for UGC + DTC ads, 10-mode product photoshoot, Amazon/Shopify marketplace cards, HTML artifact publishing, full React app generation.

## Install

Pick one. Each method handles the [`@kolbo/mcp`](https://www.npmjs.com/package/@kolbo/mcp) server setup and the API-key prompt as part of skill setup.

### Claude Code marketplace — recommended

Inside Claude Code:

```
/plugin marketplace add Zoharvan12/kolbo-skills
/plugin install kolbo@kolbo
```

You'll be prompted for your Kolbo API key once (stored in your OS keychain).

### `npx skills` — cross-agent

Works with Claude Code, Cursor, Codex, and any agent that picks up `~/.<agent>/skills/<name>/SKILL.md`. Requires Node.js.

```bash
npx skills add Zoharvan12/kolbo-skills
```

### `gh skill install` — cross-agent

GitHub CLI v2.90+ extension.

```bash
gh skill install Zoharvan12/kolbo-skills
```

### Setup script

Universal fallback. Clones the repo locally and symlinks each skill into the agent's expected directory.

```bash
git clone --depth 1 https://github.com/Zoharvan12/kolbo-skills.git
cd kolbo-skills
./setup
```

The script auto-detects Claude Code / Cursor / Codex (override with `--host <agent>`), prompts for your Kolbo API key, and symlinks each skill subdirectory into place. Idempotent.

More options in [INSTALL.md](./INSTALL.md). Agent-driven install (paste into your agent): [INSTALL_FOR_AGENTS.md](./INSTALL_FOR_AGENTS.md).

## Skills

| Skill | Invoke | Description |
|---|---|---|
| [`kolbo-generate`](./kolbo-generate) | `/kolbo:generate` | Catch-all image / video / music / TTS / sound / 3D generation across 100+ models. Default entry point for "generate X" requests. |
| [`kolbo-creative-director`](./kolbo-creative-director) | `/kolbo:creative-director` | 2–8 related outputs from one brief — storyboards, ad campaigns, character lookbooks, multi-angle/multi-pose sets. Replaces parallel `generate_image` loops. |
| [`kolbo-marketing-studio`](./kolbo-marketing-studio) | `/kolbo:marketing-studio` | Branded ad **video** — 9 modes: UGC, unboxing, tutorial, product review, TV spot, product showcase, virtual try-on, wild card. Defaults to 9:16 / no captions / no watermarks for UGC. |
| [`kolbo-dtc-ads`](./kolbo-dtc-ads) | `/kolbo:dtc-ads` | Composed brand ad **images** — brand kit + ad format + optional avatar / product / reference media. |
| [`kolbo-product-photoshoot`](./kolbo-product-photoshoot) | `/kolbo:product-photoshoot` | Brand product imagery — 10 modes (studio, lifestyle, Pinterest pin, hero banner, social carousel, ad creative pack, virtual try-on, conceptual, restyle). |
| [`kolbo-marketplace-cards`](./kolbo-marketplace-cards) | `/kolbo:marketplace-cards` | Amazon / Shopify / eBay listing visuals — main image + secondary + A+ content modules. Compliance-aware (pure white bg, no text, no props on main). |
| [`kolbo-visual-dna`](./kolbo-visual-dna) | `/kolbo:visual-dna` | Train a Visual DNA — a reusable, face-faithful identity model. Returns a `vdna_id` consumable by other skills. |
| [`kolbo-music`](./kolbo-music) | `/kolbo:music` | Music generation (Suno + variants) — full songs, lyrics, instrumentals, jingles, scores, lo-fi beats, trailers. |
| [`kolbo-html-artifacts`](./kolbo-html-artifacts) | `/kolbo:html-artifacts` | HTML artifacts — presentations / slide decks, landing pages, dashboards, data viz, interactive widgets, mini-games. Publishable to `sites.kolbo.ai`. |
| [`kolbo-transcription`](./kolbo-transcription) | `/kolbo:transcription` | Audio/video transcription (SRT + word-by-word) + multimodal analysis routing (Gemini-via-chat vs hybrid). |
| [`kolbo-app-builder`](./kolbo-app-builder) | `/kolbo:app-builder` | Generate full React apps with GitHub repo + Supabase + live deployment in one flow. |

### Skills chain

Skills communicate through return values, not implicit state:

- `kolbo-visual-dna` returns `vdna_id` → `kolbo-generate`, `kolbo-creative-director`, `kolbo-marketing-studio`, `kolbo-product-photoshoot`, `kolbo-marketplace-cards` consume via `visual_dna_ids` MCP param.
- `kolbo-marketing-studio` brand-kit research returns a brand-kit slug at `.kolbo/brand-kits/<slug>.md` → other skills `Read` it before generating.
- `kolbo-creative-director` returns frames → `kolbo-generate` animates each frame via `generate_video_from_image`.

When a request needs multiple skills ("train Visual DNA on these photos AND make an ad of me"), run them in order — finish one, capture the id, hand it to the next.

## Quick Reference

| What you want | Skill |
|---|---|
| Generate any image / video / music / sound / 3D from a prompt | `kolbo-generate` |
| 2–8 related outputs (character sheet, multi-angle, ad pack, storyboard) | `kolbo-creative-director` |
| UGC ad / TikTok / Reels / unboxing / product review / TV spot | `kolbo-marketing-studio` |
| Composed brand ad image (brand kit + format + product) | `kolbo-dtc-ads` |
| Pinterest pin / hero banner / lifestyle shot / ad creative pack | `kolbo-product-photoshoot` |
| Amazon main + 5 secondary + 7 A+ content modules | `kolbo-marketplace-cards` |
| Train a face-faithful character | `kolbo-visual-dna` |
| Song / jingle / instrumental / cinematic score / lo-fi beat | `kolbo-music` |
| Slide deck / pitch deck / landing page / dashboard / data viz / mini-game | `kolbo-html-artifacts` |
| Transcribe audio/video → SRT / word-by-word / text | `kolbo-transcription` |
| Build me a todo app / SaaS / waitlist page (full React) | `kolbo-app-builder` |

## Architecture

Every skill drives the [`@kolbo/mcp`](https://www.npmjs.com/package/@kolbo/mcp) server. The MCP server holds the authenticated HTTP connection to `api.kolbo.ai`, exposes 51 tools (image/video/music/3D/chat/Visual DNA/media library/artifact publishing/App Builder), and skills route natural-language intent to the right tool with the right defaults.

```
Claude Code / Cursor / Codex → stdio → @kolbo/mcp → HTTPS → api.kolbo.ai
                              ↑
                       skills/SKILL.md route requests
```

API keys are set once via the plugin's user-config prompt (Claude Code), via `KOLBO_API_KEY` env var (Codex / Cursor / manual), or via the `./setup` script.

## License

MIT — see [LICENSE](./LICENSE).
