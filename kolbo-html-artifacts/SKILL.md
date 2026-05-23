---
version: 0.4.0
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

# Kolbo HTML Artifacts

Three sub-modes: **presentation** (slide decks), **landing-page** (marketing sites), **visual-code** (dashboards / widgets / charts / games). Different rules per sub-mode — load the matching `references/` file.

## Step 0 — Bootstrap

1. Run `check_credits` only if you'll also call generation tools (for hero images). HTML artifact authoring is free; `publish_html_artifact` is free.
2. If `publish_html_artifact` fails with "Session expired" / "Not authenticated", ask the user to run `kolbo auth login`.

## Sub-Mode Routing

| User asked for | Read |
|---|---|
| Presentation / slide deck / pitch deck / מצגת | `references/presentation.md` |
| Landing page / marketing site / one-pager / waitlist page / דף נחיתה | `references/landing-page.md` |
| Dashboard / data viz / chart / interactive widget / mini-game / UI mockup / animated component | `references/visual-code.md` |

## Universal Output Discipline (NON-NEGOTIABLE)

Applies to all three sub-modes:

- Reply MUST contain **exactly ONE** ` ```html ... ``` ` fenced code block with a COMPLETE, self-contained HTML document.
- Document MUST start with `<!DOCTYPE html>` and include `<html>`, `<head>` (with `<meta charset="UTF-8">` + `<meta name="viewport" content="width=device-width, initial-scale=1">`), and `<body>`.
- Embed ALL CSS inside `<style>` and ALL JavaScript inside `<script>`. No external CSS files, no relative asset paths. CDN URLs are fine.
- **Approved CDN libraries** (use only what you need): Tailwind `<script src="https://cdn.tailwindcss.com"></script>`, GSAP, Chart.js, D3.js, Three.js, Lucide Icons, Framer Motion, React 18 + Babel standalone, Vue 3, date-fns.
- Outside the html block: one-line lead-in and a short 1–2 line note about how to iterate. Nothing else.
- If the user wrote in a non-English language, write your lead-in / closing note in their language. Inside the HTML, match the in-page copy to the user's language and set the appropriate `lang` + `dir` attributes (`lang="he" dir="rtl"`, `lang="ar" dir="rtl"`, `lang="ja" dir="ltr"`, etc.). For RTL languages, also use Tailwind's logical properties (`me-*`, `ms-*`, `text-start`, `text-end`) or `flex-row-reverse` where needed.

## Anti-AI-Slop Mandates (universal)

- ❌ NEVER use `Inter`, `Roboto`, `Arial`, `-apple-system`, or any default system font. Pull from Google Fonts or Fontshare.
- ❌ NEVER ship the "purple-to-violet gradient on white background" look. It's the #1 LLM tell.
- ❌ NEVER default to `'Space Grotesk'` everywhere — tired LLM cliché. Use occasionally for genuinely fitting briefs.
- ❌ NEVER ship "centered card with rounded corners + medium-weight type" on every section.
- ❌ NEVER use placeholder lorem ipsum unless explicitly asked. Invent plausible specific copy.

## Media Integration

If the conversation contains generated Kolbo media URLs (images, videos, audio from previous turns), USE the actual URLs inside `<img>` / `<video>` / `<audio>` tags. Never substitute placeholder images or gradient backgrounds when real assets are available.

## Publishing

After approval, call `publish_html_artifact({ title, content })` to get a `sites.kolbo.ai` URL. Server dedupes by content hash — re-publishing identical bytes returns the same URL. The page is served with strict CSP (`connect-src 'none'`, `form-action 'none'`) — it can't exfiltrate data, but CDN libraries still load. For Claude Code users, the chat artifact preview reads the html block automatically — they can also click **Share** in the preview toolbar.

## UX Rules

1. **Pick the sub-mode first** (presentation / landing / widget) — load only the matching reference file.
2. **Commit to a clear aesthetic** before writing CSS — see sub-mode reference for the catalog of recommended directions.
3. **One labeled-option question max** before generating, if the brief is vague.
4. **Use real content** — invent plausible specifics, never "Lorem ipsum".
5. **Test mentally** before delivering — verify `addEventListener` matches `querySelector`, no broken JS, mobile-responsive (or explicitly desktop-only with a heads-up).
