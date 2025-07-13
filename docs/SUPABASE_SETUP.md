# Supabase Setup and Configuration Guide

## Overview

This guide provides comprehensive instructions for setting up and configuring Supabase for the VibeMUSE server project. This documentation is designed for developers who are new to Supabase but have experience with SQL and relational database concepts.

> **Note**: This guide complements the [configuration reference](../database/SUPABASE_SETUP.md) with detailed step-by-step instructions and troubleshooting information.

## What is Supabase?

Supabase is an open-source Firebase alternative that provides:
- **PostgreSQL Database**: Full-featured relational database with SQL support
- **Real-time Subscriptions**: WebSocket-based real-time data synchronization
- **Authentication**: Built-in user authentication with JWT tokens
- **Row Level Security (RLS)**: Fine-grained access control at the database level
- **Storage**: File storage with image transformations
- **Edge Functions**: Serverless functions for custom logic
- **Auto-generated APIs**: RESTful APIs automatically generated from your database schema

## Why Supabase for VibeMUSE?

VibeMUSE chose Supabase for several key reasons:

1. **Real-time Communication**: Essential for MUD-style real-time interactions
2. **PostgreSQL**: Mature, powerful relational database perfect for complex game data
3. **Row Level Security**: Granular security controls for multi-user environments
4. **Developer Experience**: Excellent tooling and local development support
5. **Scalability**: Handles growth from development to production
6. **Open Source**: Can be self-hosted and customized as needed

## Prerequisites

Before starting, ensure you have:

- **Node.js** 18+ and npm
- **Docker** and Docker Compose (for local development)
- **Git** (for version control)
- **Basic SQL knowledge** (CREATE TABLE, SELECT, INSERT, etc.)
- **Understanding of relational databases** (primary keys, foreign keys, indexes)

## Part 1: Local Development Setup

### 1.1 Install Supabase CLI

```bash
# Install Supabase CLI globally
npm install -g supabase

# Verify installation
supabase --version
```

### 1.2 Initialize Local Supabase

The VibeMUSE project already has Supabase configured, but here's how it was set up:

```bash
# Navigate to project root
cd /path/to/vibemuse-server

# Initialize Supabase (already done in this project)
supabase init

# Start local Supabase services
supabase start
```

### 1.3 Understanding the Local Environment

When you run `supabase start`, it creates a local development environment with:

- **Database**: PostgreSQL 17 running on `localhost:54322`
- **API Server**: REST API on `localhost:54321`
- **Studio**: Web interface on `localhost:54323`
- **Auth**: Authentication service
- **Storage**: File storage service
- **Email**: Email testing service on `localhost:54324`

### 1.4 Environment Configuration

Copy the environment template:

```bash
cp .env.example .env.local
```

Configure the local environment variables:

```env
# Supabase Configuration
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Database Configuration
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Application Configuration
JWT_SECRET=your-super-secret-jwt-key-here
NODE_ENV=development
PORT=3000
```

**Important**: The `SUPABASE_ANON_KEY` and `SUPABASE_SERVICE_ROLE_KEY` are displayed in the terminal when you run `supabase start`.

## Part 2: Database Schema and Migrations

### 2.1 Understanding the VibeMUSE Database Schema

The VibeMUSE database is designed to support a modern MUD/MUSE environment with the following key tables:

```sql
-- Core user management
users                    -- User accounts and profiles
sessions                 -- User session management

-- Virtual world objects
virtual_objects          -- Rooms, things, exits, and players
attributes              -- Object attributes and properties

-- Communication system
messages                -- All communication (say, pose, page, mail)
channels                -- Communication channels
channel_subscriptions   -- User channel memberships
```

### 2.2 Migration System

Supabase uses a migration-based approach to manage database schema changes:

```bash
# View current migration status
supabase db status

# Create a new migration
supabase migration create "add_new_feature"

# Apply migrations
supabase db push

# Reset database (useful for development)
supabase db reset
```

### 2.3 Working with Migrations

**Creating a Migration:**

```bash
# Create a new migration file
supabase migration create "add_user_preferences"
```

This creates a file like `supabase/migrations/20240101000000_add_user_preferences.sql`.

**Migration Best Practices:**

1. **Incremental Changes**: Each migration should contain one logical change
2. **Rollback Considerations**: Write migrations that can be easily reversed
3. **Data Migrations**: Include data transformations if needed
4. **Testing**: Always test migrations on development data first

**Example Migration:**

```sql
-- Add user preferences table
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    setting_name TEXT NOT NULL,
    setting_value JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, setting_name)
);

-- Enable RLS
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- RLS Policy - users can only access their own preferences
CREATE POLICY "Users can manage their own preferences"
ON user_preferences FOR ALL
USING (auth.uid() = user_id);
```

### 2.4 Database Management Scripts

VibeMUSE provides convenient database management scripts:

```bash
# Start Supabase services
./scripts/db-manager.sh start

# Stop Supabase services
./scripts/db-manager.sh stop

# Apply migrations
./scripts/db-manager.sh migrate

# Reset database to initial state
./scripts/db-manager.sh reset

# Create a backup
./scripts/db-manager.sh backup

# Generate TypeScript types
./scripts/db-manager.sh generate-types

# Check status
./scripts/db-manager.sh status
```

## Part 3: Authentication and Security

### 3.1 Authentication Overview

VibeMUSE uses Supabase Auth for user management:

- **JWT Tokens**: Stateless authentication
- **Email/Password**: Primary authentication method
- **Session Management**: Automatic token refresh
- **Custom Claims**: Additional user metadata

### 3.2 Row Level Security (RLS)

RLS is a PostgreSQL feature that Supabase leverages for fine-grained access control:

```sql
-- Enable RLS on a table
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Create a policy for message access
CREATE POLICY "Users can read messages in their location"
ON messages FOR SELECT
USING (
    -- User can see messages in their current location
    location_id IN (
        SELECT location_id FROM users WHERE id = auth.uid()
    )
);

-- Create a policy for sending messages
CREATE POLICY "Users can send messages from their location"
ON messages FOR INSERT
WITH CHECK (
    -- User can only send messages from their current location
    sender_id = auth.uid() AND
    location_id IN (
        SELECT location_id FROM users WHERE id = auth.uid()
    )
);
```

### 3.3 Authentication Configuration

In `supabase/config.toml`:

```toml
[auth]
enabled = true
site_url = "http://127.0.0.1:3000"
jwt_expiry = 3600
enable_refresh_token_rotation = true
enable_signup = true
minimum_password_length = 8

[auth.email]
enable_signup = true
enable_confirmations = false
double_confirm_changes = true
```

### 3.4 Custom Authentication Logic

For VibeMUSE-specific authentication needs:

```sql
-- Custom function for user initialization
CREATE OR REPLACE FUNCTION initialize_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Create initial user record in our custom users table
    INSERT INTO users (id, email, display_name, location_id)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        (SELECT id FROM virtual_objects WHERE name = 'Limbo' LIMIT 1)
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to run on new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION initialize_new_user();
```

## Part 4: Real-time Features

### 4.1 Real-time Overview

Supabase provides real-time capabilities through WebSockets, enabling:

- **Live Data Sync**: Automatic UI updates when data changes
- **Real-time Communication**: Instant messaging and notifications
- **Presence**: User online/offline status
- **Collaborative Features**: Multiple users interacting with shared data

### 4.2 Enabling Real-time

In `supabase/config.toml`:

```toml
[realtime]
enabled = true
# Configure realtime settings
max_header_length = 4096
```

### 4.3 Real-time Subscriptions

**Database Level - Enable real-time for tables:**

```sql
-- Enable real-time for the messages table
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Enable real-time for user presence
ALTER PUBLICATION supabase_realtime ADD TABLE users;

-- Enable real-time for object updates
ALTER PUBLICATION supabase_realtime ADD TABLE virtual_objects;
```

**Application Level - Subscribe to changes:**

```javascript
// Subscribe to new messages in current room
const messagesSubscription = supabase
    .channel('room-messages')
    .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'messages',
        filter: `location_id=eq.${currentRoomId}`
    }, (payload) => {
        // Handle new message
        displayMessage(payload.new);
    })
    .subscribe();

// Subscribe to user presence changes
const presenceSubscription = supabase
    .channel('user-presence')
    .on('postgres_changes', {
        event: 'UPDATE',
        schema: 'public',
        table: 'users',
        filter: `location_id=eq.${currentRoomId}`
    }, (payload) => {
        // Handle user presence update
        updateUserPresence(payload.new);
    })
    .subscribe();
```

### 4.4 Real-time Best Practices

1. **Selective Subscriptions**: Only subscribe to data you need
2. **Filter Appropriately**: Use filters to reduce unnecessary traffic
3. **Cleanup**: Always unsubscribe when components unmount
4. **Error Handling**: Handle connection errors gracefully
5. **Rate Limiting**: Be mindful of subscription frequency

## Part 5: Production Deployment

### 5.1 Supabase Cloud Setup

**Create a Supabase Project:**

1. Go to [supabase.com](https://supabase.com)
2. Sign up/Login
3. Create a new project
4. Choose a region close to your users
5. Set a strong database password

**Configure Environment Variables:**

```env
# Production Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-production-service-role-key

# Production Database
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT].supabase.co:5432/postgres

# Production Settings
NODE_ENV=production
JWT_SECRET=your-production-jwt-secret
```

### 5.2 Deployment Process

**Link Local Project to Production:**

```bash
# Link to your production project
supabase link --project-ref your-project-ref

# Push schema to production
supabase db push

# Deploy any edge functions
supabase functions deploy
```

### 5.3 Production Configuration

**Database Performance:**

```sql
-- Create indexes for better performance
CREATE INDEX idx_messages_location_created ON messages(location_id, created_at);
CREATE INDEX idx_users_location ON users(location_id);
CREATE INDEX idx_virtual_objects_type ON virtual_objects(object_type);
```

**Security Settings:**

```sql
-- Ensure RLS is enabled on all tables
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE virtual_objects ENABLE ROW LEVEL SECURITY;
```

### 5.4 Monitoring and Maintenance

**Database Monitoring:**

- Use Supabase Dashboard for real-time metrics
- Monitor connection counts and query performance
- Set up alerts for high resource usage

**Backup Strategy:**

```bash
# Automated backups (configured in Supabase Dashboard)
# Manual backup
supabase db dump --local > backup.sql

# Restore from backup
supabase db reset --local
psql -h localhost -p 54322 -U postgres -d postgres < backup.sql
```

## Part 6: Development Workflow

### 6.1 Daily Development Workflow

**Starting Development:**

```bash
# 1. Start local Supabase
supabase start

# 2. Apply any new migrations
supabase db push

# 3. Start the API server
cd api && npm run dev
```

**Making Schema Changes:**

```bash
# 1. Create a new migration
supabase migration create "your_change_description"

# 2. Edit the migration file
# Add your SQL changes to the generated file

# 3. Apply the migration locally
supabase db push

# 4. Test your changes
# Run your application and verify the changes work

# 5. Generate updated TypeScript types
supabase gen types typescript --local > types/supabase.ts
```

**Committing Changes:**

```bash
# 1. Add migration files to git
git add supabase/migrations/

# 2. Add any updated TypeScript types
git add types/supabase.ts

# 3. Commit your changes
git commit -m "Add new feature: description"
```

### 6.2 TypeScript Integration

**Generate Types:**

```bash
# Generate TypeScript types from your database schema
supabase gen types typescript --local > types/supabase.ts
```

**Use Types in Your Code:**

```typescript
import { Database } from '../types/supabase';

type User = Database['public']['Tables']['users']['Row'];
type Message = Database['public']['Tables']['messages']['Row'];
type NewMessage = Database['public']['Tables']['messages']['Insert'];
```

### 6.3 Testing Strategy

**Database Testing:**

```sql
-- Create test data
INSERT INTO users (id, email, display_name) VALUES
    ('test-user-1', 'test1@example.com', 'Test User 1'),
    ('test-user-2', 'test2@example.com', 'Test User 2');

-- Test RLS policies
SET role test_user_1;
SELECT * FROM messages; -- Should only see user's messages
```

**Integration Testing:**

```javascript
// Test real-time subscriptions
const testRealtime = async () => {
    const subscription = supabase
        .channel('test-channel')
        .on('postgres_changes', {
            event: 'INSERT',
            schema: 'public',
            table: 'messages'
        }, (payload) => {
            console.log('Received:', payload);
        })
        .subscribe();

    // Insert test data
    await supabase.from('messages').insert({
        content: 'Test message',
        sender_id: 'test-user-1'
    });
};
```

## Part 7: Troubleshooting Guide

### 7.1 Common Issues

**Supabase Won't Start:**

```bash
# Check if Docker is running
docker ps

# Check if ports are available
lsof -i :54321
lsof -i :54322
lsof -i :54323

# Reset Supabase
supabase stop
supabase start
```

**Database Connection Issues:**

```bash
# Check database status
supabase db status

# Check if database is responsive
psql -h localhost -p 54322 -U postgres -d postgres -c "SELECT 1"

# Check migration status
supabase db status
```

**Authentication Issues:**

```bash
# Check auth configuration
supabase status

# Verify JWT secret
echo $JWT_SECRET

# Check user table
psql -h localhost -p 54322 -U postgres -d postgres -c "SELECT * FROM auth.users"
```

### 7.2 Performance Issues

**Slow Queries:**

```sql
-- Enable query logging
ALTER DATABASE postgres SET log_statement = 'all';

-- Check slow queries
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY total_time DESC;

-- Add indexes for common queries
CREATE INDEX idx_messages_created_at ON messages(created_at);
```

**Real-time Performance:**

```javascript
// Limit subscription scope
const subscription = supabase
    .channel('specific-channel')
    .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'messages',
        filter: `location_id=eq.${currentRoom}` // Specific filter
    }, handleMessage)
    .subscribe();
```

### 7.3 Migration Issues

**Failed Migration:**

```bash
# Check migration status
supabase db status

# Rollback last migration (if needed)
supabase db reset

# Apply migrations one by one
supabase db push --debug
```

**Schema Conflicts:**

```sql
-- Check for conflicts
SELECT * FROM pg_stat_user_tables WHERE schemaname = 'public';

-- Drop conflicting objects if safe
DROP TABLE IF EXISTS old_table CASCADE;
```

### 7.4 Real-time Issues

**Subscriptions Not Working:**

```javascript
// Check connection status
const subscription = supabase
    .channel('test-channel')
    .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'messages'
    }, (payload) => {
        console.log('Received:', payload);
    })
    .subscribe((status) => {
        console.log('Subscription status:', status);
    });
```

**Enable Table for Real-time:**

```sql
-- Ensure table is published for real-time
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
```

## Part 8: Advanced Topics

### 8.1 Custom Functions

**Creating Database Functions:**

```sql
-- Function to get messages in a location
CREATE OR REPLACE FUNCTION get_location_messages(location_uuid UUID)
RETURNS TABLE(
    id UUID,
    content TEXT,
    sender_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id,
        m.content,
        u.display_name as sender_name,
        m.created_at
    FROM messages m
    JOIN users u ON m.sender_id = u.id
    WHERE m.location_id = location_uuid
    ORDER BY m.created_at DESC
    LIMIT 50;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 8.2 Edge Functions

**Creating Edge Functions:**

```bash
# Create a new edge function
supabase functions create send-notification

# Deploy the function
supabase functions deploy send-notification
```

**Example Edge Function:**

```javascript
// supabase/functions/send-notification/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
    const supabase = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    const { userId, message } = await req.json();
    
    // Custom notification logic
    const { data, error } = await supabase
        .from('notifications')
        .insert({
            user_id: userId,
            message: message,
            created_at: new Date().toISOString()
        });

    return new Response(JSON.stringify({ success: !error }), {
        headers: { 'Content-Type': 'application/json' }
    });
});
```

### 8.3 Storage Integration

**File Storage Setup:**

```javascript
// Upload file to Supabase Storage
const uploadFile = async (file, bucket = 'avatars') => {
    const fileName = `${Date.now()}-${file.name}`;
    
    const { data, error } = await supabase.storage
        .from(bucket)
        .upload(fileName, file);
    
    if (error) throw error;
    
    // Get public URL
    const { data: { publicUrl } } = supabase.storage
        .from(bucket)
        .getPublicUrl(fileName);
    
    return publicUrl;
};
```

## Part 9: Security Best Practices

### 9.1 Environment Security

**Secure Environment Variables:**

```bash
# Never commit these to version control
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore

# Use different keys for different environments
# Development: weaker keys OK
# Production: strong, random keys required
```

### 9.2 Database Security

**RLS Policy Examples:**

```sql
-- Users can only modify their own records
CREATE POLICY "Users can update their own profile"
ON users FOR UPDATE
USING (auth.uid() = id);

-- Messages are visible based on location
CREATE POLICY "Messages visible in user's location"
ON messages FOR SELECT
USING (
    location_id IN (
        SELECT location_id FROM users WHERE id = auth.uid()
    )
);

-- Prevent unauthorized data access
CREATE POLICY "Admins can access all data"
ON sensitive_table FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM users
        WHERE id = auth.uid()
        AND role = 'admin'
    )
);
```

### 9.3 API Security

**Rate Limiting:**

```javascript
// In your API middleware
const rateLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP'
});

app.use('/api', rateLimiter);
```

**Input Validation:**

```javascript
// Validate all inputs
const validateMessage = (req, res, next) => {
    const { content, location_id } = req.body;
    
    if (!content || content.length > 1000) {
        return res.status(400).json({ error: 'Invalid message content' });
    }
    
    if (!location_id || !isValidUUID(location_id)) {
        return res.status(400).json({ error: 'Invalid location ID' });
    }
    
    next();
};
```

## Part 10: Resources and References

### 10.1 Official Documentation

- **Supabase Documentation**: https://supabase.com/docs
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **Supabase CLI Reference**: https://supabase.com/docs/reference/cli

### 10.2 VibeMUSE-Specific Resources

- **Project Documentation**: `/docs/README.md`
- **API Documentation**: `/docs/api/README.md`
- **Development Plan**: `/docs/DEVELOPMENT_PLAN.md`
- **Database Configuration Reference**: `/database/SUPABASE_SETUP.md`

### 10.3 Community Resources

- **Supabase Discord**: https://discord.supabase.com
- **Supabase GitHub**: https://github.com/supabase/supabase
- **PostgreSQL Community**: https://www.postgresql.org/community/

### 10.4 Development Tools

- **Supabase Studio**: http://localhost:54323 (local development)
- **pgAdmin**: PostgreSQL administration tool
- **PostgREST**: Auto-generated REST API
- **Realtime**: WebSocket subscriptions

## Conclusion

This guide provides a comprehensive foundation for working with Supabase in the VibeMUSE project. As you become more comfortable with these concepts, you'll be able to leverage Supabase's full power to build scalable, real-time applications.

Remember to:
- Start with local development
- Use migrations for all schema changes
- Implement proper Row Level Security
- Test real-time features thoroughly
- Follow security best practices
- Monitor performance in production

For project-specific questions or issues, refer to the main VibeMUSE documentation or create an issue in the project repository.