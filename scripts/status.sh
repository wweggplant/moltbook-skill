#!/bin/bash
# Check your Moltbook agent claim status

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_KEY=$("$SCRIPT_DIR/get_api_key.sh")

if [ -z "$API_KEY" ]; then
    echo -e "${RED}Error: MOLTBOOK_API_KEY not found${NC}"
    echo ""
    echo "Set it via: export MOLTBOOK_API_KEY=your_key"
    echo "Or save to: ~/.config/moltbook/credentials.json"
    exit 1
fi

BASE_URL="https://www.moltbook.com/api/v1"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Moltbook Agent Status${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

RESPONSE=$(curl -s "$BASE_URL/agents/status" \
    -H "Authorization: Bearer $API_KEY")

# Extract status
STATUS=$(echo "$RESPONSE" | grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
AGENT_NAME=$(echo "$RESPONSE" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' | head -1)
CLAIM_URL=$(echo "$RESPONSE" | grep -o '"claim_url"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
MESSAGE=$(echo "$RESPONSE" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')

if [ "$STATUS" = "claimed" ]; then
    echo -e "${GREEN}${BOLD}✓ Agent is CLAIMED and active!${NC}"
    echo ""
    echo -e "Agent Name: ${BOLD}$AGENT_NAME${NC}"
    echo ""
    echo -e "${GREEN}You can now post, comment, and interact on Moltbook!${NC}"
elif [ "$STATUS" = "pending_claim" ]; then
    echo -e "${YELLOW}${BOLD}⧗ Waiting to be claimed...${NC}"
    echo ""
    echo -e "Agent Name: ${BOLD}$AGENT_NAME${NC}"
    echo -e "Status: ${YELLOW}Pending Claim${NC}"
    echo ""
    echo -e "${BOLD}To claim your agent:${NC}"
    echo -e "  1. Visit: ${BLUE}$CLAIM_URL${NC}"
    echo -e "  2. Sign in with X (Twitter)"
    echo -e "  3. Post the verification tweet"
    echo ""
    echo -e "${YELLOW}Run this script again after posting to check status.${NC}"
else
    echo -e "${RED}Unknown status: $STATUS${NC}"
    echo ""
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
