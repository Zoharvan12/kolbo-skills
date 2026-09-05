---
version: 0.9.13
name: kolbo-marketing-studio
description: |
  Generate branded ad VIDEO — UGC, unboxing, tutorial, product review, TV spot,
  product showcase, virtual try-on, wild card. 9 modes, each with the right
  Kolbo MCP routing and defaults (UGC defaults to 9:16, sound off, no captions,
  no watermarks).

  Use when: "UGC ad", "make me a TikTok / Reels / Shorts", "creator video",
  "unboxing video", "product review", "TV ad", "commercial", "branded video",
  "ad spot", "talking head", "selfie video", "virtual try on", "fashion shoot",
  "vlogger", "for social", "Instagram video", "YouTube short".

  Chain: pair with kolbo-visual-dna (presenter face), kolbo-product-photoshoot
  (product photos to upload as references), or kolbo-music (separate music gen
  to layer in post). Brand-kit lookup auto-reads .kolbo/brand-kits/SLUG.md
  if a previous brand-research turn persisted one.

  NOT for: brand product IMAGES (use kolbo-product-photoshoot), marketplace
  cards (use kolbo-marketplace-cards), composed ad images (use kolbo-dtc-ads),
  generic single image / video (use kolbo-generate).
argument-hint: "[mode] [brief] [--visual-dna-id <id>] [--product-image <path>]"
allowed-tools: Bash, Read, Write, Edit
---

<!-- AUTO-GENERATED from kolbo-code packages/opencode/skills/kolbo — DO NOT EDIT.
     Edit the canonical skill and let .github/workflows/sync-skill-to-plugin.yml regenerate this. -->

# Kolbo Marketing Studio — UGC & Campaign Assets

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

## Marketing Studio — UGC, Ads & Branded Video

Load this file when the user wants **branded ad video** — UGC, unboxing, product showcase, TV spot, virtual try-on, or any "make me an ad / commercial / creator video" request.

For ad **images** (Pinterest pin, hero banner, ad creative pack) see `workflows/product-photoshoot.md`.
For **marketplace listings** (Amazon main + secondary + A+ content) see `workflows/marketplace-cards.md`.
For the **DTC ads engine flow** (brand kit + ad format + avatar + product) see `workflows/dtc-ads.md`.

### The 9 Marketing Modes

| Mode | What it's for | Hook/Setting allowed? |
|---|---|:-:|
| `ugc` | **Default.** Casual, organic-feel content from a presenter | ✅ |
| `ugc_how_to` | Tutorial / explainer — "here's how to use this" | ✅ |
| `ugc_unboxing` | Unboxing reveal — "just got this in the mail" | ✅ |
| `product_showcase` | Clean product highlight, polished | ❌ |
| `product_review` | Presenter giving an opinion on the product | ✅ |
| `tv_spot` | Broadcast-style commercial, higher production | ❌ |
| `wild_card` | Experimental — model picks the vibe | ❌ |
| `ugc_virtual_try_on` | Person trying on clothing / accessories — UGC vibe | ✅ |
| `virtual_try_on` | Same but polished, model-driven | ❌ |

**"Hook/Setting allowed"** = whether reusable opening hook prompts and scene-setting prompts can be prepended to the user prompt. Polished modes (`product_showcase`, `tv_spot`, `wild_card`, `virtual_try_on`) ignore hooks/settings.

**Default when the user doesn't specify a mode:** `ugc`.

### Picking the Mode

| User phrasing | Mode |
|---|---|
| "UGC", "creator video", "talking head", "phone-shot", "selfie video", "vlogger" | `ugc` |
| "tutorial", "how to use", "demonstrate", "walkthrough", "explainer" | `ugc_how_to` |
| "unboxing", "just got this", "reveal", "first impression" | `ugc_unboxing` |
| "product showcase", "highlight reel", "showroom" | `product_showcase` |
| "review", "my take on", "comparing X to Y", "honest opinion" | `product_review` |
| "TV ad", "commercial", "broadcast", "polished ad spot" | `tv_spot` |
| "surprise me", "something different", "experimental" | `wild_card` |
| "try on" / "wearing the X" + organic vibe | `ugc_virtual_try_on` |
| "fashion shoot", "lookbook", polished try-on | `virtual_try_on` |

If the user mentions a product / brand but no mode word, default to `ugc`. If they say "ad" without "TV ad" / "commercial" / "broadcast", default to `ugc` (most modern ads are UGC-shaped).

### Mode → Kolbo MCP Routing

The mode determines which Kolbo MCP tool to call, what defaults to set, and what's forbidden.

| Mode | Primary tool |
|---|---|
| `ugc`, `ugc_how_to`, `ugc_unboxing`, `ugc_virtual_try_on`, `product_review` | `generate_video_from_image` (frame-first) OR `generate_elements` (Visual DNA → video) |
| `product_showcase` | `generate_creative_director` with `workflow_type: "video"` (for multi-shot) OR `generate_video` (single) |
| `tv_spot` | `generate_creative_director` with `workflow_type: "video"` (3–6 shots for a beat structure) |
| `virtual_try_on` | `generate_elements` with character Visual DNA + product as `reference_images` |
| `wild_card` | User's chosen model with broader prompt latitude (no mode-specific defaults) |

Aspect / duration / sound / captions defaults for the `ugc*` family live in "UGC Family Defaults" below.

**Pick the actual model** with `list_models({ type: "..." })` and validate caps before firing — see `references/workflows/cost-and-validation.md`.

### The Look Itself — read `workflows/ugc-smartphone.md`

The modes and defaults below decide WHAT gets made. The physics that make it read as a
real phone capture — deep depth of field, computational HDR, named available light,
imperfect framing — live in `workflows/ugc-smartphone.md`. Read it before writing any
UGC prompt: **"smartphone" on its own does not produce a smartphone look**, and that file
is also where the still-image cases live (a user's product photo re-shot as a customer
snapshot, the to-camera vs observational subject dial).

### UGC Family Defaults (CRITICAL)

When ANY `ugc*` mode is selected, snap to these unless the user explicitly overrides:

| Setting | UGC default | Why |
|---|---|---|
| `aspect_ratio` | `9:16` | TikTok / Reels / Shorts are vertical-first |
| Visual aesthetic | Phone-shot, handheld, natural lighting | UGC works because it doesn't look produced |
| Camera language | Slight handheld sway, selfie-arm framing, key light from window/screen | NOT slow dollies, NOT crane moves, NOT studio key |
| Energy | "Talking to a friend" — casual, direct-to-camera, occasional gestures | Not theatrical, not staged |
| **Captions / subtitles / text overlays** | **NEVER add** unless explicitly requested | Users add captions in CapCut / native editor; baked-in captions limit reuse |
| **Brand watermarks / lower-thirds / banners** | **NEVER add** unless explicitly requested | Same reason |
| Music / SFX | OFF by default unless asked | They'll layer their own audio in post |
| Length | Model's `default_duration` (typically 5–8s) | Shorter = more usable for the algorithm |

**Phrases that activate UGC defaults:** "UGC", "user-generated", "creator video", "TikTok", "Reels", "Shorts", "POV", "selfie video", "phone-shot", "vlogger", "talking head" (when context implies social media), "for social", "Instagram video", "YouTube short".

**Phrases that OVERRIDE UGC defaults** (use them as-given, not as UGC): "commercial", "ad spot" (without UGC), "cinematic", "broadcast", "TV ad", "horizontal", "16:9", "landscape", "billboard". When the user uses one of these, switch to `product_showcase` or `tv_spot` mode.

### Hooks & Settings (concept)

Hooks and settings are **reusable opening angles / scene contexts** that get prepended to the user's prompt. Kolbo does not yet expose these as first-class MCP primitives, but the concept is portable:

- **Hook** = the opening line / angle of the ad (the first 1–2 seconds that earn the scroll). Example hooks: "POV: you just discovered X", "Why I stopped buying Y", "3 reasons this X is worth it", "Watch this before you buy a Y".
- **Setting** = the scene/environment context. Example settings: "in a bright minimalist kitchen", "walking in a busy city street", "on a yoga mat at golden hour".

**When the user asks for an ad and doesn't specify the opening**, offer 2–3 hook options (one-liner each) in a labeled-question style — never freeform "what hook?" Same for setting if the brief is location-agnostic.

**Whitelist rule:** hooks/settings only make sense for `ugc`, `ugc_how_to`, `ugc_unboxing`, `product_review`, `ugc_virtual_try_on`. For `product_showcase`, `tv_spot`, `wild_card`, `virtual_try_on` — skip hooks/settings; those modes are concept-driven not hook-driven.

**Mutually exclusive with ad references** (next section). Pick one path per generation.

### Ad References (modeling new ads after existing ones)

Sometimes the user has a reference ad they want to model the new ad after — their own previous winning ad, a competitor's ad, or a viral video. Kolbo path:

1. **Upload the reference video** via `upload_media` (returns CDN URL).
2. **Pass it as `reference_videos`** to `generate_elements`, OR as `source_video` to `generate_video_from_video` (if you want to actually restyle / re-shoot the reference).
3. **Describe in the prompt** what to preserve from the reference (`@video1`'s pacing / camera move / lighting / cut rhythm) and what to change (subject / product / setting).
4. **Tag with `@video1`** per `workflows/visual-dna.md` reference-tagging rules.

**Mutually exclusive with hooks/settings** — pick one composition path per generation. Either reference-driven (use `@video1`) or composed-from-blocks (hook + setting + product). Mixing produces muddled output.

### Avatars (= Visual DNA characters)

What other platforms call "preset avatars" or "custom avatars" Kolbo calls **Visual DNA characters**. Two ways to get one:

- **Existing character** — use `list_visual_dnas` to find one the user has already created.
- **New character** — create with `create_visual_dna({ type: "character", name, images: [...] })`. See `workflows/visual-dna.md` for the full creation flow (pre-flight, naming rule, generate-reference-images-first).

**For UGC modes:** an avatar is optional if the brief clearly mentions a person (the model can synthesize one). Pass `visual_dna_ids` when the user wants a *specific* presenter — their face, the brand founder, a previously trained character.

**Always use `@<dna-name>` in the prompt** when passing `visual_dna_ids` — see `workflows/visual-dna.md` `@name` rules.

### Products (image upload + reference)

For ads that feature a specific product:

1. **Upload product photo** via `upload_media` → Kolbo CDN URL.
2. **Pass as `reference_images`** to `generate_creative_director` / `generate_elements` / `generate_video_from_image`.
3. **Tag with `@image1`** in the prompt.
4. **After the user approves the product asset, log it in `.kolbo/production.md`** under `### Products` so future ads reuse the same CDN URL. Pending variants stay out.

If the user gives a **product URL** instead of a photo, see `workflows/research-first.md` — scrape, extract images, re-host via `upload_media`, persist as a brand kit at `.kolbo/brand-kits/<slug>.md`.

<!-- SKILL-ONLY: no server parity — UGC output routes through the creative-director / veo / seedance enhancers, so any server-side rule lives in those parity files, not here. -->

### Multi-Slot Board Method (structured shot specs + character consistency)

For any multi-shot UGC / review / how-to where the SAME presenter must stay identical across shots, compose the prompt as explicit **slots** and lock identity with a **board-first** pass. This is a prompt-only convention — no special MCP mode; it uses `generate_image` (board) + `generate_elements` / `generate_video_from_image` (per-slot animate) that already exist.

#### 1. Structured input slots

Define each shot as one row. Fill every column before generating — blanks are where identity/quality drift creeps in.

| Slot | Arc role | POV / framing | Presenter action | Product visibility | Aspect | Audio |
|---|---|---|---|:-:|:-:|:-:|
| 1 | hook | selfie arm, chest-up, eye contact | states the problem / grabs attention | held up to camera | 9:16 | monologue seg 1 |
| 2 | demo | slightly wider, hands in frame | uses / demonstrates the product | in active use | 9:16 | monologue seg 2 |
| 3 | payoff | back to selfie framing | reaction + soft CTA | resting in hand / on surface | 9:16 | monologue seg 3 |

Scale to 2–6 slots. Keep `hook → demo → payoff` as the minimum arc; add `tension` / `proof` slots between demo and payoff for longer reviews.

#### 2. Rendering rules (hard invariants — apply to EVERY slot)

- One aspect ratio across all slots (UGC = `9:16`). Never mix.
- **Identity lock**: same presenter, same wardrobe, same lighting environment across all slots — bind identity by tagging `@<dna-name>` in every slot description (identity binds via the DNA; the phrase "same character throughout all shots" is FORBIDDEN — see `models/seedance.md`).
- Hands and product must read cleanly — no deformed hands, no floating / clipping product, product logo legible when held.
- Phone-shot aesthetic (handheld sway, window/screen key) unless the mode is polished (`tv_spot`, `product_showcase`).

#### 3. Board-first consistency (the grid technique)

Before animating, generate ONE composite board image that locks the presenter's identity, then animate each panel:

1. `generate_image` a labeled N-panel grid (2×2 or 1×N) of the presenter across the slot poses — front hook pose, hands-on-product demo pose, reaction pose — locked to `visual_dna_ids` (the presenter's Visual DNA). Aspect `16:9` for the board sheet.
2. Treat that board image's CDN URL as the **`board_media_id`** — the single source of truth for identity.
3. Animate each slot with `generate_video_from_image` / `generate_elements`, passing the board panel (and product) as `reference_images` and tagging `@image1`, so every clip inherits the same face/wardrobe.

This mirrors how the best UGC pipelines keep a character consistent: lock once as a board, then move each shot — not N independent generations that drift.

#### 4. Structured parameters (what to carry per generation)

Track these so each slot's call is reproducible and the arc stays coherent:

| Param | Meaning | Maps to |
|---|---|---|
| `arc_role` | hook / tension / demo / proof / payoff | prompt framing + shot order |
| `board_media_id` | the locked board image URL | `reference_images` (`@image1`) |
| `character_media_id` / `visual_dna_id` | presenter identity | `visual_dna_ids` (`@<dna-name>`) |
| `product_media_id` | product photo URL | `reference_images` (`@image2`) |
| `input_tier` | `draft` (fast preview) vs `hero` (final) | model + resolution choice |
| `monologue_segment` | the spoken line for this slot | prompt audio/dialogue line |
| `aspect_ratio` / `duration` / `sound_enabled` | per UGC Family Defaults above | MCP call args |

#### 5. Worked example (brief → slots → board → clips)

Brief: *"15s UGC review of a skincare serum, tech-savvy woman creator."*

1. Ensure/create presenter Visual DNA (tech-savvy woman) → `visual_dna_id`.
2. Board: `generate_image` a 3-panel `16:9` sheet — (a) chest-up hook holding the serum, (b) hands applying it, (c) thumbs-up reaction — `@<dna-name>` tagged in every panel description, locked to the DNA. → `board_media_id`.
3. Slots (each `9:16`, ~5s, sound OFF, animate from the matching board panel + product `@image2`):
   - Slot 1 (hook): "Before this serum my routine was five products…" holding it to camera.
   - Slot 2 (demo): hands applying, product in active use.
   - Slot 3 (payoff): reaction + "…now it's just one step." soft CTA.
4. Deliver as a structured message (setup + monologue + media), humanized refs (names/thumbnails, not raw IDs).

### UX Rules

1. **Always pick a mode explicitly.** Don't auto-pick from one ambiguous word. If the user said "make me an ad" with no other signal, offer labeled options: `[UGC / TV Spot / Product Showcase / Surprise me]`.
2. **Always confirm aspect ratio + duration + sound** before firing — these materially change output and cost. One question, labeled options.
3. **Retries:** one retry only when `failure.retryable === true` or the generation completed with empty URLs (SKILL.md "⚠️ Generation lifecycle"); otherwise surface the reason and let the user adjust prompt or product.
4. **Show results without dumping URLs** — see SKILL.md "Generated URLs in chat".

### Prompt Template Seed for UGC

```
UGC selfie video, vertical 9:16, handheld phone aesthetic.
{presenter description or @<dna-name>} in {everyday setting},
{energy level: relaxed | enthusiastic | curious | reactive}.
They {natural action with the product/subject},
talking directly to camera.
Phone-shot lighting (window/screen key light),
slight handheld sway, no cinematic moves.
Style: authentic creator content, NOT polished commercial.
Sound: ambient room tone only, no music, no SFX overlay.
```

### Prompt Template Seed for TV Spot

```
3-shot broadcast commercial, cinematic 16:9.

Shot 1 [0–5s] — {establishing hook}: {wide angle subject + camera move}, {lighting}, {tone setter}.
Shot 2 [5–15s] — {product reveal / demo}: {medium shot with product in focus}, {practical action}, {emotional beat}.
Shot 3 [15–25s] — {payoff + CTA}: {close-up or pull-back}, {brand line in dialogue or SFX}, {final hold}.

Style: {brand mood — e.g., warm + premium / clean + modern / bold + youthful}.
Audio: full mix — dialogue + score + SFX. Music: {genre/tempo}.
```

(Run via `generate_creative_director` with `workflow_type: "video"`, `scene_count: 3`.)
