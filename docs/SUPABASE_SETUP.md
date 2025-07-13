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
4. **Developer Experience**: Excellent tooling and cloud development support
5. **Scalability**: Handles growth from development to production
6. **Open Source**: Can be self-hosted and customized as needed
7. **Cloud-First**: Seamless integration with cloud-based development tools like Lovable

## Prerequisites

Before starting, ensure you have:

- **Node.js** 18+ and npm
- **Supabase Account** (free tier available at [supabase.com](https://supabase.com))
- **Git** (for version control)
- **Basic SQL knowledge** (CREATE TABLE, SELECT, INSERT, etc.)
- **Understanding of relational databases** (primary keys, foreign keys, indexes)

> **Note**: This guide uses cloud-based Supabase instances for both development and production. This approach is required for VibeMUSE as the main client application will be developed using Lovable, which only supports hosted Supabase cloud services.

## Part 1: Cloud Development Setup

### 1.1 Create Supabase Projects

VibeMUSE uses separate Supabase projects for development and production environments. This approach allows for safe testing and development without affecting the production database.

#### Create Development Project

1. **Sign up/Login to Supabase**
   - Go to [supabase.com](https://supabase.com)
   - Create an account or log in
   - Access your dashboard

2. **Create Development Project**
   ```bash
   # Project details
   Name: vibemuse-dev
   Database Password: [secure password]
   Region: [choose closest to your location]
   Plan: Free (sufficient for development)
   ```

3. **Note Project Details**
   - Project URL: `https://your-project-id.supabase.co`
   - API Keys: Available in Settings > API
   - Database URL: Available in Settings > Database

#### Create Production Project

1. **Create Production Project**
   ```bash
   # Project details
   Name: vibemuse-prod
   Database Password: [secure password]
   Region: [choose closest to your users]
   Plan: Pro (recommended for production)
   ```

2. **Configure Production Settings**
   - Enable database backups
   - Set up custom domain (optional)
   - Configure SSL certificates

### 1.2 Install Supabase CLI

The Supabase CLI is essential for managing migrations and syncing between projects:

```bash
# Install Supabase CLI globally
npm install -g supabase

# Verify installation
supabase --version
```

### 1.3 Link Projects to CLI

Link your local development to the cloud projects:

```bash
# Navigate to project root
cd /path/to/vibemuse-server

# Link to development project
supabase link --project-ref your-dev-project-id
# Follow the prompts to authenticate and link

# You can switch between projects using:
supabase link --project-ref your-prod-project-id
```

### 1.4 Environment Configuration

Create environment files for both development and production:

#### Development Environment (.env.local)

```env
# Supabase Development Configuration
SUPABASE_URL=https://your-dev-project-id.supabase.co
SUPABASE_ANON_KEY=your-dev-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-dev-service-role-key-here

# Database Configuration
DATABASE_URL=postgresql://postgres:[password]@db.your-dev-project-id.supabase.co:5432/postgres

# Application Configuration
JWT_SECRET=your-super-secret-jwt-key-here
NODE_ENV=development
PORT=3000
```

#### Production Environment (.env.production)

```env
# Supabase Production Configuration
SUPABASE_URL=https://your-prod-project-id.supabase.co
SUPABASE_ANON_KEY=your-prod-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-prod-service-role-key-here

# Database Configuration
DATABASE_URL=postgresql://postgres:[password]@db.your-prod-project-id.supabase.co:5432/postgres

# Application Configuration
JWT_SECRET=your-super-secret-jwt-key-here
NODE_ENV=production
PORT=3000
```

### 1.5 Finding Your Project Credentials

To get your project credentials:

1. **Go to your Supabase project dashboard**
2. **Navigate to Settings > API**
3. **Copy the following values:**
   - Project URL → `SUPABASE_URL`
   - `anon` `public` key → `SUPABASE_ANON_KEY`
   - `service_role` `secret` key → `SUPABASE_SERVICE_ROLE_KEY`

4. **For Database URL:**
   - Go to Settings > Database
   - Copy the connection string
   - Replace `[YOUR-PASSWORD]` with your actual database password

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

Supabase uses a migration-based approach to manage database schema changes. With cloud instances, you'll push migrations to your development project first, then to production:

```bash
# Ensure you're linked to your development project
supabase link --project-ref your-dev-project-id

# View current migration status
supabase db remote status

# Create a new migration
supabase migration create "add_new_feature"

# Apply migrations to development
supabase db push

# Switch to production and apply migrations
supabase link --project-ref your-prod-project-id
supabase db push
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
4. **Testing**: Always test migrations on development project first
5. **Environment Order**: Apply to development first, then production

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

**Cloud Migration Workflow:**

```bash
# 1. Create migration
supabase migration create "add_user_preferences"

# 2. Edit the migration file with your SQL

# 3. Apply to development project
supabase link --project-ref your-dev-project-id
supabase db push

# 4. Test in development environment

# 5. Apply to production project
supabase link --project-ref your-prod-project-id
supabase db push
```

### 2.4 Database Management with Cloud Instances

Working with cloud instances requires a different approach than local development:

**Development Environment Management:**

```bash
# Switch to development project
supabase link --project-ref your-dev-project-id

# Check current schema status
supabase db remote status

# Apply migrations to development
supabase db push

# Generate TypeScript types from development
supabase gen types typescript > types/supabase.ts

# Create a backup of development data
supabase db dump > backups/dev-backup-$(date +%Y%m%d-%H%M%S).sql
```

**Production Environment Management:**

```bash
# Switch to production project
supabase link --project-ref your-prod-project-id

# Check current schema status
supabase db remote status

# Apply migrations to production
supabase db push

# Generate TypeScript types from production
supabase gen types typescript > types/supabase-prod.ts

# Create a backup of production data
supabase db dump > backups/prod-backup-$(date +%Y%m%d-%H%M%S).sql
```

**Database Management Scripts:**

VibeMUSE provides convenient database management scripts that work with cloud instances:

```bash
# Switch to development environment
./scripts/db-manager.sh dev

# Switch to production environment
./scripts/db-manager.sh prod

# Apply migrations to current environment
./scripts/db-manager.sh migrate

# Create backup of current environment
./scripts/db-manager.sh backup
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
site_url = "https://your-domain.com"  # or http://localhost:3000 for local testing
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

### 5.1 Production Environment Management

Since VibeMUSE uses cloud instances for both development and production, deployment becomes a matter of managing separate projects rather than migrating from local to cloud.

**Production Project Setup:**

Your production project should already be created from Part 1. If not:

1. Go to [supabase.com](https://supabase.com)
2. Create a new project named `vibemuse-prod`
3. Choose a region close to your users
4. Set a strong database password
5. Enable database backups
6. Configure custom domain (optional)

**Production Environment Variables:**

```env
# Production Supabase Configuration
SUPABASE_URL=https://your-prod-project-id.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-production-service-role-key

# Production Database
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.your-prod-project-id.supabase.co:5432/postgres

# Production Settings
NODE_ENV=production
JWT_SECRET=your-production-jwt-secret
```

### 5.2 Deployment Process

**Schema Deployment:**

```bash
# Switch to production project
supabase link --project-ref your-prod-project-id

# Check current migration status
supabase db remote status

# Apply migrations to production
supabase db push

# Generate production TypeScript types
supabase gen types typescript > types/supabase-prod.ts

# Deploy any edge functions
supabase functions deploy
```

**Environment-Specific Deployment:**

```bash
# Development testing
supabase link --project-ref your-dev-project-id
npm run test

# Production deployment
supabase link --project-ref your-prod-project-id
supabase db push
npm run build:production
# Deploy to your hosting platform
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
- Compare metrics between dev and prod environments

**Backup Strategy:**

```bash
# Create production backup
supabase link --project-ref your-prod-project-id
supabase db dump > backups/prod-backup-$(date +%Y%m%d-%H%M%S).sql

# Create development backup
supabase link --project-ref your-dev-project-id
supabase db dump > backups/dev-backup-$(date +%Y%m%d-%H%M%S).sql

# Restore from backup to development environment
# Note: This restores to your cloud development instance
supabase db reset --linked-project your-dev-project-id
psql "postgresql://postgres:[password]@db.your-dev-project-id.supabase.co:5432/postgres" < backup.sql
```

## Part 6: Development Workflow

### 6.1 Daily Development Workflow

**Starting Development:**

```bash
# 1. Ensure you're linked to your development project
supabase link --project-ref your-dev-project-id

# 2. Check and apply any new migrations
supabase db remote status
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

# 3. Apply the migration to development
supabase db push

# 4. Test your changes
# Run your application and verify the changes work

# 5. Generate updated TypeScript types
supabase gen types typescript > types/supabase.ts
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

**Deploying to Production:**

```bash
# 1. Switch to production project
supabase link --project-ref your-prod-project-id

# 2. Apply migrations to production
supabase db push

# 3. Generate production TypeScript types
supabase gen types typescript > types/supabase-prod.ts

# 4. Deploy your application code
# (Deploy to your hosting platform)
```

### 6.2 TypeScript Integration

**Generate Types:**

```bash
# Generate TypeScript types from your development database
supabase gen types typescript > types/supabase.ts

# Generate TypeScript types from your production database
supabase link --project-ref your-prod-project-id
supabase gen types typescript > types/supabase-prod.ts
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
**Connection Issues:**

```bash
# Check if you're linked to the correct project
supabase projects list
supabase link --project-ref your-project-id

# Test connection to your cloud instance
curl -H "apikey: your-anon-key" "https://your-project-id.supabase.co/rest/v1/"

# Check project status
supabase db remote status
```

**Database Connection Issues:**

```bash
# Check remote database status
supabase db remote status

# Test database connectivity
psql "postgresql://postgres:[password]@db.your-project-id.supabase.co:5432/postgres" -c "SELECT 1"

# Check migration status
supabase db remote status
```

**Authentication Issues:**

```bash
# Check project configuration
supabase projects list

# Verify environment variables
echo $SUPABASE_URL
echo $SUPABASE_ANON_KEY

# Check auth configuration in Supabase Dashboard
# Go to Authentication > Settings
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
supabase db remote status

# If migration failed, check the error logs
supabase db push --debug

# For development, you can recreate the project if needed
# (Only for development environment, never production)
```

**Schema Conflicts:**

```bash
# Check differences between local and remote
supabase db diff

# Check migration history
supabase db remote status

# If needed, reset development environment
# (Only for development, never production)
supabase link --project-ref your-dev-project-id
# Manually fix conflicts via Supabase Dashboard
```

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

- **Supabase Studio**: Access via your project dashboard at https://your-project-id.supabase.co
- **pgAdmin**: PostgreSQL administration tool
- **PostgREST**: Auto-generated REST API
- **Realtime**: WebSocket subscriptions

## Conclusion

This guide provides a comprehensive foundation for working with Supabase in the VibeMUSE project using cloud-based development and production environments. This cloud-first approach ensures compatibility with tools like Lovable while maintaining a professional development workflow.

Remember to:
- Use separate cloud instances for development and production
- Use migrations for all schema changes
- Test changes in development before applying to production
- Implement proper Row Level Security
- Test real-time features thoroughly
- Follow security best practices
- Monitor performance in both environments

The cloud-based approach provides several advantages:
- **Consistency**: Same environment for development and production
- **Collaboration**: Easy sharing of development environments
- **Tool Compatibility**: Works with cloud-based development tools
- **Scalability**: Easy to scale both development and production
- **Monitoring**: Built-in monitoring and analytics

For project-specific questions or issues, refer to the main VibeMUSE documentation or create an issue in the project repository.