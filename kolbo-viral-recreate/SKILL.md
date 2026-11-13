---
version: 0.9.32
name: kolbo-viral-recreate
description: |
  Recreate the format of a viral reel, TikTok or Short with Kolbo: the user
  gives a link or a file and wants "a video like this". Measures cuts, shot
  lengths and sound, reads the story of each beat and checks it with the user,
  writes the formula and format decisions, a concept contract per shot,
  invented-face characters, empty location images and real product refs, then
  Seedance 2.5 Draft takes (one first, then the rest), blind QC and the edit.

  Use when: "make a video like this reel", "recreate this viral format",
  "why did this go viral, make me one", "same format, my product",
  "decode this trend and make an episode".

  Recreates the format, never the clip: the reference is never fed into a
  generation. NOT for: a single clip with no reference (use kolbo-generate),
  a scripted multi-scene film (use kolbo-filmmaking), a drama series
  (use kolbo-micro-drama).
argument-hint: "[reel link or file, plus your idea]"
allowed-tools: Bash, Read, Write, Edit
---

<!-- AUTO-GENERATED from kolbo-code packages/opencode/skills/kolbo — DO NOT EDIT.
     Edit the canonical skill and let .github/workflows/sync-skill-to-plugin.yml regenerate this. -->

# Kolbo Viral Recreate — Rebuild a Viral Reel's Format

## Media selection preferences
Honor explicit models, presets, budget and inputs. Choose only eligible catalog candidates with all required capabilities. Use requested presets; otherwise use fitting presets when useful. For video generation, editing and lip-sync, when the user has not explicitly selected an output resolution, use the cheapest supported output resolution from the live catalog and pass it explicitly; do not inherit an expensive provider default. Preserve explicit user-selected resolution/settings. Finish fully, cinematic, professional, final, production and available credits are NOT permission to increase resolution. Never infer output resolution from reference media or export settings. A budget is a ceiling, not a spending target. Do not upscale or regenerate at a higher tier without explicit user authorization. If pricing or supported resolutions cannot be verified, inspect the catalog before dispatch; never invent a tier. Models with fixed output resolution use their native output. Never treat a policy refusal as a technical failure or route around safeguards.
Default images and edits: the latest GPT Image, now GPT Image 2.6 Flare (fast, everyday) / Sunburst (precise detail, consistent edits); medium for value, high for ordinary maximum quality. Older GPT Image 2.5 / 2 only when named. For no background, animated GIF or SVG use 2.6 natively (`background: "transparent"`, `output_format: "gif"` / `"svg"`); never fake them with prompt words or HTML. Reserve xhigh/max for exceptional dense or difficult multilingual text after medium/high prove insufficient; do not automatically spend on retries. Nano Banana 2.1 (latest Flash; Nano Banana 2 only when named) is secondary. Seedream 5.0 Pro favors cinematic aesthetics over complex instruction fidelity; Wan 2.7 Pro is another creative alternative. Z Image/P Image for cheap tests. Midjourney for artistic concepts only, never editing. Soul V2 for realistic people/UGC concepts; derive character sheets before registering finished Visual DNA. Mirage Film 2 for environments and cinematic inspiration.
**Seedance 2.5 Draft:** explicitly pass `model: "seedance-2-5", draft: true` (or legacy `resolution: "480p-draft"`) on the matching video generation tool. Plain `480p` is regular video, never Draft. Use ordinary credits. Finalize a saved draft via `video_tools` `draft_quote` then authorized `draft_enhance`, with its video URL, original project and quoted supported resolution; do not regenerate the prompt. See `references/seedance25.md`.
For Draft video editing, use `generate_video_from_video` with `model: "seedance-2-5-video-to-video", draft: true`. The source duration and aspect ratio are inherited. Draft uses regular edit 480p pricing; optional finalization uses regular edit 1080p pricing, both charging combined input/output seconds. Read the live catalog and quote rather than hardcoding prices. This app-credit/MCP route does not imply USD-wallet video-edit execution availability.
Default video: Seedance 2.5 for general cinematic work (not Hebrew speech). Kling specializes in controlled single-image and first/last-frame shots. Wan 3.0 specializes in motion graphics and animated typography — native Hebrew speech is poor; attached-audio lip-sync works well. It is also the proven **talking-avatar tool**: a person's Visual DNA plus 2 real face photos plus their own voice as `@Audio 1` gives 0.99 voice sync, holds their identity and works in any environment (`references/talking-avatar-wan3.md`, 2026-10-28). MiniMax H3 offers higher resolution and strong attached-audio lip-sync; H3 Max favors speed at lower resolution with the same audio lip-sync strength. **Native Hebrew dialogue:** Gemini Omni Flash 1.1 or Gemini Omni 1 (best). Seedance 2 / 2.5 do not speak Hebrew — use Latin transliteration in quotes on Seedance, or switch to Gemini Omni. Grok Imagine 1.5 and Seedance 2.0 are non-Hebrew alternatives. P Video/Draft for cheap fast tests. Use base, edit or extend variants only with their required inputs.
Existing-video lip-sync: Sync 3 for active-speaker handling; PixVerse for cartoons/2D and economical faster work. Portrait lip-sync: Veed Fabric or HeyGen Avatar; P Avatar for budget work. LTX Audio to Video for camera/environment motion with audio-driven performance.
Default music: Suno v6. ElevenLabs Music is an alternative, especially for duration-directed scoring. Both accept custom duration requests; validate the selected tool schema and inspect actual output duration.

## Step 0 — Bootstrap

Once per conversation, before any other Kolbo tool call:

1. **Run `check_credits`.** If it fails with "Session expired" / "Not authenticated", ask the user to run `kolbo auth login` (or their branded CLI command like `sapir auth login`) and reload the editor.
2. **If `list_models` returns empty**, MCP isn't wired — same fix.
3. Use the balance ONLY for the low-balance check at this moment (see the "credits remaining" rule in the brief section below).

If the user is on a whitelabel build (`sapir`, etc.), they must use their branded command — not `kolbo`. See `references/troubleshooting.md`.

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

**Cost rules** (full tables + formulas in `references/cost-and-validation.md`):

- **Video/lipsync `credit` is per-SECOND, not per-clip**: normally `total = credit × output_duration`. If video references are attached and `video_input_credit` is present, use the alternate provider tariff instead: `video_input_credit × (sum ceil(each input video duration) + output seconds) × video_input_resolution_multiplier`. Dedicated Seedance Edit uses its selected source duration as output; Extend uses the requested added duration. The other carve-out is `flat_credit_by_resolution`.
- **Batch totalling 100+ credits**: run `check_credits` first.
- **Quote real cost**: when the user approves the result, log its actual `credits_used` (from the tool result) to `.kolbo/production.md` — never `base × count`.
- **Never state "credits remaining" from arithmetic** (opening balance − generation costs). Coding/chat usage deducts credits too, so the math is always wrong. Report cost only; if the user asks for their balance, call `check_credits` fresh at that moment. Widget hosts show the total and plan, credit-pack, and redemption breakdown from `structuredContent.credits`; this is a snapshot at check time. Text hosts receive the same breakdown as plain text.
- **Out of credits → `show_plans`.** A generation refused for credits already returns the upgrade card automatically — do NOT retry it, and do not re-run the tool "to be sure". Call `show_plans` yourself when the user asks about pricing, plans, upgrading, or how to get more credits. Prices are live and promo-adjusted; never quote them from memory. The user completes any purchase themselves on app.kolbo.ai/pricing — you cannot buy for them.

For multi-scene / batch work this pairs with `generate_creative_director` (see below) — still confirm the brief first.

## ⚠️ Load the matching skill BEFORE generating (HARD RULE)

This `kolbo` skill is the mandatory first layer for every Kolbo media task. Do **not** call `generate_*` / `generate_elements` / `generate_image_edit`, or write the billable prompt for them, until you have loaded every matching dependency **in this turn** (the `skill` tool for bundled skills and Read of the required Kolbo references). "I already know this," memory, or a prior-turn load does not count. Users will never invoke these skills themselves.

Dependencies accumulate: narrative Elements work requires **Kolbo + filmmaking + elements-prompting**, not whichever one was loaded first. Before the first paid call, silently check the stack and load anything missing.

| About to call / user intent | `skill` tool | Also Read |
|---|---|---|
| `generate_elements` **or** any video with Visual DNA **or** Seedance 2 / 2.5 / WAN / MiniMax H3 / Gemini video | `elements-prompting` | `references/seedance.md` (+ `seedance25.md` if 2.5) and `references/visual-dna.md` when DNA is in play |
| `generate_image` / `generate_image_edit` | `image-prompting-guide` | `references/gpt-image.md` / `nano-banana.md` / `prompt-copilot.md` as the model requires. Complex stills / identity lock: `references/prompt-structure.md` |
| `generate_video*` that is **not** Elements/DNA (Kling, Veo, Sora, Grok, Hailuo, generic t2v/i2v) | `video-prompting-guide` | matching `references/models/*.md` |
| `generate_music` | `music-prompting` | `references/music.md` |
| UGC / phone-shot / selfie / "authentic" / must-not-look-like-an-ad | — | `references/ugc-smartphone.md` |
| Marketing / TV spot / branded video / unboxing / product review | — | `references/marketing-studio.md` |
| DTC ad image | — | `references/dtc-ads.md` |
| Product photoshoot / hero / lifestyle / try-on | — | `references/product-photoshoot.md` |
| Thumbnail / cover | — | `references/thumbnails.md` |
| Marketplace listing cards | — | `references/marketplace-cards.md` |
| Film / episode / connected scene | — | `references/filmmaking.md` + `production-planning.md` |

## ⚠️ Visual DNA `@Name` in the prompt (HARD RULE — always on)
Passing `visual_dna_ids` is **not enough**. For every DNA in that array you MUST also write `@ExactStoredName` in the prompt text (the `name` from `list_visual_dnas` / `create_visual_dna`). The engine binds identity by parsing `@tags`. No `@tag` → the DNA is wasted.

- Right: `visual_dna_ids: ["vdna_…"]` + prompt `@Zohar walks into frame`
- Wrong: `Zohar's`, `Zohar`, `the left man`, `the man on the LEFT`, `Visual DNA anchors: the man on the LEFT…` — none of these bind
- Never invent a role label or possessive as a substitute for `@Name`
- **Asset tags are exempt from every English-only prompt rule.** Copy the actual stored `name` verbatim in its original language, case, spaces, punctuation, and diacritics. Stored `אסתר` → `@אסתר`, `ليلى` → `@ليلى`, `小雨` → `@小雨`; never `@Esther`, `@Layla`, or another translated/transliterated alias. Never slugify or rename an existing DNA to make a prompt English. Preserve these tags through every rewrite and final tool call.
- Same rule for moodboards: `#ExactBoardName`

**Rewrite / compile never drops a tag.** If the user, a prior prompt, or `list_visual_dnas` already has `@gal_suit` / `@yonatan` / `#Board`, the Locked Intro you write MUST still contain those exact tokens in CAST **and** in every shot they appear in. Do not "clean" them into first names, `@Image 1 (Lee)`, "the singer", or a SCENE CONTEXT / ACTIVE REFERENCES block with no `@`. A compile that loses a tag is a failed turn — put the tags back before calling `generate_*`.

Before ANY generation call using `visual_dna_ids` (images, edits, Elements, or Creative Director): resolve each id to its stored `name` from the selected asset binding or `list_visual_dnas` / `get_visual_dna`, then confirm the final prompt includes the exact `@` + name. Missing or rewritten even one → fix the prompt, do not fire.

Resolve names with `list_visual_dnas` first. Full binding rules: `references/visual-dna.md`.

**Every still on a DNA can reach the model.** Kolbo now sends all of a DNA's reference images that fit the model's image-slot cap (user uploads first, then one still per DNA, then leftovers round-robin). If a DNA only gets one leftover slot and has no real character sheet, unused stills become a white grid. Mixed-vibe stills or environment photos that contain a main character will confuse the generation — keep each DNA surgically clean. Create-and-pack rules: `references/visual-dna.md`.

## 📁 Projects — Where Work Lands (CRITICAL)

Everything in Kolbo — sessions, generations, media, docs — lives inside a PROJECT. Getting this wrong is the #1 user complaint ("my work went to the wrong project").

1. **User names a project** ("in my Acme project", "for the film") → call `list_projects` ONCE to resolve the name to an ObjectId, then pass that **same** id as `project_id` on **EVERY** subsequent `generate_*` / `upload_media` / `create_doc` / `chat_send_message` call in **this conversation**. There is no server-side sticky store — omitting it on any later call silently lands in the default "API Generations" bucket (`is_default: true`). Once resolved, treat that id as required for the rest of the conversation. Accounts often hold hundreds of projects, so pass `list_projects({ search: "acme" })` rather than listing everything; the list is paginated (50/page) and hides archived projects unless you pass `include_archived: true`. When the user starts new work, `create_project` first, then pass its id the same way.
2. **No project mentioned** → omit `project_id`; the default bucket is correct. Don't ask unless intent is ambiguous. If `list_sessions` already returned a `project_id` for the work you are continuing, keep passing that id.
3. **Work landed in the wrong project? MOVE it, never regenerate**: `move_session` relocates a whole session + all its media (generation sessions and chats; Creative Director, transcription, global_image_edit and shorts sessions return `SESSION_TYPE_NOT_MOVABLE` — move their media with `bulk_move_media` instead); `move_media` / `bulk_move_media` / `move_folder_contents` relocate individual media items. Empty leftover sessions after a move: `delete_session` (soft-delete; `restore_session` undoes it). `rename_session` only changes the sidebar title.

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

After the user approves a bucket, write its `session_id` + plan name into `.kolbo/production.md` `### Sessions`. Do not create or update the file for a pending bucket. Full rules: `references/production-planning.md` + `production-log.md`.

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

**After `submitted` / `_timed_out` — avoid idle work (credit guard).** For a multi-output request, first submit all independent authorized items within the supported concurrency limit. Do not end the task after submitting only the first item or batch. If more requested items are waiting for capacity or output dependencies, use one batched `get_generation_status` call with `wait=true`, then submit the next ready batch. Once every requested item is submitted and no further work needs its output, tell the user it is generating in Library / the cards and end the turn. Submitted is not completed. Do not perform unrelated thinking, file edits, or speculative extra generations while waiting.

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

`failure` envelope structure + retry rules: `references/troubleshooting.md`.

## ⚠️ Generated URLs in Chat (CRITICAL)

Chat renders markdown natively. `![alt](url)` = inline image. `[label](url)` = labeled link with preview.
- **Catalog-style replies** (numbered lists of characters / scenes / products): embed `![alt](url)` so each item shows inline.
- **Conversational replies** ("4 shots ready"): keep prose short. Avoid bare URL dumps and HTML `<table>` grids — Library already provides a gallery.

**After `generate_creative_director` completes** — share results as individual URLs, one per scene. Do NOT create an HTML grid artifact.

**Never update `.kolbo/production.md` merely because a generation succeeded.** Keep the result provisional in the generation card / Library, ask the user to choose, and write only the explicitly approved winner in the same turn as approval. Brief approval before generation is not output approval; silence, a topic change, or requesting the next task is not approval. See `references/production-log.md`.

## Viral Recreate — Rebuild a Viral Reel's Format With Kolbo

The user gives a viral reel (a link or a file) and wants "a video like this". Recreate its **format** (the repeatable decisions: hook, gag, pacing, camera, look, sound, ending) with new characters, places and jokes. Never copy the clip itself.

Load with this file: [seedance-2-5.md](references/seedance25.md), [seedance25-craft.md](references/seedance25-craft.md), [video-investigation.md](references/video-investigation.md) and [visual-dna.md](references/visual-dna.md).

### Hard rules

- **Story before technique.** No formula, contract or prompt until every beat has a story line and the user confirmed the tell-back (step 2).
- **Contract before prompt.** Every paid take has a written concept contract (step 4). Never drop a contract element to make a prompt "safer". Missing elements are the most common reason a take is "nothing like the concept".
- **QC is blind and against the contract**, never against your own prompt. A wrong prompt passes a self-check every time.
- **Never feed the reference clip into a generation.** The reel is study material only: decode it with frames, measurements and analysis, then write what you learned as staging, light and motion text. Reference videos in a generation may only be the user's own or licensed footage.
- **Invented people only.** Character faces are invented, never a real actor, creator or public figure. Recognisable roles come from costume, hair, colour and one prop.
- **No famous names in prompts.** No studio, franchise, character, celebrity or brand-campaign names in any prompt (see the Seedance 2.5 rules). Real products the user names come from real product photos (step 5).
- **The supplied media is the evidence.** Articles and summaries only help locate things. Measure every reference before writing the formula.
- **Paid steps need the user's go with the credit cost stated.** Download, inspection, frames and cut detection are free; clip analysis and transcription bill usage.
- **Fire one take first.** Prove one beat before batching (step 6).
- **Format rules don't travel between formats.** Two formats can make opposite choices (step 3). Never copy one format's decisions into another.

### 1. Measure

1. Bring the reel into Kolbo: `download_media_from_url` for a public link (check progress with `get_download_status`); `upload_media` or `create_upload_ticket` for a local file. With several references, bring in and measure **every** one before writing anything.
2. `prepare_video_inspection` on the reel URL, then `get_video_inspection` until it is ready.
3. Map it:
   - `inspect_video` kind `frames` across the whole reel, then denser frames per beat (4 fps or more where actions are quick).
   - kind `cuts` for cut candidates. Verify each against nearby frames: flashes, explosions and fire add false cuts; whips and dissolves hide real ones.
   - kind `audio_levels` for loudness and silences.
4. Write a shot table: start, end, length per shot, average and longest shot, total length, aspect, loudness.
5. Sound: kind `audio` then `transcribe_audio` (or `transcribe_extracted_clip`) for speech and audio events. Music-only reels give little text: describe the track instead (genre, instruments, tempo, energy, whether cuts land on its hits, whether the reel's own audio or a trend track carries it).
6. **Classify the music: `added track` or `generator bed`.** AI-made reels often carry a faint music bed that the video model baked into the take. Signs of a generator bed: the reel's metadata names no track or artist, the bed is low and generic, and it never hits the cuts. Audio analysis and a stem split both "hear music" either way, so neither settles it; decide from those signs and confirm with the user before any music spend. A generator bed means the recreation needs no music. Write the class into the formula.
7. Per beat, extract kind `clip` and call `analyze_extracted_clip` focus `video` with a **neutral** question ("Describe who is in frame, what each person does in order, where the camera is and how it moves, and the light"). Never put your own reading into the question; the witness must be blind. It misses small things (hands below frame, speech under music), so check every claim against frames.
8. Count the real beats. A beat is a story event, not a cut. One beat can span several cuts.

Automated analysis is a lead, not a fact. A claim needs a frame time.

### 2. Read the story, then tell it back

1. **Creative read first.** Two sentences before anything technical: the illusion the reel sells ("someone really filmed this at a party") and why people share it. Every later choice serves that illusion.
2. **Story line per beat**, as a stranger would retell it:
   - who wants, wins or loses what;
   - what happens;
   - what is hidden (an off-screen cause, someone who left frame);
   - how it is revealed (a pan, a cut on impact, a wide);
   - the payoff.
   If a line could describe a different joke, it is an action list; re-read the frames. Never add structure (reveals, twists) the frames don't show.
3. **Who notices whom.** For every beat, write why the camera is where it is. The filmer can be a character, and being caught filming can be the gag.
4. **Tell-back check.** Show the user the beat chain in 3–5 short lines and wait for their "yes". Misreading a beat is the most expensive mistake in this workflow: every take built on it is wasted.

### 3. Formula and format decisions

Write the formula as numbered rules, each with its evidence (reel + time, a measured number, or the user's words):

- **Hook:** what is on screen at 0.0 s, already moving, and why it stops the scroll. Frame one is the most extreme, most recognisable thing.
- **Gag mechanic** per beat: setup, action, payoff, aftermath, and who owns which prop.
- **Pacing:** shots, average shot, acceleration, how cuts sit on the music.
- **Look:** medium (phone, camcorder, CCTV, film), light source, colour, era.
- **Ending:** last image, any call to action.
- **Subject test:** is the subject recognised in half a second?

Then the **format decisions block**. These decisions have no defaults; formats that look alike make opposite choices. State each one with its evidence:

| Decision | This format | Evidence |
|---|---|---|
| Shots per take (1 continuous, or N cuts inside a beat) | | |
| Do bystanders react to the gag? | | |
| Operator role (hidden observer, friend, crew member inside the action) | | |
| Who looks into the lens, and when | | |
| Extras per shot, and what each does | | |
| Zoom (in-camera moves with time and size, or none) | | |
| Audio in takes (diegetic only, dialogue, sirens) | | |
| Where the music comes from in the posted reel | | |

**Two anonymised examples** of how far these can differ:

- *Impossible found footage* (a past era filmed on a 1990s camcorder, one modern object per beat): 1 continuous shot per beat; bystanders never react, it is an ordinary day for them; a hidden observer who is never seen; nobody looks into the lens; busy extras, each with an ordinary task; one quick in-camera zoom per beat; diegetic sound only, no words.
- *Crime-spree reel* (costumed characters on a chaotic spree, filmed by a crew member running with them): 2–3 cuts and whip pans inside a take; bystanders react normally (duck, run, call for help); the operator is inside the action; only the final booking-photo beat looks into the lens; busy extras (tellers, guards, shoppers); zoom only in camera, never added in the edit; diegetic sound plus sirens.

Ask the user any open decisions (subject, aspect, length, budget) in one round.

### 4. Concept contract per shot

Before each prompt, write a contract with one line per element:

- on-screen text (spelled out);
- every person in frame and their action (hero and each extra);
- the location (and its location image);
- operator position and move;
- the gag;
- the payoff frame;
- every character's state at frame 0 (asleep or awake, standing or seated, who holds what). Without it Seedance starts mid-action;
- every contact action pinned to its exact target, with the wrong target named: "kisses the middle of her cheek, high on the cheekbone, well away from the mouth". "Kisses her cheek" produced a kiss on the mouth.

Each contract line maps to a prompt line. Compile the prompt with the block shape in [seedance25-craft.md](references/seedance25-craft.md): the camera written as a person, a populated world, about 1 s per action, real sounds only, an AVOID list that holds behaviours.

### 5. Build assets

- **Characters:** invented faces only. Generate a face batch, let the user pick, then a character sheet; store each recurring person as a Visual DNA (`create_visual_dna`, see [visual-dna.md](references/visual-dna.md)). Read every DNA description back and check the sheet for invented text.
- **A sheet must agree with itself.** Check every view for one hairstyle and one outfit before any take. A sheet that showed a bun in some views and loose hair in others made the hair flip between takes and even mid-shot. Fix or regenerate the sheet; never hope the prompt overrides it.
- **Locations:** one **empty** location image per beat, from the spot where the shot starts, with no people, in the reel's aspect. Use Seedream 5.5 text-to-image at 2K (confirm the current Seedream id in `list_models`). Edit it only with the matching Seedream edit model. Seedream shrinks small story props, so ask for them large. Attach it as a reference image with a role line, never as the start frame. A location described only in words drifts between takes.
- **Real products:** when the user names a real product, use real product photos (the official product page or press kit, clean product shots only; screenshots with fine print leak text into the video). Build a product DNA from them. A generic look-alike reads as fake.
- **No app screens as the gag.** Models can't render a real app interface. Show the physical product instead, and don't repeat one prop motif across beats.
- **Famous designs get blocked after the render.** Seedance's output filter blocks the most famous character designs after the take renders (0 credits, but the time is lost). Frontal shots of famous animated characters and their canon sidekicks block most often. Before writing a whole episode around a famous look, fire one test take. When it blocks, keep a generic look: go wider, into action or from behind, drop any canon names, and use a generic person with a clear role (a guard, a florist). Never put a blocked character's name back in a prompt.

### 6. Make the takes

1. `create_project` for the piece; keep every id in a production log.
2. Quote the cost: `list_models` for live rates, then state the total. Seedance 2.5 Draft is billed per second. **Budget one retake per take.** Measured baseline on a new format: first takes passed 72% of contract lines but 0 of 2 whole takes; after one targeted retake each, every story line passed.
3. Generate with `generate_elements`, `model: "seedance-2-5"`, `draft: true` (480p Draft), the DNA ids, `project_id` and `duration` equal to the prompt's total.
4. **Fire one take first.** Wait for it (`get_generation_status`), QC it (step 7), show it to the user. Only then fire the rest. Untested batches multiply the same mistake.
5. Then the rest, one beat per take. Put several shots in one generation only when the action continues across the cut.
6. Stay at 480p Draft until the user approves the cut. Finals: `video_tools` `draft_quote` on the approved draft, then `draft_enhance` only after the user approves that cost.

### 7. Blind QC against the contract

Run this on every take before the user sees it:

1. **Stranger read first.** From the frames only, before looking at the contract, write what happens in the take. If it doesn't match the story line, the take fails.
2. **Blind check.** A fresh reviewer (a subagent if available, otherwise a separate pass) gets the contract, a 4–6 fps frame strip, full-resolution frames and one reference frame. It never sees the prompt. It marks every contract line PASS or FAIL. A take passes only when every line passes.
3. **Prop in every frame.** Every prop must appear in every strip tile from its first appearance to the end. A prop that vanishes or morphs fails the take.
4. **Checks:** cut count and camera motion against the reference beat; the gag reads at phone size; cause and effect in one frame; no burned-in text or captions; no music in the take; nobody looks into the lens unless the format says so; extras are moving.

The blind reviewer is the gate, not your own read. In the measured run, the producer's stranger read caught one defect but missed a frame-0 defect (a character awake when the contract said asleep); the blind reviewer caught both.

Never call a take "works" and recommend locking it on your own read. Show only takes that pass; share them for review (see [review-collections.md](references/review-collections.md)).

**Fixing a note:** fix the unclear beat; don't swap it for a new idea. Make a weak action bigger and clearer, never safer. Keep the prompt text that produced approved beats word for word. Keep rejected and spare takes in an "unused" reel grouped by beat; never put a rejected take back into a cut because its retake failed: drop the beat or reshoot it generic.

### 8. Edit and deliver

- Cut from the measurements: hook length, average shot, beat order. Enter late, exit early, hard cuts, real time. Order beats by escalation and end on the biggest laugh.
- Any zoom happens in the take, never as a crop or scale in the edit.
- Grain, tape or VHS texture goes on as a post filter.
- Music goes in the edit, not the takes. Use music the user has the rights to on every platform they post to.
- **Music follows the class from step 1.** A `generator bed` reference: no music; deliver take audio only. An `added track` reference: make an instrumental with `generate_music` from the decoded genre, instruments and tempo. Don't fall back to generic stock music for a viral cut; it reads as an ad. For the closest match:
  - split the reference with `separate_audio_stems` (mode `full`), then either `cover_music` of its music stem (it can return 2+ minutes, so trim the opening) or `generate_music` on Suno V6 with the stem in `reference_audios`;
  - `cover_music` needs the user to confirm they hold the rights to the source. A third-party reel's track is not theirs, so ask before covering it and never set that confirmation on their behalf.
- **Mix the music low under voices:** about 18–22 dB under the dialogue, EQ'd out of the voice band (cut roughly 1–4 kHz, high-pass the lows).
- **Post the same music cut on every platform.** A version stripped to take audio for some platforms loses the timing the reel was cut to. If one platform needs different music for rights reasons, re-cut to that track rather than posting silence under the original edit.
- Deliver at the reel's aspect, without burned-in text unless the format uses captions, and give the user the review link for the final cut.
- After the user posts, compare their posted edit with your finals (hook length, what they dropped, the last image) and fold the differences into the formula for the next episode.

## Bundled references

- [acting-direction](references/acting-direction.md)
- [asset-preproduction](references/asset-preproduction.md)
- [audio-dialogue-music](references/audio-dialogue-music.md)
- [blocking-continuity](references/blocking-continuity.md)
- [cinematography](references/cinematography.md)
- [physics-action](references/physics-action.md)
- [production-bible](references/production-bible.md)
- [prompt-contracts](references/prompt-contracts.md)
- [routing](references/routing.md)
- [scene-engine](references/scene-engine.md)
- [seedance25-craft](references/seedance25-craft.md)
- [validation](references/validation.md)
- [workflows](references/workflows.md)
- [gpt-image](references/gpt-image.md)
- [music](references/music.md)
- [nano-banana](references/nano-banana.md)
- [seedance](references/seedance.md)
- [seedance25](references/seedance25.md)
- [cost-and-validation](references/cost-and-validation.md)
- [dtc-ads](references/dtc-ads.md)
- [filmmaking](references/filmmaking.md)
- [marketing-studio](references/marketing-studio.md)
- [marketplace-cards](references/marketplace-cards.md)
- [product-photoshoot](references/product-photoshoot.md)
- [production-log](references/production-log.md)
- [production-planning](references/production-planning.md)
- [prompt-structure](references/prompt-structure.md)
- [review-collections](references/review-collections.md)
- [talking-avatar-wan3](references/talking-avatar-wan3.md)
- [thumbnails](references/thumbnails.md)
- [transcription](references/transcription.md)
- [troubleshooting](references/troubleshooting.md)
- [ugc-smartphone](references/ugc-smartphone.md)
- [video-investigation](references/video-investigation.md)
- [visual-dna](references/visual-dna.md)
