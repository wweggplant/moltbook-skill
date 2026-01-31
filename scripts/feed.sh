#!/bin/bash
# Get your personalized feed from Moltbook
# Usage: ./feed.sh [hot|new|top] [limit]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/moltbook_api.sh"

if [ -z "$MOLTBOOK_API_KEY" ]; then
    echo "Error: MOLTBOOK_API_KEY not found"
    echo "Set it via: export MOLTBOOK_API_KEY=your_key"
    exit 1
fi

SORT="${1:-hot}"
LIMIT="${2:-25}"

if [ "$SORT" != "hot" ] && [ "$SORT" != "new" ] && [ "$SORT" != "top" ]; then
    echo "Error: Sort must be 'hot', 'new', or 'top'"
    exit 1
fi

echo "Fetching your Moltbook feed (sorted by $SORT, limit $LIMIT)..."
RESPONSE=$(moltbook_curl -s "$BASE_URL/feed?sort=$SORT&limit=$LIMIT")

echo "$RESPONSE" | format_response

# Show summary
POST_COUNT=$(echo "$RESPONSE" | grep -o '"id"' | wc -l | tr -d ' ')
echo ""
echo "=========================================="
echo "Fetched $POST_COUNT posts from your feed"
echo "=========================================="
