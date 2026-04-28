#!/bin/bash
# Domino App entry point
# This script is executed by Domino when the app starts

set -e

# Map Domino env vars to what the app expects
export HF_TOKEN="${HF_TOKEN:-${HF_WRITE_TOKEN:-}}"

# Ensure ANTHROPIC_API_KEY is available (should be set as Domino env var)
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "WARNING: ANTHROPIC_API_KEY is not set. The agent will not work without it."
fi

# Set default port for Domino
export PORT="${PORT:-8888}"

cd /app/backend
exec bash start.sh
