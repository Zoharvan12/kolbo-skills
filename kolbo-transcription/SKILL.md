---
version: 0.4.0
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

# Kolbo Transcription & Audio/Video Analysis

Three routes, pick by file profile.

## Step 0 — Bootstrap

1. Run `check_credits` once per conversation. If it fails, ask the user to run `kolbo auth login`.
2. Transcription bills per minute of audio (`model.credit × duration_minutes`). For a 30-min file with a standard model, that's ~6–15 credits. Run `check_credits` before transcribing very long files (>20 min).

## MCP Tools

| Tool | Purpose |
|---|---|
| `transcribe_audio` | Transcribe audio or video → text + SRT + word-by-word SRT. URL or local path. **30-min hard cap.** |
| `upload_media` | Upload a local file (or remote URL re-host) → returns stable Kolbo CDN URL |
| `chat_send_message` | Send media URLs to a chat model (Smart Select auto-routes to Gemini vision when media is detected) |

## Decision Tree

```
Image (jpg/png/webp)?                         → Read directly (native vision, up to 10 per pass)
File >100MB OR >15 min OR dialogue-dense?     → HYBRID (transcribe + ffmpeg frames + Read + your synthesis)
User wants the transcript/SRT as deliverable? → transcribe_audio, return the URLs
Precise answer about one specific frame?      → ffmpeg that frame → Read
Otherwise (short/medium video, mixed content) → upload_media → chat_send_message (Gemini native)
```

## Why `upload_media` → chat is NOT always the default

Gemini-via-chat processes frames + motion + audio in one pass and is the simplest route when it works. But it has three known failure surfaces — recognize them and pivot to the hybrid path:

1. **>100MB upload cap.** Hard limit; the upload won't succeed. Split with ffmpeg or go hybrid.
2. **Long-form decay** (rough threshold: 15–20 min). Even when it fits, attention degrades — shallow or hallucinated answers on the back half of the file.
3. **Transcription-dense laziness.** Lectures, interviews, podcasts, anything where speech is the substance: chat models summarize aggressively, paraphrase quotes wrong, or silently skip stretches. Always transcribe these first to get the actual words, then add visuals only if they matter.

## The Hybrid Path

```
1. transcribe_audio({ source }) → text, srt_url, word_by_word_srt_url, duration
2. Read the transcript text from the tool output directly
3. Pick 3–8 timestamps from the SRT where visuals actually matter
4. ffmpeg -ss <ts> -i <file> -frames:v 1 <frame.jpg>   (one extract per timestamp)
5. Read each frame with native vision (up to ~10 frames per analysis pass)
6. Synthesize from transcript + frames + the user's question
```

Usually **cheaper** than chat for long files — transcription is per-minute, ffmpeg + Read are free — and produces stronger answers on dialogue-heavy material because you have the complete text, not a model's summary of it.

For media >30 min (past the transcription cap), split with ffmpeg into ~25-min chunks, transcribe each, concatenate.

## Transcribe-as-Deliverable vs Transcribe-as-Input

| Request pattern | Action |
|---|---|
| "Transcribe this" / "give me an SRT" / "I need word-by-word timing" / "make subtitles" | Run `transcribe_audio`, return the URL(s). The transcript IS the deliverable. |
| "What did they say about X?" / "Summarize this meeting" / "Find the part where they mention Y" | Run `transcribe_audio` to *get* the text → **you** read/summarize/search. Transcript is a means, not the answer. |

## `transcribe_audio` — Tool Details

- `source`: URL or absolute local path.
- **Audio**: mp3, wav, m4a, flac, aac. **Video** (audio track extracted): mp4, mov, webm, mkv, avi, m4v.
- **30-minute hard cap.** Longer → split with ffmpeg first.
- Returns:
  - `text` — full transcript, plain.
  - `srt_url` — grouped SRT (~12 words per line, up to 2 lines per subtitle). Use this for normal subtitle delivery.
  - `word_by_word_srt_url` — one word per cue with millisecond-precise start/end (ElevenLabs Scribe v2). Use **only** when downstream is animation (Remotion captions, after-effects karaoke, precise speech-aligned cuts). Noise for normal subtitle workflows.
  - `txt_url` — plain text file.
  - `duration` — seconds.
- Cost: per-minute (`model.credit × duration_minutes`).
- Read-only / discovery — does NOT trigger production-log nudges. If the user wants the transcript saved as a durable artifact, `Write` it to a workspace file.

## `upload_media` → `chat_send_message` — Tool Details

- `upload_media({ source: "/absolute/local/path/file.mp4" })` → returns `{ url, thumbnail_url, ... }`. **Use `url`** (the CDN URL); ignore `thumbnail_url` (preview JPG only).
- `chat_send_message({ message, media_urls: [url] })`:
  - `media_urls` is **mandatory** — the model only sees the file if you pass the CDN URL. Always an array.
  - **Omit `model`** — Smart Select auto-routes to Gemini when media is detected.
  - Sessions do NOT remember media between messages. On retry: reuse the same CDN URL, always pass `media_urls` again.

## ⚠️ Batching Media in Chat (CRITICAL)

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

## Image Analysis — Never via Chat

You have native vision. **Always `Read` images directly** (up to 10 per pass). Do not `upload_media` + chat for images unless the user explicitly names a specific Kolbo chat model. Don't extract frames from images — they're already viewable.

**NEVER ask the user which path to use — diagnose from the file profile and pick.**

## UX Rules

1. Be concise. For deliverable transcripts, present the SRT URL as a clickable markdown link + a 1-line summary (duration + cost).
2. For analysis requests, deliver the answer in prose — don't dump the raw transcript unless asked.
3. Detect language — transcribe in source language; translate downstream if requested.
4. No auto-retry on transient failures — surface the reason, suggest a fix.
