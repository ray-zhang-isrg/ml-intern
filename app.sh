#!/bin/bash
# Domino App entry point
# This script is executed by Domino when the app starts

set -e

# Map Domino env vars to what the app expects
export HF_TOKEN="${HF_TOKEN:-${HF_WRITE_TOKEN:-}}"

# Verify critical environment variables
echo "=== Domino AI Assistant - Environment Check ==="
[ -n "$ANTHROPIC_API_KEY" ] && echo "  ANTHROPIC_API_KEY: set" || echo "  WARNING: ANTHROPIC_API_KEY is not set. The agent will not work without it."
[ -n "$DOMINO_API_KEY" ]    && echo "  DOMINO_API_KEY:    set" || echo "  INFO:    DOMINO_API_KEY not set (OK if running inside Domino workspace/app)."
[ -n "$GITHUB_TOKEN" ]      && echo "  GITHUB_TOKEN:      set" || echo "  INFO:    GITHUB_TOKEN not set (GitHub tools will be unavailable)."
[ -n "$HF_TOKEN" ]          && echo "  HF_TOKEN:          set" || echo "  INFO:    HF_TOKEN not set (HF tools will be unavailable)."
echo "=== Starting server ==="

# Set default port for Domino
export PORT="${PORT:-8888}"

cd /app/backend
exec bash start.sh
