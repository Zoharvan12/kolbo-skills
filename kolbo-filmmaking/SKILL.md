---
version: 0.9.10
name: kolbo-filmmaking
description: |
  Direct AI films end to end — script development, production bible, recurring
  characters and locations, acting direction, blocking and continuity, camera
  and optics, physics, dialogue and score, then executable model prompts for
  Seedance, Veo, Kling and Hailuo.

  Use when: "write this scene", "direct this shot", "make a short film",
  "build a production bible", "keep the character consistent across shots",
  "the acting feels dead", "the eyes look empty", "audit this prompt",
  "my last take failed, fix the prompt", "plan a multi-shot sequence",
  "storyboard this", "shot list", "continuity between cuts".

  Chain: develop scene (scene engine) → production bible + Visual DNA
  (kolbo-visual-dna) → shot cards → generate via kolbo-generate /
  kolbo-creative-director → audit failed takes and patch the prompt.

  NOT for: one-off images or single clips with no story or continuity
  requirement (use kolbo-generate), video editing or FFmpeg, motion graphics.
argument-hint: "[scene, shot, or prompt to direct or audit]"
allowed-tools: Bash, Read, Write, Edit
---

<!-- AUTO-GENERATED from kolbo-code packages/opencode/skills/kolbo — DO NOT EDIT.
     Edit the canonical skill and let .github/workflows/sync-skill-to-plugin.yml regenerate this. -->

# Kolbo Filmmaking — Development, Direction, Production

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

- **Video/lipsync `credit` is per-SECOND, not per-clip**: `total = credit × duration`. This is the universal rule for video/firstlast/elements/motion_graphic/cast types, not a per-model exception — `list_models` states it inline now. The one carve-out is a model with `flat_credit_by_resolution` set.
- **Batch totalling 100+ credits**: run `check_credits` first.
- **Quote real cost**: after firing, log `credits_used` (from the tool result) to `.kolbo/production.md` — never `base × count`.
- **Never state "credits remaining" from arithmetic** (opening balance − generation costs). Coding/chat usage deducts credits too, so the math is always wrong. Report cost only; if the user asks for their balance, call `check_credits` fresh at that moment.

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

Write each session's `session_id` + plan name into `.kolbo/production.md` `### Sessions`. Do **not** mark the phase Approved or jump to the next bucket until the user confirms (or you asked a labeled GATE and they answered). Full rules: `references/workflows/production-planning.md` + `production-log.md`.

## ⚠️ Generation lifecycle — source of truth, waiting, failures (HARD RULE — read this)

**How calls work:** each generation tool blocks until the job is fully complete. Images: seconds. Video: minutes. Multiple tool calls in one response run concurrently. On hosts with live widgets the tool instead returns `submitted` (or `_timed_out`) instantly — the card updates on its own.

Four surfaces show the same job. Use this map — never invent a fifth:

| Surface | What it is | Trust it for |
|---|---|---|
| **Library** (right panel — "This session" / "All media") | User-facing gallery of **completed** media | "Is the user's output there?" Point humans here — never to chat history. Finished clips/images land automatically — do **not** call `list_media` / `get_media` / `list_session_generations` to "check if it worked" after a generate you already submitted (burns credits/context, can pollute the session). A K/logo spinner tile **is** the in-progress placeholder for the same job, not a missing one. |
| **Chat generation card** | Progress chrome while a job is in flight | Status badge only (`Generating` / done). A **black / empty preview while Generating is NORMAL** — the iframe has nothing to paint yet. It is **not** failure, not "lost", not a reason to re-fire. |
| **`get_generation_status`** (MCP) | Agent API for job state | Whether the server job is `completed` / `failed` / still running, and the final `urls`. This is your SoT for in-flight work — **not** the card pixels. |
| **`.kolbo/production.md`** | Your private log across turns | Ids + URLs after success. Compaction-safe memory — not the user gallery. |

**🛑 NEVER re-fire a generation you already called.** Aborted / timed-out / `submitted` calls still process server-side. Finish with `get_generation_status` (`wait=true`) — never a second `generate_*`.

**🛑 After `submitted` / `_timed_out` — END THE TURN (credit guard).** Do **not** keep thinking, writing skills, editing files, or planning "next steps" while a generation is still running — that burns the user's coding/chat credits for nothing. Either **stop immediately** after telling the user it's generating in Library / the card above (preferred when you do not need the output URLs yet), OR — if the **next** required step needs those URLs — call `get_generation_status` **once** with `wait=true` as the **only** follow-up, no parallel Write/Edit/Think while it waits.

**Checking status — NEVER poll in a loop.** `get_generation_status` takes `wait=true` (blocks server-side until done, ~3 min) and `generation_ids` (check MANY generations in ONE call — returns `all_done` + which are still running). One `wait=true` call replaces any polling loop: check ALL in-flight ids in ONE call, never one by one, never without `wait`. If it comes back with some still processing, call it ONCE more with `wait=true` and the remaining ids.

**Detecting failure — a generation can fail three ways. Treat ALL as failure:**

1. **Tool returns `error`** — explicit. Surface, suggest retry, log `generation_id`.
2. **Tool returns `completed` but `urls` is empty** — silent failure (NSFW filter, model OOM, upstream 5xx). Tell user "completed without an output — retrying" and re-fire ONCE. Do NOT claim it worked.
3. **Tool hangs / never returns** — MCP poll timed out. Call `get_generation_status(generation_id, wait=true)` IMMEDIATELY. The server might be done.

**Reporting:**
- Don't celebrate before reading the result. Verify `urls` is non-empty.
- Don't auto-retry without surfacing the failure. Partial batches: list failed items + reasons + successful count, and surface the user's count — "6 of 8 ready", not "videos ready". Never "✅ all done!" on partials.
- Log only successes to `.kolbo/production.md` — never failed items.
- When done: say the result is in **Library → This session**. "Where is it?" → Library (This session). "Is it done?" with no urls yet → `get_generation_status` once.

`failure` envelope structure + retry rules: `references/workflows/troubleshooting.md`.

## ⚠️ Generated URLs in Chat (CRITICAL)

Chat renders markdown natively. `![alt](url)` = inline image. `[label](url)` = labeled link with preview.

- **Catalog-style replies** (numbered lists of characters / scenes / products): embed `![alt](url)` so each item shows inline.
- **Conversational replies** ("4 shots ready"): keep prose short; Library already shows the gallery.

Avoid bare URL dumps and HTML `<table>` grids — Library already provides a gallery.

**After `generate_creative_director` completes** — share results as individual URLs, one per scene. Do NOT create an HTML grid artifact.

**Always** park every successful URL + `session_id` in `.kolbo/production.md` as a **candidate**. Promote to Approved and advance the plan only after the user confirms — see `references/workflows/production-log.md`.

## Filmmaking Router

Operate as a filmmaking system, not merely a prompt writer. Preserve project truth across generations while compiling every generation into a self-contained instruction the selected model can execute.

### Start here

1. Identify the requested production stage and deliverable.
2. Read only the reference files required by the routing table below.
3. Preserve or establish the relevant production truth before writing a shot.
4. Choose generation mode, control density, craft packs, audio lane, and model adapter.
5. Produce the requested artifact in the user's language; keep generation prompts in English unless the user requests otherwise.
6. Run the applicable audit. For saved prompt/package artifacts, run the bundled validators.

Do not generate media, spend credits, or contact external systems unless the user explicitly asks. Do not silently change an existing billable prompt beyond the requested scope. In Workbench mode, patch the failed section and keep proven sections byte-stable whenever practical.

### Route the work

Read [routing.md](references/filmmaking/routing.md) for the full decision rules.

| Request | Mode | Read |
|---|---|---|
| Any multi-asset or multi-scene production — film, ad, episode, campaign, recurring or multiple characters | Production planning | `references/workflows/production-planning.md` **first** — map assets, build the DNAs, confirm the set, only then shoot |
| Premise, outline, screenplay, weak scene | Development | `scene-engine.md`, then `workflows.md` |
| Character, location, prop, state, voice, or production preparation | Pre-production | `asset-preproduction.md`, `production-bible.md`; add `acting-direction.md` for recurring characters |
| One generation-ready video prompt | Direction | `prompt-contracts.md`, selected craft references, then the model adapter |
| Connected dialogue or performance | Direction | `acting-direction.md`, `blocking-continuity.md`, `audio-dialogue-music.md`, model adapter |
| Music video, dance, singing, or exact song | Direction | `audio-dialogue-music.md`, `cinematography.md`, `blocking-continuity.md`, model adapter |
| Difficult action, transformation, scale, vehicle, creature, water, or impossible gravity | Direction | `physics-action.md`, `blocking-continuity.md`, `cinematography.md`, model adapter |
| Broken result or prompt | Audit | `validation.md` plus only the craft/model references implicated by the failure |
| Revise one failed behavior without losing what worked | Workbench | `validation.md` and the relevant craft reference |
| Multi-scene, episode, commercial, music video, or feature workflow | Production | `production-bible.md`, `workflows.md`, `validation.md` |

For Seedance 2.5, always read [seedance-2-5.md](references/models/seedance25.md) before final compilation. Treat capability numbers as a dated adapter snapshot and verify them against current provider/catalog truth when real money or production delivery depends on them.

### Keep two layers separate

#### Project truth

Maintain durable facts outside individual prompts:

- story goal, world laws, period, genre, tone, and visual registers;
- characters, immutable identity anchors, states, wardrobe, injuries, performance engines, and voices;
- locations, landmark geometry, light direction, axes, and available coverage;
- props, vehicles, creatures, scale laws, ownership, hand state, damage, and versions;
- scene and shot cards, continuity state, coverage, generation attempts, and editorial needs.

Use the templates in `assets/filmmaking/` when the task benefits from saved project state. Read [production-bible.md](references/filmmaking/production-bible.md) before creating or updating them.

#### Generation island

Compile only what the current generation needs. A video model cannot resolve “same as before” unless the needed state is restated. Include active truth explicitly, but do not carry inactive characters, stale tags, old props, irrelevant backstory, or previous-shot prose.

Kolbo Visual DNA is semantic project truth, not merely reference imagery. Read and preserve the saved DNA type and analyzed context: character DNAs own identity/state/performance/voice; environment and scene DNAs own location/geography/light; product DNAs own prop/product identity, scale, material, and state; style DNAs own the visual register. Keep exact tags and never reinterpret one DNA type as another.

### Compile a shot

Read [prompt-contracts.md](references/filmmaking/prompt-contracts.md) for exact structures.

Before writing, establish:

1. The dramatic event and the shot's job in the edit.
2. Active references and exact state variants.
3. First visible frame and final state.
4. Geography, axis, screen direction, eyelines, and prop/hand state.
5. Action feasibility inside the duration.
6. Acting tasks for performers and listeners.
7. Camera grammar and control density.
8. Audio ownership, exact words/lyrics, and whether music is native, source-driven, or reserved for post.
9. Model capability limits and target generation mode.

Prompt-length limits apply to the entire compiled generation prompt as one string, including whitespace, headers, timecodes, dialogue, audio, and locks. Count after compilation; read the cap from `max_prompt_length` via `list_models` (see `models/seedance25.md`).

**Seedance 2 / Seedance 2.5 / `generate_elements` — Locked Intro is the only compile shape.** Read `references/models/seedance.md` (and `seedance25.md` for 2.5 caps). Do not emit the SCENE CONTEXT / OPTICS / ACTION department pack below as the generation prompt. Every Visual DNA in play must be `@ExactName` in CAST and in each shot — never "the left man" or a possessive.

```text
Total: Xs / N shots / AR
[GLOBAL LOOK – LOCKED, APPLIES TO EVERY SHOT]
[CAST – IDENTICAL IN EVERY SHOT]   ← @DNAName per person
[LOCATION]
SHOT N — 0:00–0:02 — …
```

The SCENE CONTEXT pack in `prompt-contracts.md` is an **audit / pre-compile checklist** for non-Seedance models and Workbench diagnosis — not the default Elements prompt.

For anchored or exploratory work on other models, collapse compatible blocks and protect only non-negotiables. Never manufacture a rigid skeleton when a looser model-native prompt is more likely to succeed.

### Preserve continuity

Track both kinds:

- **Within-generation continuity:** positions, axis, gaze, wardrobe, props, injuries, lighting, motion, audio ownership, and state across internal cuts.
- **Across-generation continuity:** the exact final state of shot N becomes explicit input truth for shot N+1. Preserve emotional carry, breath, body tension, dirt/wetness/damage, prop hand, screen direction, ambience, and dialogue seam.

Never rely on memory alone for a substantial production. Update the continuity ledger after an approved shot or deliberate script/state change.

### Workbench revisions

When a generation fails:

1. Compare intended versus observed result.
2. Identify one primary failure owner: asset, state, dramatic design, blocking, acting, optics, camera, timing, physics, lighting, audio, model capability, or prompt contradiction.
3. Change the smallest causal unit.
4. Preserve every proven line or block.
5. Log the change and verdict.
6. After repeated failures, redesign the shot: bake the state into an asset, add a staging/layout reference, reduce actions, split the shot, change the angle, or switch model/mode.

Do not keep polishing adjectives when the shot is physically or structurally overconstrained.

### Validate

Read [validation.md](references/filmmaking/validation.md). At minimum check:

- all referenced assets exist and match the intended state;
- no stale, invented, dangling, or conflicting tags;
- character and prop counts remain feasible;
- duration, timecodes, shot count, and dialogue fit;
- continuous-take and cut instructions do not conflict;
- one actor owns each spoken/sung line;
- camera freedom does not contradict strict geography;
- model limits and prompt budget are respected;
- final frame state is explicit enough for the next shot;
- the result is usable without reading hidden reasoning.

Run:

```powershell
python scripts/filmmaking/validate_film_package.py <project-folder>
python scripts/filmmaking/lint_prompt.py <prompt.txt> --shot-card <shot-card.json> --model seedance-2.5
```

Fix errors before delivery. Report warnings that represent genuine creative tradeoffs rather than silently flattening the user's intent.

### Production workflows

Read [workflows.md](references/filmmaking/workflows.md) for single shots, dialogue scenes, music performance, connected sequences, impossible shots, and feature workflows.

This workflow is part of the canonical Kolbo skill. The Kolbo Code sync pipeline mirrors it to MCP and plugin consumers; product surfaces may compile the same filmmaking truth through their own model adapters.
