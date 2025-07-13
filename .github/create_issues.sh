#!/bin/bash

# GitHub Issues Creation Script for VibeMUSE
# This script helps create all the GitHub Issues for the VibeMUSE modernization project

set -e

# Debug mode flag
DEBUG=${DEBUG:-false}

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

# Portable date arithmetic function
# Usage: portable_date_add <base_date> <weeks_to_add>
# If base_date is empty, uses current date
portable_date_add() {
    local base_date="$1"
    local weeks="$2"
    
    # Check if we have GNU date or BSD date
    if date --version >/dev/null 2>&1; then
        # GNU date (Linux)
        if [ -n "$base_date" ]; then
            date -d "$base_date +${weeks} weeks" +%Y-%m-%d
        else
            date -d "+${weeks} weeks" +%Y-%m-%d
        fi
    else
        # BSD date (macOS)
        if [ -n "$base_date" ]; then
            date -j -f "%Y-%m-%d" "$base_date" -v+${weeks}w +%Y-%m-%d
        else
            date -v+${weeks}w +%Y-%m-%d
        fi
    fi
}

echo -e "${BLUE}VibeMUSE GitHub Issues Creation Tool${NC}"
echo -e "${BLUE}===================================${NC}"
echo
echo "Usage: $0 [OPTIONS]"
echo "Options:"
echo "  DEBUG=true    Enable debug output"
echo "  -h, --help    Show this help message"
echo
echo "This script creates GitHub issues, milestones, and labels for the VibeMUSE project."
echo "Make sure you are logged in to GitHub CLI with: gh auth login"
echo

# Handle help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Examples:"
    echo "  $0                    # Run the script normally"
    echo "  DEBUG=true $0         # Run with debug output"
    echo "  $0 --help            # Show this help"
    echo
    exit 0
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed.${NC}"
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if logged in to GitHub
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not logged in to GitHub.${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

# Check if repository exists
if ! gh repo view "$REPO_OWNER/$REPO_NAME" &> /dev/null; then
    echo -e "${RED}Error: Repository $REPO_OWNER/$REPO_NAME not found.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ GitHub CLI is installed and authenticated${NC}"
echo -e "${GREEN}✓ Repository $REPO_OWNER/$REPO_NAME found${NC}"
echo

# Function to create milestone
create_milestone() {
    local title="$1"
    local description="$2"
    local due_date="$3"
    
    echo -e "${YELLOW}Creating milestone: $title${NC}"
    
    if gh api repos/$REPO_OWNER/$REPO_NAME/milestones \
        --method POST \
        --field title="$title" \
        --field description="$description" \
        --field due_on="$due_date" &> /dev/null; then
        echo -e "${GREEN}✓ Milestone created: $title${NC}"
    else
        echo -e "${YELLOW}⚠ Milestone may already exist: $title${NC}"
    fi
}

# Function to create label
create_label() {
    local name="$1"
    local color="$2"
    local description="$3"
    
    if gh api repos/$REPO_OWNER/$REPO_NAME/labels \
        --method POST \
        --field name="$name" \
        --field color="$color" \
        --field description="$description" &> /dev/null; then
        echo -e "${GREEN}✓ Label created: $name${NC}"
    else
        echo -e "${YELLOW}⚠ Label may already exist: $name${NC}"
    fi
}

# Function to create issue from template
create_issue() {
    local template_file="$1"
    local title=$(grep "^title:" "$template_file" | sed 's/title: *//' | tr -d '"')
    local milestone=$(grep "^milestone:" "$template_file" | sed 's/milestone: *//' | tr -d '"')
    # Parse labels from YAML array format and convert to comma-separated string
    local labels=$(grep "^labels:" "$template_file" | sed 's/labels: *//' | tr -d '[]"' | sed 's/, */,/g' | tr -d ' ')
    
    # Extract body (everything after the front matter)
    local body=$(sed -n '/^---$/,/^---$/d; p' "$template_file")
    
    echo -e "${YELLOW}Creating issue: $title${NC}"
    
    # Debug output
    if [ "$DEBUG" = "true" ]; then
        echo -e "${BLUE}  Template: $template_file${NC}"
        echo -e "${BLUE}  Title: $title${NC}"
        echo -e "${BLUE}  Milestone: $milestone${NC}"
        echo -e "${BLUE}  Labels: $labels${NC}"
        echo -e "${BLUE}  Body length: $(echo "$body" | wc -c) characters${NC}"
    fi
    
    # Create the issue with better error handling
    local issue_url=""
    if [ -n "$labels" ]; then
        issue_url=$(gh issue create \
            --repo "$REPO_OWNER/$REPO_NAME" \
            --title "$title" \
            --body "$body" \
            --milestone "$milestone" \
            --label "$labels" 2>&1 || echo "")
    else
        issue_url=$(gh issue create \
            --repo "$REPO_OWNER/$REPO_NAME" \
            --title "$title" \
            --body "$body" \
            --milestone "$milestone" 2>&1 || echo "")
    fi
    
    if [[ "$issue_url" == *"https://github.com/"* ]]; then
        echo -e "${GREEN}✓ Issue created: $title${NC}"
        echo -e "${BLUE}  URL: $issue_url${NC}"
    else
        echo -e "${RED}✗ Failed to create issue: $title${NC}"
        echo -e "${RED}  Error: $issue_url${NC}"
    fi
}

# Create milestones
echo -e "${BLUE}Creating GitHub Milestones...${NC}"
echo

# Calculate milestone dates (assuming start date is 4 weeks from now)
START_DATE=$(portable_date_add "" "4")

create_milestone "Project Setup" "Initial project setup and infrastructure" "$START_DATE"
create_milestone "Phase 1 - Foundation & Database" "Database schema, Supabase setup, and migration tools" "$(portable_date_add "$START_DATE" "4")"
create_milestone "Phase 2 - Core API Infrastructure" "Authentication, user management, and object APIs" "$(portable_date_add "$START_DATE" "8")"
create_milestone "Phase 3 - Game Mechanics APIs" "Real-time communication and movement systems" "$(portable_date_add "$START_DATE" "12")"
create_milestone "Phase 4 - World Building & Administration" "Building tools and administrative interfaces" "$(portable_date_add "$START_DATE" "16")"
create_milestone "Phase 5 - Advanced Features" "Complex interactions and system optimization" "$(portable_date_add "$START_DATE" "20")"
create_milestone "Phase 6 - Frontend Development" "React application and user interfaces" "$(portable_date_add "$START_DATE" "28")"
create_milestone "Phase 7 - Testing & Polish" "Testing, optimization, and production readiness" "$(portable_date_add "$START_DATE" "32")"

echo

# Create labels
echo -e "${BLUE}Creating GitHub Labels...${NC}"
echo

# Phase labels
create_label "phase-1" "0052cc" "Phase 1 - Foundation & Database"
create_label "phase-2" "0052cc" "Phase 2 - Core API Infrastructure"
create_label "phase-3" "0052cc" "Phase 3 - Game Mechanics APIs"
create_label "phase-4" "0052cc" "Phase 4 - World Building & Administration"
create_label "phase-5" "0052cc" "Phase 5 - Advanced Features"
create_label "phase-6" "0052cc" "Phase 6 - Frontend Development"
create_label "phase-7" "0052cc" "Phase 7 - Testing & Polish"

# Priority labels
create_label "critical" "d73a4a" "Critical priority - must be completed"
create_label "high" "fb8500" "High priority - should be completed soon"
create_label "medium" "fbca04" "Medium priority - normal timeline"
create_label "low" "0e8a16" "Low priority - can be deferred"

# Functional labels
create_label "database" "1f77b4" "Database related tasks"
create_label "api" "ff7f0e" "API development tasks"
create_label "frontend" "2ca02c" "Frontend development tasks"
create_label "infrastructure" "d62728" "Infrastructure and setup tasks"
create_label "security" "9467bd" "Security related tasks"
create_label "testing" "8c564b" "Testing and quality assurance"
create_label "documentation" "e377c2" "Documentation tasks"
create_label "performance" "7f7f7f" "Performance optimization tasks"
create_label "project-management" "17becf" "Project management tasks"

echo

# Create issues
echo -e "${BLUE}Creating GitHub Issues...${NC}"
echo

# Define issue creation order (most important first)
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

# Create issues in order
for issue_file in "${ISSUES[@]}"; do
    issue_path="$ISSUES_DIR/$issue_file"
    if [ -f "$issue_path" ]; then
        create_issue "$issue_path"
        echo
        sleep 2  # Rate limiting
    else
        echo -e "${RED}✗ Issue template not found: $issue_file${NC}"
    fi
done

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}GitHub Issues Creation Complete!${NC}"
echo -e "${GREEN}===========================================${NC}"
echo
echo -e "${BLUE}Summary:${NC}"
echo -e "• Created milestones for all 7 phases"
echo -e "• Created comprehensive label system"
echo -e "• Created ${#ISSUES[@]} GitHub issues"
echo
echo -e "${BLUE}Next Steps:${NC}"
echo -e "1. Review created issues in GitHub"
echo -e "2. Assign issues to team members"
echo -e "3. Set up project board for tracking"
echo -e "4. Begin with Project Management issues"
echo
echo -e "${BLUE}Repository: https://github.com/$REPO_OWNER/$REPO_NAME/issues${NC}"
echo