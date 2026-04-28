# Stage 1: Build frontend
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Stage 2: Production
FROM python:3.12-slim

# Install uv directly from official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Create user with UID 12574 (Domino standard)
RUN useradd -m -u 12574 domino

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies into /app/.venv
# Use --frozen to ensure exact versions from uv.lock
RUN uv sync --no-dev --frozen

# Copy application code
COPY agent/ ./agent/
COPY backend/ ./backend/
COPY configs/ ./configs/

# Copy Domino MCP server
COPY mcp-servers/ ./mcp-servers/

# Pre-install MCP server dependencies so they are cached in the image
RUN cd /app/mcp-servers/domino_mcp_server && uv sync --frozen 2>/dev/null || uv sync

# Copy built frontend
COPY --from=frontend-builder /app/frontend/dist ./static/

# Create directories and set ownership
RUN mkdir -p /app/session_logs && \
    chown -R domino:domino /app

# Switch to non-root user
USER domino

# Set environment
ENV HOME=/home/domino \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    PATH="/app/.venv/bin:$PATH"

# Expose port (Domino apps use 8888 by default)
EXPOSE 8888

# Run the application from backend directory
WORKDIR /app/backend
CMD ["bash", "start.sh"]
