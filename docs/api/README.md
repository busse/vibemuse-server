# VibeMUSE API Documentation

This directory contains the OpenAPI 3.0 specification for the VibeMUSE RESTful API, a modernized port of the classic TinyMUSE server functionality.

## Overview

VibeMUSE provides a comprehensive REST API that enables modern web and mobile clients to interact with a multi-user simulated environment (MUSE) while preserving the core functionality and user experience of the original TinyMUSE.

## API Structure

The API is organized into the following main service areas:

### 🔐 Authentication & Session Management
- **Path**: `/auth/*`
- **File**: `paths/auth.yaml`
- **Features**: User login, logout, registration, session management

### 👥 User Management
- **Path**: `/users/*`
- **File**: `paths/users.yaml`
- **Features**: User profiles, permissions, powers, online status

### 🏗️ World Management
- **Path**: `/objects/*`, `/rooms/*`
- **Files**: `paths/objects.yaml`, `paths/rooms.yaml`
- **Features**: Virtual world objects, rooms, exits, attributes

### 💬 Communication
- **Path**: `/messages/*`, `/mail/*`, `/channels/*`
- **Files**: `paths/communication.yaml`, `paths/mail.yaml`, `paths/channels.yaml`
- **Features**: Real-time messaging, mail system, chat channels

### 🚶 Movement & Navigation
- **Path**: `/movement/*`
- **File**: `paths/movement.yaml`
- **Features**: Player movement, teleportation, following

### 🎮 Game Actions
- **Path**: `/actions/*`
- **File**: `paths/actions.yaml`
- **Features**: Object interactions, examination, inventory management

### 🛠️ Building & Creation
- **Path**: `/building/*`
- **File**: `paths/building.yaml`
- **Features**: World building, object creation, room construction

### ⚙️ Administration
- **Path**: `/admin/*`
- **File**: `paths/admin.yaml`
- **Features**: Server administration, user management, system maintenance

### 📊 System Information
- **Path**: `/system/*`
- **File**: `paths/system.yaml`
- **Features**: Server status, health monitoring, version information

## File Structure

```
docs/api/
├── openapi.yaml           # Main OpenAPI specification
├── README.md             # This documentation
├── schemas/
│   └── common.yaml       # Shared data schemas
└── paths/
    ├── auth.yaml         # Authentication endpoints
    ├── users.yaml        # User management endpoints
    ├── objects.yaml      # Object management endpoints
    ├── rooms.yaml        # Room management endpoints
    ├── communication.yaml # Communication endpoints
    ├── mail.yaml         # Mail system endpoints
    ├── channels.yaml     # Channel system endpoints
    ├── movement.yaml     # Movement endpoints
    ├── actions.yaml      # Game action endpoints
    ├── building.yaml     # Building endpoints
    ├── admin.yaml        # Administration endpoints
    └── system.yaml       # System information endpoints
```

## Key Features

### 🔄 RESTful Design
- Standard HTTP methods (GET, POST, PATCH, DELETE)
- Resource-based URL structure
- Consistent response formats
- Proper HTTP status codes

### 🔒 Security
- JWT-based authentication
- Session-based authentication (cookies)
- Role-based access control
- Granular permission system

### 📄 Rich Data Models
- Comprehensive object system (rooms, things, exits, players)
- Flexible attribute system
- Hierarchical user classes and powers
- Complex communication features

### 🎯 Original Feature Preservation
- All core TinyMUSE functionality preserved
- Command equivalents mapped to REST endpoints
- Traditional permission system maintained
- Compatible with existing game mechanics

## Authentication

The API supports two authentication methods:

1. **JWT Bearer Token**
   ```
   Authorization: Bearer <jwt_token>
   ```

2. **Session Cookie**
   ```
   Cookie: sessionId=<session_id>
   ```

## Response Format

All API responses follow a consistent structure:

### Success Response
```json
{
  "success": true,
  "data": { /* response data */ },
  "message": "Optional success message",
  "timestamp": "2024-12-12T15:57:00Z"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": { /* additional error details */ }
  },
  "timestamp": "2024-12-12T15:57:00Z"
}
```

## Core Object Types

### User
Represents a player in the virtual world with authentication, permissions, and profile information.

### VirtualObject
Base type for all objects in the virtual world (rooms, things, exits, players).

### Room
Specialized object representing locations where players can gather.

### Exit
Specialized object representing connections between rooms.

### Message
Represents communication between users (say, page, mail, etc.).

### Channel
Represents chat channels for group communication.

### Attribute
Flexible property system for customizing object behavior.

## Permission System

The API implements a hierarchical permission system:

### User Classes
- **Guest**: Limited access, cannot create objects
- **Visitor**: Basic exploration capabilities
- **Group**: Group membership functionality
- **Citizen**: Standard user privileges
- **PCitizen**: Premium citizen features
- **Guide**: Helper/mentor capabilities
- **Official**: Administrative assistance
- **Builder**: Object creation and modification
- **Admin**: Full system administration
- **Director**: Ultimate system control

### Powers
Fine-grained permissions for specific actions:
- `POW_ANNOUNCE`: Server-wide announcements
- `POW_BOOT`: Disconnect other users
- `POW_BROADCAST`: Send messages to all users
- `POW_EXAMINE`: Examine any object
- And 40+ additional powers

## Usage Examples

### Authentication
```bash
# Login
curl -X POST /api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "Gandalf", "password": "youshallnotpass"}'

# Get current user
curl -X GET /api/v1/auth/me \
  -H "Authorization: Bearer <token>"
```

### World Interaction
```bash
# Get room details
curl -X GET /api/v1/rooms/12345 \
  -H "Authorization: Bearer <token>"

# Say something in current room
curl -X POST /api/v1/messages/say \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello everyone!"}'

# Move north
curl -X POST /api/v1/movement/go \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"direction": "north"}'
```

### Building
```bash
# Create a new room
curl -X POST /api/v1/building/dig \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Ancient Library",
    "description": "A vast library filled with ancient tomes and scrolls",
    "flags": ["LINK_OK", "ENTER_OK"]
  }'
```

## Development Tools

### OpenAPI Validation
The specification can be validated using standard OpenAPI tools:

```bash
# Using swagger-codegen
swagger-codegen validate -i openapi.yaml

# Using redoc-cli
redoc-cli validate openapi.yaml
```

### Documentation Generation
Generate interactive documentation:

```bash
# Generate HTML documentation
redoc-cli build openapi.yaml --output api-docs.html

# Serve interactive documentation
redoc-cli serve openapi.yaml
```

### Code Generation
Generate client libraries:

```bash
# JavaScript/TypeScript client
swagger-codegen generate -i openapi.yaml -l typescript-axios -o client-js

# Python client
swagger-codegen generate -i openapi.yaml -l python -o client-python

# Java client
swagger-codegen generate -i openapi.yaml -l java -o client-java
```

## Version History

### v1.0.0 (Current)
- Initial API specification
- Complete TinyMUSE functionality coverage
- Authentication and authorization
- All core game mechanics
- Administrative tools

## Contributing

When contributing to the API specification:

1. Follow OpenAPI 3.0 standards
2. Maintain consistency with existing patterns
3. Include comprehensive examples
4. Document all error conditions
5. Preserve original TinyMUSE functionality
6. Update this README for structural changes

## Related Documentation

- [Software Architecture](../software-architecture.md)
- [Server Architecture](../server-architecture.md)
- [Features](../features.md)
- [Potential Issues](../potential-issues.md)

## License

This API specification is part of the VibeMUSE project and is licensed under the MIT License.