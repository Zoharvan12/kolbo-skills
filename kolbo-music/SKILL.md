---
version: 0.8.4
name: kolbo-music
description: |
  Generate music via Kolbo — primarily Suno + variants. Full songs, lyrics,
  instrumentals, jingles, scores, soundtracks, lo-fi beats, ad music,
  cinematic trailers.

  Use when: "make me a song", "Suno prompt", "write lyrics for", "music prompt",
  "ai song", "soundtrack", "jingle", "lo-fi beat", "cinematic score",
  "instrumental for [scene]", "background music for my video".

  Chain: usually standalone, but ad/video flows often pair this with
  kolbo-marketing-studio or kolbo-generate (video) — generate music separately,
  then mux client-side or pass the music URL into a video tool that supports
  `audio_url`.

  NOT for: TTS / voice cloning (use kolbo-generate with `generate_speech`),
  sound effects (use kolbo-generate with `generate_sound`), full ad video
  (use kolbo-marketing-studio).
argument-hint: "[style description] [--lyrics file] [--instrumental] [--duration <s>]"
allowed-tools: Bash, Read, Write, Edit
---

<!-- AUTO-GENERATED from kolbo-code packages/opencode/skills/kolbo — DO NOT EDIT.
     Edit the canonical skill and let .github/workflows/sync-skill-to-plugin.yml regenerate this. -->

# Kolbo Music

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

<!-- PARITY: this file mirrors getMusicPromptSystemPrompt() in
     kolbo-api/src/config/systemPrompt.js (lines ~1259–1371).
     When that function changes, update this file in the same session. -->

## Music — Prompt Rules (Suno-led)

Load this file when the user wants AI-generated **music** — full songs, lyrics, instrumentals, jingles, scores, soundtracks, lo-fi beats, trailers, ad music. Primarily Suno; the same craft applies to other music models. For TTS / voice cloning see `models/prompt-copilot.md`. For sound effects see SKILL.md "Sound Effects".

**Kolbo MCP routing:** call `generate_music`. Suno is a model option — use `list_models({ type: "music_gen" })` to see versions. Pass `instrumental` and `duration` as separate params; pass the Style/Description text as `style` and the Lyrics as `lyrics`.

**Wants an EXISTING track, not a new song?** ("background music", "stock music", "royalty-free track") → don't generate. Use `search_stock_media` with `mediaType: "music"` (semantic vibe query — "tense cinematic pulse", "uplifting corporate background") → `get_stock_asset` for download URLs. Free, no credits. The older `*_music_library` tools are deprecated adapters over the stock library — prefer the stock tools.

### CRITICAL Kolbo Platform Rules

- **Model version, duration, and instrumental toggle are MCP-tool params.** Don't write `v4.5`, `30 seconds`, or `instrumental: true` inside the prompt fields themselves.
- **Exact track length = `duration_seconds`** (clamped 5–300s). Only length-controllable models honor it (e.g. ElevenLabs Music, `music-v1`) — without it those models default to a ~10s track, so ALWAYS pass it for jingles/beds on those models. Suno ignores it and picks its own length.
- Suno generations have **two separate input fields**: a **Style / Description** field (`style` param) and a **Lyrics** field (`lyrics` param). Output your prompt as **TWO separate fenced code blocks** so the user (and the tool call) know exactly what goes where.
- Tell the user to run the prompt multiple times — Suno output varies significantly between generations, that's a feature. Use `num_generations` if the tool supports it, or fire 2–4 parallel `generate_music` calls.

### How Music Prompting Actually Works

Suno responds to **descriptive, layered prompts**, not vague ones.
- ❌ "make a pop song"
- ⚠️ "upbeat dance-pop, female vocals, glossy production, catchy chorus, summer vibe"
- ✅ "Dance-pop track, bright analog synths, female lead vocal with airy harmonies, catchy four-on-the-floor hook, 120 BPM, summer road-trip energy"

The formula: **Genre + Mood + Instrumentation + Vocal style + Tempo/BPM + Scene/era anchor**

### The Style / Description Field (`style`)

Pack these into one comma-separated descriptor line (no labels, no quotes around the whole thing — Suno reads it as a style descriptor):
- **Genre / sub-genre** — `synthwave`, `neo-soul`, `bedroom indie pop`, `drill`, `baroque trap`, `cinematic orchestral trailer`
- **Mood** — `melancholic`, `euphoric`, `tense`, `hopeful`, `hypnotic`, `nostalgic`
- **Instrumentation** — `bright analog synths`, `fingerpicked nylon guitar`, `808 sub bass`, `brushed snare`, `Rhodes electric piano`, `strings + harpsichord`, `muted brass section`
- **Vocal style** — `female lead with airy harmonies`, `whispered male falsetto`, `autotuned melodic rap`, `gospel choir backing`, `spoken-word female narrator`, `no vocals` (for instrumental)
- **Tempo / BPM** — `120 BPM`, `slow tempo 70 BPM`, `uptempo 140 BPM`
- **Era / production cue** — `80s analog warmth`, `modern polished pop production`, `lo-fi cassette tape feel`, `live-room reverb`, `bedroom production`
- **Scene anchor (optional but powerful)** — `late night highway drive`, `80s prom night`, `rainy city rooftop`, `Tokyo bullet train`

**Style cap**: keep this field to roughly **8–15 descriptors**. More starts to muddy the output.

### The Lyrics Field (`lyrics`)

Use Suno's section tags to control structure. Each tag goes on its own line, content under it:
- `[Intro]`
- `[Verse]` / `[Verse 1]` / `[Verse 2]`
- `[Pre-Chorus]`
- `[Chorus]`
- `[Bridge]`
- `[Outro]`
- `[Instrumental]` / `[Solo]`

**Production tags** (inline, in brackets — Suno follows them):
- `[Bass drop]`, `[Beat switch]`, `[Tempo change]`
- `[Whisper vocals]`, `[Falsetto]`, `[Spoken word]`, `[Gospel choir]`
- `[Flute solo]`, `[Guitar riff]`, `[808 drop]`
- `[Stop]`, `[Build up]`, `[Breakdown]`
- `- crowd noise -`, `- record scratch -` (SFX in dashes)

**Emphasis**: ALL CAPS amplifies intensity / emotion on that word or line. Use sparingly for impact moments.

**Structure templates**:
- Pop / radio: Intro → Verse → Chorus → Verse → Chorus → Bridge → Chorus → Outro
- Hip-hop: Intro → Verse → Hook → Verse → Hook → Bridge → Hook → Outro
- Cinematic / score: Intro (build) → Theme A → Theme B → Climax → Resolution
- Lo-fi / chill: Intro → Loop A → Loop B → Loop A → Outro (often no vocals)

### Power Moves

- **Mix unexpected genres** — `country + EDM`, `folk + ambient synths`, `classical + trap drums`, `baroque + 808s`. Best outputs often come from contrast.
- **Scene-based language beats sound-only language** — `late-night highway drive` does more work than `atmospheric`.
- **Tags shape structure better than prose** — don't write "then there's a chorus", write `[Chorus]`.
- **No real artist names** — Suno blocks them. Reverse-engineer their style: vocal style + production era + instrumentation + mood.
- **Lean into imperfection** — Suno's quirks often produce the best moments. Don't over-correct.
- **Generate multiple times** — same prompt produces wildly different songs. Tell the user to run 3–4 takes.

### Workflow by Use Case

#### Full song with vocals
- `style`: full descriptor stack
- `lyrics`: tagged structure with lyric content
- Recommend: 2–3 generations to compare

#### Instrumental / score / lo-fi beat
- `style`: descriptor stack + `instrumental`, `no vocals`
- `lyrics`: structure tags only (`[Intro]`, `[Theme A]`, `[Build]`, `[Drop]`), no lyric lines. Or leave empty and pass `instrumental: true` to the tool.

#### Jingle / ad music (15–30s)
- `style`: short, punchy descriptor (`upbeat retail pop jingle, female vocal, claps, glossy production, summer energy`)
- `lyrics`: 2–4 short lines max, often just chorus
- Pass the shortest `duration` the tool supports — or, on a length-controllable model (ElevenLabs Music), pass the exact `duration_seconds` (e.g. `15` or `30`).

#### Cinematic trailer / score
- `style`: `cinematic orchestral trailer, swelling strings, taiko drums, hybrid choir, dramatic build, modern hybrid score`
- `lyrics`: structure tags only — `[Intro]` `[Build]` `[Drop]` `[Climax]` `[Resolution]`
- `instrumental: true`

### Output Discipline

Always output **two fenced code blocks**, clearly labeled (these map directly to `style` and `lyrics` MCP params):

```
STYLE / DESCRIPTION:
<style descriptors, comma-separated, one line>
```

```
LYRICS:
[Intro]
...
[Verse]
...
[Chorus]
...
```

When summarizing to the user, state separately:
- **Instrumental:** yes / no (the `instrumental` param)
- **Recommended duration:** short / medium / long (the `duration` param)
- **Run takes:** N generations (usually 2–4) — fire them in parallel
- **Why this works:** 1 line on the key genre / structure / instrumentation choice

If the user is in any language other than English, explanations in their language; lyric language matches what the user wants (any language works in Suno).
