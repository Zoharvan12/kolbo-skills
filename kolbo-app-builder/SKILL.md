---
version: 0.4.0
name: kolbo-app-builder
description: |
  Generate and iterate on full React apps via Kolbo's App Builder. The backend
  auto-provisions a GitHub repo, Supabase database (when the app needs storage),
  and a live hosted deployment in one flow.

  Use when: "build me a todo app", "make me a SaaS landing page with waitlist",
  "make me a dashboard", "scaffold a React app", "create a fullstack app",
  "give me a working web app", "build me a [X] app", "add dark mode to my app",
  "add a contact form", "edit my app".

  Chain: returns deployment_url + github_repo_url + supabase_url. Can be
  paired with kolbo-generate (generate hero images / brand assets) and
  kolbo-html-artifacts (publish a marketing page for the app).

  NOT for: static HTML pages (use kolbo-html-artifacts), motion graphics or
  video assets, non-React frameworks (Vue / Svelte / Solid — App Builder is
  React-only today).
argument-hint: "[prompt] [--session <id>] [--edit-instruction <text>]"
allowed-tools: Bash, Read, Write, Edit
---

# Kolbo App Builder

Full React app generation with GitHub repo + Supabase + live deployment in one flow.

## Step 0 — Bootstrap

1. Run `check_credits` once per conversation. If it fails, ask the user to run `kolbo auth login`.
2. App Builder usually requires a Basic+ plan. If `check_credits` shows free plan and the user requests app generation, surface that before submitting.

## Standard Workflow

1. **Find project ID** — `app_builder_list_projects` → pick the right project (ask the user if multiple).
2. **Create session** — `app_builder_create_session({ project_id })` → returns `session_id`.
3. **Generate app** — `app_builder_generate_app({ session_id, prompt: "<user's brief>" })`:
   - Fires the build in the background, polls until `build_status === "deployed"` (up to 5 min).
   - Always surface the `deployment_url` to the user: **"Your app is live at: [<deployment_url>](<deployment_url>)"**.
4. **Iterate** — `app_builder_list_generations({ session_id })` → get the latest `generation_id` → `app_builder_edit_app({ generation_id, instruction: "<natural-language edit>" })`.

No manual polling needed — `generate_app` and `edit_app` block until the build completes.

## MCP Tools

| Tool | Purpose |
|---|---|
| `app_builder_list_projects` | List Kolbo projects (to find a `project_id`) |
| `app_builder_create_session` | Create a new App Builder session inside a project |
| `app_builder_generate_app` | Generate a fresh app from a text prompt — fires build, polls, returns live URL |
| `app_builder_edit_app` | Edit an existing app with a natural-language instruction |
| `app_builder_list_sessions` | List all sessions in a project |
| `app_builder_list_generations` | List all generations in a session (needed for `edit_app`) |
| `app_builder_get_session` | Get full session details incl. GitHub repo URL + Supabase credentials |
| `app_builder_get_build_status` | Manually poll build status (fallback after `generate_app` timeout) |
| `app_builder_delete_session` | Permanently delete a session + GitHub repo + Supabase DB + history. IRREVERSIBLE. |

## Local Dev Workflow

If the user wants to run the app locally or connect to the database directly:

```bash
# 1. Get the GitHub + Supabase details
app_builder_get_session({ session_id }) → returns:
  github_repo_url   →  git clone <url> && npm install && npm run dev
  supabase_url      →  paste into .env as NEXT_PUBLIC_SUPABASE_URL
  supabase_anon_key →  paste into .env as NEXT_PUBLIC_SUPABASE_ANON_KEY
```

Surface these as a clean code block the user can copy.

## Routing — User Says → Call

| User says | Sequence |
|---|---|
| "Build me a todo app" / "Make a landing page with waitlist" / "Create a dashboard" | `app_builder_list_projects` → `app_builder_create_session` → `app_builder_generate_app` → show `deployment_url` |
| "Add dark mode to my app" / "Add a contact form" / "Make the hero bigger" | `app_builder_list_generations` → `app_builder_edit_app` |
| "Give me the GitHub repo" / "Supabase credentials" | `app_builder_get_session` → return `github_repo_url` + `supabase_url` + `supabase_anon_key` |
| "Show me my apps" / "list sessions" | `app_builder_list_sessions` |
| "Delete this app" / "wipe everything" | **CONFIRM with user** → `app_builder_delete_session` (irreversible) |
| Build seems stuck / timed out | `app_builder_get_build_status({ session_id })` to manually check |

## ⚠️ Rules

- **Always confirm before `app_builder_delete_session`** — permanently deletes the GitHub repo, Supabase DB (unless the user wired their own), all deployed files, and history. IRREVERSIBLE.
- **On build timeout** (rare — builds usually complete in 1–5 min): use `app_builder_get_build_status` to check manually, then continue or report.
- **Whitelabel users**: the MCP client routes App Builder calls through whitelabel API endpoints automatically — no extra config needed.
- **Pair with generation tools**: when the user wants brand assets (hero image, founder portrait, logo) for the app, fire the relevant `kolbo-generate` / `kolbo-visual-dna` calls in parallel, then `edit_app` with the image URLs baked in.

## UX Rules

1. Be concise. The `deployment_url` is the headline — put it on its own line as a clickable markdown link.
2. Skip the project-picker question if there's only one project — auto-pick.
3. After delivery, suggest the next iteration: "Want to add [feature]? I can edit the app with `app_builder_edit_app`."
4. Polling is silent — don't narrate "checking build status".
