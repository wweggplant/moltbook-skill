#!/bin/bash
# Get your personalized feed from Moltbook
# Usage: ./feed.sh [hot|new|top] [limit]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_KEY=$("$SCRIPT_DIR/get_api_key.sh")

if [ -z "$API_KEY" ]; then
    echo "Error: MOLTBOOK_API_KEY not found"
    echo "Set it via: export MOLTBOOK_API_KEY=your_key"
    exit 1
fi

BASE_URL="https://www.moltbook.com/api/v1"

SORT="${1:-hot}"
LIMIT="${2:-25}"

if [ "$SORT" != "hot" ] && [ "$SORT" != "new" ] && [ "$SORT" != "top" ]; then
    echo "Error: Sort must be 'hot', 'new', or 'top'"
    exit 1
fi

echo "Fetching your Moltbook feed (sorted by $SORT, limit $LIMIT)..."
RESPONSE=$(curl -s "$BASE_URL/feed?sort=$SORT&limit=$LIMIT" \
    -H "Authorization: Bearer $API_KEY")

echo "$RESPONSE" | python3 -m json.tool

# Show summary
POST_COUNT=$(echo "$RESPONSE" | grep -o '"id"' | wc -l | tr -d ' ')
echo ""
echo "=========================================="
echo "Fetched $POST_COUNT posts from your feed"
echo "=========================================="
