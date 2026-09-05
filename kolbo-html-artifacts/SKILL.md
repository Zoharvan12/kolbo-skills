---
version: 0.9.13
name: kolbo-html-artifacts
description: |
  Build distinctive, production-grade HTML artifacts — slide decks /
  presentations / pitch decks, landing pages / marketing sites / one-pagers,
  and interactive widgets (dashboards, data viz, mini-games, UI mockups, charts,
  animated components). Publishable to sites.kolbo.ai with strict CSP.

  Use when: "build me a presentation / slide deck / pitch deck / mצגת",
  "build me a landing page / one-pager / SaaS site / waitlist page / דף נחיתה",
  "build me a dashboard / data visualization / interactive widget / animated
  component / mini-game / UI mockup / chart / tool / demo", "publish this HTML",
  "share this artifact".

  Chain: pair with kolbo-generate for hero images / background visuals, then
  publish_html_artifact returns a sites.kolbo.ai URL.

  NOT for: any non-rendered code (use kolbo-app-builder for full React apps),
  motion graphics or video (use kolbo-generate), generic markdown documentation.
argument-hint: "[type: presentation|landing|widget] [brief]"
allowed-tools: Bash, Read, Write, Edit
---

<!-- AUTO-GENERATED from kolbo-code packages/opencode/skills/kolbo — DO NOT EDIT.
     Edit the canonical skill and let .github/workflows/sync-skill-to-plugin.yml regenerate this. -->

# Kolbo HTML Artifacts

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

<!-- PARITY: this file mirrors getHtmlPresentationSystemPrompt() + HTML_ARTIFACT_BOILERPLATE
     in kolbo-api/src/config/systemPrompt.js (lines ~1377–1515).
     When that function changes, update this file in the same session. -->

## HTML Presentation — Build Rules

Load this file when the user wants to **build / create / generate an HTML presentation, slide deck, or pitch deck**. For landing pages see `models/landing-page.md`; for any other interactive HTML artifact (dashboard, game, chart, widget) see `models/visual-code.md`.

**Kolbo Code routing:** write the artifact as a single HTML block in your reply. The Kolbo Code panel renders it as a previewable artifact card. Optionally call `publish_html_artifact({ title, content })` afterward to get a public `sites.kolbo.ai` URL.

### 🚨 NON-NEGOTIABLE: Viewport Fitting

Every single slide MUST fit exactly within 100vh. **No scrolling within a slide, ever.** If content doesn't fit, SPLIT into multiple slides. This is the #1 rule, no exceptions.

Apply these invariants to EVERY slide in EVERY deck:
- Every `.slide` element has: `height: 100vh; height: 100dvh; overflow: hidden;` and a centered flex/grid layout.
- ALL font sizes and spacing use `clamp(min, preferred, max)` — **never fixed px/rem**. Example: `font-size: clamp(2.5rem, 5vw, 5rem);`.
- Content containers need explicit `max-height` constraints.
- Images: `max-height: min(50vh, 400px); object-fit: contain;`.
- Include short-viewport breakpoints: `@media (max-height: 700px)`, `(max-height: 600px)`, `(max-height: 500px)` — reduce font sizes / hide decoration / tighten gaps at each.
- Add `@media (prefers-reduced-motion: reduce) { *, *::before, *::after { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; } }`.
- Never negate CSS functions directly. `-clamp()` is silently ignored. Use `calc(-1 * clamp(...))`.

### 🚨 NON-NEGOTIABLE: Content Density Limits per Slide

| Slide Type     | Maximum Content |
| -------------- | --------------- |
| Title slide    | 1 heading + 1 subtitle + optional tagline |
| Content slide  | 1 heading + 4–6 bullets OR 1 heading + 2 short paragraphs |
| Feature grid   | 1 heading + max 6 cards (2×3 or 3×2) |
| Code slide     | 1 heading + 8–10 lines of code max |
| Quote slide    | 1 quote (≤3 lines) + attribution |
| Image slide    | 1 heading + 1 image (max 60vh height) |

**Content exceeds limits? Split into more slides. Never cram, never shrink fonts to fit, never enable scrolling.**

### Deck Length & Structure

- **Default 8–12 slides** unless the user specifies otherwise. **Hard cap 16 slides** — bigger decks become unwieldy.
- Pick a structure based on the purpose:
  - **Pitch deck**: Hook → Problem → Solution → How it works → Traction → Market → Team → Ask
  - **Product / feature demo**: Title → Why → What → How (3 features) → Demo → Pricing → Next steps
  - **Educational**: Title → Learning goals → Concept 1 → Concept 2 → Concept 3 → Example → Recap → Q&A
  - **Status / review**: Title → Wins → Numbers → Challenges → Next quarter → Ask
- **One idea per slide.** Headlines lead: short, declarative, ideally <8 words. Body copy supports.

### Slide Layout Palette (vary these — never use the same layout twice in a row)

- **Title slide**: oversized headline, subtitle, optional brand mark / date / speaker name.
- **Content slide**: headline + 4–6 bullets OR 2-column split (text left, visual right).
- **Quote / pull-quote**: big quote, attribution, optional accent.
- **Data slide**: big number (kpi) + label + small supporting chart (Chart.js).
- **Image-led slide**: full-bleed image with caption overlay.
- **Comparison slide**: side-by-side with checkmarks/crosses.
- **Process / flow slide**: numbered steps with arrows / chevrons.
- **Closing / CTA slide**: short CTA, contact, thank-you.

### Aesthetic Direction — COMMIT BOLDLY

**Pick a clear conceptual direction and execute it with precision.** No timid middle-ground choices. Bold maximalism and refined minimalism both work — what matters is intentionality.

Before writing CSS, pick ONE aesthetic and commit:
- **Bold Signal** — high-contrast monochrome + one electric accent, oversized type
- **Electric Studio** — saturated brand color, generous whitespace, geometric accents
- **Dark Botanical** — near-black + deep emerald + warm gold, organic curves
- **Creative Voltage** — bright neon palette, kinetic typography, motion-led
- **Neon Cyber** — black + cyan + magenta, scanlines / grid lines, terminal vibes
- **Split Pastel** — soft duotones, rounded geometry, friendly playful
- **Notebook Tabs** — paper textures, marker-style annotations, hand-drawn shapes
- **Paper & Ink** — cream + black + warm red, classical serif, editorial restraint
- **Swiss Modern** — pure white + black + one accent, grid-disciplined, helvetica-class fonts
- **Vintage Editorial** — sepia / cream tones, classical serif headlines, golden-ratio layouts
- **Pastel Geometry** — soft palette, bold shapes, layered transparencies
- Or invent one that matches the topic. Don't always default to the same look.

### Typography — DISTINCTIVE FONTS ONLY

**Never use system fonts. Never use Inter, Roboto, or Arial.** Pull from Google Fonts or Fontshare. Pair a distinctive display font with a refined body font:
- Editorial: `'Fraunces'` / `'Playfair Display'` / `'DM Serif Display'` + `'Source Sans 3'` body
- Modern technical: `'Bricolage Grotesque'` / `'Instrument Serif'` / `'Geist'` + `'IBM Plex Sans'` body
- Bold creative: `'Boldonse'` / `'Anton'` / `'Archivo Black'` + `'Manrope'` body
- Mono accent: `'JetBrains Mono'` / `'Geist Mono'` / `'IBM Plex Mono'`
- **Avoid `'Space Grotesk'` for everything** — it's an LLM cliché. Pick something else most of the time.

Hebrew: `'Heebo'`, `'Rubik'`, `'Frank Ruhl Libre'`, `'Assistant'`. Arabic: `'Cairo'`, `'Tajawal'`, `'IBM Plex Sans Arabic'`, `'Reem Kufi'`.

### Color & Background

- Commit to a cohesive palette. **Dominant color with sharp accents beats timid evenly-distributed palettes.** Use CSS custom properties (`:root { --bg: ...; --fg: ...; --accent: ...; }`).
- Backgrounds with atmosphere, not solid colors: layered gradients, gradient meshes, subtle noise texture (data-URI SVG noise), geometric patterns, grain overlays, scanlines, dot grids.
- ❌ NEVER: default purple/violet gradient on white background — instant AI-slop signal.

### Motion — High-Impact, Not Scattered

- One well-orchestrated page-load with staggered reveals (`animation-delay` ladder) beats scattered micro-interactions sprinkled everywhere.
- Slide transitions: `transform: translateX()` + `opacity` with 300–500ms ease-out cubic-bezier. No bouncy / corny effects.
- Use CSS keyframes for everything. GSAP via CDN ONLY if you need a timeline or scroll-trigger.
- Always include the `prefers-reduced-motion` media query.

### Slide Mechanics

- Each slide = `<section class="slide">` inside `<main id="deck">`.
- Only ONE slide visible at a time. Non-active slides: `display: none` (or `opacity: 0; pointer-events: none` if cross-fading). Active slide: `.active` with the slide-type's display.
- Navigation:
  - Arrow keys: `ArrowRight` / `Space` → next, `ArrowLeft` → prev. `Home` / `End` → first/last.
  - On-screen prev/next buttons at bottom corners, semi-transparent.
  - Slide counter "3 / 10" in a corner.
  - Press `F` for fullscreen (`document.documentElement.requestFullscreen()`). `Esc` exits.
  - Press number keys 1–9 to jump to that slide.
  - **RTL decks**: swap arrow direction — right arrow → previous, left arrow → next.
- Subtle progress bar at the very top, fills as the user advances.

### RTL / Multilingual

- Detect language. Set `<html lang="he" dir="rtl">` (or appropriate) when content is Hebrew / Arabic / Persian / Urdu.
- Use Tailwind logical properties (`me-*`, `ms-*`, `ps-*`, `pe-*`, `text-start`, `text-end`) or CSS logical properties (`margin-inline-start`).
- Headline fonts: use locale-appropriate fonts (see Typography section).

### Real Content, Not Lorem Ipsum

- If the user gave you content, use it verbatim where appropriate.
- If they gave a topic only, **invent plausible specific content** for that topic — real numbers, real-sounding quotes, real-feeling section headings. Never "Lorem ipsum", never "Insert your text here".

### Output Discipline — HTML Artifact (NON-NEGOTIABLE)

- Your reply MUST contain exactly ONE ` ```html ... ``` ` fenced code block with a COMPLETE, self-contained HTML document.
- Document must start with `<!DOCTYPE html>` and include `<html>`, `<head>` (with `<meta charset="UTF-8">` + `<meta name="viewport" content="width=device-width, initial-scale=1">`), and `<body>`.
- Embed ALL CSS inside `<style>` and ALL JavaScript inside `<script>`. No external CSS files, no relative asset paths. CDN URLs are fine.
- Approved CDN libraries (use only what you need): Tailwind `<script src="https://cdn.tailwindcss.com"></script>`, GSAP, Chart.js, D3.js, Three.js, Lucide Icons, Framer Motion, React 18 + Babel standalone, Vue 3, date-fns.
- Outside the html block you can write a one-line lead-in and a short 1–2 line note about how to iterate. Nothing else.
- If the user wrote in any language other than English, write your lead-in / closing note in their language. Inside the HTML, match the in-page copy to the user's language and set the appropriate `lang` + `dir` attributes.

### Media Integration

If the conversation contains generated Kolbo media URLs (images, videos, audio), USE the actual URLs inside `<img>` / `<video>` / `<audio>` tags. Never substitute placeholder images or gradient backgrounds when real assets are available.

### Publishing

After the user approves the deck, offer `publish_html_artifact({ title, content })` to get a shareable `sites.kolbo.ai` URL. Server dedupes by content hash — re-publishing identical bytes returns the same URL. The page is served with strict CSP, so it cannot exfiltrate data; CDN frameworks still load.
