---
version: 0.9.24
name: kolbo-micro-drama
description: |
  Create a vertical micro-drama or short-form drama series in Kolbo.AI,
  from series bible, scripts and recurring cast to Draft episodes,
  approved finals, edits, trailers, social cuts and key art.
  Use for episodic vertical drama, branded drama series, and shows
  like ReelShort or DramaBox. Continue through the agreed series stages.
  A standalone unrelated clip belongs to kolbo-generate.
argument-hint: "[series premise or episode request]"
allowed-tools: Bash, Read, Write, Edit
---

<!-- AUTO-GENERATED from kolbo-code packages/opencode/skills/kolbo — DO NOT EDIT.
     Edit the canonical skill and let .github/workflows/sync-skill-to-plugin.yml regenerate this. -->

# Kolbo Micro-Drama Studio

## Media selection preferences
Honor explicit models, presets, budget and inputs. Choose only eligible catalog candidates with all required capabilities. Use requested presets; otherwise use fitting presets when useful. For video generation, editing and lip-sync, when the user has not explicitly selected an output resolution, use the cheapest supported output resolution from the live catalog and pass it explicitly; do not inherit an expensive provider default. Preserve explicit user-selected resolution/settings. Finish fully, cinematic, professional, final, production and available credits are NOT permission to increase resolution. Never infer output resolution from reference media or export settings. A budget is a ceiling, not a spending target. Do not upscale or regenerate at a higher tier without explicit user authorization. If pricing or supported resolutions cannot be verified, inspect the catalog before dispatch; never invent a tier. Models with fixed output resolution use their native output. Never treat a policy refusal as a technical failure or route around safeguards.
Default images and edits: GPT Image 2.5 Flare/Sunburst; medium for value, high for ordinary maximum quality. Reserve xhigh/max for exceptional dense or difficult multilingual text after medium/high prove insufficient; do not automatically spend on retries. Nano Banana 2 is secondary. Seedream 5.0 Pro favors cinematic aesthetics over complex instruction fidelity; Wan 2.7 Pro is another creative alternative. Z Image/P Image for cheap tests. Midjourney for artistic concepts only, never editing. Soul V2 for realistic people/UGC concepts; derive character sheets before registering finished Visual DNA. Mirage Film 2 for environments and cinematic inspiration.
**Seedance 2.5 Draft:** explicitly pass `model: "seedance-2-5", draft: true` (or legacy `resolution: "480p-draft"`) on the matching video generation tool. Plain `480p` is regular video, never Draft. Use ordinary credits. Finalize a saved draft via `edit_video` `draft_quote` then authorized `draft_enhance`, with its video URL, original project and quoted supported resolution; do not regenerate the prompt. See `references/seedance25.md`.
For Draft video editing, use `generate_video_from_video` with `model: "seedance-2-5-video-to-video", draft: true`. The source duration and aspect ratio are inherited. Draft uses regular edit 480p pricing; optional finalization uses regular edit 1080p pricing, both charging combined input/output seconds. Read the live catalog and quote rather than hardcoding prices. This app-credit/MCP route does not imply USD-wallet video-edit execution availability.

Default video: Seedance 2.5 for general cinematic work (not Hebrew speech). Kling specializes in controlled single-image and first/last-frame shots. Wan 3.0 specializes in motion graphics and animated typography — native Hebrew speech is poor; attached-audio lip-sync works well. MiniMax H3 offers higher resolution and strong attached-audio lip-sync; H3 Max favors speed at lower resolution with the same audio lip-sync strength. **Native Hebrew dialogue:** Gemini Omni Flash 1.1 or Gemini Omni 1 (best). Seedance 2 / 2.5 do not speak Hebrew — use Latin transliteration in quotes on Seedance, or switch to Gemini Omni. Grok Imagine 1.5 and Seedance 2.0 are non-Hebrew alternatives. P Video/Draft for cheap fast tests. Use base, edit or extend variants only with their required inputs.
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
- **Conversational replies** ("4 shots ready"): keep prose short; Library already shows the gallery.

Avoid bare URL dumps and HTML `<table>` grids — Library already provides a gallery.

**After `generate_creative_director` completes** — share results as individual URLs, one per scene. Do NOT create an HTML grid artifact.

**Never update `.kolbo/production.md` merely because a generation succeeded.** Keep the result provisional in the generation card / Library, ask the user to choose, and write only the explicitly approved winner in the same turn as approval. Brief approval before generation is not output approval; silence, a topic change, or requesting the next task is not approval. See `references/production-log.md`.

## Micro-Drama Studio

Produce a vertical micro-drama series end to end in Kolbo: series bible, cast, locations, voices, Seedance 2.5 Draft episodes, finals, the edit, a series trailer, social cutdowns and key art. Use when the user wants a micro-drama, a short-form drama series, episodic vertical drama, a branded drama series, or "a show like ReelShort / DramaBox".

This file is the router and the operating contract. Load the stage file when you reach that stage; each one is short and owns its QA gate.

| Stage | Read | Output |
|---|---|---|
| 0. Kickoff | this file | answers to the kickoff questions, Kolbo project, bible Doc |
| 1. Bible + season | `references/series-bible.md`, `references/writing.md` | logline, world + look, characters, season outline with every Looks table |
| 2. Episode script | `references/writing.md` | beats, dialogue, parts, trailer moments |
| 3. Cast, looks, locations, voices | `references/cast-locations-voices.md` | character sheets + Visual DNAs, location frames, locked voice samples |
| 4. Shots + prompts | `references/shots-prompts.md` + `references/seedance25.md` | one Seedance 2.5 prompt per part |
| 5. Draft render, review, finals | `references/render-qa.md` | approved Draft parts, finalized keepers |
| 6. Edit + delivery | `references/edit-deliver.md` | tight cut, platform episode, social cutdowns, trailer, key art |

Craft depth lives in the filmmaking packs; reuse them, do not restate them: `references/filmmaking.md` (router), `references/scene-engine.md`, `references/acting-direction.md`, `references/blocking-continuity.md`, `references/audio-dialogue-music.md`, `references/visual-dna.md`, `references/video-editor.md`.

### Stage 0 — Kickoff (ask once, in one labeled question card)

Ask these before any paid step, with the suggested default first. Store the answers at the top of the bible.

1. **Idea + genre**: the user's premise, and one of the genre templates in `references/writing.md` (romance/revenge, thriller/mystery, brand series, comedy) or "other".
2. **Season shape**: number of episodes (suggest 6), episode length (suggest 45-90 s), aspect (suggest 9:16).
3. **Language**: English is the reliable default. Seedance 2.5 performs English dialogue natively. For any other language, tell the user before anything is generated: Seedance 2.5 may not speak it (it does not speak Hebrew at all), and the route is either a model that speaks it natively (check `list_models`) or recorded/generated speech with a lip-sync model, both with their own cost and quality trade-offs. Let the user choose.
4. **Look route**: photoreal drama, or a stylized glamour / nostalgic look (Midjourney stills as the look source). See `references/cast-locations-voices.md`.
5. **Finals**: episodes are always blocked in Seedance 2.5 Draft. Read `draft_resolutions[].final_resolutions` for `seedance-2-5` in `list_models` (as of 2026-10 a Draft finalizes to 1080p only). If there is a choice, ask which tier; if not, tell the user the final tier and its cost per 30 s, and ask whether to finalize at all or deliver the Draft cut.
6. **Credit cap** for the season (and per episode), quoted against the estimate in `references/render-qa.md`.

Then create one Kolbo project per series (`create_project`) and pass its `project_id` on every call. The bible is a Kolbo Doc in that project (`create_doc`), so Kobi, the user and outside agents read the same source of truth.

### Approval gates (the user decides; the agent runs everything between them)

1. Concept + season outline.
2. Each new character's sheet, then its voice (picked from 2-4 auditions).
3. Credit cap. Inside the cap, Draft renders run without asking. Every finalization, and anything over the cap, needs a yes with the quoted cost.
4. The tight cut of each episode.
5. Publishing is always the user's action.

In Kobi Act, `submit_plan` is the approval card for each gate; do not add extra confirmation loops between gates. Outside Kobi, follow the Kolbo brief-and-cost confirmation rule at each gate.

### Chat and discovery

Kolbo Chat exposes this workflow as **Micro-Drama Studio** (`micro_drama`). Chat uses `references/chat.md` for planning and prompt delivery; Kobi Act loads this router and the stage files from the bundled Kolbo skill. The public standalone command is `/kolbo:micro-drama`.

### Where it runs

Any agent connected to the Kolbo MCP can run this workflow end to end: Kobi in the Kolbo app, Kolbo Code, Claude Code, Codex / ChatGPT agents, Cursor. Generation, references, project, bible Doc and transcription are all Kolbo tools. The only local part is the optional edit scripts, which need a shell, Python 3, numpy and ffmpeg; agents without a shell build the cut in the Kolbo Video Editor instead.

### Who edits

- **Kobi** builds every cut in the Kolbo Video Editor (`references/video-editor.md`), so the user can open and tweak it.
- **Outside agents** (Claude Code, Codex, Kolbo Code) with a shell edit locally with the bundled scripts in `scripts/micro-drama/` (Python 3 + numpy + ffmpeg). They may also hand the user a Video Editor session if asked.

### Hard rules

- Every character is fictional and a clearly adult (21+), stated in every character prompt and visible on screen. No real-person or celebrity likeness. No famous names or IP in any prompt.
- Consent is explicit in any romantic or intimate beat. No sexual content; heat stays at the level the user's platforms allow.
- Never spend over the cap. Never finalize without a quote and a yes.
- Every stage ends in its QA gate. A failed gate gets the smallest fix (one shot, not the episode), at most 2 retries per item, then report to the user with evidence.
- Every user note becomes a fix plus a rule in the series bible's "House rules" section, so the next episode does not repeat it.

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
- [micro-drama](references/micro-drama.md)
- [cast-locations-voices](references/cast-locations-voices.md)
- [chat](references/chat.md)
- [edit-deliver](references/edit-deliver.md)
- [render-qa](references/render-qa.md)
- [series-bible](references/series-bible.md)
- [shots-prompts](references/shots-prompts.md)
- [writing](references/writing.md)
- [product-photoshoot](references/product-photoshoot.md)
- [production-log](references/production-log.md)
- [production-planning](references/production-planning.md)
- [prompt-structure](references/prompt-structure.md)
- [thumbnails](references/thumbnails.md)
- [troubleshooting](references/troubleshooting.md)
- [ugc-smartphone](references/ugc-smartphone.md)
- [video-editor](references/video-editor.md)
- [visual-dna](references/visual-dna.md)
