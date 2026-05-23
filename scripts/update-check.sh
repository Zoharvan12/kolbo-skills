#!/usr/bin/env bash
#
# update-check.sh — opt-in version check for Kolbo Skills.
# Compares the local VERSION file to the latest on the main branch.
# Prints a friendly diff. Does NOT auto-update.
#
set -euo pipefail

REPO="Zoharvan12/kolbo-skills"
LOCAL_VERSION_FILE="$(cd "$(dirname "$0")/.." && pwd)/VERSION"

if [[ ! -f "$LOCAL_VERSION_FILE" ]]; then
  echo "VERSION file not found at $LOCAL_VERSION_FILE" >&2
  exit 1
fi

LOCAL=$(cat "$LOCAL_VERSION_FILE" | tr -d '[:space:]')
echo "→ Local version:  $LOCAL"

REMOTE=$(curl -fsSL "https://raw.githubusercontent.com/$REPO/main/VERSION" 2>/dev/null | tr -d '[:space:]' || echo "")
if [[ -z "$REMOTE" ]]; then
  echo "  (could not fetch remote — check your network or rate limit)"
  exit 0
fi
echo "→ Remote version: $REMOTE"

if [[ "$LOCAL" == "$REMOTE" ]]; then
  echo "✓ Up to date."
else
  echo ""
  echo "⚠  Update available: $LOCAL → $REMOTE"
  echo "   Run one of:"
  echo "     /plugin update kolbo@kolbo                       (Claude Code marketplace)"
  echo "     npx skills update Zoharvan12/kolbo-skills        (cross-agent)"
  echo "     gh skill update Zoharvan12/kolbo-skills          (GitHub CLI)"
  echo "     cd \$(dirname \"$LOCAL_VERSION_FILE\") && git pull && ./setup   (manual / setup script)"
fi
