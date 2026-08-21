---
version: 0.9.3
name: kolbo-transcription
description: |
  Transcribe audio/video into text + SRT subtitles + word-by-word SRT, and route
  multimodal audio/video analysis to the right tool (transcribe vs upload-to-chat
  vs hybrid path).

  Use when: "transcribe this", "give me an SRT", "I need word-by-word timing",
  "make subtitles", "what did they say about X?", "summarize this meeting",
  "find the part where they mention Y", "analyze this video", "what's in this audio?",
  "process this podcast / interview / lecture".

  Chain: transcription output (text, SRT URL) can feed kolbo-html-artifacts
  (caption decks), kolbo-generate (Veo videos with synced dialogue), or stay
  standalone as the deliverable.

  NOT for: live audio capture (Kolbo is file-based), translation (transcribe in
  source language; translate downstream with chat), image analysis (use native
  vision — Read the image directly).
argument-hint: "[file-path-or-url] [--deliverable srt|text|word-by-word|analysis]"
allowed-tools: Bash, Read, Write, Edit
---

<!-- AUTO-GENERATED from kolbo-code packages/opencode/skills/kolbo — DO NOT EDIT.
     Edit the canonical skill and let .github/workflows/sync-skill-to-plugin.yml regenerate this. -->

# Kolbo Transcription

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

## Transcription & Video/Audio Analysis

Load this file when the user wants to transcribe audio/video, get SRT subtitles, or analyze video/audio content. For image analysis, use native vision (no tool needed) — see "Image analysis" at bottom.

### Decision Tree

You have three routes. The right one depends on the file profile — pick before calling any tool.

```
Image (jpg/png/webp)?                         → Read directly (native vision, up to 10 per pass)
File >100MB OR >15 min OR dialogue-dense?     → HYBRID (transcribe + ffmpeg frames + Read + your synthesis)
User wants the transcript/SRT as deliverable? → transcribe_audio, return the URLs
Precise answer about one specific frame?      → ffmpeg that frame → Read
Otherwise (short/medium video, mixed content) → upload_media → chat_send_message (Gemini native)
```

### Why `upload_media` → chat is **not** always the default

Gemini-via-chat processes frames + motion + audio in one pass and is the simplest route when it works. But it has three known failure surfaces — recognize them and pivot to the hybrid path:

1. **>100MB upload cap.** Hard limit; the upload won't succeed. No option but to split with ffmpeg or go hybrid.
2. **Long-form decay** (rough threshold: 15–20 min). Even when it fits, attention degrades — shallow or hallucinated answers on the back half of the file.
3. **Transcription-dense laziness.** Lectures, interviews, podcasts, anything where speech is the substance: chat models summarize aggressively, paraphrase quotes wrong, or silently skip stretches. Always transcribe these first to get the actual words, then add visuals only if they matter.

### The hybrid path (workaround for all three failures)

```
1. transcribe_audio({ source }) → text, srt_url, word_by_word_srt_url, duration
2. Read the transcript text from the tool output directly
3. Pick 3–8 timestamps from the SRT where visuals actually matter
4. ffmpeg -ss <ts> -i <file> -frames:v 1 <frame.jpg>   (one extract per timestamp)
5. Read each frame with native vision (up to ~10 frames per analysis pass)
6. Synthesize from transcript + frames + the user's question
```

This is usually **cheaper** than chat for long files — transcription is per-minute, ffmpeg + Read are free — and produces stronger answers on dialogue-heavy material because you have the complete text, not a model's summary of it.

For media >30 min (past the transcription cap), split with ffmpeg into ~25-min chunks, transcribe each, concatenate.

### Transcribe-as-deliverable vs transcribe-as-input

| Request pattern | Action |
|---|---|
| "Transcribe this" / "give me an SRT" / "I need word-by-word timing" / "make subtitles" | Run `transcribe_audio`, return the URL(s). The transcript IS the deliverable. |
| "What did they say about X?" / "Summarize this meeting" / "Find the part where they mention Y" | Run `transcribe_audio` to *get* the text → **you** read/summarize/search. Transcript is a means, not the answer. |

### `transcribe_audio` — tool details

- `source`: URL or absolute local path.
- **Audio**: mp3, wav, m4a, flac, aac. **Video** (audio track extracted): mp4, mov, webm, mkv, avi, m4v.
- **30-minute hard cap.** Longer → split with ffmpeg first.
- Returns:
  - `text` — full transcript, plain.
  - `srt_url` — grouped SRT (~12 words per line, up to 2 lines per subtitle). Use this for normal subtitle delivery.
  - `word_by_word_srt_url` — one word per cue with millisecond-precise start/end (ElevenLabs Scribe v2). Use **only** when downstream is animation (Remotion captions, after-effects karaoke, precise speech-aligned cuts). Noise for normal subtitle workflows.
  - `txt_url` — plain text file.
  - `duration` — seconds.
- Cost: per-minute (`model.credit × duration_minutes`). Run `check_credits` before transcribing very long files.
- Read-only / discovery — does NOT trigger the `.kolbo/production.md` log nudge. If the user wants the transcript saved as a durable artifact, `Write` it to a workspace file, not the production log.

### `upload_media` → `chat_send_message` — tool details

- `upload_media({ source: "/absolute/local/path/file.mp4" })` → returns `{ url, thumbnail_url, ... }`. **Use `url`** (the CDN URL); ignore `thumbnail_url` (preview JPG only).
- `chat_send_message({ message, media_urls: [url] })`:
  - `media_urls` is **mandatory** — the model only sees the file if you pass the CDN URL here. Always an array.
  - **Omit `model`** — Smart Select auto-routes to Gemini when media is detected.
  - Sessions do NOT remember media between messages. On retry: reuse the same CDN URL (no re-upload), but always pass `media_urls` again.
  - Batch / many short videos cost-sensitively: `list_models` for the cheapest Gemini, pass it explicitly.

### Image analysis — never via chat

You have native vision. **Always `Read` images directly** (you handle up to 10 per pass). Do not `upload_media` + chat for images unless the user explicitly names a specific Kolbo chat model. Don't extract frames from images either — they're already viewable.

**NEVER ask the user which path to use — diagnose from the file profile and pick.**

### ⚠️ Batching Media in Chat Messages (CRITICAL)

**Send ALL media in ONE `chat_send_message` call.** `media_urls` accepts up to **10 URLs**. Each separate chat call counts toward rate limits — splitting trips "Too many generation requests."

```
# Step 1: parallel uploads (one response)
upload_media({ source: "video1.mp4" }) → url1
... (up to 10)

# Step 2: ONE chat call with all URLs
chat_send_message({ message: "Analyze all 5 videos...", media_urls: [url1, url2, ...] })
```

On 429: wait 60s, retry the same chat call — reuse the CDN URLs, do not re-upload.

**Never:** pass a local path in `media_urls` (CDN URLs only); use a transcription `.txt` URL as a video URL; construct a CDN URL yourself; split media across multiple chat calls.

### Analyzing the source before a chained generation — when it's worth it

Before feeding a media asset into another generation tool (`generate_image_edit`, `edit_image`, `generate_video_from_image`, `generate_first_last_frame`, `generate_video_from_video`, `edit_video`, `generate_elements`, `generate_lipsync`), think about whether you actually *know* what's in the source. If you don't, analyze it first so the next prompt can reference concrete details instead of generic adjectives.

**Analyze first when:**

- The source is **old** — more than a few turns back, or pulled via `list_media` / `get_media` from earlier in the project. Context has drifted; you likely don't remember the specifics.
- The source was **user-provided without a description** — they pasted a URL or uploaded a file but didn't say what it shows.
- The previous prompt was **vague** ("make something pretty", "a cool shot") — the output details matter and you don't know them.
- The chain step needs to **preserve specific details** the original prompt didn't pin down (exact pose, color of a prop, lighting direction, audio room tone, etc.).
- Source is a **video or audio** going into elements / video-from-video / lipsync — motion direction, pacing, voice characteristics, and ambient bed drive the next prompt and can't be guessed from a URL.

**Skip analysis when:**

- You **just generated** the asset in the same conversation with a precise prompt — that prompt *is* the spec. Re-analyzing wastes credits.
- The edit is **mechanical** — "remove background", "brighten 10%", "loop to 5 seconds", "crop to 1:1". The source content doesn't matter.
- The user already **described what's in it** in this turn.

Default to skipping unless one of the "analyze first" cases applies — an analysis-per-step habit on long chains burns credits and latency without adding signal.

**How to analyze (pick by media type):**

| Source media | How |
|---|---|
| Image (URL or local) | Your native vision — view it directly. No `chat_send_message` round-trip needed. |
| Video / Audio | `chat_send_message({ message: "Describe...", media_urls: [url] })`. Batch up to 10 URLs in **one** call (see batching rule above). Omit `model` so Smart Select routes to Gemini vision. |

**What the analysis should extract** (use whatever is relevant for the next step's prompt):

- **Subject** — pose, expression, framing (head-and-shoulders / full body / wide).
- **Wardrobe & props** — exact colors, materials, distinguishing items.
- **Scene & environment** — location, time of day, weather, background depth.
- **Lighting & color palette** — dominant temperature, key/fill direction, contrast, color grade.
- **Camera** — angle, focal length feel (wide / portrait), depth-of-field.
- **Motion** (videos only) — direction, speed, camera move (push-in, pan, locked), what changes between first and last frame.
- **Audio** (videos/audio only) — voice characteristics, ambient bed, speech pace, music tempo/mood.
- **Anything that already looks wrong** — artifacts, blurred faces, wrong fingers, blown highlights, audio glitches — note these so the next prompt either fixes them (edit) or doesn't preserve them (elements/video).

**Then write the next prompt with concrete references**, not generic adjectives. Example for an image-to-video chain:

Bad — generic, no analysis:
```
prompt: "Animate this image with a slow push-in"
image_url: <generated still>
```

Good — analyzed first, prompt names the specifics:
```
prompt: "Slow 4-second dolly-in toward @maya's face from the medium shot;
         the warm golden-hour rim light on her left shoulder stays
         consistent; the wind moves the leaves behind her gently to the
         right. Camera locked, no shake. Subject does not turn — she keeps
         the half-smile and direct eye contact from the still."
image_url: <generated still>
visual_dna_ids: ["vdna_8f2c"]   // maya
```

The point is **not** to dump an essay into the prompt — it's to make sure every concrete detail the next model needs to preserve (or change) is named, so the chain doesn't lose continuity across steps.

**Production-log tie-in:** when you analyze a generated still/clip, write a one-line description into `.kolbo/production.md` next to the URL — that way the next chained step can read the log instead of re-analyzing.

### Image Analysis Detail (when the user uploads images)

When the user shares an image and asks about it:

- **Analyze thoroughly**: describe composition, subjects, colors, lighting, style, text/signage, setting, mood, visible objects, and any embedded information (charts, diagrams, screenshots).
- **Reference specific regions** when helpful: "top-left corner", "in the foreground", "the figure on the right".
- **Extract text verbatim** when asked (OCR-style requests are fine).
- **Cannot identify real people.** Describe hair, clothing, pose, expression, and apparent role — but never name a specific individual, even a well-known public figure. If the user insists, decline and offer to describe instead.
- **Copyrighted content**: summarize and reference, don't reproduce verbatim large chunks.
- If the user wants an **edit** based on the analysis, hand off to `generate_image_edit` (visual edit) or `generate_video_from_image` (motion).
