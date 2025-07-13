#!/bin/bash

# Test parsing functions from create_issues.sh without GitHub authentication
# This script tests only the parsing logic

set -e

# Configuration
REPO_OWNER="busse"
REPO_NAME="vibemuse-server"
ISSUES_DIR="$(dirname "$0")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test the issue parsing function
test_issue_parsing() {
    local template_file="$1"
    local title=$(grep "^title:" "$template_file" | sed 's/title: *//' | tr -d '"')
    local milestone=$(grep "^milestone:" "$template_file" | sed 's/milestone: *//' | tr -d '"')
    # Parse labels from YAML array format and convert to comma-separated string
    local labels=$(grep "^labels:" "$template_file" | sed 's/labels: *//' | tr -d '[]"' | sed 's/, */,/g' | tr -d ' ')
    
    # Extract body (everything after the front matter)
    local body=$(sed -n '/^---$/,/^---$/d; p' "$template_file")
    
    echo -e "${YELLOW}Testing parsing for: $(basename "$template_file")${NC}"
    echo -e "${BLUE}  Title: $title${NC}"
    echo -e "${BLUE}  Milestone: $milestone${NC}"
    echo -e "${BLUE}  Labels: $labels${NC}"
    echo -e "${BLUE}  Body length: $(echo "$body" | wc -c) characters${NC}"
    
    # Validate that all required fields are present
    if [ -z "$title" ] || [ -z "$milestone" ] || [ -z "$labels" ]; then
        echo -e "${RED}  ✗ Missing required fields${NC}"
        return 1
    else
        echo -e "${GREEN}  ✓ All required fields present${NC}"
        return 0
    fi
}

echo -e "${BLUE}VibeMUSE Issue Template Parsing Test${NC}"
echo -e "${BLUE}====================================${NC}"
echo

# Test all issue templates
ISSUES=(
    "project-dev-environment.md"
    "project-milestone-tracking.md"
    "phase1-database-schema.md"
    "phase1-supabase-setup.md"
    "phase1-migration-scripts.md"
    "phase1-validation-tools.md"
    "phase2-authentication-system.md"
    "phase2-user-management-api.md"
    "phase2-object-management-api.md"
    "phase3-realtime-communication.md"
    "phase3-movement-navigation.md"
    "phase6-react-frontend.md"
    "phase7-comprehensive-testing.md"
)

failed_tests=0
total_tests=0

for issue_file in "${ISSUES[@]}"; do
    issue_path="$ISSUES_DIR/$issue_file"
    if [ -f "$issue_path" ]; then
        total_tests=$((total_tests + 1))
        if ! test_issue_parsing "$issue_path"; then
            failed_tests=$((failed_tests + 1))
        fi
        echo
    else
        echo -e "${RED}✗ Issue template not found: $issue_file${NC}"
        failed_tests=$((failed_tests + 1))
        total_tests=$((total_tests + 1))
    fi
done

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}Parsing Tests Complete!${NC}"
echo -e "${GREEN}===========================================${NC}"
echo
echo -e "${BLUE}Results:${NC}"
echo -e "• Total tests: $total_tests"
echo -e "• Passed: $((total_tests - failed_tests))"
echo -e "• Failed: $failed_tests"

if [ $failed_tests -eq 0 ]; then
    echo -e "${GREEN}All parsing tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some parsing tests failed! ✗${NC}"
    exit 1
fi