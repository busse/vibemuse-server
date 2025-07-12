---
title: "[Phase 1] Database Schema Design and Creation"
labels: ["phase-1", "database", "critical", "foundation"]
milestone: "Phase 1 - Foundation & Database"
assignees: []
---

## Overview
Design and implement the complete PostgreSQL database schema for VibeMUSE, mapping all TinyMUSE object types and relationships to modern relational database structures.

## User Story
As a **developer**, I need a comprehensive database schema that accurately represents all TinyMUSE data structures, so that I can migrate existing data and build the REST API on a solid foundation.

## Acceptance Criteria
- [ ] Complete database schema created for all TinyMUSE object types (users, rooms, things, exits)
- [ ] User class and power system properly modeled
- [ ] Attribute system implemented with flexible JSON storage
- [ ] Proper foreign key relationships established
- [ ] Database indexes created for performance optimization
- [ ] Row Level Security (RLS) policies defined
- [ ] Audit logging tables created
- [ ] Schema documentation completed

## Technical Details

### Required Tables
- **users** - Player accounts with classes and powers
- **objects** - Virtual objects (rooms, things, exits)
- **attributes** - Flexible attribute system
- **messages** - Communication history
- **sessions** - User sessions and authentication
- **audit_logs** - Change tracking

### Key Requirements
- PostgreSQL 15+ compatibility
- UUID primary keys
- JSONB for flexible attributes
- Proper constraints and validations
- Performance indexes on frequently queried fields
- Audit trail for all changes

## Database Schema Structure
```sql
-- Users table with class hierarchy
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(255) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  user_class user_class_enum NOT NULL DEFAULT 'visitor',
  powers TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE,
  online_status BOOLEAN DEFAULT false,
  current_location UUID,
  profile JSONB DEFAULT '{}'
);

-- Objects table for all game entities
CREATE TABLE objects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  object_type object_type_enum NOT NULL,
  owner_id UUID REFERENCES users(id),
  location_id UUID REFERENCES objects(id),
  description TEXT,
  attributes JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Definition of Done
- [ ] All tables created with proper structure
- [ ] Foreign key constraints implemented
- [ ] Indexes created for performance
- [ ] RLS policies implemented
- [ ] Database migration scripts created
- [ ] Schema documentation completed
- [ ] Peer review completed
- [ ] Database tests pass

## Dependencies
- Supabase project setup must be completed first
- Development environment configured

## Estimated Effort
**2 weeks** (Week 1-2 of Phase 1)

## Notes
- This is a critical foundation piece - all other development depends on this
- Schema should be designed for scalability and performance
- Must maintain compatibility with existing TinyMUSE data structures
- Consider future extensibility needs