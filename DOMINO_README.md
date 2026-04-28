# Domino AI Assistant (ml-intern for Domino)

An ML engineering assistant adapted from [ml-intern](https://github.com/huggingface/ml-intern) to run on [Domino Data Lab](https://intuitive.domino.tech).

## What It Does

- Chat-based AI assistant powered by Claude Sonnet 4.5
- 10 Domino MCP tools: run jobs, check status, sync files, browse projects, get environment info
- Deep knowledge of Domino platform: jobs, workspaces, environments, datasets, experiment tracking, model endpoints, GenAI tracing
- Web UI served on port 8888

## Required Environment Variables

| Variable | Description |
|---|---|
| `ANTHROPIC_API_KEY` | Anthropic API key for Claude |
| `DOMINO_API_KEY` | Domino API key (for MCP server operations) |
| `HF_WRITE_TOKEN` | *(Optional)* Hugging Face token, auto-mapped to `HF_TOKEN` |

`DOMINO_HOST` defaults to `https://intuitive.domino.tech` — no need to set it.

## Local Testing

```bash
# 1. Install backend deps
uv sync --no-dev

# 2. Install MCP server deps
cd mcp-servers/domino_mcp_server && uv sync && cd ../..

# 3. Build frontend
cd frontend && npm ci && npm run build && cd ..
cp -r frontend/dist static

# 4. Set env vars
export ANTHROPIC_API_KEY="your-key"
export DOMINO_API_KEY="your-key"
export MCP_SERVER_DIR=$(pwd)/mcp-servers/domino_mcp_server
export PYTHONPATH=$(pwd)

# 5. Start server
cd backend
../.venv/bin/python -m uvicorn main:app --host 0.0.0.0 --port 8890
```

Open http://localhost:8890.

## Deploy as Domino App

1. Set `ANTHROPIC_API_KEY` and `DOMINO_API_KEY` as project environment variables
2. Publish as a Domino App with **`app.sh`** as the launch script
3. The app serves on port **8888**

### Using Docker (alternative)

The included `Dockerfile` builds a self-contained image:
- Domino user UID 12574
- Frontend built at build time
- MCP server deps pre-installed
- Exposes port 8888

## Project Structure (key Domino additions)

```
app.sh                          # Domino app entry point
agent/prompts/system_prompt_domino.yaml  # Domino-aware system prompt
mcp-servers/domino_mcp_server/  # Domino MCP server (job runs, file sync, etc.)
configs/frontend_agent_config.json       # Config with Domino MCP + Claude model
```
