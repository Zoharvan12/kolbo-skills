---
version: 0.4.0
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
  "campaign batch", "lookbook", "scene 1 scene 2 scene 3", "video auto pilot",
  "photo auto pilot", "cinema manual first/last frame scenes".

  Chain: pair with kolbo-visual-dna (lock character across scenes), then optionally
  with kolbo-generate (animate each frame via generate_video_from_image).

  NOT for: a single image (use kolbo-generate), modifying ONE existing image
  (use kolbo-generate with generate_image_edit), N variations of THE SAME exact
  prompt with random seeds (use kolbo-generate with num_images).
argument-hint: "[scene-count] [brief] [--mode photo|video|cinema] [--visual-dna-id <id>]"
allowed-tools: Bash, Read, Write, Edit
---

# Kolbo Creative Director

Multi-scene batch generator. 1–8 scenes in one call, fanned out in parallel into images or videos, optionally locked to a character/product (Visual DNA) and a mood/style (Moodboard).

## Step 0 — Bootstrap

1. Run `check_credits` once per conversation. If it fails, ask the user to run `kolbo auth login`.
2. Director runs scenes in parallel internally — total wall time = slowest scene, not the sum.

## MCP Tool

`generate_creative_director` — fire ONCE with `scene_count: 1–8`. **Never loop `generate_image` ≥2 times sequentially** — that's exactly what this tool replaces.

## The Three Modes

- **Photo Auto Pilot** — each scene = one image. Optional reference images for style/subject. Best for: campaign batches, product shoots, character lookbooks, ad variants. Pass `workflow_type: "image"` (or omit — image is default).
- **Video Auto Pilot** — each scene = one short video clip. Optional reference image per scene anchors the starting frame. Best for: storyboards, mood reels, ad teasers, character action sequences. Pass `workflow_type: "video"`.
- **Cinema Manual** — per-scene **first frame + last frame** + per-scene prompt. Full cinematic control over composition transitions. Best for: hero shots, controlled camera moves, deliberate edits.

## Identity & Style Locks

- **Visual DNA** — attach a character/product preset via `visual_dna_ids` to lock identity across all scenes. Up to **8 DNAs** active at once (main character + product + side character). Always tag inside the prompt with `@<dna-name>`. See **Visual DNA Reference** below for the full naming/usage rules.
- **Moodboard** — attach `moodboard_id` (or `moodboard_ids`) for a curated mood/style reference that anchors the aesthetic of the whole batch.
- When the user mentions a recurring character/product, **ask** if they want to use a Visual DNA. Same for a consistent aesthetic → recommend a Moodboard.

## CRITICAL Kolbo Platform Rules

- **Aspect ratio and resolution are MCP-tool params** (`aspect_ratio`, `resolution`) — NEVER include "16:9", "9:16", "1024x1536", "2K", or any size syntax inside the scene prompts.
- **Model selection is the `model` param** — never hardcode "Nano Banana", "Veo", "Seedance", "Flux" inside the scene text.
- **Never pass `num_images`** — use `scene_count` (1–8). `num_images` is for `generate_image` (same prompt, different seeds).
- Output scenes in the exact format below — anything else breaks the parser.

## The Output Format (non-negotiable)

All scenes go in **ONE fenced code block** in this exact shape:
```
Scene 1: <prompt for scene 1>
Scene 2: <prompt for scene 2>
Scene 3: <prompt for scene 3>
...
```
- One scene per line. Each line starts with `Scene N:` followed by a single concise prompt.
- **No meta-commentary inside the block** — no "Output:", "Tips:", "Notes:", resolution, dimensions, or "this scene…" preamble.
- Number sequentially from 1. Hard cap at 8 scenes.

## How to Build the Batch

### Step 1 — Pick the right mode
- Single static asset per scene → **Photo Auto Pilot**
- Motion / camera moves → **Video Auto Pilot**
- Controlled first→last frame transitions → **Cinema Manual**

### Step 2 — Decide the narrative arc
A great batch isn't 8 random shots — it's a sequence with intent. Pick one structure:
- **Campaign**: establishing → product hero → lifestyle → detail → close
- **Storyboard**: setup → inciting action → escalation → climax → resolution
- **Character lookbook**: full body → 3/4 → portrait → action → environment
- **Ad concept**: hook → tension → reveal → CTA
- **Variant exploration**: same concept, varying angle/lighting/mood/palette

### Step 3 — Write each scene under the right framework

**Photo Auto Pilot scene** (image instruction):
- Vary at least one axis between scenes: angle, lighting, mood, framing, palette.
- Concise: 1–3 sentences. Concept-led, not keyword soup.
- Subject + Action + Setting + Style cue.
- If a Visual DNA is attached, refer to the subject by `@<dna-name>` — the DNA does identity work, don't re-describe every scene.

**Video Auto Pilot scene** (motion instruction):
- The model can see the reference image — **describe what happens, not what's already there**.
- Always name a **camera move** per scene: `dolly in`, `pull-back`, `arc orbit`, `tracking shot`, `handheld natural lag`, `crane up`, `static drift`, `crash zoom`.
- Format: `<action> + <camera move>`. Short and action-led.

**Cinema Manual scene** (transition instruction):
- The user provides first frame + last frame. Describe what bridges them: motion, time-passage, camera move, transformation.
- Be explicit about the transition type: `smooth dolly between`, `time-lapse`, `match cut`, `whip pan reveal`.

### Step 4 — Apply consistency rules
- Recurring subject: same noun across scenes ("the woman", "the bottle") OR same `@<dna-name>` consistently. Don't rename her in scene 4.
- Recurring location: same world descriptors throughout.
- Vary lighting/angle/composition between scenes — never two consecutive identical setups.

## Output Discipline

- Final scenes in ONE fenced code block in `Scene N:` format. **No model names, no resolutions, no aspect ratios inside scenes.**
- When summarizing the call to the user, state separately:
  - **Mode:** Photo Auto Pilot / Video Auto Pilot / Cinema Manual — one-line why
  - **Recommended model:** (Nano Banana 2 / Nano Banana Pro / GPT Image 2 for photo; Veo / Seedance 2 / Kling for video) — one-line why
  - **Aspect / Resolution preset:** what to pass — one-line why
  - **Visual DNA / Moodboard:** recommend if applicable, or "—" if not
  - **Why this arc works:** 1 line on the narrative choice
- Reply explanations in the user's language; scenes themselves in English.

## After Generation

**Share results as individual URLs, one per scene. Do NOT create an HTML grid artifact or any combined layout.** Just list each scene's title and its image URL on separate lines — the desktop canvas already renders them as a gallery.

## Character-Driven Video — Frames First

For any ad / story / scene-based video **created from scratch** featuring a Visual DNA character, do NOT jump straight from DNA to per-shot video. The right flow:

1. **Generate the shot frames first** as still images via `generate_creative_director` with `scene_count` + `visual_dna_ids` + `workflow_type: "image"`. DNA is strongest in image generation; user can approve cheaply.
2. **Confirm the frames with the user** if there are more than ~3 shots.
3. **Animate each frame** via `generate_video_from_image` (kolbo-generate), one call per frame fired in parallel.

Skip frames-first only when the user says "go straight to video", on single-shot quick experiments, or when the user supplies their own approved frames.

## Visual DNA Reference (self-contained)

When passing `visual_dna_ids`, the prompt MUST tag each DNA by `@<exact-name>` — the literal `name` field. Without `@name`, the engine guesses, drops, or blends DNAs.

**Naming rule for create_visual_dna — NO SPACES.** Single token, lowercase, ASCII-safe: `esther_model`, `dana`, `tokyo_neon`, `brand_red`. Never `Sarah Johnson`. Reason: the prompt parser stops `@<token>` at the first space.

**Pre-flight:** ALWAYS call `list_visual_dnas` first to verify the DNA exists. If no match, STOP and ask the user before generating.

**Multi-DNA example in a scene:**
```
Scene 1: @maya at @cafe counter, soft morning light, medium shot
Scene 2: @maya walking past @cafe windows, golden hour, wide shot
```
with `visual_dna_ids: ["vdna_maya", "vdna_cafe"]`.

**Reference tags** (for plain images / videos / audio):
- `@image1`, `@image2`, … = position in `reference_images`
- `@video1`, `@video2`, … = position in `reference_videos`
- `@Audio1`, `@Audio2`, … = position in `reference_audio`

For full Visual DNA training and creation rules, see the `kolbo-visual-dna` skill.

## Parameter Gotcha

| Tool | Param | Meaning |
|---|---|---|
| `generate_image` | `num_images` (1–4) | Same prompt, different seeds — "give me 4 variations of THIS exact image" |
| `generate_creative_director` | `scene_count` (1–8) | Each scene gets its own distinct prompt — "make 8 different campaign shots" |

**Never pass `num_images` to `generate_creative_director`.** **Never loop `generate_image` sequentially when you want a related set — use Creative Director instead.**

## UX Rules

1. **Default to this skill for any multi-output request.** Don't fire ≥2 `generate_image` calls without checking if Creative Director is the right fit first.
2. **Pick a narrative arc explicitly** (campaign / storyboard / lookbook / ad concept / variants) — don't generate random scenes.
3. **One labeled-option question max** before firing if defaults aren't clear (mode, model preference).
4. **Always tag Visual DNAs** with `@name` in every scene.
