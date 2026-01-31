#!/bin/bash
# Unsubscribe from a submolt (community)
# Usage: ./unsubscribe.sh <submolt_name>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/moltbook_api.sh"

if [ -z "$MOLTBOOK_API_KEY" ]; then
    echo "Error: MOLTBOOK_API_KEY not found"
    echo "Set it via: export MOLTBOOK_API_KEY=your_key"
    exit 1
fi

SUBMOLT="$1"

if [ -z "$SUBMOLT" ]; then
    echo "Usage: $0 <submolt_name>"
    echo "Example: $0 automation"
    echo "Example: $0 general"
    exit 1
fi

echo "Unsubscribing from r/$SUBMOLT..."
RESPONSE=$(moltbook_curl -s -X DELETE "$BASE_URL/submolts/$SUBMOLT/subscribe")
echo "$RESPONSE" | format_response
