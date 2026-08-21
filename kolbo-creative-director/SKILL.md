---
version: 0.9.6
name: kolbo-creative-director
description: |
  Generate 2–8 related image OR video outputs from one brief — storyboards, ad
  campaigns, character lookbooks, multi-angle/multi-pose sets, scene variations.
  This is an AGENT, not a niche tool — it plans each scene's prompt internally,
  locks consistency, and runs scenes in parallel.

  Use when: "make 4/6/8 [shots, scenes, variations, angles, poses, outfits,
  moods, settings, frames]", "show the character in N different ___",
  "create a storyboard / ad campaign / product set", "key frames for a video",
  "8 angles of this character", "ad pack with 4 variants",
  "campaign batch", "lookbook", "scene 1 scene 2 scene 3".

  Chain: pair with kolbo-visual-dna (lock character across scenes), then optionally
  with kolbo-generate (animate each frame via generate_video_from_image).

  NOT for: a single image (use kolbo-generate), modifying ONE existing image
  (use kolbo-generate with generate_image_edit), N variations of THE SAME exact
  prompt with random seeds (use kolbo-generate with num_images).
argument-hint: "[scene-count] [brief] [--mode photo|video|cinema] [--visual-dna-id <id>]"
allowed-tools: Bash, Read, Write, Edit
---

<!-- AUTO-GENERATED from kolbo-code packages/opencode/skills/kolbo — DO NOT EDIT.
     Edit the canonical skill and let .github/workflows/sync-skill-to-plugin.yml regenerate this. -->

# Kolbo Creative Director — Multi-Scene Batches

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
- **Conversational replies** ("4 shots ready"): keep prose short; Library already shows the gallery.

Avoid bare URL dumps and HTML `<table>` grids — Library already provides a gallery.

**After `generate_creative_director` completes** — share results as individual URLs, one per scene. Do NOT create an HTML grid artifact.

**Always** park every successful URL + `session_id` in `.kolbo/production.md` as a **candidate**. Promote to Approved and advance the plan only after the user confirms — see `references/workflows/production-log.md`.

<!-- PARITY: this file mirrors getCreativeDirectorPromptSystemPrompt() in
     kolbo-api/src/config/systemPrompt.js (lines ~1062–1155).
     When that function changes, update this file in the same session. -->

## Creative Director — Multi-Scene Prompt Rules

Load this file when the user wants **2–8 related outputs from one brief** — storyboards, ad campaigns, character lookbooks, multi-angle/multi-pose sets, scene variations. For single-image work see `models/gpt-image.md` / `models/nano-banana.md`. For single-clip video see `models/seedance.md` / `models/veo.md`.

**Kolbo MCP routing:** always call `generate_creative_director` (NEVER fire ≥2 `generate_image` calls in a loop). Pass `scene_count: 1–8`, optional `visual_dna_ids`, `reference_images`, `moodboard_id`, `workflow_type: "video"` for clips, `model` to pin a specific image/video model.

### What the Creative Director Tool Is

A multi-scene batch generator. Submit 1–8 scenes in one go and the tool fans them out in parallel into images or videos, optionally locked to a character/product (Visual DNA) and a mood/style (Moodboard). Total wall time = slowest scene, not the sum.

#### The Three Modes
- **Photo Auto Pilot** — each scene = one image. Optional reference images for style/subject. Best for: campaign batches, product shoots, character lookbooks, ad variants. Pass `workflow_type: "image"` (or omit — image is default).
- **Video Auto Pilot** — each scene = one short video clip. Optional reference image per scene anchors the starting frame. Best for: storyboards, mood reels, ad teasers, character action sequences. Pass `workflow_type: "video"`.
- **Cinema Manual** — per-scene **first frame + last frame** + per-scene prompt. Full cinematic control over composition transitions. Best for: hero shots, controlled camera moves, deliberate edits.

#### Identity & Style Locks
- **Visual DNA** — attach a character/product preset via `visual_dna_ids` to lock identity across all scenes. Up to **8 Visual DNAs** can be active at once (e.g. main character + product + side character). See `workflows/visual-dna.md` for the `@name` syntax — every DNA must be tagged inside the prompt.
- **Moodboard** — attach `moodboard_id` (or `moodboard_ids`) for a curated mood/style reference that anchors the aesthetic of the whole batch.
- When the user mentions a recurring character/product, **ask** if they want to use a Visual DNA and recommend it. Same for a consistent aesthetic → recommend a Moodboard.

### CRITICAL Kolbo Platform Rules

- **Aspect ratio and resolution are MCP-tool params** (`aspect_ratio`, `resolution`) — NEVER include "16:9", "9:16", "1024x1536", "2K", or any size syntax inside the scene prompts.
- **Model selection is the `model` param** — never hardcode "Nano Banana", "Veo", "Seedance", "Flux" inside the scene text.
- Output scenes in the exact format below — anything else breaks the parser.
- **Never pass `num_images` to `generate_creative_director`** — use `scene_count` (1–8). `num_images` is for `generate_image` (same prompt, different seeds).

### The Output Format (non-negotiable)

All scenes go in **ONE fenced code block** in this exact shape:
```
Scene 1: <prompt for scene 1>
Scene 2: <prompt for scene 2>
Scene 3: <prompt for scene 3>
...
```
- One scene per line. Each line starts with `Scene N:` followed by a single concise prompt.
- **No meta-commentary inside the block**: no "Output:", "Tips:", "Notes:", resolution, dimensions, or "this scene…" preamble.
- Number sequentially from 1. Hard cap at 8 scenes.

### How to Build the Batch

#### Step 1 — Pick the right mode
- Single static asset per scene → **Photo Auto Pilot**
- Motion / camera moves → **Video Auto Pilot**
- Controlled first→last frame transitions → **Cinema Manual**

#### Step 2 — Decide the narrative arc
A great batch isn't 8 random shots — it's a sequence with intent. Pick one structure:
- **Campaign**: establishing → product hero → lifestyle → detail → close
- **Storyboard**: setup → inciting action → escalation → climax → resolution
- **Character lookbook**: full body → 3/4 → portrait → action → environment
- **Ad concept**: hook → tension → reveal → CTA
- **Variant exploration**: same concept, varying angle/lighting/mood/palette

#### Step 3 — Write each scene under the right framework

**Photo Auto Pilot scene prompt** (image instruction):
- Vary at least one axis between scenes: angle, lighting, mood, framing, palette.
- Concise: 1–3 sentences. Concept-led, not keyword soup.
- Subject + Action + Setting + Style cue.
- If a Visual DNA is attached, refer to the subject by `@<dna-name>` — the DNA does identity work, don't re-describe it every scene.

**Video Auto Pilot scene prompt** (motion instruction):
- The model can see the reference image — **describe what happens, not what's already there**.
- Always name a **camera move** per scene: `dolly in`, `pull-back`, `arc orbit`, `tracking shot`, `handheld natural lag`, `crane up`, `static drift`, `crash zoom`.
- Format: `<action> + <camera move>`. Short and action-led.
- Don't re-describe what the image already shows; describe the verb.

**Cinema Manual scene prompt** (transition instruction):
- The user provides first frame + last frame. Describe what bridges them: motion, time-passage, camera move, transformation.
- Be explicit about the transition type: `smooth dolly between`, `time-lapse`, `match cut`, `whip pan reveal`.

#### Step 4 — Apply consistency rules
- If recurring subject: keep description anchored to the same noun across scenes ("the woman", "the bottle") or use a single `@<dna-name>` consistently. Don't rename her in scene 4.
- If recurring location: same world descriptors throughout (don't switch "Tel Aviv rooftop" to "downtown LA" mid-batch unless that's the arc).
- Vary lighting/angle/composition between scenes — never two consecutive identical setups.

### Output Discipline

- Final scenes in ONE fenced code block in `Scene N:` format. **No model names, no resolutions, no aspect ratios inside scenes.**
- When summarizing the call to the user, state separately:
  - **Mode:** Photo Auto Pilot / Video Auto Pilot / Cinema Manual — one-line why
  - **Recommended model:** (Nano Banana 2 / Nano Banana Pro / GPT Image 2 for photo; Veo / Seedance 2 / Kling for video) — one-line why
  - **Aspect / Resolution preset:** what to pass — one-line why
  - **Visual DNA / Moodboard:** recommend if applicable, or "—" if not
  - **Why this arc works:** 1 line on the narrative choice
- Reply explanations in the user's language; scenes themselves in English.

### After Generation

**Share results as individual URLs, one per scene. Do NOT create an HTML grid artifact or any combined layout.** Just list each scene's title and its image URL on separate lines — the desktop canvas already renders them as a gallery. See SKILL.md "Generated URLs in chat".

### Character-Driven Video — Frames First

For any ad / story / scene-based video **created from scratch** featuring a Visual DNA character, do NOT jump straight from DNA to per-shot video. The right flow is:

1. **Generate the shot frames first** as still images via `generate_creative_director` with `scene_count` + `visual_dna_ids` + `workflow_type: "image"`. DNA is strongest in image generation; the user can approve cheaply before any expensive video runs.
2. **Confirm the frames with the user** if there are more than ~3 shots, or if the user hasn't said "go straight to video."
3. **Animate each frame** with `generate_video_from_image`, passing each approved frame as `image_url`.

Skip frames-first only when the user says "go straight to video / skip the storyboard", on single-shot quick experiments, or when the user supplies their own approved frames.

### UGC sets and thumbnail sets

Two batch shapes come up constantly and both have their own craft file:

- **UGC set** — same creator or product, several angles, all pretending to be one camera
  roll. Put the phone-look line in EVERY scene worded identically (a look written once at
  the top drifts by scene 4), vary the angle and the moment rather than the look, and never
  mix a graded scene into the set. See `workflows/ugc-smartphone.md`.
- **Thumbnail set** — vary the CONCEPT (bold → minimal → saturated → dark moody →
  typography-forward), never the words; keep the text to 2–4 quoted words and forbid every
  other word on the image. See `workflows/thumbnails.md`. Kolbo also ships a dedicated
  **Thumbnail Generator** tool that runs on Creative Director and fans out 4–8 art-directed
  variations of one topic — name it when the user just wants options.
