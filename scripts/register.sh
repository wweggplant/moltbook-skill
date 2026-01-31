#!/bin/bash
# Register a new Agent on Moltbook
# Usage: ./register.sh <agent_name> <description>

# Use www.moltbook.com to avoid redirect issues
BASE_URL="https://www.moltbook.com/api/v1"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

NAME="$1"
DESCRIPTION="$2"

if [ -z "$NAME" ] || [ -z "$DESCRIPTION" ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo ""
    echo "Usage: $0 <agent_name> <description>"
    echo ""
    echo "Example:"
    echo "  $0 \"MyAgent\" \"An AI agent that helps with coding\""
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Moltbook Agent Registration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Agent Name: ${BOLD}$NAME${NC}"
echo -e "Description: $DESCRIPTION"
echo ""
echo -e "${YELLOW}Registering...${NC}"

RESPONSE=$(curl -s -X POST "$BASE_URL/agents/register" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$NAME\", \"description\": \"$DESCRIPTION\"}")

# Check if registration was successful
if echo "$RESPONSE" | grep -q '"success":[[:space:]]*false'; then
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  Registration Failed${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
    echo ""
    # Check if name is already taken
    if echo "$RESPONSE" | grep -q "already taken\|already registered"; then
        echo -e "${YELLOW}Tip: Try a different agent name${NC}"
    fi
    exit 1
fi

# Extract information from response
API_KEY=$(echo "$RESPONSE" | grep -o '"api_key"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
CLAIM_URL=$(echo "$RESPONSE" | grep -o '"claim_url"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
VERIFICATION_CODE=$(echo "$RESPONSE" | grep -o '"verification_code"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
PROFILE_URL=$(echo "$RESPONSE" | grep -o '"profile_url"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
AGENT_NAME=$(echo "$RESPONSE" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' | head -1)

if [ -z "$API_KEY" ]; then
    echo -e "${RED}Error: Failed to extract API key from response${NC}"
    echo "Response: $RESPONSE"
    exit 1
fi

# Success! Display the information
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  Registration Successful! 🦞${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BOLD}Step 1: Save your API Key${NC}"
echo -e "   ${YELLOW}This is required for all Moltbook requests!${NC}"
echo ""
echo -e "   Your API Key:"
echo -e "   ${GREEN}${BOLD}$API_KEY${NC}"
echo ""
echo -e "   Set it as environment variable:"
echo -e "   ${BLUE}export MOLTBOOK_API_KEY=$API_KEY${NC}"
echo ""
echo -e "   Or save to config file:"
echo -e "   ${BLUE}mkdir -p ~/.config/moltbook${NC}"
echo -e "   ${BLUE}echo '{\"api_key\": \"$API_KEY\", \"agent_name\": \"$AGENT_NAME\"}' > ~/.config/moltbook/credentials.json${NC}"
echo ""

echo -e "${BOLD}Step 2: Claim Your Agent${NC}"
echo -e "   ${YELLOW}Your agent needs to be claimed by a human before posting.${NC}"
echo ""
echo -e "   1. Visit your claim URL:"
echo -e "      ${BLUE}$CLAIM_URL${NC}"
echo ""
echo -e "   2. Sign in with X (Twitter)"
echo ""
echo -e "   3. Post this verification tweet:"
echo -e "      ${BOLD}I'm claiming my AI agent \"$AGENT_NAME\" on @moltbook 🦞${NC}"
echo -e "      ${BOLD}Verification: $VERIFICATION_CODE${NC}"
echo ""

echo -e "${BOLD}Step 3: Wait for Verification${NC}"
echo -e "   Moltbook will automatically verify your tweet."
echo -e "   Once claimed, you can start posting!"
echo ""

echo -e "${BOLD}Your Agent Profile${NC}:"
echo -e "   ${BLUE}$PROFILE_URL${NC}"
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Ready to join the Moltbook community!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
