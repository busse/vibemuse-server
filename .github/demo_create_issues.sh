#!/bin/bash

# Demo script showing how create_issues.sh would work with GitHub authentication
# This script simulates the GitHub CLI calls without actually creating issues
# Updated to demonstrate the improved error handling messages

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}VibeMUSE Issues Creation Demo${NC}"
echo -e "${BLUE}============================${NC}"
echo

# Simulate the issue creation process
simulate_issue_creation() {
    local template_file="$1"
    local title=$(grep "^title:" "$template_file" | sed 's/title: *//' | tr -d '"')
    local milestone=$(grep "^milestone:" "$template_file" | sed 's/milestone: *//' | tr -d '"')
    # Parse labels from YAML array format and convert to comma-separated string
    local labels=$(grep "^labels:" "$template_file" | sed 's/labels: *//' | tr -d '[]"' | sed 's/, */,/g' | tr -d ' ')
    
    echo -e "${YELLOW}Would create issue: $title${NC}"
    echo -e "${BLUE}  Template: $(basename "$template_file")${NC}"
    echo -e "${BLUE}  Milestone: $milestone${NC}"
    echo -e "${BLUE}  Labels: $labels${NC}"
    
    # Simulate the GitHub CLI command
    echo -e "${BLUE}  Command: gh issue create --repo busse/vibemuse-server --title \"$title\" --milestone \"$milestone\" --label \"$labels\"${NC}"
    echo -e "${GREEN}  ✓ Issue would be created successfully${NC}"
    echo
}

echo -e "${YELLOW}Simulating issue creation for first few templates...${NC}"
echo

# Test a few issue templates
DEMO_ISSUES=(
    "project-dev-environment.md"
    "project-milestone-tracking.md"
    "phase1-database-schema.md"
)

for issue_file in "${DEMO_ISSUES[@]}"; do
    issue_path="./$issue_file"
    if [ -f "$issue_path" ]; then
        simulate_issue_creation "$issue_path"
    else
        echo -e "${RED}✗ Issue template not found: $issue_file${NC}"
    fi
done

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}Demo Complete!${NC}"
echo -e "${GREEN}===========================================${NC}"
echo
echo -e "${BLUE}To run the actual script:${NC}"
echo -e "1. Ensure you're logged in to GitHub CLI: ${YELLOW}gh auth login${NC}"
echo -e "2. Run the script: ${YELLOW}./create_issues.sh${NC}"
echo -e "3. For debug output: ${YELLOW}DEBUG=true ./create_issues.sh${NC}"
echo -e "4. For help: ${YELLOW}./create_issues.sh --help${NC}"
echo