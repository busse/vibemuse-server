# VibeMUSE Server - Phase 1 Implementation

## Overview

This is the implementation of Phase 1 of the VibeMUSE modernization project - Foundation & Database Setup. VibeMUSE is a modernization of the classic TinyMUSE server, transforming it into a modern web-based platform with RESTful APIs and real-time capabilities.

## Phase 1 Status

✅ **Completed Tasks:**
- [x] Supabase project initialization
- [x] Database schema design and implementation
- [x] Row Level Security (RLS) policies
- [x] Real-time subscriptions configuration
- [x] API project structure setup
- [x] Environment configuration
- [x] Development scripts and automation
- [x] Basic authentication setup
- [x] WebSocket foundation

## Project Structure

```
vibemuse-server/
├── api/                    # Node.js/TypeScript API server
│   ├── src/
│   │   ├── lib/           # Core libraries (Supabase client, etc.)
│   │   ├── routes/        # API route handlers
│   │   ├── middleware/    # Express middleware
│   │   ├── services/      # Business logic services
│   │   ├── types/         # TypeScript type definitions
│   │   └── utils/         # Utility functions
│   ├── dist/              # Compiled JavaScript (generated)
│   └── package.json
├── supabase/              # Supabase configuration
│   ├── config.toml        # Supabase project configuration
│   ├── migrations/        # Database migrations
│   └── seed.sql          # Initial database seed data
├── scripts/               # Development and deployment scripts
├── types/                 # Shared TypeScript types
├── database/             # Database documentation and schemas
├── docs/                 # Project documentation
├── .env.example          # Environment variables template
└── .env.local           # Local development configuration
```

## Prerequisites

- **Node.js** 18+ and npm
- **Docker** and Docker Compose
- **Git**

## Quick Start

1. **Clone and Setup:**
   ```bash
   git clone <repository-url>
   cd vibemuse-server
   ./scripts/setup-dev.sh
   ```

2. **Start Development Server:**
   ```bash
   cd api
   npm run dev
   ```

3. **Access Services:**
   - API Server: http://localhost:3000
   - Health Check: http://localhost:3000/health
   - Supabase Studio: http://localhost:54323

## Database Configuration

### Supabase Setup

The project uses Supabase as the primary database and backend-as-a-service platform:

- **Database**: PostgreSQL 17
- **Real-time**: WebSocket subscriptions enabled
- **Authentication**: JWT-based with custom claims
- **Row Level Security**: Enabled for all tables

### Database Schema

The database includes the following key tables:

- **users**: User accounts and profiles
- **virtual_objects**: Rooms, things, exits, and players
- **attributes**: Object attributes and properties
- **messages**: All communication (say, pose, page, mail, channels)
- **channels**: Communication channels
- **channel_subscriptions**: User channel memberships
- **sessions**: User session management

### Database Management

Use the provided database management script:

```bash
# Start Supabase locally
./scripts/db-manager.sh start

# Run migrations
./scripts/db-manager.sh migrate

# Generate TypeScript types
./scripts/db-manager.sh generate-types

# Create backup
./scripts/db-manager.sh backup

# Check status
./scripts/db-manager.sh status
```

## API Server

### Development Mode

```bash
cd api
npm run dev
```

### Production Build

```bash
cd api
npm run build
npm start
```

### Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm test` - Run tests
- `npm run lint` - Run linting
- `npm run type-check` - TypeScript type checking

## Environment Configuration

### Environment Variables

Copy `.env.example` to `.env.local` and configure:

```env
# Supabase Configuration
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Database
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Application
JWT_SECRET=your-jwt-secret
NODE_ENV=development
PORT=3000

# Frontend
FRONTEND_URL=http://localhost:5173
```

### Security Configuration

- **Row Level Security (RLS)**: Enabled for all tables
- **JWT Authentication**: Custom claims supported
- **CORS**: Configured for frontend access
- **Rate Limiting**: Configured for API endpoints

## Real-time Features

### WebSocket Configuration

The server includes WebSocket support for real-time features:

- **Connection Management**: Automatic connection handling
- **Event System**: Structured event handling
- **Channel Support**: Real-time channel communications
- **Presence System**: User online/offline tracking

### Real-time Tables

The following tables have real-time subscriptions enabled:

- `users` - User status and profile changes
- `virtual_objects` - Object updates and movements
- `messages` - Live chat and communication
- `channels` - Channel management
- `channel_subscriptions` - Subscription changes

## Testing

### Manual Testing

1. **Health Check:**
   ```bash
   curl http://localhost:3000/health
   ```

2. **API Test:**
   ```bash
   curl http://localhost:3000/api/v1/test
   ```

3. **WebSocket Test:**
   Use a WebSocket client to connect to `ws://localhost:3000`

### Automated Testing

```bash
cd api
npm test
```

## Backup and Recovery

### Automated Backups

Backups are automatically created using the database management script:

```bash
./scripts/db-manager.sh backup
```

### Recovery Procedures

1. **From Backup:**
   ```bash
   ./scripts/db-manager.sh restore backups/vibemuse_backup_YYYYMMDD_HHMMSS.sql
   ```

2. **Reset to Initial State:**
   ```bash
   ./scripts/db-manager.sh reset
   ```

## Security Considerations

- ✅ API keys properly secured through environment variables
- ✅ RLS policies prevent unauthorized access
- ✅ Database credentials encrypted and isolated
- ✅ Production environment separation configured
- ✅ Backup data would be encrypted (when using cloud storage)

## Development Guidelines

### Code Structure

- **Routes**: Handle HTTP requests and responses
- **Services**: Business logic and data manipulation
- **Middleware**: Authentication, validation, error handling
- **Types**: Shared TypeScript definitions
- **Utils**: Reusable utility functions

### Database Migrations

- All schema changes must be in migration files
- Use `./scripts/db-manager.sh migrate` to apply changes
- Never modify existing migration files
- Test migrations in development before applying to production

## Troubleshooting

### Common Issues

1. **Supabase Won't Start:**
   - Check Docker is running
   - Verify ports 54321-54324 are available
   - Check Docker has sufficient resources

2. **Database Connection Issues:**
   - Verify environment variables are set
   - Check Supabase is running (`./scripts/db-manager.sh status`)
   - Verify database URL format

3. **API Server Issues:**
   - Check Node.js version (must be 18+)
   - Verify all dependencies are installed
   - Check environment variables are loaded

### Logs

- **API Server**: Console output in development mode
- **Supabase**: Docker logs available through Docker Desktop
- **Database**: PostgreSQL logs through Supabase Studio

## Next Steps

Phase 1 is complete! The foundation is now ready for Phase 2 development:

- **Phase 2**: Core API Infrastructure (Authentication, User Management, Object System)
- **Phase 3**: Game Mechanics APIs (Communication, Movement, Navigation)
- **Phase 4**: World Building & Administration
- **Phase 5**: Advanced Features
- **Phase 6**: Frontend Development
- **Phase 7**: Testing & Polish

## Contributing

1. Follow the existing code structure and patterns
2. Add tests for new functionality
3. Update documentation for significant changes
4. Use TypeScript for type safety
5. Follow security best practices

## License

MIT License - see LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review the documentation in `/docs`
3. Check existing GitHub issues
4. Create a new issue with detailed information

---

**VibeMUSE** - Modernizing TinyMUSE for the web era.