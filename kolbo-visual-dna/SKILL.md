---
version: 0.4.0
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
  with the `@<name>` tag in the prompt.

  NOT for: one-shot face swaps (use kolbo-generate with `source_images`),
  named real public figures (refuses on policy), one-time edits without
  reusing the identity.
argument-hint: "[name] [photo paths...] [--type character|style|product|scene]"
allowed-tools: Bash, Read, Write, Edit
---

# Kolbo Visual DNA — Character / Style Consistency

Train a face-faithful identity model. Reusable across all DNA-aware Kolbo generations.

## Step 0 — Bootstrap

Once per conversation, before any other Kolbo tool call:
1. Run `check_credits`. If it fails with "Session expired" / "Not authenticated", ask the user to run `kolbo auth login` (or their branded CLI command) and reload the editor.
2. If `list_visual_dnas` returns empty AND `list_models` also returns empty, MCP isn't wired — same fix.

## What Visual DNA Is

A Visual DNA captures the "identity" of a character, style, product, or scene from reference media. Pass `visual_dna_ids` to any compatible generation tool — the server expands the DNA's reference images and auto-routes to the model's edit variant when appropriate. Up to **8 DNAs** can be active in a single generation (e.g. main character + product + side character).

## MCP Tools

| Tool | Purpose |
|---|---|
| `create_visual_dna` | Create a DNA from reference images (+ optional video / audio). Max 4 images. |
| `list_visual_dnas` | List all DNAs in the user's library (id, name, type, thumbnail). |
| `get_visual_dna` | Fetch full profile incl. system prompt + reference images. |
| `delete_visual_dna` | Remove a DNA. |

**Server-side auto-routing:** passing `visual_dna_ids` is enough — the server expands the DNA's reference images and auto-routes the chosen text-to-image model to its image-editing variant (e.g. `nano-banana-2` → `nano-banana-2-image-editing`). You do NOT need to also pass `reference_images` when using DNA. If the chosen model has no edit variant, the server falls back to using the DNA's images as style references on the t2i model. DNA payloads are never silently dropped.

## Workflow

1. **Get name.** One word, single-token, lowercase, ASCII-safe — used for the `@name` tag in every future prompt. Ask if missing.
2. **Get photos.** 5–20 face photos, varied angles and lighting. Local paths or already-uploaded media URLs both work — `create_visual_dna` accepts either.
3. **Pick type.** `character` (default), `style`, `product`, `scene`, `environment`.
4. **MANDATORY pre-flight: generate 2 reference images first.**
   - Fire both in parallel — one `generate_image` call each:
     - 4-angle character sheet (aspect_ratio `16:9`): `"[character description], character reference sheet showing front view, back view, left side view, right side view, four panels arranged in a 2x2 grid, neutral solid background, full body, photorealistic"`
     - Close-up portrait (aspect_ratio `1:1`): `"[character description], close-up portrait, face and shoulders, neutral solid background, soft studio lighting, photorealistic"`
   - These two generated images give the DNA engine multi-angle coverage and dramatically improve identity consistency.
5. **Submit.** `create_visual_dna({ name, type, images: [<4-angle sheet URL>, <close-up URL>, ...user's reference paths/URLs] })`. Up to 4 images total — if the user gave more than 2, pick the 2 most representative or ask which to keep.
6. **Capture `vdna_id`** from the response.
7. **Deliver.** "Visual DNA `<name>` ready. Use it in any generation by passing `visual_dna_ids: [\"<vdna_id>\"]` and writing `@<name>` in the prompt."

**Skip step 4 only if:** the user explicitly says "just use my image as-is" OR they provided 3+ reference images already covering multiple angles.

## ⚠️ Pre-flight: Verify the Visual DNA Exists Before Using It (MANDATORY)

When ANOTHER skill (kolbo-generate, kolbo-marketing-studio, etc.) wants to use a DNA by name, the agent MUST verify it exists before generating:

1. Call `list_visual_dnas` to get the actual available DNAs (id + name).
2. Match the user's reference (by name) to a real DNA.
3. If there is **no match**, STOP and ask: "I don't see a Visual DNA named `<X>` in your library. Do you want me to create one now (I'll need reference image(s)), use an existing one (<list>), or proceed without DNA using direct reference images?"
4. Only proceed once you have a real `vdna_*` id.

Do NOT: invent a DNA id, assume one exists, use the same id for a different character because "it sounded close", or carry a DNA id from `.kolbo/production.md` without re-confirming via `list_visual_dnas`.

## ⚠️ @name Syntax — ALWAYS use it (MANDATORY)

Whenever a generation call passes `visual_dna_ids` (even just one), the prompt MUST refer to each DNA by `@<exact-name>` — the literal `name` field. Without `@name`, the engine guesses, drops the DNA, or blends multiple DNAs together.

**Naming rule for `create_visual_dna` — NO SPACES.** The `name` MUST be a single token, lowercase, no spaces, ASCII-safe — `esther_model`, `dana`, `tokyo_neon`, `brand_red`. Never `Sarah Johnson`, never `the red dress`. Reason: the prompt parser stops `@<token>` at the first space. So `@Sarah Johnson` matches only `Sarah` — if no DNA named `Sarah` exists, the mention is silently dropped and the DNA never binds. Use underscores for multi-word concepts. When the user proposes a name with spaces, collapse it (`"Sarah Johnson"` → `sarah_johnson`) and tell them once how you'll refer to it.

**Right:**
```
prompt: "@esther_model wearing a gold necklace, half-body portrait"
visual_dna_ids: ["vdna_abc"]   // esther_model
```

**Wrong** (the engine sees plain text "esther" and has no idea it should bind):
```
prompt: "esther wearing a gold necklace"
visual_dna_ids: ["vdna_abc"]
```

**Multi-DNA example:**
```
prompt: "@dana standing in @shop, picking up a product"
visual_dna_ids: ["vdna_dana", "vdna_shop"]
```

**Any language:** if the DNA was created with `name: "אסתר"` you write `@אסתר`. Use the EXACT stored string.

## Reference Tagging — `@image1` / `@video1` / `@Audio1`

When a generation call ALSO passes plain references (`reference_images`, `source_images`, `reference_videos`, `reference_audio`), tag them by position so the engine knows which asset plays which role:

| Tag | Refers to |
|---|---|
| `@image1`, `@image2`, … | Plain images in `reference_images` / `source_images` (position in the array) |
| `@video1`, `@video2`, … | Videos in `reference_videos` / `source_videos` |
| `@Audio1`, `@Audio2`, … | Audio in `reference_audio` / `audio` slots |
| `@<dna-name>` | Visual DNA (name-based, not positional) |

**Reserved:** never name a Visual DNA `Image1` / `Video2` / etc. — those tokens are claimed by the positional parser.

**Tagged prompt example:**
```
Place @maya at the coffee-shop counter from @image1, wearing the leather jacket
from @image2. Keep the warm window light from @image1; ignore the people in
the background of @image2.
```

## When to Use DNA — Routing per Tool

| Tool | DNA support | Field |
|---|:-:|---|
| `generate_image` | ✅ | `visual_dna_ids` (text-to-image; image-editing variant auto-routed) |
| `generate_image_edit` | ✅ | `visual_dna_ids` (combine with `source_images`) |
| `generate_creative_director` | ✅ | `visual_dna_ids` (locks character across every scene) |
| `generate_elements` | ✅ | `visual_dna_ids` (PRIMARY route for DNA → video) |
| `generate_video_from_image` | ✅ | `visual_dna_ids` (image is the anchor; DNA adds identity lock) |
| `generate_video_from_video` | ✅ | `visual_dna_ids` (re-style with locked identity) |
| `generate_first_last_frame` | ✅ | `visual_dna_ids` |
| `generate_video` | ❌ | text-to-video SILENTLY DROPS `visual_dna_ids` — use `generate_elements` instead |
| `generate_lipsync` | — | source face IS the identity; DNA not needed |

**Cap:** read `max_visual_dna` (+ `supports_visual_dna` boolean) on each model from `list_models`. Typical: image models up to 8, Kling 3, Elements 3–5.

## ⚠️ Don't re-fetch / re-list your own outputs (CRITICAL)

After `create_visual_dna` returns, the DNA is already in the user's library and visible in the desktop canvas. Do NOT call `list_visual_dnas` again "to verify". Do NOT pass the DNA's reference images to `chat_send_message` "to confirm". Burns credits and flickers the gallery.

## Presenting list results — show thumbnails (MANDATORY)

When you display `list_visual_dnas`, render each item's thumbnail as a markdown image:

```
Visual DNAs (6):
1. **Maya** — `vdna_abc` (character)
   ![Maya](https://cdn.kolbo.ai/.../maya-thumb.jpg)
2. **Tokyo Neon** — `vdna_xyz` (style)
   ![Tokyo Neon](https://cdn.kolbo.ai/.../tokyo-thumb.jpg)
```

Fields to read for image source (first one present): `thumbnail`, `thumbnail_url`, `preview_url`, `url`, `image`.

## When NOT to Use Visual DNA

- **Animating an image** → `generate_video_from_image`; the source image IS the reference, don't add `visual_dna_ids`.
- **Video DNA via `generate_video`** → text-to-video silently drops `visual_dna_ids`. For character-consistent video, route through `generate_elements`.

## UX Rules

1. Be concise. No raw IDs in chat — just say "Visual DNA `<name>` ready" with a friendly reference.
2. Detect language and respond in it. CLI flags and `@name` tags stay in the form they were stored.
3. Ask for the smallest set of inputs: name + photos. Pick a sensible type default (character).
4. Polling is silent — training takes ~30s. Don't repeat status updates.
5. After delivery, suggest one concrete next call: "Want to use `@<name>` in a UGC ad now? (kolbo-marketing-studio)"
