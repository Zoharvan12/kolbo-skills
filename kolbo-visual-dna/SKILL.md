---
version: 0.9.0
name: kolbo-visual-dna
description: |
  Train a Visual DNA — a personalized model that captures the visual identity
  of a character, style, product, or scene from reference media. Kolbo uses
  the trained DNA for identity-faithful image and video generation across
  every DNA-aware tool.

  Use when: "create a Visual DNA", "train my face", "make my digital twin",
  "build me an avatar", "learn my appearance", "create a character of me",
  "set up identity for video", "I want my face in generated images",
  "consistent character across X", "keep the same look/face/product".

  Chain: train Visual DNA (one-time, returns vdna_id) → use in
  kolbo-generate / kolbo-creative-director / kolbo-marketing-studio /
  kolbo-product-photoshoot / kolbo-marketplace-cards via `visual_dna_ids: ["..."]`
  with the `@NAME` tag in the prompt.

  NOT for: one-shot face swaps (use kolbo-generate with `source_images`),
  named real public figures (refuses on policy), one-time edits without
  reusing the identity.
argument-hint: "[name] [photo paths...] [--type character|style|product|scene]"
allowed-tools: Bash, Read, Write, Edit
---

<!-- AUTO-GENERATED from kolbo-code packages/opencode/skills/kolbo — DO NOT EDIT.
     Edit the canonical skill and let .github/workflows/sync-skill-to-plugin.yml regenerate this. -->

# Kolbo Visual DNA — Character / Style Consistency

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

## Visual DNA — Character / Style Consistency

Load this file when the user wants character or style consistency across multiple images/videos, OR when any generation call passes `visual_dna_ids`, OR when the user references a stored DNA by name.

### What Visual DNA Is

Visual DNA profiles capture the visual "identity" of a character, style, product, or scene from reference media. Pass `visual_dna_ids` to any compatible generation tool — the server expands the DNA's reference images and auto-routes to the model's edit variant when appropriate.

### Workflow

1. **Create** a profile with `create_visual_dna` — provide reference images (max 4 — if the user gives more, pick the 4 most representative or ask which to keep; never pass 5+), optionally video and audio.
2. **Types**: `character` (default), `style`, `product`, `scene`, `environment`.
3. **Use** the profile by passing its `id` in `visual_dna_ids` in: `generate_image`, `generate_creative_director`, `generate_elements`, `generate_video_from_image`, `generate_video_from_video`, `generate_first_last_frame`.
4. **List/inspect** profiles with `list_visual_dnas` / `get_visual_dna`.

**Server-side auto-routing:** passing `visual_dna_ids` is enough — the server expands the DNA's reference images and auto-routes the selected text-to-image model to its image-editing variant (e.g. `nano-banana-2` → `nano-banana-2-image-editing`). You do NOT need to also pass `reference_images` when using DNA. If the chosen model has no edit variant at all, the server falls back to using the DNA's images as style references on the t2i model. DNA payloads are never silently dropped.

### ⚠️ Pre-flight: Verify the Visual DNA Exists Before Using It (MANDATORY)

NEVER reference a Visual DNA by name, role, or assumed identity without first confirming it exists in the user's library. This is a frequent failure mode: the user mentions a character ("אסתר", "Maya", "the model from before"), the agent assumes a matching Visual DNA exists, calls `generate_image` / `generate_elements` with a guessed or fabricated `visual_dna_ids` value, and the generation fails or produces the wrong identity.

**Before** any generation call that uses `visual_dna_ids`:

1. Call `list_visual_dnas` to get the actual available DNAs (id + name).
2. Match the user's reference (by name, type, or your `.kolbo/production.md` log) to a real DNA in that list.
3. If there is **no match**, STOP and ask the user one of:
   - "I don't see a Visual DNA named <X> in your library. Do you want me to create one now (I'll need reference image(s)), use an existing DNA (<list>), or proceed without DNA using direct reference images?"
4. Only proceed once you have a real `vdna_*` id confirmed by either the list or a fresh `create_visual_dna` call you just made.

Do NOT:
- Invent a Visual DNA id or assume one exists from context.
- Use the same DNA id for a different character because "it sounded close."
- Carry a DNA id from `.kolbo/production.md` into a new generation without re-confirming it still exists (`list_visual_dnas` is cheap — call it).

When the user says "use the model אסתר" but you've only created a DNA for "זוהר", you MUST ask before generating — never silently substitute or guess.

### ⚠️ Don't re-fetch / re-list your own outputs (CRITICAL)

After a generation tool returns its URLs, those URLs are **already** in the canvas (the desktop app's gallery panel) and in `.kolbo/production.md`. Do **NOT** call `list_media`, `get_media`, `get_media_stats`, `list_visual_dnas`, or `chat_send_message` with `media_urls` on those URLs just to "verify" or "fetch thumbnails of the results":

- It burns credits and time for zero new information.
- Every such tool call streams partial output into the session, which forces the desktop canvas to re-evaluate (visible flicker on the gallery tiles).
- The thumbnails returned by `list_media` / `get_media` are the SAME asset you just generated.

**Only call list/get media tools when:**
- The user explicitly asks ("what do I have in my library?", "show me my old DNAs").
- You need details about something generated in an **earlier session** that you don't have a record of.
- You're chasing a specific user reference like "the rainy clip from yesterday" that isn't in the current chat's `.kolbo/production.md`.

For media you generated this session, you already know the prompt, model, and result URL — write that into `.kolbo/production.md` and reference it from context.

### ⚠️ Presenting list results — show thumbnails (MANDATORY)

When you display the result of `list_visual_dnas`, `list_media`, `list_moodboards`, or any other tool that returns items with image/thumbnail URLs, render each item's thumbnail as a markdown image so the user can actually see what they have. The chat view auto-renders both `![](url)` markdown and bare image URLs, plus auto-injects a player below links to videos/audio.

Do NOT dump a text-only bullet list of ids + names when a thumbnail field is available in the response.

**Visual DNA listing format:**
```
Visual DNAs (6):
1. **Maya** — `vdna_abc` (character)
   ![Maya](https://cdn.kolbo.ai/.../maya-thumb.jpg)
2. **Tokyo Neon** — `vdna_xyz` (style)
   ![Tokyo Neon](https://cdn.kolbo.ai/.../tokyo-thumb.jpg)
```

**Media listing format:**
```
1. **rain-loop.mp4** — `med_abc` (video, 5s, 1080p)
   https://cdn.kolbo.ai/.../rain-loop.mp4
2. **coffee-01.png** — `med_def` (image, 1024x1024)
   ![](https://cdn.kolbo.ai/.../coffee-01.png)
```

Fields to read for the image source (use the first one present on the item): `thumbnail`, `thumbnail_url`, `preview_url`, `url`, `image`. For videos and audio, use the file `url` directly.

### ⚠️ @name Syntax — ALWAYS use it when passing visual_dna_ids (MANDATORY)

Whenever a generation call passes `visual_dna_ids` (even just one), the prompt MUST refer to each Visual DNA by `@<exact-name>` — the literal `name` field as it was set in `create_visual_dna` and as it appears in `list_visual_dnas`. This is how the engine binds the DNA to a role in the scene. Without `@name`, the engine guesses, drops the DNA, or blends multiple DNAs together.

**Use the actual stored name, programmatically.** When you call `list_visual_dnas` (or `create_visual_dna`), read the `name` field off the response and use that exact string after the `@`. Do NOT:

- Translate the name into another language ("אסתר" / "esther" / "אסתי" — pick whichever string is in `name` and use ONLY that one).
- Invent a friendlier alias ("the model", "המודל", "her", "Zohar's", "the left man", "the man on the LEFT").
- Write a "Visual DNA anchors:" prose block that describes position/wardrobe but never writes `@ExactName`.
- Write the character's name in plain text without the `@` prefix.
- Drop the `@name` when only one DNA is passed — the engine still needs the binding so it knows the DNA is the *subject* and not a passive style.

**Wrong** (DNA `name` is `esther_model`, user wrote prompt in Hebrew):
```
prompt: "אסתר לובשת שרשרת זהב, פורטרט חצי גוף"
visual_dna_ids: ["vdna_abc"]
```
The engine sees plain text "אסתר" and has no idea it should bind to the DNA.

**Right:**
```
prompt: "@esther_model לובשת שרשרת זהב, פורטרט חצי גוף"
visual_dna_ids: ["vdna_abc"]   // esther_model
```

**Multi-DNA example:**
```
prompt: "@dana standing in @shop, picking up a product"
visual_dna_ids: ["vdna_abc",  // dana
                 "vdna_xyz"]  // shop
```

**How `@name` actually binds:** kolbo-api parses the prompt for `@<name>` mentions, queries the DB for a Visual DNA whose `name` matches (case-insensitive), and **replaces the `@name` token with that DNA's stored `systemPrompt`**. If no `@name` is in the prompt, the systemPrompt never gets injected — the `visual_dna_ids` slot is effectively wasted.

The match is **literal and case-insensitive**, so:
- The `@name` must equal the stored `name` field (e.g. if `name: "esther_model"` → write `@esther_model`, not `@Esther`, not `@אסתר`, not `@the model`).
- Any-language characters are supported — if the DNA was created with `name: "אסתר"` you write `@אסתר`. Use the EXACT stored string.
- Mentions terminate at punctuation (`.,!?`), double-spaces, another `@`, or end of string. So `@maya, wearing...` matches `maya`.

This composes with `@image1` / `@image2` positional tags for plain reference/source images — see "Reference Tagging" below.

#### ⚠️ Naming rule for `create_visual_dna` — NO SPACES (MANDATORY)

The `name` you set MUST be a **single token, lowercase, no spaces, ASCII-safe** — `esther_model`, `dana`, `tokyo_neon`, `brand_red`. Never `Sarah Johnson`, never `the red dress`.

Reason: the prompt parser stops the `@<token>` match at the first space (and at `.,!?` punctuation). So `@Sarah Johnson` matches *only* `Sarah` — if no DNA named `Sarah` exists, the mention is silently dropped and the DNA never binds. A single-token name is the only way to guarantee inline `@name` works in any sentence, in any language, without forcing the user to write awkward punctuation around it.

Use underscores for multi-word concepts (`old_town`, not `Old Town`). When the user proposes a name with spaces, accept the intent but collapse it into a single token before storing (`"Sarah Johnson"` → `sarah_johnson`) and tell them once how you'll refer to it. Source of truth: [kolbo-docs / Visual DNA & @ References](https://docs.kolbo.ai/kolbo-code/visual-dna).

### Reference Tagging — `@image1` / `@video1` / `@Audio1`

When a generation call passes ANY references (`reference_images`, `source_images`, `reference_videos`, `source_videos`, `reference_audio`, `elements`, OR `visual_dna_ids`), name them inside the prompt so the model knows **which asset plays which role**. Without tags, the engine guesses and the wrong reference bleeds into the wrong slot.

**Tag namespaces, used together:**

| Tag | Refers to | Order rule |
|---|---|---|
| `@image1`, `@image2`, … | Plain images in `reference_images` / `source_images` | Position in the array — `@image1` = `images[0]` |
| `@video1`, `@video2`, … | Videos in `reference_videos` / `source_videos` / video `elements` slots | Position in the array |
| `@Audio1`, `@Audio2`, … | Audio in `reference_audio` / `audio` slots (lipsync source, music style ref, voice clone, etc.) | Position in the array |
| `@<dna-name>` | A Visual DNA — use the literal `name` field | Name-based, never positional |

**Reserved**: `@Image\d+`, `@Video\d+`, `@Audio\d+` are reserved by the Kinovi Omni Reference parser — they are NOT looked up as Visual DNAs. Never name a Visual DNA `Image1` / `Video2` / etc. (kolbo-api rejects this on creation).

**How to write a tagged prompt:**

```
Place @maya at the coffee-shop counter from @image1, wearing the leather jacket from @image2.
Keep the warm window light from @image1; ignore the people in the background of @image2.
```

```
Animate @maya walking through @video1's snowy street, matching the camera move of @video1; ignore the people in @video1.
```

```
Lipsync @video1's speaker to the dialogue track @Audio1, keeping the original ambient room tone of @video1.
```

**Rules:**

1. **Order is contract.** `@imageN` / `@videoN` / `@AudioN` are bound to position N in the array you pass. Reordering silently changes what each tag points to — don't reorder mid-conversation; if you need to add a new ref, append it rather than inserting.
2. **For edits, the source is `@image1` (or `@video1`).** In `generate_image_edit`, the first entry of `source_images` is the canonical base.
3. **Visual DNA tags are name-based, not positional.** `@maya` always means the DNA you registered as `name: "maya"`, regardless of where its id sits in `visual_dna_ids`.
4. **Tag every reference you actually pass.** If you pass a reference but never mention it in the prompt, the engine often treats it as decorative — either drop it or name it explicitly.
5. **Tags carry across the production log.** When you log a generation to `.kolbo/production.md`, write the prompt with the tags intact and record the `@name → URL` / `@name → vdna_id` binding alongside.
6. **Tag even single-reference calls when a DNA, video, or audio is involved.** Single plain image with no DNA can use prose ("this image"), but as soon as the call also carries a DNA, a video ref, or an audio ref, tag every asset so the engine knows the subject vs. the modifier role.

**Failure modes the tags fix:**

| Without tags | With tags |
|---|---|
| "Combine these two images" → engine averages them | "Put the subject from @image1 into the scene of @image2" |
| "Same character, new outfit" with 2 refs → wrong face | "Keep @maya's face from the Visual DNA; apply the outfit from @image1" |
| "Edit this" with 3 source images → engine edits whichever is first | "In @image1, replace the sky with the sky from @image2" |
| "Lipsync this video to this audio" with 2 audio tracks → wrong track picked | "Lipsync @video1 to @Audio1; ignore @Audio2 (that's the music bed)" |
| "Match this video's style" with 2 video refs → blended motion | "Use @video1's camera move; use @video2's color grade" |
| "Music like this" with a reference track → engine ignores it | "Compose in the style of @Audio1, but slower and without vocals" |

### Mixing References, Visual DNAs, and Moodboards

You can combine all three reference types in a single call — they're additive, not exclusive. The system blends them; the model uses whichever it can interpret best for the prompt.

| Tool | `source_images` | `reference_images` | `visual_dna_ids` | `moodboard_id` |
|---|:-:|:-:|:-:|:-:|
| `generate_image` | — | ✅ | ✅ | ✅ |
| `generate_image_edit` | ✅ required | — (source_images plays this role) | ✅ | ✅ |
| `generate_creative_director` | — | ✅ (applied to every scene) | ✅ (locks character across scenes) | ✅ / `moodboard_ids` |
| `generate_elements` (video) | — | ✅ (also `reference_videos`, `audio_url`) | ✅ | — |

**Practical combinations:**
- *"Make her in a Tokyo street, matching this mood board, with the same face as Visual DNA Maya"* → `generate_image` with `visual_dna_ids=[maya], moodboard_id=tokyo_neon`. No `reference_images` needed.
- *"Same character, but place her like in this composition"* → `generate_image` with `visual_dna_ids=[maya], reference_images=[layout.png]`. The DNA owns the *face*; the reference owns the *pose/composition*.
- *"Edit this photo to give her the leather-jacket look from Visual DNA Maya"* → `generate_image_edit` with `source_images=[photo.png], visual_dna_ids=[maya]`. Source is what's edited; the DNA injects the wardrobe identity.
- *"4 angles of this character, brand-styled"* → `generate_creative_director` with `scene_count=4, visual_dna_ids=[maya], moodboard_id=brand_x`. DNA keeps the face; moodboard sets the look.
- *"Generate 6 product hero shots; here are 3 reference comp images and our brand moodboard"* → `generate_creative_director` with `scene_count=6, reference_images=[comp1, comp2, comp3], moodboard_id=brand_x`. No DNA needed if it's a product not a face.

**Rule of thumb:**
- Need an **identity** (face, character, specific product) to stay constant → `visual_dna_ids`.
- Need a **composition / pose / mood reference** → `reference_images`.
- Need an **overall style / palette / brand look** → `moodboard_id`.
- Need all three at once → pass all three. They compose.

### Visual DNA Limits

Read `max_visual_dna` from `list_models` for the exact cap, AND `supports_visual_dna` for the on/off boolean. A model can support DNA without an explicit cap, or have a non-null cap but silently ignore DNA on certain paths (e.g. `generate_video`). Typical ranges: image models (non-Kling) up to **8**, Kling image models **3**, Elements video models **3–5**, everything else up to **3**.

### ⚠️ Visual DNA Creation — Always Generate Reference Images First (MANDATORY)

**Before calling `create_visual_dna` for a character**, always generate 2 reference images first and include them alongside any user-provided images. These give the Visual DNA engine multi-angle coverage and dramatically improve consistency.

**Step 1 — Generate both images in parallel (one `generate_image` call each, fire simultaneously):**

1. **4-angle character sheet** — prompt: `"[character description], character reference sheet showing front view, back view, left side view, right side view, four panels arranged in a 2x2 grid, neutral solid background, full body, photorealistic"`, aspect ratio `16:9` (or `3:2` — always landscape, see the aspect-ratio rule below)
2. **Close-up portrait** — prompt: `"[character description], close-up portrait, face and shoulders, neutral solid background, soft studio lighting, photorealistic"`, aspect ratio `1:1`

**Step 2 — Call `create_visual_dna`** with:
- `images`: the 4-angle sheet URL first, then the close-up URL — **plus** the user's reference photo(s) only if they provided one (i.e. a real person or existing character they want to match). If they gave no reference image, the 2 generated images alone are sufficient.
- `type`: `"character"`
- `name`: single-token lowercase descriptive name (see naming rule above)

**Why:** A single reference photo only shows one angle. The close-up gives the engine facial detail; the 4-angle sheet gives it body geometry and pose range. Together they produce far more consistent generations.

**Skip this only if** the user explicitly says "just use my image as-is" or provides 3+ reference images already covering multiple angles.

### When to Use

- User wants the same character across multiple **images** or a campaign → `generate_image` / `generate_creative_director` with `visual_dna_ids`
- User wants to animate a character in video using **elements models** (Seedance 2, Kling O3 Reference, Grok Imagine, Veo 3.1, etc.) → `generate_elements` with `visual_dna_ids`
- User wants a consistent brand style across a campaign → `generate_creative_director` with `visual_dna_ids`
- User references "keep the same look", "same character", or "use that character"
- User provides reference photos of a person/product to maintain consistency
- User asks to put a character in a specific environment or scene → create both a character Visual DNA and an environment Visual DNA, use `@name` syntax to place them

### ⚠️ When NOT to Use Visual DNA

- **Animating an image** → `generate_video_from_image`; the source image IS the reference, don't add `visual_dna_ids`.
- **Video DNA support is limited to `generate_elements`** (Seedance 2, Kling O3 Reference, Grok Imagine). `generate_video`, `generate_video_from_image`, and `generate_first_last_frame` all ignore `visual_dna_ids` — for character-consistent video, route through `generate_elements`.

### Folders — organizing a large cast

Tools: `list_visual_dna_folders`, `create_visual_dna_folder` (`name`, optional hex `color`), `update_visual_dna_folder`, `delete_visual_dna_folder`, `move_visual_dna_to_folder`.

- Folders are user-scoped and flat; names are unique per user (409 on duplicate).
- **Personal DNAs only** — global presets must be imported first; organization DNAs cannot go in personal folders (server rejects with a clear message).
- **Deleting a folder never deletes DNAs** — contents move back to root (`items_moved_to_root` in the response). Mention this instead of asking for confirmation on non-empty folders.
- **Creating many characters for one production?** Create the folder FIRST, then `move_visual_dna_to_folder` each DNA right after `create_visual_dna` — don't leave a big cast unsorted at root.
- To list a folder's contents: `list_visual_dnas` and filter by each profile's `folder_id` (there is no server-side folder filter).

### Character sheet — offer it for character DNAs

`generate_character_sheet` builds a multi-angle turnaround from reference image URLs — the strongest consistency booster for a character DNA. It CHARGES CREDITS, so:
- When the user is about to create a **character** DNA, proactively OFFER it: "want me to generate a character sheet first? It makes the character far more consistent and costs a few credits." Run it only on a yes.
- Flow: `generate_character_sheet {image_urls}` → show the sheet → `create_visual_dna {name, images, character_sheet_url: <url>}`.
- For non-character DNAs (style/product/environment), skip it.

#### ⚠️ Aspect ratio — character sheets and bibles are LANDSCAPE

Default every character sheet, turnaround, and character/production **bible** sheet to **`3:2` or `16:9`** unless the user asks for something else.

These are multi-panel grids laid out side by side — front, back, left, right, plus detail callouts. A square or portrait frame forces the panels to stack, which shrinks each one and costs the engine the very facial and body detail the sheet exists to capture. Landscape gives each panel usable width.

- Character sheet / turnaround / bible sheet → `3:2` or `16:9`
- Close-up portrait reference → `1:1` (a single panel, so the grid logic doesn't apply)
- Only deviate when the user explicitly names a different ratio.
