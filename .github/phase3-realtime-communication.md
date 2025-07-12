---
title: "[Phase 3] Real-time Communication System"
labels: ["phase-3", "communication", "websocket", "critical"]
milestone: "Phase 3 - Game Mechanics APIs"
assignees: []
---

## Overview
Implement real-time communication system with WebSocket support for instant messaging, chat, and real-time interactions in VibeMUSE.

## User Story
As a **player**, I need real-time communication capabilities (say, pose, page, channels) that work instantly without page refreshes, so that I can interact naturally with other players in the game world.

## Acceptance Criteria
- [ ] WebSocket connection management implemented
- [ ] Say/pose command APIs with real-time delivery
- [ ] Room-based message distribution
- [ ] Private messaging (page) system
- [ ] Channel-based chat system
- [ ] Message history and persistence
- [ ] Real-time user presence indicators
- [ ] Message formatting and parsing
- [ ] Anti-spam and rate limiting

## Technical Details

### Communication Components
1. **WebSocket Management**
   - Connection establishment and maintenance
   - User authentication over WebSocket
   - Connection pooling and scaling
   - Graceful disconnection handling

2. **Message Distribution**
   - Room-based message broadcasting
   - Private message delivery
   - Channel subscription management
   - Message routing and filtering

3. **Message Types**
   - Say messages (room-wide)
   - Pose/emote messages
   - Page messages (private)
   - Channel messages
   - System announcements
   - Out-of-character (OOC) messages

## API Endpoints
```typescript
// WebSocket connection
WS     /api/ws                     # WebSocket connection endpoint

// Communication HTTP endpoints (for history/management)
GET    /api/communication/history/:roomId    # Get room message history
GET    /api/communication/pages/:userId      # Get private message history
POST   /api/communication/channels           # Create/join channel
DELETE /api/communication/channels/:id       # Leave channel
GET    /api/communication/channels/:id/history # Get channel history

// Message management endpoints
GET    /api/messages/:id           # Get specific message
PUT    /api/messages/:id           # Edit message (if allowed)
DELETE /api/messages/:id           # Delete message (if allowed)
POST   /api/messages/:id/report    # Report message
```

### WebSocket Message Protocol
```typescript
// WebSocket message structure
interface WebSocketMessage {
  type: MessageType;
  data: any;
  timestamp: Date;
  messageId: string;
  fromUser: string;
  toUser?: string;
  roomId?: string;
  channelId?: string;
}

// Message types
enum MessageType {
  // Outgoing (client to server)
  SAY = 'say',
  POSE = 'pose',
  PAGE = 'page',
  CHANNEL = 'channel',
  JOIN_ROOM = 'join_room',
  LEAVE_ROOM = 'leave_room',
  JOIN_CHANNEL = 'join_channel',
  LEAVE_CHANNEL = 'leave_channel',
  
  // Incoming (server to client)
  MESSAGE = 'message',
  USER_JOINED = 'user_joined',
  USER_LEFT = 'user_left',
  CHANNEL_MESSAGE = 'channel_message',
  SYSTEM_MESSAGE = 'system_message',
  ERROR = 'error'
}

// Say message data
interface SayMessageData {
  text: string;
  roomId: string;
  messageType: 'say' | 'pose' | 'ooc';
}

// Page message data
interface PageMessageData {
  text: string;
  toUserId: string;
  isPrivate: boolean;
}

// Channel message data
interface ChannelMessageData {
  text: string;
  channelId: string;
  channelName: string;
}
```

### WebSocket Service Implementation
```typescript
class CommunicationService {
  private connections: Map<string, WebSocket> = new Map();
  private roomSubscriptions: Map<string, Set<string>> = new Map();
  private channelSubscriptions: Map<string, Set<string>> = new Map();
  
  async handleConnection(ws: WebSocket, userId: string) {
    // Store connection
    this.connections.set(userId, ws);
    
    // Set up message handlers
    ws.on('message', (data) => this.handleMessage(userId, data));
    ws.on('close', () => this.handleDisconnection(userId));
    
    // Notify user's rooms of presence
    await this.notifyUserOnline(userId);
  }
  
  async handleMessage(userId: string, data: any) {
    const message = JSON.parse(data.toString());
    
    switch (message.type) {
      case MessageType.SAY:
        await this.handleSayMessage(userId, message.data);
        break;
      case MessageType.POSE:
        await this.handlePoseMessage(userId, message.data);
        break;
      case MessageType.PAGE:
        await this.handlePageMessage(userId, message.data);
        break;
      case MessageType.CHANNEL:
        await this.handleChannelMessage(userId, message.data);
        break;
      case MessageType.JOIN_ROOM:
        await this.handleJoinRoom(userId, message.data);
        break;
      case MessageType.LEAVE_ROOM:
        await this.handleLeaveRoom(userId, message.data);
        break;
    }
  }
  
  async handleSayMessage(userId: string, data: SayMessageData) {
    // Validate user is in room
    const user = await this.userService.getUser(userId);
    if (user.currentLocation !== data.roomId) {
      return this.sendError(userId, 'You are not in that room');
    }
    
    // Create message record
    const message = await this.messageService.createMessage({
      type: 'say',
      text: data.text,
      fromUserId: userId,
      roomId: data.roomId,
      messageType: data.messageType
    });
    
    // Broadcast to room
    await this.broadcastToRoom(data.roomId, {
      type: MessageType.MESSAGE,
      data: message
    });
  }
  
  async broadcastToRoom(roomId: string, message: any) {
    const subscribers = this.roomSubscriptions.get(roomId) || new Set();
    
    for (const userId of subscribers) {
      const ws = this.connections.get(userId);
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify(message));
      }
    }
  }
  
  async sendPrivateMessage(fromUserId: string, toUserId: string, message: any) {
    const ws = this.connections.get(toUserId);
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(message));
    } else {
      // Store for offline delivery
      await this.messageService.storeOfflineMessage(toUserId, message);
    }
  }
}
```

## Implementation Tasks
- [ ] **WebSocket Connection Management**
  - Connection establishment and authentication
  - Connection pooling and cleanup
  - Reconnection handling
  - User presence tracking

- [ ] **Message Broadcasting**
  - Room-based message distribution
  - Private message delivery
  - Channel subscription management
  - Message routing logic

- [ ] **Message Persistence**
  - Message history storage
  - Offline message delivery
  - Message search and filtering
  - Message archival

- [ ] **Real-time Features**
  - User presence indicators
  - Typing indicators
  - Message delivery confirmations
  - Real-time user lists

## Definition of Done
- [ ] WebSocket connection management working
- [ ] Real-time message delivery functional
- [ ] Room-based communication working
- [ ] Private messaging implemented
- [ ] Channel system operational
- [ ] Message history persistence working
- [ ] Anti-spam measures implemented
- [ ] Performance testing completed
- [ ] Integration tests passing

## Dependencies
- User management API must be completed
- Object management API must be implemented
- Database schema must support message persistence

## Estimated Effort
**2 weeks** (Week 9-10 of Phase 3)

## Performance Requirements
- [ ] Message delivery <100ms
- [ ] Support 1000+ concurrent connections
- [ ] Efficient message broadcasting
- [ ] Optimized database queries
- [ ] Memory-efficient connection management

## Security Requirements
- [ ] WebSocket authentication
- [ ] Message validation and sanitization
- [ ] Rate limiting per user
- [ ] Anti-spam measures
- [ ] Permission-based message access

## Testing Requirements
- [ ] Unit tests for message services
- [ ] Integration tests for WebSocket connections
- [ ] Performance tests for concurrent users
- [ ] Message delivery reliability tests
- [ ] Security tests for message validation

## Notes
- Critical for real-time game experience
- Must handle network disconnections gracefully
- Consider message delivery guarantees
- Implement efficient scaling for multiple servers