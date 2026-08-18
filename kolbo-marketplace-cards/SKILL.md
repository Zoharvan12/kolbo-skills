---
version: 0.8.4
name: kolbo-marketplace-cards
description: |
  Generate marketplace listing visuals for Amazon / Shopify / eBay / Etsy /
  Walmart — main image (compliance-aware), secondary product images, and
  A+ content modules. 4 bundle scopes (main / product-images / aplus / full-set)
  + 13 named asset types.

  Use when: "Amazon main image", "Amazon listing", "Shopify product cards",
  "marketplace listing", "A+ content", "infographic for my product",
  "what's in the box image", "marketplace image set", "full Amazon set",
  "main + secondary + A+", "Walmart listing", "Etsy listing".

  Chain: optional brand-kit lookup (.kolbo/brand-kits/SLUG.md), routes
  bundles through kolbo-creative-director under the hood, pair with
  kolbo-product-photoshoot for additional non-listing brand imagery.

  NOT for: generic brand product photography without marketplace/listing
  context (use kolbo-product-photoshoot), video generation or UGC ads
  (use kolbo-marketing-studio), Visual DNA training (use kolbo-visual-dna).
argument-hint: "[--scope main|product-images|aplus|full-set] [brief] [--image <product>]"
allowed-tools: Bash, Read, Write, Edit
---

<!-- AUTO-GENERATED from kolbo-code packages/opencode/skills/kolbo — DO NOT EDIT.
     Edit the canonical skill and let .github/workflows/sync-skill-to-plugin.yml regenerate this. -->

# Kolbo Marketplace Cards

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

## ⚠️ Visual DNA `@Name` in the prompt (HARD RULE — always on)

Passing `visual_dna_ids` is **not enough**. For every DNA in that array you MUST also write `@ExactStoredName` in the prompt text (the `name` from `list_visual_dnas` / `create_visual_dna`). The engine binds identity by parsing `@tags`. No `@tag` → the DNA is wasted.

- Right: `visual_dna_ids: ["vdna_…"]` + prompt `@Zohar walks into frame`
- Wrong: `Zohar's`, `Zohar`, `the left man`, `the man on the LEFT`, `Visual DNA anchors: the man on the LEFT…` — none of these bind
- Never invent a role label or possessive as a substitute for `@Name`
- Same rule for moodboards: `#ExactBoardName`

Resolve names with `list_visual_dnas` first. Full binding rules: `references/workflows/visual-dna.md`.

## 📁 Projects — Where Work Lands (CRITICAL)

Everything in Kolbo — sessions, generations, media, docs — lives inside a PROJECT. Getting this wrong is the #1 user complaint ("my work went to the wrong project").

1. **User names a project** ("in my Acme project", "for the film") → call `list_projects` ONCE to resolve the name to an ObjectId, then pass that **same** id as `project_id` on **EVERY** subsequent `generate_*` / `upload_media` / `create_doc` / `chat_send_message` call in **this conversation**. There is no server-side sticky store — omitting it on any later call silently lands in the default "API Generations" bucket (`is_default: true`). Once resolved, treat that id as required for the rest of the conversation. Accounts often hold hundreds of projects, so pass `list_projects({ search: "acme" })` rather than listing everything; the list is paginated (50/page) and hides archived projects unless you pass `include_archived: true`.
2. **No project mentioned** → omit `project_id`; the default bucket is correct. Don't ask unless intent is ambiguous. If `list_sessions` already returned a `project_id` for the work you are continuing, keep passing that id.
3. **Work landed in the wrong project? MOVE it, never regenerate**: `move_session` relocates a whole session + all its media (works for any session type — the `session_id` from generation responses, chats, transcriptions); `move_media` / `bulk_move_media` / `move_folder_contents` relocate individual media items. Empty leftover sessions after a move: `delete_session` (soft-delete; `restore_session` undoes it). `rename_session` only changes the sidebar title.

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

**Always** record every URL in `.kolbo/production.md` — see `references/workflows/production-log.md`.

## Marketplace Cards — Amazon / Shopify / eBay Listings

Load this file when the user wants **marketplace listing visuals** — main image, secondary product images, infographics, or A+ content modules for Amazon, Shopify, eBay, Etsy, Walmart, or similar.

For generic brand product photography (Pinterest, hero banner, lifestyle, ad pack) see `workflows/product-photoshoot.md`. For ad video see `workflows/marketing-studio.md`. For composed DTC ads see `workflows/dtc-ads.md`.

### What This Is

Marketplace listings need a **specific, compliance-aware visual system** that's different from brand campaign imagery:

- **Main image** — strict marketplace rules (typically pure white background, product fills 85% of frame, no text, no props, no shadows). This is the conversion-critical thumbnail.
- **Secondary product images** — multi-angle, detail shots, lifestyle, "what's in the box". Show the product from every angle a shopper needs before clicking buy.
- **A+ content / Enhanced Brand Content (Amazon)** — long-form modules below the fold: hero banner, pain-point grid, feature comparison, ingredients breakdown, efficacy proof, how-to-use steps, brand endorsement / founder story.

### The 4 Bundle Scopes

When the user asks for a common bundle, fire one call per scope:

| Scope | Creates |
|---|---|
| `main` | 1 marketplace main image |
| `product-images` | main image + 5 secondary images |
| `aplus` | main image + 7 A+ content modules |
| `full-set` | main image + 5 secondary + 7 A+ modules (13 assets total) |

Use a **custom subset** of the asset list below when the user wants a non-standard combination (e.g. "just main + infographic + lifestyle").

### The 13 Asset Types

| Asset | Purpose | Aspect ratio | Model preference |
|---|---|---|---|
| `main_image` | Marketplace thumbnail — strict compliance: pure white bg, product fills 85% of frame, no text, no props | `1:1` | Nano Banana 2 (clean studio render) |
| `infographic` | Feature callouts with text labels and product hero | `1:1` or `4:5` | **GPT Image 2** (dense on-image text) |
| `multi_angle` | 4-up grid showing front / back / sides of product | `1:1` | Nano Banana 2 |
| `detail_shot` | Macro shot of texture / material / mechanism | `1:1` | Nano Banana 2 |
| `lifestyle` | Product in use in real environment | `1:1` or `4:5` | Nano Banana 2 |
| `whats_in_box` | Flat-lay showing the product + accessories laid out neatly | `1:1` | Nano Banana 2 |
| `aplus_hero_banner` | Wide A+ header — brand identity hit | `3:1` | GPT Image 2 |
| `aplus_pain_points` | 3-up grid showing the problem this product solves | `16:9` | GPT Image 2 (text) |
| `aplus_features` | 3-up or 4-up feature breakdown with labels | `16:9` | GPT Image 2 |
| `aplus_ingredients` | Ingredients / materials breakdown (skincare, food, supplements) | `16:9` | GPT Image 2 |
| `aplus_efficacy` | Before/after, % stats, clinical results — proof block | `16:9` | GPT Image 2 (charts + text) |
| `aplus_how_to_use` | Numbered step-by-step usage instructions | `16:9` | GPT Image 2 |
| `aplus_endorsement` | Founder story, brand mission, testimonial-style | `16:9` | Nano Banana 2 (people) + GPT Image 2 (text overlay) |

### Kolbo MCP Routing

For **bundles** (`product-images`, `aplus`, `full-set`): use `generate_creative_director` with `scene_count` = number of assets in the bundle. Pass the product image as `reference_images[0]` so it appears consistently across every asset. Each scene's prompt encodes one asset type.

For **single `main` image** or **custom subset** of ≤ 2 assets: `generate_image` per asset, fired in parallel (single response, multiple tool calls).

For **multi-angle** specifically: this is one image with a 4-up grid composition — use `generate_image` with a prompt describing the 2×2 layout, NOT `generate_creative_director`. (Or alternatively, fire 4 separate `generate_image` calls and composite the grid yourself — depends on user preference.)

**Always pass the product photo** as `reference_images` for every call. `@image1` references it in the prompt. If the user gave a URL instead of a photo, run `workflows/research-first.md` first.

### Main Image Compliance Rules (HARD)

Different marketplaces have different rules. The **strictest is Amazon's**, which most other marketplaces follow:

1. **Pure white background** (`#FFFFFF`, no gradients, no shadow tone).
2. **Product fills ≥ 85% of the frame** — minimal margin.
3. **NO text** — no logos baked in, no callouts, no "NEW" stickers, no watermarks.
4. **NO props** — just the product. No hands, no models, no styling pieces.
5. **NO multiple products** — single hero (variant grids go in secondary, not main).
6. **NO color borders / decorative frames**.

Bake these into every `main_image` prompt as explicit prohibitions:

```
Pure white background (#FFFFFF), seamless studio sweep.
Product (@image1) centered, fills 85% of frame.
Tack-sharp focus, no shadows on background, soft contact shadow only.
NO text, NO logos, NO captions, NO props, NO models, NO decorative borders.
Photographic, catalog-grade, neutral color.
```

### Secondary Image Strategy

5-image standard set (when the user says `product-images` scope):

1. **Lifestyle** — product in use, real environment
2. **Detail / texture** — macro of the key material or feature
3. **Multi-angle** — 4-up showing all sides
4. **What's-in-the-box** — flat-lay of components
5. **Scale / size reference** — product next to a hand or known-size object

Adjust based on category: skincare needs ingredients close-up + texture-on-skin; apparel needs front + back + on-model + detail + size chart; electronics needs ports/buttons close-up + size comparison.

### A+ Content Strategy

A+ modules tell a story below the fold. Standard 7-module flow:

1. `aplus_hero_banner` — brand identity / aspirational hero
2. `aplus_pain_points` — what problem we solve
3. `aplus_features` — how we solve it (3–4 differentiators)
4. `aplus_ingredients` (skincare/food/supplements) OR materials/specs (electronics/apparel)
5. `aplus_efficacy` — proof (before/after, % stats, third-party data)
6. `aplus_how_to_use` — usage steps
7. `aplus_endorsement` — founder story / mission / testimonial

For dense-text modules (`aplus_features`, `aplus_pain_points`, `aplus_efficacy`, `aplus_how_to_use`): always recommend **GPT Image 2** at `resolution: "2K"` or `"4K"` (text needs the higher tier to stay sharp).

### Brand Kit Reuse

Check `.kolbo/brand-kits/<slug>.md` before generating. Pull `primary_color`, `accent_color`, `text_color`, `bg_color`, `fonts`. Bake into every A+ module prompt — marketplace pages live or die on visual consistency across the 13 assets.

### Pre-Generation Interview

Ask 2–3 short labeled questions before firing:

1. **Which marketplace?** `[Amazon US / Amazon EU / Shopify / Etsy / eBay / Walmart / Other]` — affects compliance rules
2. **Which bundle?** `[main / product-images / aplus / full-set / custom subset]`
3. **Brand kit?** Auto-detect from `.kolbo/brand-kits/<slug>.md`; otherwise ask if brand colors / fonts should be applied

Skip questions whose answer is obvious from the request.

### Output Discipline

- For bundles: `generate_creative_director` returns N URLs. Present them in chat as a numbered list, one URL per line, with the asset name as label:
  ```
  Marketplace cards ready:
  1. Main image: https://...
  2. Lifestyle: https://...
  3. Detail shot: https://...
  ...
  ```
  Do NOT wrap them in an HTML grid artifact — the canvas already shows the gallery.
- Log all URLs to `.kolbo/production.md` under `## Production: <product name>` → `### Marketplace Cards` subsection.
- If a `main_image` came back with text / props (compliance failure), surface the issue and re-fire with stronger prompt prohibitions — don't ship a non-compliant main image.

### Existing Main-Image Reuse

If the user already has an approved `main_image` from a prior session and wants to generate only secondary / A+ assets that match it:

1. Look up the main image URL from `.kolbo/production.md`.
2. Pass it as `reference_images[0]` (in addition to the product photo) so the new assets match the main's exact rendering style — same lighting, same color cast, same product orientation.
3. Tag it as `@image2` in the prompt: "Match the product rendering from `@image2` exactly — same angle, same lighting, same color cast."

### UX Rules

1. **Always ask which marketplace** — compliance rules vary.
2. **Strict compliance prompts on main_image** — explicit NO text / NO props / NO models / NO borders.
3. **Always reuse brand kit** — Read `.kolbo/brand-kits/<slug>.md` first; pass palette + fonts to every A+ module.
4. **Recommend GPT Image 2 + 2K/4K for dense-text A+ modules** — Nano Banana renders text well but GPT Image 2 wins at multi-line technical layouts.
5. **For bundles, always use `generate_creative_director`** — never fire 13 parallel `generate_image` calls.
6. **Log everything to `.kolbo/production.md`** — marketplace listings get updated quarterly; reuse beats regenerate.
