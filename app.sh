#!/bin/bash
# Domino App entry point
# Works in both Docker (/app) and non-Docker (/mnt/code) deployments

set -e

# Detect project root: Docker image uses /app, Domino workspace/app uses /mnt/code
if [ -d "/app/backend" ]; then
    PROJECT_ROOT="/app"
else
    PROJECT_ROOT="${DOMINO_WORKING_DIR:-/mnt/code}"
fi

# Map Domino env vars to what the app expects
export HF_TOKEN="${HF_TOKEN:-${HF_WRITE_TOKEN:-}}"
export PYTHONPATH="$PROJECT_ROOT"
export MCP_SERVER_DIR="${MCP_SERVER_DIR:-$PROJECT_ROOT/mcp-servers/domino_mcp_server}"

# Verify critical environment variables
echo "=== Domino AI Assistant - Environment Check ==="
echo "  PROJECT_ROOT:      $PROJECT_ROOT"
[ -n "$ANTHROPIC_API_KEY" ] && echo "  ANTHROPIC_API_KEY: set" || echo "  WARNING: ANTHROPIC_API_KEY is not set. The agent will not work without it."
[ -n "$DOMINO_API_KEY" ]    && echo "  DOMINO_API_KEY:    set" || echo "  INFO:    DOMINO_API_KEY not set (OK if running inside Domino workspace/app)."
[ -n "$GITHUB_TOKEN" ]      && echo "  GITHUB_TOKEN:      set" || echo "  INFO:    GITHUB_TOKEN not set (GitHub tools will be unavailable)."
[ -n "$HF_TOKEN" ]          && echo "  HF_TOKEN:          set" || echo "  INFO:    HF_TOKEN not set (HF tools will be unavailable)."

# Install dependencies if not already present (non-Docker deployments)
if [ ! -d "$PROJECT_ROOT/.venv" ]; then
    echo "=== Installing backend dependencies ==="
    cd "$PROJECT_ROOT"
    pip install uv 2>/dev/null || true
    uv sync --no-dev 2>&1 | tail -3
fi

# Install MCP server dependencies if needed
if [ ! -d "$MCP_SERVER_DIR/.venv" ]; then
    echo "=== Installing MCP server dependencies ==="
    cd "$MCP_SERVER_DIR"
    uv sync 2>&1 | tail -3
fi

# Build frontend if static dir doesn't exist
if [ ! -d "$PROJECT_ROOT/static" ]; then
    echo "=== Building frontend ==="
    cd "$PROJECT_ROOT/frontend"
    npm ci 2>&1 | tail -3
    npm run build 2>&1 | tail -3
    cp -r dist "$PROJECT_ROOT/static"
fi

echo "=== Starting server on port ${PORT:-8888} ==="
export PORT="${PORT:-8888}"

cd "$PROJECT_ROOT/backend"
exec bash start.sh
