---
version: 0.9.13
name: kolbo-product-photoshoot
description: |
  Generate brand-quality product images across 10 specialized modes:
  product_shot (clean studio), lifestyle_scene, closeup_product_with_person,
  moodboard_pin (Pinterest), hero_banner, social_carousel, ad_creative_pack,
  virtual_model_tryout, conceptual_product (surreal/CGI), restyle.

  Use when: "product photo", "studio shot", "lifestyle image", "Pinterest pin",
  "hero/banner", "carousel", "ad creative", "Meta ads", "virtual try-on",
  "model wearing", "person holding product", "closeup with hands",
  "CGI/surreal product", "restyle", or any product/brand/paid-social creative.

  Chain: optional brand-kit lookup (.kolbo/brand-kits/SLUG.md), pair with
  kolbo-visual-dna for character locks (virtual_model_tryout, closeup with face),
  multi-output modes (social_carousel, ad_creative_pack) auto-route to
  kolbo-creative-director.

  NOT for: no-product text-to-image (use kolbo-generate), branded ad VIDEO
  (use kolbo-marketing-studio), marketplace listing cards (use
  kolbo-marketplace-cards).
argument-hint: "[mode] [brief] [--image <product-photo>] [--count N]"
allowed-tools: Bash, Read, Write, Edit
---

<!-- AUTO-GENERATED from kolbo-code packages/opencode/skills/kolbo — DO NOT EDIT.
     Edit the canonical skill and let .github/workflows/sync-skill-to-plugin.yml regenerate this. -->

# Kolbo Product Photoshoot

## Step 0 — Bootstrap

Once per conversation, before any other Kolbo tool call:

1. **Run `check_credits`.** If it fails with "Session expired" / "Not authenticated", ask the user to run `kolbo auth login` (or their branded CLI command like `sapir auth login`) and reload the editor.
2. **If `list_models` returns empty**, MCP isn't wired — same fix.
3. Use the balance ONLY for the low-balance check at this moment (see the "credits remaining" rule in the brief section below).

If the user is on a whitelabel build (`sapir`, etc.), they must use their branded command — not `kolbo`. See `references/workflows/troubleshooting.md`.

## 🎬 Confirm the Creative Brief & Cost BEFORE Generating (CRITICAL — read first)

Never fire a paid generation the moment the user says "make X". First **present the brief back as a confirmation the user can change** — this is the single most important interaction. It gives the user control over what gets created and what it costs, instead of silently spending credits on defaults.

**Before ANY paid image / video / music / speech / 3D generation**, unless the user has *explicitly* dictated every key parameter in this message, ask ONE labeled question (the UI renders it as an options card) confirming:

- **Model** — your recommended pick as the default option, plus 1–2 alternatives (with their credit cost). Suggest a cheaper alternative if one fits.
- **Aspect ratio** — e.g. `1:1 / 9:16 / 16:9` (offer the sensible default first).
- **Count** — how many (1 / 4 / …).
- **Resolution / quality / duration** — where the model supports it.
- **Creative direction** — style / mood / scene, when the user was vague ("4 cats" → offer style options: photoreal / illustrated / cinematic / surprise-me).
- **Credit cost** — state the total (`✦ N credits`) right in the question so cost is never a surprise.

Then generate **only** with the confirmed parameters. If the user changes an option, use the change. This mirrors the approval-card flow: propose → let them adjust → confirm → generate. Never fire on defaults the user didn't choose.

**Only skip the brief/cost confirmation when** the user's message already pins model + aspect + count + creative direction (e.g. "generate 4 photoreal tabby cats, 1:1, z-image/turbo") — then just state the cost one-liner and fire. A low credit cost is **not** a reason to skip: cheap ≠ no-confirmation. What matters is whether the user actually chose the parameters.

**Cost rules** (full tables + formulas in `references/workflows/cost-and-validation.md`):

- **Video/lipsync `credit` is per-SECOND, not per-clip**: normally `total = credit × output_duration`. If video references are attached and `video_input_credit` is present, use the alternate provider tariff instead: `video_input_credit × (sum ceil(each input video duration) + output seconds) × video_input_resolution_multiplier`. Dedicated Seedance Edit uses its selected source duration as output; Extend uses the requested added duration. The other carve-out is `flat_credit_by_resolution`.
- **Batch totalling 100+ credits**: run `check_credits` first.
- **Quote real cost**: when the user approves the result, log its actual `credits_used` (from the tool result) to `.kolbo/production.md` — never `base × count`.
- **Never state "credits remaining" from arithmetic** (opening balance − generation costs). Coding/chat usage deducts credits too, so the math is always wrong. Report cost only; if the user asks for their balance, call `check_credits` fresh at that moment.
- **Out of credits → `show_plans`.** A generation refused for credits already returns the upgrade card automatically — do NOT retry it, and do not re-run the tool "to be sure". Call `show_plans` yourself when the user asks about pricing, plans, upgrading, or how to get more credits. Prices are live and promo-adjusted; never quote them from memory. The user completes any purchase themselves on app.kolbo.ai/pricing — you cannot buy for them.

For multi-scene / batch work this pairs with `generate_creative_director` (see below) — still confirm the brief first.

## ⚠️ Load the matching skill BEFORE generating (HARD RULE)

This `kolbo` skill is the mandatory first layer for every Kolbo media task. Do **not** call `generate_*` / `generate_elements` / `generate_image_edit`, or write the billable prompt for them, until you have loaded every matching dependency **in this turn** (the `skill` tool for bundled skills and Read of the required Kolbo references). "I already know this," memory, or a prior-turn load does not count. Users will never invoke these skills themselves.

Dependencies accumulate: narrative Elements work requires **Kolbo + filmmaking + elements-prompting**, not whichever one was loaded first. Before the first paid call, silently check the stack and load anything missing.

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
- **Asset tags are exempt from every English-only prompt rule.** Copy the actual stored `name` verbatim in its original language, case, spaces, punctuation, and diacritics. Stored `אסתר` → `@אסתר`, `ليلى` → `@ليلى`, `小雨` → `@小雨`; never `@Esther`, `@Layla`, or another translated/transliterated alias. Never slugify or rename an existing DNA to make a prompt English. Preserve these tags through every rewrite and final tool call.
- Same rule for moodboards: `#ExactBoardName`

**Rewrite / compile never drops a tag.** If the user, a prior prompt, or `list_visual_dnas` already has `@gal_suit` / `@yonatan` / `#Board`, the Locked Intro you write MUST still contain those exact tokens in CAST **and** in every shot they appear in. Do not "clean" them into first names, `@Image 1 (Lee)`, "the singer", or a SCENE CONTEXT / ACTIVE REFERENCES block with no `@`. A compile that loses a tag is a failed turn — put the tags back before calling `generate_*`.

Before ANY generation call using `visual_dna_ids` (images, edits, Elements, or Creative Director): resolve each id to its stored `name` from the selected asset binding or `list_visual_dnas` / `get_visual_dna`, then confirm the final prompt includes the exact `@` + name. Missing or rewritten even one → fix the prompt, do not fire.

Resolve names with `list_visual_dnas` first. Full binding rules: `references/workflows/visual-dna.md`.

**Every still on a DNA can reach the model.** Kolbo now sends all of a DNA's reference images that fit the model's image-slot cap (user uploads first, then one still per DNA, then leftovers round-robin). If a DNA only gets one leftover slot and has no real character sheet, unused stills become a white grid. Mixed-vibe stills or environment photos that contain a main character will confuse the generation — keep each DNA surgically clean. Create-and-pack rules: `references/workflows/visual-dna.md`.

## 📁 Projects — Where Work Lands (CRITICAL)

Everything in Kolbo — sessions, generations, media, docs — lives inside a PROJECT. Getting this wrong is the #1 user complaint ("my work went to the wrong project").

1. **User names a project** ("in my Acme project", "for the film") → call `list_projects` ONCE to resolve the name to an ObjectId, then pass that **same** id as `project_id` on **EVERY** subsequent `generate_*` / `upload_media` / `create_doc` / `chat_send_message` call in **this conversation**. There is no server-side sticky store — omitting it on any later call silently lands in the default "API Generations" bucket (`is_default: true`). Once resolved, treat that id as required for the rest of the conversation. Accounts often hold hundreds of projects, so pass `list_projects({ search: "acme" })` rather than listing everything; the list is paginated (50/page) and hides archived projects unless you pass `include_archived: true`. When the user starts new work, `create_project` first, then pass its id the same way.
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

After the user approves a bucket, write its `session_id` + plan name into `.kolbo/production.md` `### Sessions`. Do not create or update the file for a pending bucket. Full rules: `references/workflows/production-planning.md` + `production-log.md`.

## ⚠️ Generation lifecycle — source of truth, waiting, failures (HARD RULE — read this)

**How calls work:** each generation tool blocks until the job is fully complete. Images: seconds. Video: minutes. Multiple tool calls in one response run concurrently. On hosts with live widgets the tool instead returns `submitted` (or `_timed_out`) instantly — the card updates on its own.

Four surfaces show the same job. Use this map — never invent a fifth:

| Surface | What it is | Trust it for |
|---|---|---|
| **Library** (right panel — "This session" / "All media") | User-facing gallery of **completed** media | "Is the user's output there?" Point humans here — never to chat history. Finished clips/images land automatically — do **not** call `list_media` / `get_media` / `list_session_generations` to "check if it worked" after a generate you already submitted (burns credits/context, can pollute the session). A K/logo spinner tile **is** the in-progress placeholder for the same job, not a missing one. |
| **Chat generation card** | Progress chrome while a job is in flight | Status badge only (`Generating` / done). A **black / empty preview while Generating is NORMAL** — the iframe has nothing to paint yet. It is **not** failure, not "lost", not a reason to re-fire. |
| **`get_generation_status`** (MCP) | Agent API for job state | Whether the server job is `completed` / `failed` / still running, and the final `urls`. This is your SoT for in-flight work — **not** the card pixels. |
| **`.kolbo/production.md`** | Your private log across turns | User-approved ids + URLs only. Compaction-safe memory — not the user gallery or a candidate scratchpad. |

**🛑 NEVER re-fire a generation you already called.** Aborted / timed-out / `submitted` calls still process server-side. Finish with `get_generation_status` (`wait=true`) — never a second `generate_*`.

**🛑 After `submitted` / `_timed_out` — END THE TURN (credit guard).** Do **not** keep thinking, writing skills, editing files, or planning "next steps" while a generation is still running — that burns the user's coding/chat credits for nothing. Either **stop immediately** after telling the user it's generating in Library / the card above (preferred when you do not need the output URLs yet), OR — if the **next** required step needs those URLs — call `get_generation_status` **once** with `wait=true` as the **only** follow-up, no parallel Write/Edit/Think while it waits.

**Checking status — NEVER poll in a loop.** `get_generation_status` takes `wait=true` (blocks server-side until done, ~3 min) and `generation_ids` (check MANY generations in ONE call — returns `all_done` + which are still running). One `wait=true` call replaces any polling loop: check ALL in-flight ids in ONE call, never one by one, never without `wait`. If it comes back with some still processing, call it ONCE more with `wait=true` and the remaining ids.

**Detecting failure — a generation can fail three ways. Treat ALL as failure:**

1. **Tool returns `error`** — explicit. Surface it and suggest a retry. Keep the `generation_id` in the active run for recovery; never put failures in production.md.
2. **Tool returns `completed` but `urls` is empty** — silent failure (NSFW filter, model OOM, upstream 5xx). Tell user "completed without an output — retrying" and re-fire ONCE. Do NOT claim it worked.
3. **Tool hangs / never returns** — MCP poll timed out. Call `get_generation_status(generation_id, wait=true)` IMMEDIATELY. The server might be done.

**Reporting:**
- Don't celebrate before reading the result. Verify `urls` is non-empty.
- Don't auto-retry without surfacing the failure. Partial batches: list failed items + reasons + successful count, and surface the user's count — "6 of 8 ready", not "videos ready". Never "✅ all done!" on partials.
- Log only successful results the user explicitly approves to `.kolbo/production.md` — never pending, rejected, or failed items.
- When done: say the result is in **Library → This session**. "Where is it?" → Library (This session). "Is it done?" with no urls yet → `get_generation_status` once.

`failure` envelope structure + retry rules: `references/workflows/troubleshooting.md`.

## ⚠️ Generated URLs in Chat (CRITICAL)

Chat renders markdown natively. `![alt](url)` = inline image. `[label](url)` = labeled link with preview.

- **Catalog-style replies** (numbered lists of characters / scenes / products): embed `![alt](url)` so each item shows inline.
- **Conversational replies** ("4 shots ready"): keep prose short; Library already shows the gallery.

Avoid bare URL dumps and HTML `<table>` grids — Library already provides a gallery.

**After `generate_creative_director` completes** — share results as individual URLs, one per scene. Do NOT create an HTML grid artifact.

**Never update `.kolbo/production.md` merely because a generation succeeded.** Keep the result provisional in the generation card / Library, ask the user to choose, and write only the explicitly approved winner in the same turn as approval. Brief approval before generation is not output approval; silence, a topic change, or requesting the next task is not approval. See `references/workflows/production-log.md`.

## Product Photoshoot — Brand Product Imagery

Load this file when the user wants **brand-quality product images** — studio shots, lifestyle scenes, Pinterest pins, hero banners, social carousels, ad packs, virtual try-ons, conceptual / CGI product shots, or seasonal restyles.

For ad **video** see `workflows/marketing-studio.md`. For composed brand ads (brand kit + ad format + avatar) see `workflows/dtc-ads.md`. For marketplace listings (Amazon main + secondary + A+ content) see `workflows/marketplace-cards.md`.

### The 10 Modes

Pick by intent, not surface keyword. When two modes could apply, prefer the more specific one.

| Mode | When user wants… |
|---|---|
| `product_shot` | Product on neutral / studio / catalog background (Shopify, white-bg) |
| `lifestyle_scene` | Product in a real environment — hands, action, atmosphere (kitchen, gym, outdoor) |
| `closeup_product_with_person` | Tight crop with hands or partial face — beauty application, demonstrating, holding |
| `moodboard_pin` | Vertical 2:3 Pinterest-native pin, moodboard feel |
| `hero_banner` | Wide-format website / email / campaign header |
| `social_carousel` | 3–10 connected slides for IG / LinkedIn / Facebook |
| `ad_creative_pack` | Coordinated pack of static ad variants for Meta / TikTok / Pinterest / Google Ads |
| `virtual_model_tryout` | Product worn or used by an AI-rendered model (fashion, accessories) |
| `conceptual_product` | Surreal / CGI / levitating / splash / sculptural product |
| `restyle` | Transform an EXISTING image's aesthetic, mood, or seasonal context (without changing the subject) |

#### Picking the Mode

| User phrasing | Mode |
|---|---|
| neutral / clean / white / studio / catalog / Shopify | `product_shot` |
| scene / in use / kitchen / outdoor / cafe / gym | `lifestyle_scene` |
| hands holding / face with product / beauty application / demonstrating | `closeup_product_with_person` |
| Pinterest / pin / vertical pin | `moodboard_pin` |
| hero / banner / website header / landing page / email header / wide format | `hero_banner` |
| carousel / slide post / multi-slide / swipeable | `social_carousel` |
| ads / ad pack / paid social / Meta / TikTok / Pinterest ads / Google ads | `ad_creative_pack` |
| model wearing / virtual try-on / on body / fashion shoot / lookbook | `virtual_model_tryout` |
| levitating / floating / splash / frozen motion / surreal / CGI / sculptural | `conceptual_product` |
| modify EXISTING image's aesthetic / mood / season — without changing subject | `restyle` |

**Tie-breakers:**
- "Pinterest pin of my product on a kitchen counter" → `moodboard_pin` (Pinterest is the platform)
- "Hero banner showing my product in use" → `hero_banner` (banner format wins)
- "Carousel of my product in different scenes" → `social_carousel` (multi-slide wins)
- "Closeup of person applying my serum" → `closeup_product_with_person` (specific genre wins)

### Mode → Kolbo MCP Routing

The mode determines which Kolbo MCP tool to call and what defaults to use.

| Mode | Primary tool | Model preference | aspect_ratio | Count default |
|---|---|---|---|---|
| `product_shot` | `generate_image` | GPT Image 2 (clean studio look + dense label text) | `1:1` | 1 or `num_images: 3` for variants |
| `lifestyle_scene` | `generate_image` | Nano Banana 2 (best lifestyle realism) | `1:1` or `4:5` | 1 or `num_images: 3` |
| `closeup_product_with_person` | `generate_image` | Nano Banana 2 | `1:1` or `4:5` | 1 |
| `moodboard_pin` | `generate_image` | Nano Banana 2 | **`2:3`** (Pinterest native) | 1 or `num_images: 3` |
| `hero_banner` | `generate_image` | GPT Image 2 (large format + brand text) | `16:9` or `3:1` | 1 |
| `social_carousel` | **`generate_creative_director`** with `scene_count: 3–10` | Nano Banana 2 | `1:1` (IG) or `4:5` | `scene_count` |
| `ad_creative_pack` | **`generate_creative_director`** with `scene_count: 4–8` | GPT Image 2 or Nano Banana 2 | Mixed per ad placement (`1:1`, `9:16`, `1.91:1`) — fire one director call per aspect | `scene_count` |
| `virtual_model_tryout` | `generate_image_edit` with character Visual DNA + product source | Nano Banana Pro (identity-sensitive edits) | `1:1`, `4:5`, or `9:16` | 1–3 |
| `conceptual_product` | `generate_image` | Nano Banana 2 or GPT Image 2 | `1:1` or `2:3` | 1–4 |
| `restyle` | `generate_image_edit` with `source_images: [existing]` | Same model that produced the original (or Nano Banana 2 for safe re-render) | Inherit from source | 1–3 |

**For multi-output modes** (`social_carousel`, `ad_creative_pack`), always use `generate_creative_director` — never fire ≥2 `generate_image` calls in a loop. See `models/creative-director.md`.

**Always validate** `aspect_ratio` and `resolution` against the chosen model's `supported_aspect_ratios` / `supported_resolutions` via `list_models` — see `references/workflows/cost-and-validation.md`.

### Pre-Generation Interview (CRITICAL)

Ask **at most 4 short questions** before submitting, always with **labeled options, never open-ended**. Skip a question whose answer is obvious from context (uploaded image, prior turn, brand memory in `.kolbo/brand-kits/`).

Pick the question stack based on user state:

#### Type A — Uploaded a product photo, said "make me images / photoshoots"

1. **How many?** `[1 / 3 / 5]`
2. **What style/mood?** `[Clean studio / Lifestyle / Conceptual / With a model / Other]`
3. **Where will you use them?** `[Shopify / Instagram / Pinterest / Paid ads / Website hero]`
4. **Brand colors to match?** (skip if a brand kit exists at `.kolbo/brand-kits/<slug>.md`)

#### Type B — Uploaded a product photo + named a use case

E.g. "make ads for my product", "make a Pinterest pin", "make a hero banner". Mode is obvious. Ask only the gaps:

1. **How many?** (only if multi-output mode)
2. **What's the offer / mood / hook?**
3. **Anything in particular to emphasize?**

#### Type C — Text only, no product photo

1. **Can you upload a product photo?** (preferred — much higher fidelity)
2. **If not, describe the product** — category, packaging, color, distinctive features
3. **What style?** `[Clean studio / Lifestyle / Conceptual / With a model / Other]`
4. **Where will you use it?** `[Shopify / Instagram / Pinterest / Paid ads / Website hero]`

#### Type D — Uploaded existing image, "redo / change vibe / different version"

→ Mode: `restyle`

1. **What aesthetic?** `[Clean girl / Cottagecore / Quiet luxury / Dark academia / Y2K / Other]`
2. **Seasonal context?** `[Christmas / Valentine's / Halloween / Black Friday / None]`
3. **What to preserve, what to change?** (only if ambiguous)

#### Type E — Model wearing a product (fashion, accessories)

→ Mode: `virtual_model_tryout`

1. **Model archetype?** (suggest 2–3 based on brand audience — don't open-end)
2. **Environment?** `[Studio clean / Outdoor natural / Street style / Editorial / Home cozy]`
3. **Framing?** `[Full body / Three-quarter / Waist up / Closeup on product area]`

#### Type F — Vague request, unclear subject

E.g. "make me something cool for my brand".

1. **What product or topic?**
2. **Goal?** `[Sell on a marketplace / Build awareness / Run paid ads / Update website]`
3. **Upload a reference image?**

After answers → return to the relevant Type A–E.

### Brand Kit Integration

Before any generation, check if `.kolbo/brand-kits/<slug>.md` exists for the brand:

- **Exists** → Read it. Pull `primary_color`, `accent_color`, `fonts`, `logo_url`. Bake hex codes + named fonts into the prompt. Pass the logo as `reference_images[0]` if relevant.
- **Doesn't exist** but user gave a brand URL → Run `workflows/research-first.md` first to build one.
- **Doesn't exist** and user gave no URL → Proceed without; ask in Type A's question 4 if relevant.

### Multi-Variant Strategy

For `count > 1` on a single-output mode (`product_shot`, `lifestyle_scene`, `closeup_product_with_person`, `moodboard_pin`, `hero_banner`, `conceptual_product`):

- Use `num_images: N` on `generate_image` — same prompt, different seeds, fast.
- Variations come from the model's randomness, not intentional direction.

For `social_carousel` / `ad_creative_pack` (multi-output by design):

- Use `generate_creative_director` with `scene_count: N`.
- Each scene gets its **own intentional prompt** (different angle / framing / mood / palette) — not paraphrased copies of one scene.
- Pass the same `visual_dna_ids` and `reference_images` across all scenes to lock product identity.

### Output Discipline

- Call the chosen MCP tool — single command, no preamble.
- For multi-output: `generate_creative_director` returns N URLs; share them as individual lines (do NOT build an HTML grid artifact — the canvas already shows the gallery).
- For single-output: one image URL.
- After the user approves a result, log only that URL + model + resolution + mode into `.kolbo/production.md` under `### <Mode>`.

### UX Rules

1. **Pick the mode by intent**, not surface keyword. The user saying "Pinterest" → `moodboard_pin` regardless of what's IN the image.
2. **Ask at most 4 labeled-option questions** before generating. Skip any question whose answer is obvious.
3. **Always confirm aspect ratio + resolution + count** before firing — they materially change output and cost.
4. **Reuse brand kits** — Read `.kolbo/brand-kits/<slug>.md` before generating.
5. **Strict NO uninvited additions** — "NO captions, NO subtitles, NO watermarks, NO extra text beyond what's specified" in every prompt.
6. **No auto-retry on failure** — surface and let the user adjust.

### Prompt Template Seeds

#### `product_shot`
```
Clean studio product photograph of @image1 (the product),
centered on a {neutral white | seamless gradient | catalog beige} background.
Soft front-fill + subtle rim light, no harsh shadows, no reflections.
Tack-sharp focus on the product, slight depth-of-field falloff on the background.
{Brand palette: primary #..., accent #...}
NO captions, NO watermarks, NO extra text.
```

#### `lifestyle_scene`
```
@image1 (the product) in a {real-world scene description},
natural {time-of-day} light, {natural action involving the product}.
Photographic, editorial style, {iPhone | 35mm film | medium format} feel.
<!-- "iPhone feel" is not a look on its own — for a genuine phone-shot / UGC product
     photo (deep focus, computational HDR, named available light, real clutter, and the
     rules for keeping label identity intact) read workflows/ugc-smartphone.md. -->
{Optional: include hands, partial face — never identifiable people}.
{Brand palette baked into props/clothing}.
NO captions, NO watermarks.
```

#### `moodboard_pin`
```
Vertical 2:3 Pinterest pin, moodboard aesthetic.
@image1 (the product) integrated into a {seasonal/aesthetic theme} flatlay or scene.
{Aesthetic anchor: cottagecore / quiet luxury / Y2K / clean girl / dark academia}.
Soft natural light, low-saturation editorial palette,
optional textural overlay (paper, linen, marble).
Centered hero composition, generous negative space at top for pin overlay.
NO captions, NO text.
```

#### `restyle`
```
@image1 — preserve {subject / composition / camera angle / framing} exactly.
Change ONLY the {aesthetic / season / mood} to {target aesthetic description}.
Keep product geometry, label legibility, and identifying details unchanged.
{Specific change list, e.g.: "swap warm tones for cool blue/silver, add subtle snowflake bokeh,
shift wood prop to ceramic, keep everything else identical"}.
```

(More seeds belong here as we learn from real Kolbo generations — append, don't replace.)
