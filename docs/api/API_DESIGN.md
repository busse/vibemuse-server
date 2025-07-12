# VibeMUSE API Design Document

## Overview

This document describes the design and implementation of RESTful APIs for VibeMUSE, a modernized port of the classic TinyMUSE server. The API design preserves all core functionality of the original 1990s C-based server while providing a modern, web-friendly interface.

## Design Philosophy

### 1. Functionality Preservation
- **Complete Feature Coverage**: All TinyMUSE features are accessible via REST endpoints
- **Permission System**: Original hierarchical user classes and powers are maintained
- **Game Mechanics**: Traditional MUD/MUSE interactions preserved
- **Backward Compatibility**: API design allows for future telnet protocol support

### 2. Modern Web Standards
- **RESTful Architecture**: Resource-based URLs with standard HTTP methods
- **JSON-First**: All data exchange uses JSON format
- **OpenAPI 3.0**: Comprehensive API specification for documentation and tooling
- **Standard Authentication**: JWT tokens and session-based authentication

### 3. Developer Experience
- **Consistent Patterns**: Uniform response formats and error handling
- **Comprehensive Documentation**: Detailed OpenAPI specification with examples
- **Client Generation**: Support for automatic client library generation
- **Interactive Documentation**: Browsable API documentation

## API Architecture

### Service Domains

The API is organized into logical service domains that correspond to TinyMUSE's core functionality:

1. **Authentication & Session Management** (`/auth/*`)
2. **User Management** (`/users/*`)
3. **World Management** (`/objects/*`, `/rooms/*`)
4. **Communication** (`/messages/*`, `/mail/*`, `/channels/*`)
5. **Movement & Navigation** (`/movement/*`)
6. **Game Actions** (`/actions/*`)
7. **Building & Creation** (`/building/*`)
8. **Administration** (`/admin/*`)
9. **System Information** (`/system/*`)

### Resource Model

#### Core Resources
- **Users**: Player accounts with authentication, permissions, and profile data
- **Objects**: Virtual world entities (rooms, things, exits, players)
- **Messages**: Communication between users (various types)
- **Channels**: Group communication channels
- **Attributes**: Flexible property system for objects

#### Relationships
- **Ownership**: Users own objects they create
- **Location**: Objects exist within other objects (containment)
- **Connections**: Exits link rooms together
- **Permissions**: Users have classes and powers that control access

### API Patterns

#### Request/Response Format
All API endpoints follow consistent patterns:

```json
// Success Response
{
  "success": true,
  "data": { /* resource data */ },
  "message": "Optional message",
  "timestamp": "2024-12-12T15:57:00Z"
}

// Error Response
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": { /* additional context */ }
  },
  "timestamp": "2024-12-12T15:57:00Z"
}
```

#### Pagination
List endpoints support pagination:
```json
{
  "success": true,
  "data": {
    "data": [ /* array of resources */ ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5,
      "hasNext": true,
      "hasPrevious": false
    }
  }
}
```

## Feature Mapping

### Command-to-Endpoint Mapping

| TinyMUSE Command | REST Endpoint | HTTP Method | Description |
|------------------|---------------|-------------|-------------|
| `connect <user> <password>` | `/auth/login` | POST | User authentication |
| `create <user> <password>` | `/auth/register` | POST | User registration |
| `WHO` | `/users/online` | GET | List online users |
| `look <object>` | `/objects/{id}` | GET | Examine object |
| `"<message>` | `/messages/say` | POST | Say message |
| `:<action>` | `/messages/pose` | POST | Pose action |
| `page <user>=<message>` | `/messages/page` | POST | Page user |
| `go <direction>` | `/movement/go` | POST | Move through exit |
| `home` | `/movement/home` | POST | Go to home location |
| `get <object>` | `/actions/get` | POST | Pick up object |
| `drop <object>` | `/actions/drop` | POST | Drop object |
| `@create <name>` | `/building/create` | POST | Create object |
| `@dig <name>` | `/building/dig` | POST | Create room |
| `@open <direction>` | `/building/open` | POST | Create exit |
| `@stats` | `/admin/stats` | GET | Server statistics |
| `@dump` | `/admin/database/dump` | POST | Database dump |

### Permission System

#### User Classes (Hierarchical)
```
Guest → Visitor → Group → Citizen → PCitizen → Guide → Official → Builder → Admin → Director
```

#### Powers (40+ individual permissions)
- `POW_ANNOUNCE`: Server-wide announcements
- `POW_BOOT`: Disconnect other users
- `POW_BROADCAST`: Send to all users
- `POW_EXAMINE`: Examine any object
- `POW_CHOWN`: Change object ownership
- And many more...

### Object System

#### Object Types
- **Room**: Locations where players can gather
- **Thing**: Objects that can be manipulated
- **Exit**: Connections between rooms
- **Player**: User avatars in the virtual world

#### Attributes
Flexible property system allowing:
- Custom object properties
- Inheritance from parent objects
- Type-specific behaviors
- Permission-controlled access

## Implementation Details

### Authentication
- **JWT Tokens**: Primary authentication method
- **Session Cookies**: Alternative for web browsers
- **Token Refresh**: Automatic token renewal
- **Permission Caching**: Efficient permission checking

### Data Models
- **Comprehensive Schemas**: Detailed OpenAPI data models
- **Validation**: Input validation on all endpoints
- **Relationships**: Proper foreign key relationships
- **Extensibility**: Support for future enhancements

### Error Handling
- **Standard HTTP Codes**: Proper status code usage
- **Detailed Messages**: Clear error descriptions
- **Context Information**: Additional error details
- **Logging**: Comprehensive error logging

## API Specification

### Files Structure
```
docs/api/
├── openapi.yaml           # Main OpenAPI specification
├── README.md             # API documentation
├── API_DESIGN.md         # This design document
├── schemas/
│   └── common.yaml       # Shared data schemas
└── paths/
    ├── auth.yaml         # Authentication endpoints
    ├── users.yaml        # User management
    ├── objects.yaml      # Object management
    ├── rooms.yaml        # Room management
    ├── communication.yaml # Communication
    ├── mail.yaml         # Mail system
    ├── channels.yaml     # Chat channels
    ├── movement.yaml     # Player movement
    ├── actions.yaml      # Game actions
    ├── building.yaml     # World building
    ├── admin.yaml        # Administration
    └── system.yaml       # System information
```

### Validation
All API specifications are validated for:
- **YAML Syntax**: Proper YAML formatting
- **OpenAPI Compliance**: Valid OpenAPI 3.0 structure
- **Schema Consistency**: Consistent data models
- **Reference Integrity**: Valid $ref references

## Usage Scenarios

### Web Client Integration
```javascript
// Login user
const response = await fetch('/api/v1/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ username: 'Gandalf', password: 'secret' })
});

// Get current room
const room = await fetch('/api/v1/rooms/12345', {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

### Mobile App Integration
```swift
// Swift iOS client
class VibeMUSEClient {
    func login(username: String, password: String) async throws -> LoginResponse {
        // Generated client code from OpenAPI spec
    }
}
```

### Third-Party Integration
```python
# Python client
from vibemuse_client import VibeMUSEClient

client = VibeMUSEClient(api_key="your_api_key")
users = client.users.list_online()
```

## Future Enhancements

### Real-Time Features
- **WebSocket Support**: Real-time message delivery
- **Event Streaming**: Live updates for room changes
- **Push Notifications**: Mobile app notifications

### Advanced Features
- **GraphQL Support**: Alternative query language
- **Rate Limiting**: API usage throttling
- **Caching**: Response caching for performance
- **Monitoring**: API usage analytics

### Integration Options
- **Webhook Support**: Event notifications
- **OAuth Providers**: Third-party authentication
- **SSO Integration**: Single sign-on support
- **API Gateway**: Centralized API management

## Development Workflow

### API Development
1. Design endpoints in OpenAPI specification
2. Validate specification syntax and structure
3. Generate client libraries for testing
4. Implement server-side endpoints
5. Test with generated clients
6. Deploy and monitor

### Documentation Maintenance
1. Update OpenAPI specification
2. Regenerate documentation
3. Update client libraries
4. Notify API consumers
5. Version management

## Conclusion

The VibeMUSE API design successfully modernizes the classic TinyMUSE server while preserving all core functionality. The comprehensive OpenAPI specification provides a solid foundation for building modern web and mobile clients, enabling the classic MUD/MUSE experience to reach new audiences in the modern web era.

The API design balances backward compatibility with modern web standards, ensuring that both existing users and new developers can effectively interact with the VibeMUSE platform.