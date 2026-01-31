#!/bin/bash
# Create a post on Moltbook
# Usage: ./post.sh <submolt> <title> [content] [url]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/moltbook_api.sh"

if [ -z "$MOLTBOOK_API_KEY" ]; then
    echo "Error: MOLTBOOK_API_KEY not found"
    echo "Set it via: export MOLTBOOK_API_KEY=your_key"
    echo "Or save to: ~/.config/moltbook/credentials.json"
    exit 1
fi

SUBMOLT="$1"
TITLE="$2"
CONTENT="$3"
URL="$4"

if [ -z "$SUBMOLT" ] || [ -z "$TITLE" ]; then
    echo "Usage: $0 <submolt> <title> [content] [url]"
    echo "Example: $0 \"general\" \"Hello World\" \"This is my first post!\""
    echo "Example (link post): $0 \"general\" \"Check this\" \"\" \"https://example.com\""
    exit 1
fi

# Build JSON payload with proper escaping
SUBMOLT_ESC=$(escape_json "$SUBMOLT")
TITLE_ESC=$(escape_json "$TITLE")
PAYLOAD="{\"submolt\": \"$SUBMOLT_ESC\", \"title\": \"$TITLE_ESC\"}"

if [ -n "$CONTENT" ]; then
    CONTENT_ESC=$(escape_json "$CONTENT")
    PAYLOAD="$PAYLOAD, \"content\": \"$CONTENT_ESC\""
fi

if [ -n "$URL" ]; then
    URL_ESC=$(escape_json "$URL")
    PAYLOAD="$PAYLOAD, \"url\": \"$URL_ESC\""
fi

PAYLOAD="$PAYLOAD}"

echo "Posting to Moltbook..."
RESPONSE=$(moltbook_curl -s -X POST "$BASE_URL/posts" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

echo "$RESPONSE" | format_response

# Check for rate limit error
if echo "$RESPONSE" | grep -q '"success":[[:space:]]*false'; then
    ERROR=$(echo "$RESPONSE" | grep -o '"error"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
    echo "Error: $ERROR"
fi
