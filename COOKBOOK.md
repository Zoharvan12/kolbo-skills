# COOKBOOK — End-to-End Recipes

Concrete multi-skill workflows. Each recipe spans 2+ skills and shows the actual chain of MCP calls.

## 1. Train your face → make a UGC ad of you holding your product

**Skills:** `kolbo-visual-dna` → `kolbo-marketing-studio`

```
You: "Train a Visual DNA called 'maya' from these 8 photos.
      Then make a UGC ad of @maya holding my product, casual selfie style."

Agent (kolbo-visual-dna):
  1. list_visual_dnas (check if maya already exists — she doesn't)
  2. generate_image x2 in parallel — 4-angle character sheet + close-up portrait
  3. create_visual_dna({ name: "maya", type: "character", images: [8 user photos + 2 generated] })
  4. Wait → returns vdna_id = "vdna_8f2c"

Agent (kolbo-marketing-studio):
  5. Detect mode = ugc (default); aspect 9:16; sound off; no captions; no watermarks
  6. upload_media(product photo) → product_url
  7. generate_video_from_image({
       image_url: <frame for maya holding product>,
       prompt: "UGC selfie video — @maya holding the product, casual phone-shot...",
       visual_dna_ids: ["vdna_8f2c"],
       aspect_ratio: "9:16",
       duration: 6,
       sound_enabled: false
     })
  8. Returns video URL
```

## 2. Brand research → 8-scene IG campaign → marketplace cards

**Skills:** brand kit (research-first inside `kolbo-product-photoshoot`) → `kolbo-creative-director` → `kolbo-marketplace-cards`

```
You: "Build me an 8-scene IG campaign for drinkolipop.com, then create
      Amazon marketplace cards for their peach flavor."

Agent (kolbo-product-photoshoot — research stage):
  1. Check .kolbo/brand-kits/drinkolipop.md — doesn't exist
  2. WebFetch + WebSearch in parallel — palette, fonts, voice, product images
  3. upload_media for each scraped product image → Kolbo CDN URLs
  4. Write .kolbo/brand-kits/drinkolipop.md with brand identity + re-hosted assets
  5. Ask user: "Type B detected — uploaded brief + named use case (IG campaign).
      How many slides (default 8)? Mood?" Get answers.

Agent (kolbo-creative-director):
  6. generate_creative_director({
       scene_count: 8,
       prompt: "8-scene IG carousel for OliPop peach flavor — Type B brand brief,
                cottagecore aesthetic, brand palette baked in",
       reference_images: [logo_url, product_hero_url],
       workflow_type: "image",
       aspect_ratio: "1:1",
       model: "nano-banana-2"
     })
  7. Returns 8 image URLs → log to .kolbo/production.md

Agent (kolbo-marketplace-cards):
  8. Detect bundle = full-set (main + 5 secondary + 7 A+ modules)
  9. Read .kolbo/brand-kits/drinkolipop.md (palette + fonts ready)
  10. generate_creative_director({
        scene_count: 13,
        prompt: "Amazon listing full-set for OliPop peach...
                 Scene 1: main_image (pure white bg, no text, no props, ...)
                 Scene 2: lifestyle (drinking poolside)
                 Scene 3: detail (can texture macro)
                 ... (per the 13 asset taxonomy)",
        reference_images: [product_hero, logo],
        workflow_type: "image",
        model: "nano-banana-2"
      })
  11. Returns 13 marketplace-ready URLs
```

## 3. URL → DTC ad headline image in one shot

**Skills:** `kolbo-dtc-ads` (which internally does research-first if no brand kit exists)

```
You: "Make me a headline-driven DTC ad image for https://my-startup.com,
      hero word 'FINALLY.' on a marble background."

Agent (kolbo-dtc-ads):
  1. Detect no .kolbo/brand-kits/my-startup.md exists
  2. Run research-first sub-workflow → WebFetch + WebSearch in parallel,
     extract palette + voice + hero images, re-host via upload_media
  3. Write .kolbo/brand-kits/my-startup.md
  4. Ask user (labeled options): "Pick an ad format:
     [Headline-driven / Bullet points / Founder statement]"
     Already mentioned headline → confirmed.
  5. generate_image({
       prompt: "Bold hero word 'FINALLY.' centered on marble surface,
                brand palette #FF4D2E primary + #1A1A1A text,
                Inter Bold typeface, asymmetric composition with
                product (@image1) bottom-right at 30% scale.
                NO captions, NO watermarks, NO extra text.",
       reference_images: [product_hero_url, logo_url],
       model: "gpt-image-2",
       aspect_ratio: "1:1",
       resolution: "2K",
       quality: "high"
     })
  6. Returns ad image URL
```

## 4. Transcribe a long podcast → generate matching Veo cinematic intro

**Skills:** `kolbo-transcription` → `kolbo-generate` (Veo)

```
You: "Here's a 25-minute podcast. Transcribe it, then make me an 8-second
      Veo intro video that captures its vibe."

Agent (kolbo-transcription):
  1. File profile check: 25 min → fits in transcription cap (30 min). Audio-only → use
     transcribe_audio directly (not hybrid path).
  2. transcribe_audio({ source: <path> }) → text + srt_url + word_by_word_srt_url

Agent (kolbo-generate, then defers to Veo via prompt-copilot):
  3. Read transcript text → summarize the vibe (5 keywords)
  4. Detect user wants Veo specifically → load veo prompt rules
  5. generate_video({
       prompt: "Wide slow dolly shot, cinematic 16:9, opens on
                <vibe-summary scene>, warm golden grading,
                A swelling orchestral theme begins to play, no dialogue",
       model: "veo-3.1",
       aspect_ratio: "16:9",
       duration: 8,
       resolution: "1080p",
       sound_enabled: true
     })
  6. Returns video URL + SRT URL from earlier
```

## 5. Build a landing page + publish it + generate a hero image for it

**Skills:** `kolbo-html-artifacts` → `kolbo-generate` → `kolbo-html-artifacts` (re-publish)

```
You: "Build a landing page for my cold-brew startup, then generate
      a hero image and publish the page."

Agent (kolbo-html-artifacts):
  1. Pick aesthetic (labeled options): "Editorial / Bold Modern / Brutalist / ..."
     User picks Bold Modern.
  2. Draft full HTML with placeholder hero image
  3. Return artifact preview

Agent (kolbo-generate):
  4. generate_image({
       prompt: "Cinematic product photograph of cold-brew bottle on
                blackened iron surface, dramatic chiaroscuro lighting,
                editorial fashion magazine style, photorealistic",
       model: "nano-banana-pro",
       aspect_ratio: "3:1",
       resolution: "4K"
     })
  5. Returns hero_url

Agent (kolbo-html-artifacts — re-publish):
  6. Update the HTML — replace placeholder hero with <img src="<hero_url>" />
  7. publish_html_artifact({ title: "Cold Brew Co.", content: <full html> })
  8. Returns sites.kolbo.ai URL
```

## 6. Single product photo → 10-mode photoshoot variants

**Skills:** `kolbo-product-photoshoot`

```
You: "Here's my candle. Give me 1 photo in each of these modes:
      product_shot, lifestyle_scene, moodboard_pin, hero_banner, conceptual_product."

Agent (kolbo-product-photoshoot):
  1. Detect Type B (uploaded photo + named use case)
  2. Skip the interview — modes are explicit
  3. Fire 5 parallel generate_image calls (one per mode), each with the right
     model + aspect ratio per the mode→routing table:
       - product_shot: gpt-image-2, 1:1
       - lifestyle_scene: nano-banana-2, 1:1
       - moodboard_pin: nano-banana-2, 2:3
       - hero_banner: gpt-image-2, 16:9
       - conceptual_product: nano-banana-2, 1:1
  4. Returns 5 URLs, one per mode, each tagged in chat with mode label
```

## 7. Train Visual DNA → fashion virtual try-on across 5 outfits

**Skills:** `kolbo-visual-dna` → `kolbo-creative-director`

```
You: "Train Visual DNA on me from these 12 photos, then show me in 5 different outfits."

Agent (kolbo-visual-dna):
  1. Generate 4-angle sheet + close-up first (mandatory)
  2. create_visual_dna({ name: "user_face", type: "character", images: [12 + 2] })
  3. Returns vdna_id

Agent (kolbo-creative-director):
  4. Detect mode: virtual_model_tryout, multi-variant → use Creative Director
  5. generate_creative_director({
       scene_count: 5,
       prompt: "5 outfit variants of @user_face, full-body shots,
                Scene 1: casual streetwear
                Scene 2: business formal
                Scene 3: athletic wear
                Scene 4: evening wear
                Scene 5: beachwear,
                consistent face/body across all scenes, neutral studio backdrop",
       visual_dna_ids: ["<vdna_id>"],
       workflow_type: "image",
       aspect_ratio: "9:16",
       model: "nano-banana-pro"
     })
  6. Returns 5 URLs (one per outfit, same face/body)
```

## 8. Full React waitlist app + Visual DNA founder portrait

**Skills:** `kolbo-app-builder` → `kolbo-generate` → `kolbo-app-builder` (re-edit)

```
You: "Build me a waitlist app for my SaaS, then add a founder portrait section
      with my Visual DNA."

Agent (kolbo-app-builder):
  1. app_builder_list_projects → app_builder_create_session → app_builder_generate_app({
       prompt: "Waitlist page for <SaaS> — hero, value prop, email capture, footer"
     })
  2. Returns deployment_url

Agent (kolbo-generate):
  3. generate_image({
       prompt: "Founder portrait of @founder, professional editorial, warm lighting",
       visual_dna_ids: ["<founder_vdna_id>"],
       aspect_ratio: "1:1",
       resolution: "2K",
       model: "nano-banana-pro"
     })
  4. Returns founder_image_url

Agent (kolbo-app-builder):
  5. app_builder_list_generations → app_builder_edit_app({
       generation_id: <latest>,
       instruction: "Add a 'Meet the founder' section with portrait at <founder_image_url>
                     and a short bio under it"
     })
  6. Returns updated deployment_url
```

---

These recipes show the IDEAL chain. In practice, the agent should ask **one labeled-option question per skill** when defaults aren't clear (mode, aspect ratio, quantity) rather than batch-asking everything upfront.
