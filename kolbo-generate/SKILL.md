---
version: 0.4.0
name: kolbo-generate
description: |
  Generate any image / video / music / TTS / sound / 3D content via the Kolbo AI
  MCP server. Default entry point for generic "make me X" requests across
  100+ models (GPT Image, Nano Banana, Seedance, Veo, Kling, Flux, Suno, ...).

  Use when: "generate", "create", "make me a", "edit", "animate", "transcribe",
  any model name by itself (Flux, Kling, Suno, etc.), generic single-output
  generation requests.

  Chain: pair with kolbo-visual-dna (consume vdna_id via `visual_dna_ids`),
  hand off multi-output requests to kolbo-creative-director, hand off
  Marketing Studio / DTC / product / marketplace work to the matching skill,
  hand off HTML artifacts to kolbo-html-artifacts.

  NOT for: 2+ related outputs (use kolbo-creative-director), branded ad video
  (use kolbo-marketing-studio), brand product imagery (use kolbo-product-photoshoot),
  marketplace cards (use kolbo-marketplace-cards), HTML artifacts (use
  kolbo-html-artifacts), full React apps (use kolbo-app-builder).
argument-hint: "[prompt-or-command] [--model NAME] [--image <path>] [--video <path>]"
allowed-tools: Bash, Read, Write, Edit
---

# Kolbo Generate — Catch-All Generation Entry Point

Direct access to the Kolbo AI creative platform via MCP tools. Use them to generate and deliver real content — do NOT just describe what you would create.

> 🚫 **Don't dump generated URLs as bare text or markdown links in chat** — the UI renders artifacts as a gallery tile + canvas. Refer by description ("the rainy scene"), store URLs in `.kolbo/production.md`. INLINE `![](url)` images ARE allowed for catalog-style replies (per-item thumbs in numbered lists).

## Step 0 — Bootstrap

Once per conversation, before any other Kolbo tool call:

1. **Run `check_credits`.** If it fails with "Session expired" / "Not authenticated", ask the user to run `kolbo auth login` (or their branded CLI command like `sapir auth login`) and reload the editor.
2. **If `list_models` returns empty**, MCP isn't wired — same fix.
3. Remember the credit balance for the session; don't re-check every turn.

## Routing — Read These on Demand

| If the user wants… | Read first |
|---|---|
| Seedance 2 video | `references/models/seedance.md` |
| GPT Image 2 image | `references/models/gpt-image.md` |
| Nano Banana / Gemini image | `references/models/nano-banana.md` |
| Veo 3 / 3.1 video | `references/models/veo.md` |
| Any other generation model (Flux, Kling, Sora, Hailuo, ElevenLabs, …) + universal prompt-engineering basics | `references/models/prompt-copilot.md` |
| Confirm cost / validate aspect / resolution / duration against model caps | `references/workflows/cost-and-validation.md` |
| Start or continue a multi-step production | `references/workflows/production-log.md` |
| Browse, manage, or present existing media library items | `references/workflows/media-library.md` |
| Auth / MCP / 429 issue | `references/workflows/troubleshooting.md` |
| 2+ related outputs (storyboard, campaign batch, multi-angle) | → switch to the `kolbo-creative-director` skill |
| Visual DNA / character consistency / `@name` syntax | → switch to the `kolbo-visual-dna` skill |
| UGC ad / TV spot / branded video | → switch to `kolbo-marketing-studio` |
| Composed DTC ad images | → switch to `kolbo-dtc-ads` |
| Brand product imagery (Pinterest / hero banner / ad pack) | → switch to `kolbo-product-photoshoot` |
| Amazon / Shopify marketplace cards | → switch to `kolbo-marketplace-cards` |
| Music (Suno + variants) | → switch to `kolbo-music` |
| HTML presentations / landing pages / dashboards | → switch to `kolbo-html-artifacts` |
| Transcription / audio + video analysis | → switch to `kolbo-transcription` |
| Full React app generation | → switch to `kolbo-app-builder` |

## Available MCP Tools (51 total)

### Generation

| Tool | Description |
|------|-------------|
| `generate_image` | Single image from a text prompt. Supports Visual DNA, moodboards, reference images, web-search grounding. |
| `generate_image_edit` | Edit/transform an existing image. Pass `source_images` + edit prompt. |
| `generate_creative_director` | **2–8 related images or videos as one coherent set** — handled by the `kolbo-creative-director` skill. |
| `generate_video` | Text-to-video. Does **not** support Visual DNA — use `generate_elements` for character-consistent video. |
| `generate_video_from_image` | Animate a still. Prompt describes motion, not subject. |
| `generate_video_from_video` | Restyle/transform an existing video. Keeps original motion. |
| `generate_elements` | Reference-driven video. **Primary route for DNA → video.** |
| `generate_first_last_frame` | Keyframe interpolation between two frames. |
| `generate_lipsync` | Lipsync audio to an image or video face. |
| `generate_music` | Music generation — see `kolbo-music`. |
| `generate_speech` | TTS. Use `list_voices` to pick a voice. |
| `generate_sound` | Sound effects. |
| `generate_3d` | 3D models from text / single image / multi-view. Returns GLB/FBX/OBJ/USDZ. |
| `transcribe_audio` | Audio/video → text + SRT + word-by-word SRT — see `kolbo-transcription`. |

### Discovery, Library, Visual DNA, Moodboards, Chat, App Builder, Publishing

| Tool | Purpose |
|------|---------|
| `list_models` / `list_voices` / `check_credits` / `get_generation_status` / `get_session_usage` | Discovery + status |
| `upload_media` / `list_media` / `get_media` / `get_media_stats` / `favorite_media` / `unfavorite_media` / `delete_media` / `restore_media` / `permanently_delete_media` / `move_media` / `bulk_*_media` / `*_media_folder` | Media library — see `references/workflows/media-library.md` |
| `create_visual_dna` / `list_visual_dnas` / `get_visual_dna` / `delete_visual_dna` | Visual DNA — see `kolbo-visual-dna` skill |
| `list_moodboards` / `get_moodboard` / `list_presets` | Style overlays |
| `chat_send_message` / `chat_list_conversations` / `chat_get_messages` | Kolbo chat with optional `media_urls` (up to 10 per call) |
| `app_builder_*` (9 tools) | Full React app gen — see `kolbo-app-builder` skill |
| `publish_html_artifact` | Publish HTML / SVG / Mermaid to `sites.kolbo.ai` — see `kolbo-html-artifacts` skill |

## ⚠️ If the User Names a Tool, USE THAT TOOL (HARD RULE)

A user-named tool — in any language — overrides every other rule.

| User said (any language) | Use exactly |
|---|---|
| "director", "creative director", **"במאי"**, "ad set", "campaign tool", "storyboard tool" | `generate_creative_director` (route to `kolbo-creative-director` skill) |
| "image edit", "edit", "modify", "remove background", **"עריכת תמונה"** | `generate_image_edit` |
| "elements" / **"אלמנטים"** | `generate_elements` |
| "first/last frame" / **"פריימים"** | `generate_first_last_frame` |
| "lipsync" / **"ליפסינק"** | `generate_lipsync` |

**Mixed signals — named tool always wins.** "Image edit with the director tool to make 4 angles" → `generate_creative_director`.

## ⚠️ Generate vs Edit (when the user did NOT name a tool)

| User intent | Action | NOT this |
|-------------|--------|----------|
| "Create a video from scratch" | `generate_video` | — |
| "Edit / Cut / Trim / Add subtitles / Remove silence / Convert to 9:16" | Load `video-production` skill → FFmpeg | ❌ `generate_video` |
| "Create motion graphics / animated text / title sequence" | Load `remotion-best-practices` skill | ❌ `generate_video` |
| "Animate this image" | `generate_video_from_image` | — |
| "Restyle this video as anime" | `generate_video_from_video` | — |
| "Modify THIS one image" — change bg, remove object, recolor | `generate_image_edit` | ❌ Not for multi-output |
| "4 angles / poses / views of this character" | → switch to `kolbo-creative-director` | ❌ Don't loop `generate_image_edit` |
| "4 variations of THIS exact image" (same prompt, different seeds) | `generate_image` with `num_images=4` | ❌ Not `generate_image_edit` |

## Core Workflow

1. **Check credits** ONCE per conversation (Step 0).
2. **Discover models** with `list_models` using a `type` filter — but **skip when the user names a specific model**.
3. **Pick the model**:
   - User named one → use it.
   - Auto-select → only from "Auto-selectable" section (models with a `summary`). Cheapest fit. Prefer `[RECOMMENDED]` when cost is similar.
   - Never auto-select from "Named-only" section.
4. **Validate inputs** against model caps — see `references/workflows/cost-and-validation.md`.
5. **How calls work**: each tool blocks until generation is fully complete. Images: seconds. Video: minutes. Multiple tool calls in one response run concurrently. If a call times out, use `get_generation_status` with the returned generation ID.
6. **Share the URL** after success. Never fabricate URLs.

Model types for `list_models`: `text_to_img`, `image_editing`, `text_to_video`, `img_to_video`, `draw_to_video`, `video_to_video`, `elements`, `firstlastgenerations`, `lipsync-image`, `lipsync-video`, `music_gen`, `text_to_speech`, `text_to_sound`, `stt`, `text`, `3d_text_to_model`, `3d_image_to_model`, `3d_multi_image_to_model`, `3d_world`.

## Cost Awareness — Quick Rules

Full tables + formulas in `references/workflows/cost-and-validation.md`. Quick rules:

- **Skip cost confirmation** when user already specified model + count + duration, OR when single generation < 5 credits.
- **Required cost confirmation** otherwise: one-line summary, suggest cheaper alternative, wait for confirm.
- **Batch totalling 100+ credits**: run `check_credits` first.
- **Quote real cost**: after firing, log `credits_used` (from the tool result) to `.kolbo/production.md` — never `base × count`.

## Rate Limiting & Batch Generation

- `generate_image`: 30/min. Other generation tools: 10/min per type. 300/min global. `upload_media`: 300/min, no credit cost.
- **⚠️ NEVER re-fire a generation you already called.** Aborted / timed-out calls still process server-side. Run `get_generation_status` before retrying.
- **Batch ≤10 items**: output ALL tool calls in one response — they run concurrently.
- **Bulk >10 items**: real-world ceilings — `generate_image` 8–10 in-flight, video tools 3–5. Fire one batch → wait → fire next. Persist every `generation_id` in `.kolbo/production.md`.
- **`upload_media` external URLs first.** `files`/`source_images`/`image_url` only accept Kolbo-hosted URLs reliably.

## 🛑 Runaway-Loop Guard — ONE Generation per Requested Item (CRITICAL)

When the user asks for **one specific change**, the answer is **a single tool call**. After URLs return, **stop**. Surface and wait.

NOT allowed: fire the same tool 3+ times in a single turn (unless user asked for "N variations"), re-fire because the result might not be exactly right, auto-retry on success, fire 5+ parallel `generate_video*` calls speculatively.

**Only re-fire when:** user explicitly asked for variations with a count, OR previous call returned `failure.retryable === true` (ONE retry), OR previous call returned `completed` but `urls.length === 0` (ONE retry).

## ⚠️ Editing an Existing Video → ONE Call, Not Frames-First (CRITICAL)

Existing video → modify → **single `generate_video_from_video` call** with source video URL + edit prompt. **Use a TRUE video-to-video model** (image-to-video models reject with `WRONG_MODEL_TYPE`). Valid: `wan/2-7-videoedit`, `happyhorse/video-edit`, `kling-video/o3-video-to-video`, or any model whose DB `type` includes `video_to_video`.

## ⚠️ Detecting Failed Generations (CRITICAL)

Three failure modes — treat ALL as failure:
1. **Tool returns `error`** — explicit. Surface, suggest retry, log `generation_id`.
2. **Tool returns `completed` but `urls` is empty** — silent failure. Tell user "completed without an output — retrying" and re-fire ONCE. Do NOT log to `.kolbo/production.md`. Do NOT claim it worked.
3. **Tool hangs / never returns** — call `get_generation_status(generation_id)` IMMEDIATELY.

**Always:** don't celebrate before reading the result; partial batches list failed items + reasons + successful count ("6 of 8 ready", not "videos ready"); never auto-retry without surfacing; never log failures to `.kolbo/production.md`.

## ⚠️ Generated URLs in Chat (CRITICAL)

Chat renders markdown natively. `![alt](url)` = inline image. `[label](url)` = labeled link with preview.

- **Catalog-style replies** (numbered lists): embed `![alt](url)` so each item shows inline.
- **Conversational replies** ("4 shots ready"): keep prose short; canvas chip already shows gallery.

Avoid bare URL dumps and HTML `<table>` grids. Always record every URL in `.kolbo/production.md` — see `references/workflows/production-log.md`.

## Speech / Sound / 3D — Quick Rules

- **TTS** — call `list_voices` first, pass `voice_id` to `generate_speech`. For multilingual, pick a voice that supports the language.
- **Sound effects** — describe physically, not emotionally. "Heavy wooden door creaking open slowly, echoing in a stone hallway" not "creepy atmosphere".
- **3D** — three modes: text-only, single image, multi-view. Returns GLB/FBX/OBJ/USDZ. Use `list_models({ type: "three_d" })` to discover.

## Limitations & Safety

- **Real people**: never identify specific individuals in photos, even public figures.
- **NSFW**: Kolbo enforces content safety at the model level. Failed on safety → rephrase, don't retry identically.
- **Copyright**: style references are fine ("in the style of Studio Ghibli"); verbatim reproduction is not.
- **No fabricated URLs**: only share URLs that actually came back from a tool call.

---

If you still don't know which `references/` file to load, default to `references/models/prompt-copilot.md` for generation prompts or `references/workflows/cost-and-validation.md` for cost/validation, or just keep going with this core file's rules.
