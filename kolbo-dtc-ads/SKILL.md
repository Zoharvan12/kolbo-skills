---
version: 0.9.3
name: kolbo-dtc-ads
description: |
  Compose a brand ad IMAGE from 5 building blocks: brand kit + ad format
  (headline-driven, bullet-points, us-vs-them, before/after, founder statement,
  lifestyle hero, testimonial, pattern interrupt, …) + optional avatar +
  optional product + optional reference media.

  Use when: "headline ad", "founder ad", "before/after ad", "bullet points ad",
  "us vs them comparison", "DTC ad image", "branded ad creative",
  "make me an ad image", "ad for [brand]", "[brand]-style ad creative".

  Chain: optional brand-kit lookup (.kolbo/brand-kits/SLUG.md), pair with
  kolbo-visual-dna for a specific presenter, kolbo-product-photoshoot for the
  product hero, or kolbo-creative-director for multi-variant ad packs.

  NOT for: ad VIDEO (use kolbo-marketing-studio), product photography
  without ad-format structure (use kolbo-product-photoshoot), marketplace
  listings (use kolbo-marketplace-cards).
argument-hint: "[format] [brief] [--brand-kit SLUG] [--avatar <vdna_id>] [--product <path>]"
allowed-tools: Bash, Read, Write, Edit
---

<!-- AUTO-GENERATED from kolbo-code packages/opencode/skills/kolbo — DO NOT EDIT.
     Edit the canonical skill and let .github/workflows/sync-skill-to-plugin.yml regenerate this. -->

# Kolbo DTC Ads

## Step 0 — Bootstrap

Once per conversation, before any other Kolbo tool call:

1. **Run `check_credits`.** If it fails with "Session expired" / "Not authenticated", ask the user to run `kolbo auth login` (or their branded CLI command like `sapir auth login`) and reload the editor.
2. **If `list_models` returns empty**, MCP isn't wired — same fix.
3. Use the balance ONLY for the low-balance check at this moment. **Never quote a "credits remaining" number later in the session** — coding/chat usage also deducts credits, so any remembered or computed balance is stale. Report only what each generation cost (`credits_used`); if the user asks what's left, run `check_credits` fresh right then.

If the user is on a whitelabel build (`sapir`, etc.), they must use their branded command — not `kolbo`. See `references/workflows/troubleshooting.md`.

## 🎬 Confirm the Creative Brief BEFORE Generating (CRITICAL — read first)

Never fire a paid generation the moment the user says "make X". First **present the brief back as a confirmation the user can change** — this is the single most important interaction. It gives the user control over what gets created and what it costs, instead of silently spending credits on defaults.

**Before ANY paid image / video / music / speech / 3D generation**, unless the user has *explicitly* dictated every key parameter in this message, ask ONE labeled question (the UI renders it as an options card) confirming:

- **Model** — your recommended pick as the default option, plus 1–2 alternatives (with their credit cost).
- **Aspect ratio** — e.g. `1:1 / 9:16 / 16:9` (offer the sensible default first).
- **Count** — how many (1 / 4 / …).
- **Resolution / quality / duration** — where the model supports it.
- **Creative direction** — style / mood / scene, when the user was vague ("4 cats" → offer style options: photoreal / illustrated / cinematic / surprise-me).
- **Credit cost** — state the total (`✦ N credits`) right in the question so cost is never a surprise.

Then generate **only** with the confirmed parameters. If the user changes an option, use the change. This mirrors the approval-card flow: propose → let them adjust → confirm → generate.

**Only skip the brief confirmation when** the user's message already pins model + aspect + count + creative direction (e.g. "generate 4 photoreal tabby cats, 1:1, z-image/turbo") — then just state the cost one-liner and fire. A low credit cost is **not** a reason to skip: cheap ≠ no-confirmation. What matters is whether the user actually chose the parameters.

For multi-scene / batch work this pairs with `generate_creative_director` (see below) — still confirm the brief first.

## ⚠️ Load the matching skill BEFORE generating (HARD RULE)

Do **not** call `generate_*` / `generate_elements` / `generate_image_edit` until you have loaded the matching skill **in this turn** (the `skill` tool for bundled skills, and/or Read of the `references/` file). "I already know this" is not a load. Users will never invoke these skills themselves.

| About to call / user intent | `skill` tool | Also Read |
|---|---|---|
| `generate_elements` **or** any video with Visual DNA **or** Seedance 2 / 2.5 / WAN / MiniMax H3 / Gemini video | `elements-prompting` | `references/models/seedance.md` (+ `seedance25.md` if 2.5) and `references/workflows/visual-dna.md` when DNA is in play |
| `generate_image` / `generate_image_edit` | `image-prompting-guide` | `references/models/gpt-image.md` / `nano-banana.md` / `prompt-copilot.md` as the model requires. Complex stills / identity lock: `references/workflows/prompt-structure.md` |
| `generate_video*` that is **not** Elements/DNA (Kling, Veo, Sora, Grok, Hailuo, generic t2v/i2v) | `video-prompting-guide` | matching `references/models/*.md` |
| `generate_music` | `music-prompting` | `references/models/music.md` |
| UGC / phone-shot / selfie / "authentic" / must-not-look-like-an-ad | — | `references/workflows/ugc-smartphone.md` |
| Marketing / TV spot / branded video / unboxing / product review | — | `references/workflows/marketing-studio.md` |
| DTC ad image | — | `references/workflows/dtc-ads.md` |
| Product photoshoot / hero / lifestyle / try-on | — | `references/workflows/product-photoshoot.md` |
| Thumbnail / cover | — | `references/workflows/thumbnails.md` |
| Marketplace listing cards | — | `references/workflows/marketplace-cards.md` |
| Film / episode / connected scene | — | `references/workflows/filmmaking.md` + `production-planning.md` |

## ⚠️ Visual DNA `@Name` in the prompt (HARD RULE — always on)

Passing `visual_dna_ids` is **not enough**. For every DNA in that array you MUST also write `@ExactStoredName` in the prompt text (the `name` from `list_visual_dnas` / `create_visual_dna`). The engine binds identity by parsing `@tags`. No `@tag` → the DNA is wasted.

- Right: `visual_dna_ids: ["vdna_…"]` + prompt `@Zohar walks into frame`
- Wrong: `Zohar's`, `Zohar`, `the left man`, `the man on the LEFT`, `Visual DNA anchors: the man on the LEFT…` — none of these bind
- Never invent a role label or possessive as a substitute for `@Name`
- Same rule for moodboards: `#ExactBoardName`

**Rewrite / compile never drops a tag.** If the user, a prior prompt, or `list_visual_dnas` already has `@gal_suit` / `@yonatan` / `#Board`, the Locked Intro you write MUST still contain those exact tokens in CAST **and** in every shot they appear in. Do not "clean" them into first names, `@Image 1 (Lee)`, "the singer", or a SCENE CONTEXT / ACTIVE REFERENCES block with no `@`. A compile that loses a tag is a failed turn — put the tags back before calling `generate_*`.

Before `generate_elements` / any DNA video: for each id in `visual_dna_ids`, confirm the prompt string includes `@` + that DNA's stored `name`. Missing even one → fix the prompt, do not fire.

Resolve names with `list_visual_dnas` first. Full binding rules: `references/workflows/visual-dna.md`.

**Every still on a DNA can reach the model.** Kolbo now sends all of a DNA's reference images that fit the model's image-slot cap (user uploads first, then one still per DNA, then leftovers round-robin). If a DNA only gets one leftover slot and has no real character sheet, unused stills become a white grid. Mixed-vibe stills or environment photos that contain a main character will confuse the generation — keep each DNA surgically clean. Create-and-pack rules: `references/workflows/visual-dna.md`.

## 📁 Projects — Where Work Lands (CRITICAL)

Everything in Kolbo — sessions, generations, media, docs — lives inside a PROJECT. Getting this wrong is the #1 user complaint ("my work went to the wrong project").

1. **User names a project** ("in my Acme project", "for the film") → call `list_projects` ONCE to resolve the name to an ObjectId, then pass that **same** id as `project_id` on **EVERY** subsequent `generate_*` / `upload_media` / `create_doc` / `chat_send_message` call in **this conversation**. There is no server-side sticky store — omitting it on any later call silently lands in the default "API Generations" bucket (`is_default: true`). Once resolved, treat that id as required for the rest of the conversation. Accounts often hold hundreds of projects, so pass `list_projects({ search: "acme" })` rather than listing everything; the list is paginated (50/page) and hides archived projects unless you pass `include_archived: true`.
2. **No project mentioned** → omit `project_id`; the default bucket is correct. Don't ask unless intent is ambiguous. If `list_sessions` already returned a `project_id` for the work you are continuing, keep passing that id.
3. **Work landed in the wrong project? MOVE it, never regenerate**: `move_session` relocates a whole session + all its media (works for any session type — the `session_id` from generation responses, chats, transcriptions); `move_media` / `bulk_move_media` / `move_folder_contents` relocate individual media items. Empty leftover sessions after a move: `delete_session` (soft-delete; `restore_session` undoes it). `rename_session` only changes the sidebar title.

## ⚠️ One session per plan bucket (HARD RULE)

Omitting `session_id` on a generate call creates a **new** Kolbo sidebar session. Do that only when the **plan** starts a new bucket — not per take, not per shot, not because you just called a tool.

Name buckets from the plan you already showed the user, then `rename_session` on first create:

| Bucket | What lives in it | Kind |
|---|---|---|
| `Cast` | every character sheet / character DNA | image |
| `Locations` | every environment | image |
| `Props` | hero products / vehicles (if any) | image |
| `Scene NN — <slug>` | that scene's video shots **and** retakes | video |

How to thread:

1. First generate of a bucket → omit `session_id`, read it from the result, immediately `rename_session` to the plan name (`Cast`, `Locations`, `Scene 03 — rooftop chase`).
2. Every later generate in that bucket (more characters, another environment, shot 2, "make it darker", redo take 3) → pass that **same** `session_id`.
3. New scene or new concept → new session. Same scene / same cast pass → never a new session.
4. Image tools and video tools cannot share an id (server kinds differ). Cast/Locations stay image; scene clips stay video.

Write each session's `session_id` + plan name into `.kolbo/production.md` `### Sessions`. Do **not** mark the phase Approved or jump to the next bucket until the user confirms (or you asked a labeled GATE and they answered). Full rules: `references/workflows/production-planning.md` + `production-log.md`.

## Cost Awareness — Quick Rules

Full tables + formulas in `references/workflows/cost-and-validation.md`. Quick rules:

- **Skip the brief/cost confirmation ONLY** when the user's message already pins model + count + aspect + creative direction (see "Confirm the Creative Brief" above). Low cost alone is **not** a reason to skip — cheap generations still get the one labeled confirmation unless the user chose the parameters.
- **Otherwise confirm** via the labeled-question card: the parameters + the credit cost, suggest a cheaper alternative if one fits, wait for the user's pick. Never fire on defaults the user didn't choose.
- **Batch totalling 100+ credits**: run `check_credits` first.
- **Quote real cost**: after firing, log `credits_used` (from the tool result) to `.kolbo/production.md` — never `base × count`.
- **Video/lipsync `credit` is per-SECOND, not per-clip**: `total = credit × duration`. This is the universal rule for video/firstlast/elements/motion_graphic/cast types, not a per-model exception — `list_models` states it inline now. The one carve-out is a model with `flat_credit_by_resolution` set.
- **Never state "credits remaining" from arithmetic** (opening balance − generation costs). Coding/chat usage deducts credits too, so the math is always wrong. Report cost only; if the user asks for their balance, call `check_credits` fresh at that moment.

## 🛑 Runaway-Loop Guard — ONE Generation per Requested Item (CRITICAL)

When the user asks for **one specific change**, the answer is **a single tool call**. After URLs return, **stop**. Surface and wait.

You are NOT allowed to:
- Fire the same tool 3+ times in a single turn unless the user explicitly asked for "N variations".
- Re-fire because you think the result might not be exactly what the user wanted.
- Auto-retry on success.
- Fire 5+ parallel `generate_video*` calls speculatively.

**Only re-fire when:** user explicitly asked for variations with a count, OR previous call returned `failure.retryable === true` (ONE retry), OR previous call returned `completed` but `urls.length === 0` (ONE retry).

## ⚠️ Detecting Failed Generations (CRITICAL)

A generation can fail three ways. Treat ALL as failure:

1. **Tool returns `error`** — explicit. Surface, suggest retry, log `generation_id`.
2. **Tool returns `completed` but `urls` is empty** — silent failure (NSFW filter, model OOM, upstream 5xx). Tell user "completed without an output — retrying" and re-fire ONCE. Do NOT log to `.kolbo/production.md`. Do NOT claim it worked.
3. **Tool hangs / never returns** — MCP poll timed out. Call `get_generation_status(generation_id, wait=true)` IMMEDIATELY. The server might be done.

**Always:**
- Don't celebrate before reading the result. Verify `urls` is non-empty.
- Don't auto-retry without surfacing the failure. Partial batches: list failed items + reasons + successful count. Never "✅ all done!" on partials.
- Don't log failed items to `.kolbo/production.md`. Only successes.
- Surface the user's count. "6 of 8 ready", not "videos ready".

`failure` envelope structure + retry rules: `references/workflows/troubleshooting.md`.

## ⚠️ Generated URLs in Chat (CRITICAL)

Chat renders markdown natively. `![alt](url)` = inline image. `[label](url)` = labeled link with preview.

- **Catalog-style replies** (numbered lists of characters / scenes / products): embed `![alt](url)` so each item shows inline.
- **Conversational replies** ("4 shots ready"): keep prose short; canvas chip already shows gallery.

Avoid bare URL dumps and HTML `<table>` grids — canvas already provides a gallery.

**After `generate_creative_director` completes** — share results as individual URLs, one per scene. Do NOT create an HTML grid artifact.

**Always** park every successful URL + `session_id` in `.kolbo/production.md` as a **candidate**. Promote to Approved and advance the plan only after the user confirms — see `references/workflows/production-log.md`.

## DTC Ads — Composed Brand Image Workflow

Load this file when the user wants a **DTC ad image** composed from brand identity + ad format + optional avatar/product/reference media. For ad **video** see `workflows/marketing-studio.md`. For brand **product imagery** (Pinterest pin, hero banner, ad pack) see `workflows/product-photoshoot.md`. For marketplace listings see `workflows/marketplace-cards.md`.

### What This Is

A DTC ad is built from **5 composable blocks**:

1. **Ad format** — the structural template (headline-driven, bullet-points, us-vs-them, before-after, founder-statement, etc.). Defines the layout shape.
2. **Brand kit** *(optional)* — palette, fonts, logo, tone, voice. Keeps every ad in a campaign visually consistent.
3. **Avatar** *(optional)* — a presenter face (curated character or trained Visual DNA). Use when the brand has a specific founder, model, or recurring presenter.
4. **Product** *(optional)* — the item being sold. One product image, or a product brief from a URL.
5. **Reference media** *(optional)* — up to ~14 reference images to anchor style / composition / setting.

You don't need all 5. The minimum is: a **prompt** + an **ad format**. Everything else is opt-in based on what the user provides.

### End-to-End Flow

```
1. Pick an ad format     → ask user (labeled options, never auto-pick)
2. Pick / build brand kit → workflows/research-first.md persists to .kolbo/brand-kits/<slug>.md
3. Attach avatar          → workflows/visual-dna.md ("character" type DNA)
4. Attach product         → upload_media → reference_images
5. Attach reference media → upload_media → reference_images (up to ~14 total)
6. Generate               → generate_creative_director (multi-variant) or generate_image (single)
7. Deliver                → image URLs + brief one-line summary
```

### Ad Format — Always Ask Explicitly

Picking an ad format is **mandatory and creative** — don't auto-pick from the user's phrasing. The catalogue is small and the choice changes the layout shape dramatically. Always present labeled options:

| Format type | Examples |
|---|---|
| **Headline-driven** | Big hero phrase + small product. "Hero word" style. |
| **Bullet points** | 3–5 benefit bullets + product hero. SaaS / DTC standard. |
| **Us vs Them** | Side-by-side comparison column. Competitor takedown style. |
| **Before / After** | Split frame showing transformation. Great for skincare, fitness, home. |
| **Founder statement** | Founder portrait + quote + product. Trust-builder. |
| **Lifestyle hero** | Product in-use in an aspirational scene. No copy hero. |
| **Pure product** | Clean studio product shot with brand framing. |
| **Testimonial** | Customer quote + face + product. Social proof. |
| **Pattern interrupt** | Bold color block / typographic shock / surreal composition. Scroll-stopper. |

When the user says "make me an ad" without naming a format, offer 3 of these in a labeled question (don't dump all 9). Pick the 3 that best fit the product / brand / phase the user mentioned.

### Brand Kit Reuse

If `.kolbo/brand-kits/<slug>.md` exists for the brand (see `workflows/research-first.md`), **Read it first** and pull `primary_color`, `accent_color`, `text_color`, `bg_color`, `fonts`, `tone`, `target_user`, `logo_url`. Bake these into the prompt:

- Exact hex codes for every color (`#FF4D2E` not "orange")
- Named fonts (`Inter Bold for headline, Inter Regular for body`)
- Tone descriptors from `### Voice & Audience`
- Logo as `reference_images[0]` with `@image1` reference in the prompt ("place logo from `@image1` top-left at 8% width, no recolor")

If no brand kit exists and the user gives a brand URL, run `workflows/research-first.md` to build one. Then come back here.

### Avatar Workflow

For ads featuring a specific presenter (founder, recurring model, character):

1. **Check if a Visual DNA exists** — `list_visual_dnas`. Match by name or recent use.
2. **If yes** — pass `visual_dna_ids: ["<id>"]` and reference as `@<dna-name>` in the prompt.
3. **If no** and the user wants a specific person — create one per `workflows/visual-dna.md` (always generate 2 reference images first; lock single-token lowercase name).
4. **If no** and the brief doesn't need a specific face — skip the avatar entirely; the model will synthesize a plausible presenter.

### Product Workflow

For ads featuring a specific product:

| User provides | Do |
|---|---|
| **Product photo** (local file or URL) | `upload_media({ source })` → tag as `@image1` in prompt → log to `.kolbo/production.md` under `### Products` |
| **Product URL only** (no photo) | Run `workflows/research-first.md` first to scrape hero images + brand palette; re-host via `upload_media` → use Kolbo CDN URL |
| **Multiple angles** | Upload all in parallel (one `upload_media` call each) → pass all in `reference_images` → tag `@image1`, `@image2`, … per `workflows/visual-dna.md` reference-tagging rules |
| **Nothing — text only** | Ask once: "Do you have a product photo? It dramatically improves fidelity." If they say no, proceed text-only but warn quality may be lower |

**Always log products in `.kolbo/production.md`** so subsequent ads in the same workspace reuse the same CDN URL without re-uploading.

### Reference Media Cap

Up to **~14 reference images per call**. Higher = the model gets confused about which reference plays which role. Use **`@image1` / `@image2` / …** tags to bind each reference to a role:

```
Headline ad with @maya (the founder) holding @image1 (the product),
shot in the style of @image2 (lifestyle reference).
Match the palette from the brand kit (#FF4D2E primary, #1A1A1A text).
```

See `workflows/visual-dna.md` for the full tagging system.

### Generate

**Pick the right Kolbo MCP tool based on output count:**

- **Single ad image** → `generate_image` with `model: "<from list_models>"`. Use Nano Banana 2 for character/lifestyle, GPT Image 2 for layouts with dense on-image text or infographics, Nano Banana Pro for hero/brand-final assets.
- **Multi-variant set** (3–8 variants of the same ad concept with different palettes / angles / hooks) → `generate_creative_director` with `scene_count`. The director plans each variant's prompt internally.
- **Identical prompt, just different seeds** (rare for ads — usually you want varied direction) → `generate_image` with `num_images: 1–4`.

### Output Settings — Always Confirm

These materially change output and cost. Ask once, labeled options, before firing:

| Setting | Common options for ads |
|---|---|
| `aspect_ratio` | `1:1` (IG feed) / `9:16` (Reels / TikTok / Stories) / `4:5` (IG portrait) / `16:9` (YouTube, banners) / `1.91:1` (Facebook feed) |
| `resolution` | `1K` (drafts, fast iteration) / `2K` (standard delivery) / `4K` (hero / print) |
| Quantity | `1` (test) / `3–4` (variant exploration) / `8` (full ad pack via Creative Director) |

Default-to-cheapest when the user hasn't expressed a quality intent and the difference is ≤ 2× cost.

### Failure Handling

- **Content-policy refusal** → don't retry the same prompt. Suggest less-explicit phrasing or a different product framing.
- **Brand asset not loading** (logo URL 404, hex code typo) → fix the brand kit file, then retry.
- **Watermarks / extra text appearing uninvited** → add explicit prompt constraints: "NO captions, NO subtitles, NO watermarks, NO extra text beyond what's specified." This is the most common DTC ad failure mode — models love to invent copy.
- **Generic 5xx / rate-limit** → retry ONCE with the same payload after a short pause. See SKILL.md "Detecting failed generations".

### UX Rules

1. **Always pick an ad format explicitly** with the user — never auto-pick.
2. **Always confirm aspect ratio + resolution + quantity** before firing.
3. **Always check for a brand kit** before scraping fresh — `Read .kolbo/brand-kits/<slug>.md` first.
4. **Always log products + brand kits in `.kolbo/production.md`** so future ads reuse instead of re-uploading / re-scraping.
5. **No auto-retry on failure** — surface the reason and let the user adjust.
6. **Strict NO uninvited additions** in every ad prompt: "NO captions, NO subtitles, NO watermarks, NO extra text beyond what's specified."
