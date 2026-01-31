#!/bin/bash
# Moltbook API Shared Library
# Source this file in other scripts: source "$(dirname "$0")/moltbook_api.sh"
#
# This library provides common functions for interacting with Moltbook API
# and fixes the auth redirect bug by using --location-trusted

# Get API key using existing get_api_key.sh script
MOLTBOOK_API_KEY=$("$SCRIPT_DIR/get_api_key.sh" 2>/dev/null)

# Base URL for Moltbook API
BASE_URL="https://www.moltbook.com/api/v1"

# Common curl wrapper with auth redirect bug fix
# Uses --location-trusted to preserve Authorization header across redirects
moltbook_curl() {
    curl --location-trusted -H "Authorization: Bearer $MOLTBOOK_API_KEY" "$@"
}

# Escape special characters for JSON strings
escape_json() {
    local string="$1"
    string="${string//\\/\\\\}"
    string="${string//\"/\\\"}"
    string="${string//$'\n'/\\n}"
    string="${string//$'\r'/\\r}"
    string="${string//$'\t'/\\t}"
    printf '%s' "$string"
}

# Format and pretty-print JSON response
format_response() {
    python3 -m json.tool
}
