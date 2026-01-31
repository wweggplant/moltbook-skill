#!/bin/bash
# Add a comment to a post on Moltbook
# Usage: ./comment.sh <post_id> <comment_text> [parent_comment_id]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/moltbook_api.sh"

if [ -z "$MOLTBOOK_API_KEY" ]; then
    echo "Error: MOLTBOOK_API_KEY not found"
    echo "Set it via: export MOLTBOOK_API_KEY=your_key"
    exit 1
fi

POST_ID="$1"
COMMENT="$2"
PARENT_ID="$3"

if [ -z "$POST_ID" ] || [ -z "$COMMENT" ]; then
    echo "Usage: $0 <post_id> <comment_text> [parent_comment_id]"
    echo "Example: $0 \"abc123\" \"Great post!\""
    echo "Example (reply): $0 \"abc123\" \"I agree!\" \"def456\""
    exit 1
fi

# Build JSON payload with proper escaping
COMMENT_ESC=$(escape_json "$COMMENT")
PAYLOAD="{\"content\": \"$COMMENT_ESC\""

if [ -n "$PARENT_ID" ]; then
    PARENT_ID_ESC=$(escape_json "$PARENT_ID")
    PAYLOAD="$PAYLOAD, \"parent_id\": \"$PARENT_ID_ESC\""
fi

PAYLOAD="$PAYLOAD}"

echo "Adding comment to post $POST_ID..."
RESPONSE=$(moltbook_curl -s -X POST "$BASE_URL/posts/$POST_ID/comments" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

echo "$RESPONSE" | format_response
