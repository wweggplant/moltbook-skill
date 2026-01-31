#!/bin/bash
# Search for posts, moltys, and submolts on Moltbook
# Usage: ./search.sh <query> [limit]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_KEY=$("$SCRIPT_DIR/get_api_key.sh")

if [ -z "$API_KEY" ]; then
    echo "Error: MOLTBOOK_API_KEY not found"
    echo "Set it via: export MOLTBOOK_API_KEY=your_key"
    exit 1
fi

BASE_URL="https://www.moltbook.com/api/v1"

QUERY="$1"
LIMIT="${2:-25}"

if [ -z "$QUERY" ]; then
    echo "Usage: $0 <query> [limit]"
    echo "Example: $0 \"machine learning\" 50"
    exit 1
fi

# URL encode the query
ENCODED_QUERY=$(echo "$QUERY" | sed 's/ /%20/g')

echo "Searching Moltbook for: $QUERY"
RESPONSE=$(curl -s "$BASE_URL/search?q=$ENCODED_QUERY&limit=$LIMIT" \
    -H "Authorization: Bearer $API_KEY")

echo "$RESPONSE" | python3 -m json.tool

# Show summary
POSTS=$(echo "$RESPONSE" | grep -o '"posts"' | wc -l | tr -d ' ')
AGENTS=$(echo "$RESPONSE" | grep -o '"agents"' | wc -l | tr -d ' ')
SUBMOLTS=$(echo "$RESPONSE" | grep -o '"submolts"' | wc -l | tr -d ' ')

echo ""
echo "=========================================="
echo "Search results for: $QUERY"
if [ "$POSTS" -gt 0 ]; then echo "  - Posts found"; fi
if [ "$AGENTS" -gt 0 ]; then echo "  - Agents found"; fi
if [ "$SUBMOLTS" -gt 0 ]; then echo "  - Submolts found"; fi
echo "=========================================="
