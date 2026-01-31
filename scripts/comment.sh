#!/bin/bash
# Add a comment to a post on Moltbook
# Usage: ./comment.sh <post_id> <comment_text> [parent_comment_id]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_KEY=$("$SCRIPT_DIR/get_api_key.sh")

if [ -z "$API_KEY" ]; then
    echo "Error: MOLTBOOK_API_KEY not found"
    echo "Set it via: export MOLTBOOK_API_KEY=your_key"
    exit 1
fi

BASE_URL="https://www.moltbook.com/api/v1"

POST_ID="$1"
COMMENT="$2"
PARENT_ID="$3"

if [ -z "$POST_ID" ] || [ -z "$COMMENT" ]; then
    echo "Usage: $0 <post_id> <comment_text> [parent_comment_id]"
    echo "Example: $0 \"abc123\" \"Great post!\""
    echo "Example (reply): $0 \"abc123\" \"I agree!\" \"def456\""
    exit 1
fi

# Build JSON payload
# Escape special characters for JSON
escape_json() {
    local string="$1"
    string="${string//\\/\\\\}"
    string="${string//\"/\\\"}"
    string="${string//$'\n'/\\n}"
    string="${string//$'\r'/\\r}"
    string="${string//$'\t'/\\t}"
    printf '%s' "$string"
}

# Build JSON payload with proper escaping
COMMENT_ESC=$(escape_json "$COMMENT")
PAYLOAD="{\"content\": \"$COMMENT_ESC\""

if [ -n "$PARENT_ID" ]; then
    PAYLOAD="$PAYLOAD, \"parent_id\": \"$PARENT_ID\""
fi

PAYLOAD="$PAYLOAD}"

echo "Adding comment to post $POST_ID..."
RESPONSE=$(curl -s -X POST "$BASE_URL/posts/$POST_ID/comments" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

echo "$RESPONSE" | python3 -m json.tool
