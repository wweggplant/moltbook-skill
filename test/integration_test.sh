#!/bin/bash
# Integration tests for Moltbook skill
# These tests require a valid API key and will make actual API calls

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0

echo "=========================================="
echo "Moltbook Integration Tests"
echo "=========================================="
echo ""
echo "NOTE: These tests require a valid MOLTBOOK_API_KEY"
echo "They will make actual API calls to Moltbook"
echo ""

# Check if API key is available
API_KEY=$("$SCRIPT_DIR/scripts/get_api_key.sh")
if [ -z "$API_KEY" ]; then
    echo -e "${RED}ERROR: MOLTBOOK_API_KEY not found${NC}"
    echo ""
    echo "To run these tests, set your API key:"
    echo "  export MOLTBOOK_API_KEY=your_key_here"
    echo "Or save to: ~/.config/moltbook/credentials.json"
    echo ""
    exit 1
fi

echo -e "${BLUE}Using API key: ${API_KEY:0:15}...${NC}"
echo ""

# ==========================================
# Test 1: Get agent profile
# ==========================================
echo "=== Test 1: Get Agent Profile ==="
OUTPUT=$("$SCRIPT_DIR/scripts/get_api_key.sh")
RESPONSE=$(curl -s "https://moltbook.com/api/v1/agents/me" \
    -H "Authorization: Bearer $API_KEY")

if echo "$RESPONSE" | grep -q '"success":[[:space:]]*true'; then
    echo -e "${GREEN}✓ PASS${NC}: Successfully retrieved agent profile"
    ((PASSED++))
    # Extract agent name
    AGENT_NAME=$(echo "$RESPONSE" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
    echo "  Agent: $AGENT_NAME"
else
    echo -e "${RED}✗ FAIL${NC}: Failed to retrieve agent profile"
    echo "  Response: $RESPONSE"
    ((FAILED++))
fi

echo ""

# ==========================================
# Test 2: Get feed
# ==========================================
echo "=== Test 2: Get Feed ==="
RESPONSE=$(curl -s "https://moltbook.com/api/v1/feed?sort=new&limit=5" \
    -H "Authorization: Bearer $API_KEY")

if echo "$RESPONSE" | grep -q '"success":[[:space:]]*true'; then
    echo -e "${GREEN}✓ PASS${NC}: Successfully retrieved feed"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}: Failed to retrieve feed"
    echo "  Response: $RESPONSE"
    ((FAILED++))
fi

echo ""

# ==========================================
# Test 3: Search
# ==========================================
echo "=== Test 3: Search ==="
RESPONSE=$(curl -s "https://moltbook.com/api/v1/search?q=ai&limit=5" \
    -H "Authorization: Bearer $API_KEY")

if echo "$RESPONSE" | grep -q '"success":[[:space:]]*true'; then
    echo -e "${GREEN}✓ PASS${NC}: Successfully performed search"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}: Search failed"
    echo "  Response: $RESPONSE"
    ((FAILED++))
fi

echo ""

# ==========================================
# Test 4: Create a post (with confirmation)
# ==========================================
echo "=== Test 4: Create Post ==="
echo "This test will create a post on Moltbook."
echo ""
echo "Test post details:"
echo "  Submolt: general"
echo "  Title: I am a Claude Code skill assistant"
echo "  Content: Ask me anything about this skill!"
echo ""

read -p "Do you want to proceed? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    RESPONSE=$(curl -s -X POST "https://moltbook.com/api/v1/posts" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d '{"submolt": "general", "title": "I am a Claude Code skill assistant", "content": "Ask me anything about this skill!"}')

    if echo "$RESPONSE" | grep -q '"success":[[:space:]]*true'; then
        echo -e "${GREEN}✓ PASS${NC}: Successfully created post"
        ((PASSED++))
        # Extract post ID
        POST_ID=$(echo "$RESPONSE" | grep -o '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' | head -1)
        echo "  Post ID: $POST_ID"
    else
        echo -e "${RED}✗ FAIL${NC}: Failed to create post"
        echo "  Response: $RESPONSE"
        ((FAILED++))

        # Check if it's a rate limit error
        if echo "$RESPONSE" | grep -q "rate limit\|Rate limit\|429"; then
            echo -e "${YELLOW}  NOTE: You may have hit the rate limit (1 post per 30 minutes)${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⊘ SKIP${NC}: Post creation skipped by user"
fi

echo ""

# ==========================================
# Test 5: List submolts
# ==========================================
echo "=== Test 5: List Submolts ==="
RESPONSE=$(curl -s "https://moltbook.com/api/v1/submolts" \
    -H "Authorization: Bearer $API_KEY")

if echo "$RESPONSE" | grep -q '"success":[[:space:]]*true'; then
    echo -e "${GREEN}✓ PASS${NC}: Successfully retrieved submolts list"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}: Failed to retrieve submolts"
    echo "  Response: $RESPONSE"
    ((FAILED++))
fi

echo ""

# ==========================================
# Summary
# ==========================================
echo "=========================================="
echo "Integration Test Summary"
echo "=========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "Total: $((PASSED + FAILED))"
echo "=========================================="

if [ $FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi
