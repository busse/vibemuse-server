# VibeMUSE Modernization Architecture

## Architecture Overview

This document details the technical architecture for modernizing TinyMUSE into a contemporary web-based system while preserving all original functionality.

## Current vs. Target Architecture

### Current Architecture (TinyMUSE)
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   TCP Clients   │    │   TCP Clients   │    │   TCP Clients   │
│   (Telnet)      │    │   (Telnet)      │    │   (Telnet)      │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │    TinyMUSE Server        │
                    │   (Single C Process)      │
                    └─────────────┬─────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │   Text Database File      │
                    │  (Custom Format)          │
                    └───────────────────────────┘
```

### Target Architecture (VibeMUSE)
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Clients   │    │  Mobile Clients │    │  Python Scripts│
│ (React/TypeScript)│    │   (React Native)│    │   (Admin Tools) │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │ HTTP/WebSocket
                    ┌─────────────┴─────────────┐
                    │   API Gateway/Load Balancer│
                    └─────────────┬─────────────┘
                                 │
          ┌──────────────────────┼──────────────────────┐
          │                      │                      │
┌─────────┴───────┐    ┌─────────┴───────┐    ┌─────────┴───────┐
│  Auth Service   │    │  Game Service   │    │  Chat Service   │
│   (Node.js)     │    │   (Node.js)     │    │   (Node.js)     │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │    Supabase Platform      │
                    │  (PostgreSQL + Real-time) │
                    └───────────────────────────┘
```

## Core Technology Stack

### Backend Services
- **Runtime**: Node.js 18+ with TypeScript
- **Framework**: Express.js or Fastify for HTTP APIs
- **WebSocket**: Socket.IO for real-time communication
- **Authentication**: JWT tokens + session cookies
- **Validation**: Zod or Joi for request validation
- **ORM**: Prisma or Drizzle for database operations

### Database Layer
- **Primary Database**: Supabase (PostgreSQL 15+)
- **Real-time**: Supabase Real-time subscriptions
- **Caching**: Redis for session storage and frequently accessed data
- **Search**: PostgreSQL full-text search + optional Elasticsearch
- **Backup**: Automated daily backups with point-in-time recovery

### Frontend Stack
- **Framework**: React 18+ with TypeScript
- **Build Tool**: Vite for development and building
- **State Management**: Zustand or Redux Toolkit
- **UI Components**: Tailwind CSS + Headless UI or similar
- **Real-time**: Socket.IO client for WebSocket connections
- **Testing**: Jest + React Testing Library

### Infrastructure
- **Hosting**: Vercel (frontend) + Railway/Render (backend)
- **CDN**: Vercel Edge Network or Cloudflare
- **Monitoring**: Sentry for error tracking, Datadog for metrics
- **CI/CD**: GitHub Actions
- **Documentation**: Storybook for components, OpenAPI for APIs

## Database Schema Design

### Core Tables Structure

#### Users Table
```sql
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
  current_location UUID REFERENCES virtual_objects(id),
  profile JSONB DEFAULT '{}'
);
```

#### Virtual Objects Table
```sql
CREATE TABLE virtual_objects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  object_type object_type_enum NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  owner_id UUID REFERENCES users(id),
  location_id UUID REFERENCES virtual_objects(id),
  zone_id UUID REFERENCES virtual_objects(id),
  flags TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  object_data JSONB DEFAULT '{}'
);
```

#### Attributes Table
```sql
CREATE TABLE attributes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  object_id UUID REFERENCES virtual_objects(id),
  name VARCHAR(255) NOT NULL,
  value TEXT,
  flags TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(object_id, name)
);
```

#### Messages Table
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID REFERENCES users(id),
  recipient_id UUID REFERENCES users(id),
  room_id UUID REFERENCES virtual_objects(id),
  channel_id UUID REFERENCES channels(id),
  message_type message_type_enum NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB DEFAULT '{}'
);
```

### Enums and Types
```sql
CREATE TYPE user_class_enum AS ENUM (
  'guest', 'visitor', 'group', 'citizen', 'pcitizen',
  'guide', 'official', 'builder', 'admin', 'director'
);

CREATE TYPE object_type_enum AS ENUM (
  'room', 'thing', 'exit', 'player'
);

CREATE TYPE message_type_enum AS ENUM (
  'say', 'pose', 'page', 'mail', 'channel', 'announce'
);
```

## API Design Patterns

### RESTful Resource Structure
```
/api/v1/
├── auth/
│   ├── login (POST)
│   ├── logout (POST)
│   ├── register (POST)
│   ├── refresh (POST)
│   └── me (GET)
├── users/
│   ├── / (GET, POST)
│   ├── /{id} (GET, PATCH, DELETE)
│   ├── /{id}/profile (GET, PATCH)
│   └── /{id}/powers (GET, PATCH)
├── objects/
│   ├── / (GET, POST)
│   ├── /{id} (GET, PATCH, DELETE)
│   ├── /{id}/attributes (GET, POST)
│   └── /{id}/attributes/{name} (GET, PATCH, DELETE)
├── rooms/
│   ├── / (GET, POST)
│   ├── /{id} (GET, PATCH, DELETE)
│   ├── /{id}/contents (GET)
│   └── /{id}/exits (GET)
├── communication/
│   ├── say (POST)
│   ├── pose (POST)
│   ├── page (POST)
│   └── channels/ (GET, POST)
└── admin/
    ├── users/ (GET, POST, PATCH, DELETE)
    ├── system/stats (GET)
    └── maintenance/ (POST)
```

### WebSocket Event Structure
```typescript
interface WebSocketEvent {
  type: string;
  data: any;
  timestamp: string;
  userId?: string;
  roomId?: string;
}

// Example events
interface SayEvent extends WebSocketEvent {
  type: 'say';
  data: {
    userId: string;
    username: string;
    message: string;
    roomId: string;
  };
}

interface MovementEvent extends WebSocketEvent {
  type: 'movement';
  data: {
    userId: string;
    username: string;
    fromRoom: string;
    toRoom: string;
    direction?: string;
  };
}
```

## Real-time Communication Architecture

### WebSocket Connection Management
```typescript
class WebSocketManager {
  private connections: Map<string, WebSocket> = new Map();
  private roomSubscriptions: Map<string, Set<string>> = new Map();
  
  async handleConnection(socket: WebSocket, userId: string) {
    this.connections.set(userId, socket);
    await this.subscribeToUserRooms(userId);
  }
  
  async broadcastToRoom(roomId: string, event: WebSocketEvent) {
    const subscribers = this.roomSubscriptions.get(roomId) || new Set();
    for (const userId of subscribers) {
      const socket = this.connections.get(userId);
      if (socket && socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify(event));
      }
    }
  }
}
```

### Message Distribution Patterns
1. **Room-based Broadcasting**: Messages sent to all users in a room
2. **Direct Messaging**: Private messages between users
3. **Channel Broadcasting**: Messages to channel subscribers
4. **System Announcements**: Server-wide notifications

## Security Implementation

### Authentication Flow
```typescript
// JWT Token Structure
interface JWTPayload {
  userId: string;
  username: string;
  userClass: string;
  powers: string[];
  exp: number;
  iat: number;
}

// Session Management
interface Session {
  userId: string;
  sessionId: string;
  createdAt: Date;
  lastActivity: Date;
  ipAddress: string;
  userAgent: string;
}
```

### Permission System
```typescript
class PermissionManager {
  static hasPermission(user: User, action: string, target?: any): boolean {
    // Check user class permissions
    if (this.checkClassPermission(user.userClass, action)) {
      return true;
    }
    
    // Check specific powers
    if (user.powers.includes(this.getRequiredPower(action))) {
      return true;
    }
    
    // Check object-specific permissions
    if (target && this.checkObjectPermission(user, action, target)) {
      return true;
    }
    
    return false;
  }
}
```

## Data Migration Strategy

### Migration Tools Architecture
```typescript
class MigrationManager {
  async migrateTinyMUSEDatabase(filePath: string) {
    const parser = new TinyMUSEParser();
    const data = await parser.parse(filePath);
    
    // Migrate in specific order to maintain references
    await this.migrateUsers(data.users);
    await this.migrateRooms(data.rooms);
    await this.migrateObjects(data.objects);
    await this.migrateExits(data.exits);
    await this.migrateAttributes(data.attributes);
    await this.migrateMessages(data.messages);
  }
}
```

### Data Transformation Patterns
1. **Object ID Mapping**: Convert TinyMUSE dbref to UUID
2. **Attribute Conversion**: Transform custom attributes to JSON
3. **Permission Migration**: Map powers to new system
4. **Relationship Preservation**: Maintain parent-child relationships

## Performance Optimization

### Caching Strategy
```typescript
interface CacheStrategy {
  // User sessions and authentication
  userSessions: 'redis'; // 24 hour TTL
  
  // Frequently accessed objects
  rooms: 'redis'; // 1 hour TTL
  userProfiles: 'redis'; // 30 minute TTL
  
  // Database query results
  objectQueries: 'postgresql'; // Query-level caching
  
  // Real-time presence
  onlineUsers: 'redis'; // 5 minute TTL
}
```

### Database Optimization
- **Indexes**: Critical paths (user lookups, room contents, message history)
- **Partitioning**: Messages table by date for performance
- **Connection Pooling**: Optimized connection management
- **Query Optimization**: Efficient joins and aggregations

## Monitoring and Observability

### Metrics Collection
```typescript
interface SystemMetrics {
  // Performance metrics
  apiResponseTime: number;
  websocketLatency: number;
  databaseQueryTime: number;
  
  // Business metrics
  concurrentUsers: number;
  messagesPerSecond: number;
  objectCreationRate: number;
  
  // System health
  memoryUsage: number;
  cpuUsage: number;
  databaseConnections: number;
}
```

### Logging Strategy
- **Structured Logging**: JSON format for log aggregation
- **Log Levels**: DEBUG, INFO, WARN, ERROR, FATAL
- **Audit Logging**: Track all administrative actions
- **Performance Logging**: Monitor slow queries and operations

## Deployment Architecture

### Production Environment
```yaml
# docker-compose.yml
version: '3.8'
services:
  api:
    image: vibemuse-api:latest
    replicas: 3
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - api
```

### Scaling Considerations
- **Horizontal Scaling**: Multiple API instances behind load balancer
- **Database Scaling**: Read replicas for heavy read operations
- **WebSocket Scaling**: Redis pub/sub for multi-instance WebSocket coordination
- **CDN**: Static asset delivery optimization

## Quality Assurance

### Testing Strategy
```typescript
describe('API Integration Tests', () => {
  describe('Authentication', () => {
    it('should authenticate user with valid credentials');
    it('should reject invalid credentials');
    it('should handle session expiration');
  });
  
  describe('Game Mechanics', () => {
    it('should handle user movement between rooms');
    it('should broadcast messages to room occupants');
    it('should enforce object permissions');
  });
});
```

### Test Coverage Requirements
- **Unit Tests**: 90%+ coverage for business logic
- **Integration Tests**: All API endpoints and WebSocket events
- **End-to-End Tests**: Critical user journeys
- **Performance Tests**: Load testing with realistic user scenarios

## Conclusion

This modernization architecture provides a robust foundation for transforming TinyMUSE into a contemporary web application while preserving all original functionality. The design emphasizes scalability, security, and maintainability while ensuring a smooth migration path from the legacy system.

The architecture supports both immediate needs and future expansion, with clear separation of concerns and modern development practices throughout the stack.