# VibeMUSE Supabase Configuration Guide

This document provides comprehensive information about the Supabase setup and configuration for VibeMUSE.

## Overview

VibeMUSE uses Supabase as its primary database and backend-as-a-service platform, providing:

- **PostgreSQL Database**: Modern relational database with full SQL support
- **Real-time Subscriptions**: WebSocket-based real-time updates
- **Authentication**: JWT-based authentication with custom claims
- **Row Level Security**: Fine-grained access control
- **Storage**: File storage capabilities for future media features
- **Edge Functions**: Server-side logic execution

## Project Structure

```
supabase/
├── config.toml              # Supabase project configuration
├── migrations/              # Database schema migrations
│   └── 20240713000001_initial_schema.sql
├── seed.sql                 # Initial data seeding
└── .gitignore              # Git ignore patterns
```

## Database Schema

### Core Tables

1. **users** - User accounts and profiles
   - Authentication and authorization
   - User classes (guest, visitor, citizen, admin, etc.)
   - Online status and location tracking
   - Custom powers and permissions

2. **virtual_objects** - All game objects
   - Rooms, things, exits, and players
   - Hierarchical object relationships
   - Object flags and properties
   - Extensible JSON data storage

3. **attributes** - Object attributes
   - Key-value attribute storage
   - Attribute flags and permissions
   - Object-specific properties

4. **messages** - All communication
   - Say, pose, page, mail, channels
   - Message history and persistence
   - Real-time delivery support

5. **channels** - Communication channels
   - Public and private channels
   - Channel settings and permissions
   - Real-time channel management

6. **channel_subscriptions** - User channel memberships
   - Channel subscription management
   - User aliases and preferences

7. **sessions** - User session management
   - Session tokens and expiration
   - Activity tracking
   - Security metadata

### Enums

- **user_class_enum**: User privilege levels
- **object_type_enum**: Object type classification
- **message_type_enum**: Communication type classification

## Row Level Security (RLS)

### Security Policies

All tables have RLS enabled with appropriate policies:

#### Users Table
- Users can view and update their own profiles
- Public user data is readable by all authenticated users
- Private data is restricted to the owner

#### Virtual Objects Table
- Objects are viewable by all users
- Modification restricted to object owners
- Special permissions for admin users

#### Messages Table
- Users can view messages they sent or received
- Channel messages follow channel permissions
- Message creation restricted to authenticated users

#### Sessions Table
- Users can only access their own sessions
- Session management restricted to owner

### Security Best Practices

1. **Environment Variables**: All sensitive keys stored in environment variables
2. **Service Role Key**: Used only for server-side operations
3. **Anon Key**: Used for client-side operations with RLS enforcement
4. **JWT Tokens**: Short-lived tokens with automatic refresh
5. **Backup Encryption**: Production backups should be encrypted

## Real-time Configuration

### Enabled Tables

Real-time subscriptions are configured for:

- `users` - User status and profile changes
- `virtual_objects` - Object updates and movements
- `messages` - Live chat and communication
- `channels` - Channel management changes
- `channel_subscriptions` - Subscription updates

### WebSocket Events

The system supports real-time events for:

- User login/logout notifications
- Object movement and updates
- Live chat messages
- Channel activity
- System announcements

## Authentication Setup

### JWT Configuration

- **Expiry**: 1 hour (3600 seconds)
- **Refresh**: Automatic token rotation enabled
- **Claims**: Custom user class and powers support
- **Security**: Minimum 6-character passwords

### User Classes

The system supports hierarchical user classes:

1. **guest** - Temporary anonymous access
2. **visitor** - Basic registered users
3. **group** - Group accounts
4. **citizen** - Trusted users
5. **pcitizen** - Premium citizens
6. **guide** - Helper users
7. **official** - Official representatives
8. **builder** - World building permissions
9. **admin** - Administrative access
10. **director** - Full system control

### Rate Limiting

Protection against abuse:

- **Email**: 2 per hour
- **SMS**: 30 per hour
- **Anonymous**: 30 per hour
- **Token Refresh**: 150 per 5 minutes
- **Sign-ins**: 30 per 5 minutes
- **Verifications**: 30 per 5 minutes

## Development Environment

### Local Development

1. **Start Supabase:**
   ```bash
   ./scripts/db-manager.sh start
   ```

2. **Access Services:**
   - API: http://127.0.0.1:54321
   - Studio: http://127.0.0.1:54323
   - Database: postgresql://postgres:postgres@127.0.0.1:54322/postgres

3. **Run Migrations:**
   ```bash
   ./scripts/db-manager.sh migrate
   ```

4. **Generate Types:**
   ```bash
   ./scripts/db-manager.sh generate-types
   ```

### Environment Variables

Required environment variables:

```env
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

## Production Deployment

### Cloud Setup

1. **Create Supabase Project:**
   - Visit https://supabase.com
   - Create new project
   - Note project URL and keys

2. **Configure Database:**
   - Run production migrations
   - Set up proper RLS policies
   - Configure backup schedules

3. **Environment Setup:**
   - Set production environment variables
   - Configure CORS origins
   - Set up SSL certificates

### Migration Strategy

1. **Development to Production:**
   - Export schema from development
   - Apply migrations to production
   - Verify RLS policies
   - Test real-time functionality

2. **Backup Strategy:**
   - Daily automated backups
   - Weekly archive backups
   - Pre-deployment safety backups
   - Off-site backup storage

## Monitoring and Maintenance

### Health Checks

Monitor these key metrics:

- Database connection pool status
- Real-time subscription health
- Authentication success rates
- Query performance metrics
- Storage usage and limits

### Maintenance Tasks

Regular maintenance includes:

- **Database Optimization**: Analyze and vacuum tables
- **Index Maintenance**: Monitor and optimize indexes
- **Log Management**: Rotate and archive logs
- **Security Updates**: Keep Supabase CLI updated
- **Backup Verification**: Test backup restoration

## Troubleshooting

### Common Issues

1. **Connection Failures:**
   - Check Docker status
   - Verify port availability (54321-54324)
   - Check environment variables

2. **Migration Errors:**
   - Verify schema syntax
   - Check for conflicting constraints
   - Review migration order

3. **Real-time Issues:**
   - Check WebSocket connections
   - Verify RLS policies
   - Monitor subscription limits

4. **Performance Issues:**
   - Review query plans
   - Check index usage
   - Monitor connection pool

### Debug Commands

```bash
# Check Supabase status
./scripts/db-manager.sh status

# View Docker logs
docker logs supabase_db

# Test database connection
psql -h 127.0.0.1 -p 54322 -U postgres -d postgres

# Check real-time subscriptions
curl http://127.0.0.1:54321/rest/v1/users?select=*
```

## Security Considerations

### Data Protection

- **Encryption**: All data encrypted in transit and at rest
- **Access Control**: RLS policies enforce data access
- **Audit Logging**: All database changes are logged
- **Backup Security**: Production backups are encrypted

### Vulnerability Management

- **Dependencies**: Regular security updates
- **Policies**: Regular RLS policy reviews
- **Monitoring**: Security event monitoring
- **Testing**: Regular security testing

## Future Enhancements

### Planned Features

1. **Advanced Analytics**: Query performance analytics
2. **Enhanced Monitoring**: Custom metrics and alerting
3. **Edge Functions**: Complex server-side logic
4. **Storage Integration**: Media file handling
5. **Advanced Auth**: Multi-factor authentication
6. **Scaling**: Read replicas and connection pooling

### Integration Opportunities

- **Redis**: Session and cache storage
- **Elasticsearch**: Advanced search capabilities
- **CloudFlare**: CDN and edge computing
- **Monitoring**: Prometheus and Grafana integration

---

This configuration provides a solid foundation for the VibeMUSE modernization project, with proper security, scalability, and maintainability considerations built in from the start.