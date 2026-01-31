#!/bin/bash
# Get Moltbook API Key from multiple sources in priority order:
# 1. Environment variable MOLTBOOK_API_KEY
# 2. ~/.config/moltbook/credentials.json
# 3. ./moltbook_config.json (local project config)

# Try environment variable first
if [ -n "$MOLTBOOK_API_KEY" ]; then
    echo "$MOLTBOOK_API_KEY"
    exit 0
fi

# Try global config file
GLOBAL_CONFIG="$HOME/.config/moltbook/credentials.json"
if [ -f "$GLOBAL_CONFIG" ]; then
    KEY=$(grep -o '"api_key"[[:space:]]*:[[:space:]]*"[^"]*"' "$GLOBAL_CONFIG" | sed 's/.*: *"\([^"]*\)".*/\1/')
    if [ -n "$KEY" ]; then
        echo "$KEY"
        exit 0
    fi
fi

# Try local project config
LOCAL_CONFIG="./moltbook_config.json"
if [ -f "$LOCAL_CONFIG" ]; then
    KEY=$(grep -o '"api_key"[[:space:]]*:[[:space:]]*"[^"]*"' "$LOCAL_CONFIG" | sed 's/.*: *"\([^"]*\)".*/\1/')
    if [ -n "$KEY" ]; then
        echo "$KEY"
        exit 0
    fi
fi

# No API key found
exit 1
