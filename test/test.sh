#!/bin/bash
# Unit tests for Moltbook skill scripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0
SKIPPED=0

# Helper functions
assert_success() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $1"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}: $1"
        ((FAILED++))
    fi
}

assert_fail() {
    if [ $? -ne 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $1"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}: $1"
        ((FAILED++))
    fi
}

assert_contains() {
    if echo "$2" | grep -q "$1"; then
        echo -e "${GREEN}✓ PASS${NC}: Output contains '$1'"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}: Output does not contain '$1'"
        ((FAILED++))
    fi
}

skip() {
    echo -e "${YELLOW}⊘ SKIP${NC}: $1"
    ((SKIPPED++))
}

echo "=========================================="
echo "Moltbook Skill Test Suite"
echo "=========================================="
echo ""

# ==========================================
# Test 1: Script existence
# ==========================================
echo "=== Test 1: Script Files Existence ==="

for script in get_api_key.sh register.sh post.sh comment.sh vote.sh feed.sh search.sh; do
    if [ -f "$SCRIPT_DIR/scripts/$script" ]; then
        echo -e "${GREEN}✓${NC} $script exists"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $script missing"
        ((FAILED++))
    fi
done

echo ""

# ==========================================
# Test 2: Script executability
# ==========================================
echo "=== Test 2: Script Executability ==="

for script in scripts/*.sh; do
    if [ -x "$SCRIPT_DIR/$script" ]; then
        echo -e "${GREEN}✓${NC} $(basename $script) is executable"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $(basename $script) is not executable"
        ((FAILED++))
    fi
done

echo ""

# ==========================================
# Test 3: get_api_key.sh tests
# ==========================================
echo "=== Test 3: API Key Retrieval ==="

# Test with no API key set
unset MOLTBOOK_API_KEY
OUTPUT=$("$SCRIPT_DIR/scripts/get_api_key.sh" 2>&1)
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}: Returns error when no API key configured"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}: Should return error when no API key configured"
    ((FAILED++))
fi

# Test with environment variable
export MOLTBOOK_API_KEY="test_key_123"
OUTPUT=$("$SCRIPT_DIR/scripts/get_api_key.sh")
if [ "$OUTPUT" = "test_key_123" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Reads from environment variable"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}: Should read from environment variable"
    ((FAILED++))
fi

echo ""

# ==========================================
# Test 4: Script validation (syntax)
# ==========================================
echo "=== Test 4: Script Syntax Validation ==="

for script in scripts/*.sh; do
    if bash -n "$SCRIPT_DIR/$script" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $(basename $script) syntax valid"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $(basename $script) syntax error"
        ((FAILED++))
    fi
done

echo ""

# ==========================================
# Test 5: SKILL.md validation
# ==========================================
echo "=== Test 5: SKILL.md Validation ==="

# Check if SKILL.md exists
if [ -f "$SCRIPT_DIR/SKILL.md" ]; then
    echo -e "${GREEN}✓ PASS${NC}: SKILL.md exists"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}: SKILL.md missing"
    ((FAILED++))
fi

# Check for required frontmatter fields
if grep -q "^name: moltbook" "$SCRIPT_DIR/SKILL.md"; then
    echo -e "${GREEN}✓ PASS${NC}: SKILL.md has name field"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}: SKILL.md missing name field"
    ((FAILED++))
fi

if grep -q "^description:" "$SCRIPT_DIR/SKILL.md"; then
    echo -e "${GREEN}✓ PASS${NC}: SKILL.md has description field"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}: SKILL.md missing description field"
    ((FAILED++))
fi

echo ""

# ==========================================
# Test 6: Reference documentation
# ==========================================
echo "=== Test 6: Reference Documentation ==="

if [ -f "$SCRIPT_DIR/references/api_endpoints.md" ]; then
    echo -e "${GREEN}✓ PASS${NC}: api_endpoints.md exists"
    ((PASSED++))
    # Check for key API endpoints in docs
    if grep -q "POST /agents/register" "$SCRIPT_DIR/references/api_endpoints.md"; then
        echo -e "${GREEN}✓ PASS${NC}: Documentation includes register endpoint"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}: Documentation missing register endpoint"
        ((FAILED++))
    fi
else
    echo -e "${RED}✗ FAIL${NC}: api_endpoints.md missing"
    ((FAILED++))
fi

echo ""

# ==========================================
# Test 7: Script help/usage messages
# ==========================================
echo "=== Test 7: Script Help Messages ==="

# Test register.sh without arguments
OUTPUT=$("$SCRIPT_DIR/scripts/register.sh" 2>&1)
if echo "$OUTPUT" | grep -q "Usage:"; then
    echo -e "${GREEN}✓ PASS${NC}: register.sh shows usage without arguments"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}: register.sh should show usage without arguments"
    ((FAILED++))
fi

# Test post.sh without arguments
OUTPUT=$("$SCRIPT_DIR/scripts/post.sh" 2>&1)
if echo "$OUTPUT" | grep -q "Usage:"; then
    echo -e "${GREEN}✓ PASS${NC}: post.sh shows usage without arguments"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC}: post.sh should show usage without arguments"
    ((FAILED++))
fi

echo ""

# ==========================================
# Summary
# ==========================================
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}Skipped: $SKIPPED${NC}"
echo "Total: $((PASSED + FAILED + SKIPPED))"
echo "=========================================="

if [ $FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi
