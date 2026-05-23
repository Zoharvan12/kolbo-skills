---
version: 0.4.0
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

# Kolbo Music

Suno-led music generation. Two-field prompt (Style + Lyrics).

## Step 0 — Bootstrap

1. Run `check_credits` once per conversation. If it fails, ask the user to run `kolbo auth login`.
2. Music generations cost 15–60 credits flat (Suno v5 = 15 cr; ElevenLabs Music = 60 cr) — no per-second billing.

## MCP Tool

`generate_music` — call `list_models({ type: "music_gen" })` to see variants. Pass `style` and `lyrics` as separate params; pass `instrumental: true/false`, `vocal_gender`, `duration` per the model's schema.

## How Music Prompting Actually Works

Suno responds to **descriptive, layered prompts**, not vague ones:
- ❌ "make a pop song"
- ⚠️ "upbeat dance-pop, female vocals, glossy production, catchy chorus, summer vibe"
- ✅ "Dance-pop track, bright analog synths, female lead vocal with airy harmonies, catchy four-on-the-floor hook, 120 BPM, summer road-trip energy"

**Formula:** Genre + Mood + Instrumentation + Vocal style + Tempo/BPM + Scene/era anchor.

## The Style / Description Field (`style` param)

Pack into one comma-separated descriptor line (no labels, no quotes around the whole thing):
- **Genre / sub-genre** — `synthwave`, `neo-soul`, `bedroom indie pop`, `drill`, `baroque trap`, `cinematic orchestral trailer`
- **Mood** — `melancholic`, `euphoric`, `tense`, `hopeful`, `hypnotic`, `nostalgic`
- **Instrumentation** — `bright analog synths`, `fingerpicked nylon guitar`, `808 sub bass`, `brushed snare`, `Rhodes electric piano`, `strings + harpsichord`, `muted brass section`
- **Vocal style** — `female lead with airy harmonies`, `whispered male falsetto`, `autotuned melodic rap`, `gospel choir backing`, `spoken-word female narrator`, `no vocals` (for instrumental)
- **Tempo / BPM** — `120 BPM`, `slow tempo 70 BPM`, `uptempo 140 BPM`
- **Era / production cue** — `80s analog warmth`, `modern polished pop production`, `lo-fi cassette tape feel`, `live-room reverb`, `bedroom production`
- **Scene anchor (optional, powerful)** — `late night highway drive`, `80s prom night`, `rainy city rooftop`, `Tokyo bullet train`

**Style cap:** keep this field to roughly **8–15 descriptors**. More starts to muddy the output.

## The Lyrics Field (`lyrics` param)

Use Suno's section tags to control structure. Each tag goes on its own line:
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

**Emphasis**: ALL CAPS amplifies intensity on that word or line. Use sparingly.

**Structure templates:**
- Pop / radio: Intro → Verse → Chorus → Verse → Chorus → Bridge → Chorus → Outro
- Hip-hop: Intro → Verse → Hook → Verse → Hook → Bridge → Hook → Outro
- Cinematic / score: Intro (build) → Theme A → Theme B → Climax → Resolution
- Lo-fi / chill: Intro → Loop A → Loop B → Loop A → Outro (often no vocals)

## Power Moves

- **Mix unexpected genres** — `country + EDM`, `folk + ambient synths`, `classical + trap drums`, `baroque + 808s`. Best outputs often come from contrast.
- **Scene-based language beats sound-only language** — `late-night highway drive` does more work than `atmospheric`.
- **Tags shape structure better than prose** — don't write "then there's a chorus", write `[Chorus]`.
- **No real artist names** — Suno blocks them. Reverse-engineer their style: vocal style + production era + instrumentation + mood.
- **Lean into imperfection** — Suno's quirks often produce the best moments. Don't over-correct.
- **Generate multiple times** — same prompt produces wildly different songs. Tell the user to run 2–4 takes in parallel.

## Workflow by Use Case

### Full song with vocals
- `style`: full descriptor stack
- `lyrics`: tagged structure with lyric content
- Recommend 2–3 parallel generations to compare

### Instrumental / score / lo-fi beat
- `style`: descriptor stack + `instrumental`, `no vocals`
- `lyrics`: structure tags only (`[Intro]`, `[Theme A]`, `[Build]`, `[Drop]`), no lyric lines, OR leave empty and pass `instrumental: true`

### Jingle / ad music (15–30s)
- `style`: short, punchy descriptor (`upbeat retail pop jingle, female vocal, claps, glossy production, summer energy`)
- `lyrics`: 2–4 short lines max, often just chorus
- Pass the shortest `duration` the model supports

### Cinematic trailer / score
- `style`: `cinematic orchestral trailer, swelling strings, taiko drums, hybrid choir, dramatic build, modern hybrid score`
- `lyrics`: structure tags only — `[Intro]` `[Build]` `[Drop]` `[Climax]` `[Resolution]`
- `instrumental: true`

## Output Discipline

Output the prompt as **two fenced code blocks**, clearly labeled (these map to `style` and `lyrics` MCP params):

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

After firing the tool, share the resulting audio URL. When summarizing in chat, state:
- **Instrumental:** yes / no
- **Recommended duration:** short / medium / long
- **Run takes:** N parallel generations (usually 2–4) and pick the best
- **Why this works:** 1 line on the key genre / structure / instrumentation choice

If the user is in any language other than English, explanations in their language; lyric language matches what the user wants (any language works in Suno).

## Run It

```
generate_music({
  style: "Dance-pop, bright analog synths, female lead with airy harmonies, 120 BPM, summer road-trip energy",
  lyrics: "[Intro]\n...\n[Verse]\n...\n[Chorus]\n...",
  instrumental: false,
  duration: 60
})
```

After it returns, log the URL + cost (`credits_used` from the response) to `.kolbo/production.md` under `### Tracks`.
