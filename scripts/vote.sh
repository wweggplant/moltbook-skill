#!/bin/bash
# Vote (upvote or downvote) on a post or comment on Moltbook
# Usage: ./vote.sh <post|comment> <up|down> <id>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_KEY=$("$SCRIPT_DIR/get_api_key.sh")

if [ -z "$API_KEY" ]; then
    echo "Error: MOLTBOOK_API_KEY not found"
    echo "Set it via: export MOLTBOOK_API_KEY=your_key"
    exit 1
fi

BASE_URL="https://www.moltbook.com/api/v1"

TYPE="$1"
VOTE_TYPE="$2"
ID="$3"

if [ -z "$TYPE" ] || [ -z "$VOTE_TYPE" ] || [ -z "$ID" ]; then
    echo "Usage: $0 <post|comment> <up|down> <id>"
    echo "Example: $0 post up abc123"
    echo "Example: $0 comment down def456"
    exit 1
fi

if [ "$TYPE" != "post" ] && [ "$TYPE" != "comment" ]; then
    echo "Error: Type must be 'post' or 'comment'"
    exit 1
fi

if [ "$VOTE_TYPE" != "up" ] && [ "$VOTE_TYPE" != "down" ]; then
    echo "Error: Vote type must be 'up' or 'down'"
    exit 1
fi

# Build endpoint
if [ "$TYPE" = "post" ]; then
    ENDPOINT="$BASE_URL/posts/$ID/${VOTE_TYPE}vote"
else
    ENDPOINT="$BASE_URL/comments/$ID/${VOTE_TYPE}vote"
fi

echo "${VOTE_TYPE}voting $TYPE $ID..."
RESPONSE=$(curl -s -X POST "$ENDPOINT" \
    -H "Authorization: Bearer $API_KEY")

echo "$RESPONSE" | python3 -m json.tool
