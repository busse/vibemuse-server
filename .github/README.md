# VibeMUSE GitHub Issues Templates

This directory contains GitHub Issue templates for the VibeMUSE modernization project. These templates represent the complete backlog needed to transform the TinyMUSE server from a C-based application to a modern web architecture.

## Quick Start

### Option 1: Automated Creation (Recommended)
```bash
# Make sure you have GitHub CLI installed and authenticated
gh auth login

# Run the creation script
./create_issues.sh
```

### Option 2: Manual Creation
1. Create milestones in GitHub for each phase
2. Create labels using the label definitions below
3. Create issues using the templates in this directory

## Project Overview

The VibeMUSE modernization project follows a **32-week timeline** across **7 development phases**:

1. **Phase 1**: Foundation & Database (4 weeks)
2. **Phase 2**: Core API Infrastructure (4 weeks) 
3. **Phase 3**: Game Mechanics APIs (4 weeks)
4. **Phase 4**: World Building & Administration (4 weeks)
5. **Phase 5**: Advanced Features (4 weeks)
6. **Phase 6**: Frontend Development (8 weeks)
7. **Phase 7**: Testing & Polish (4 weeks)

## Issue Templates Included

### Project Management (2 issues)
- `project-dev-environment.md` - Development environment setup
- `project-milestone-tracking.md` - Project tracking and milestones

### Phase 1: Foundation & Database (4 issues)
- `phase1-database-schema.md` - Database schema design
- `phase1-supabase-setup.md` - Supabase project configuration
- `phase1-migration-scripts.md` - Data migration tools
- `phase1-validation-tools.md` - Data validation and integrity

### Phase 2: Core API Infrastructure (3 issues)
- `phase2-authentication-system.md` - Authentication and security
- `phase2-user-management-api.md` - User management APIs
- `phase2-object-management-api.md` - Object management APIs

### Phase 3: Game Mechanics APIs (2 issues)
- `phase3-realtime-communication.md` - Real-time communication
- `phase3-movement-navigation.md` - Movement and navigation

### Phase 6: Frontend Development (1 issue)
- `phase6-react-frontend.md` - React application setup

### Phase 7: Testing & Polish (1 issue)
- `phase7-comprehensive-testing.md` - Testing suite

## Label System

### Phase Labels
- `phase-1` - Foundation & Database
- `phase-2` - Core API Infrastructure  
- `phase-3` - Game Mechanics APIs
- `phase-4` - World Building & Administration
- `phase-5` - Advanced Features
- `phase-6` - Frontend Development
- `phase-7` - Testing & Polish

### Priority Labels
- `critical` - Must be completed (red)
- `high` - Should be completed soon (orange)
- `medium` - Normal timeline (yellow)
- `low` - Can be deferred (green)

### Functional Labels
- `database` - Database related tasks
- `api` - API development tasks
- `frontend` - Frontend development tasks
- `infrastructure` - Infrastructure and setup
- `security` - Security related tasks
- `testing` - Testing and QA
- `documentation` - Documentation tasks
- `performance` - Performance optimization
- `project-management` - Project management

## Milestone Structure

Each milestone corresponds to a development phase with specific deliverables:

```
Project Setup (Pre-Phase 1)
├── Development Environment Setup
└── Project Milestone and Progress Tracking

Phase 1 - Foundation & Database (Weeks 1-4)
├── Database Schema Design and Creation
├── Supabase Project Setup and Configuration
├── TinyMUSE Data Migration Scripts
└── Data Validation and Integrity Tools

Phase 2 - Core API Infrastructure (Weeks 5-8)
├── Authentication System Implementation
├── User Management API
├── Object Management API
└── Permission System Implementation

[... and so on for all phases]
```

## Issue Template Structure

Each issue template follows a consistent format:

```markdown
---
title: "[Phase X] Feature Name"
labels: ["phase-x", "category", "priority"]
milestone: "Phase X - Description"
assignees: []
---

## Overview
Brief description of the feature/task

## User Story
As a [role], I need [functionality], so that [benefit]

## Acceptance Criteria
- [ ] Specific, measurable requirements
- [ ] Definition of done items
- [ ] Success criteria

## Technical Details
Implementation specifics, code examples, architecture

## Definition of Done
- [ ] Completion criteria
- [ ] Testing requirements
- [ ] Documentation requirements

## Dependencies
What must be completed before this can start

## Estimated Effort
Time estimate and phase timing

## Notes
Additional context and considerations
```

## Usage Instructions

### For Project Managers
1. Create all issues using the templates
2. Assign issues to appropriate team members
3. Set up project boards for tracking progress
4. Monitor milestone completion

### For Developers
1. Review issue requirements and acceptance criteria
2. Check dependencies before starting work
3. Follow the technical implementation details
4. Ensure all definition of done items are met

### For Stakeholders
1. Track progress through milestone completion
2. Review issue summaries for project status
3. Monitor risk and timeline updates
4. Provide feedback on deliverables

## File Structure

```
/tmp/github-issues/
├── README.md                           # This file
├── ISSUES_SUMMARY.md                   # Complete issue summary
├── create_issues.sh                    # Automated creation script
├── project-dev-environment.md          # Project setup
├── project-milestone-tracking.md       # Project tracking
├── phase1-database-schema.md           # Database schema
├── phase1-supabase-setup.md            # Supabase setup
├── phase1-migration-scripts.md         # Migration tools
├── phase1-validation-tools.md          # Validation tools
├── phase2-authentication-system.md     # Authentication
├── phase2-user-management-api.md       # User management
├── phase2-object-management-api.md     # Object management
├── phase3-realtime-communication.md    # Real-time communication
├── phase3-movement-navigation.md       # Movement system
├── phase6-react-frontend.md            # Frontend application
└── phase7-comprehensive-testing.md     # Testing suite
```

## Contributing

When creating new issue templates:

1. Follow the established template structure
2. Use consistent labeling and milestone naming
3. Include detailed acceptance criteria
4. Provide realistic effort estimates
5. Identify dependencies clearly
6. Update the summary files

## Support

For questions about the issue templates or VibeMUSE project:

1. Review the comprehensive documentation in `/docs`
2. Check the project tracker for current status
3. Consult the development plan for context
4. Reach out to project maintainers

---

**Total Issues**: 13 templates provided (representative sample)
**Full Project Scope**: 30+ issues across all phases
**Timeline**: 32 weeks (8 months)
**Tech Stack**: Node.js, React, PostgreSQL, Supabase