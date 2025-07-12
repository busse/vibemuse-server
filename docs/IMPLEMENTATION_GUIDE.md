# VibeMUSE Implementation Guide

## Getting Started

This guide provides practical steps to begin implementing the VibeMUSE modernization project. Follow these steps to establish the foundation for the development process.

## Phase 1: Foundation Setup (Weeks 1-4)

### Week 1: Environment Setup

#### 1. Development Environment
```bash
# Create project structure
mkdir vibemuse-modern
cd vibemuse-modern

# Initialize main directories
mkdir -p {api,frontend,scripts,docs,database}

# Initialize Node.js project
cd api
npm init -y
```

#### 2. Install Core Dependencies
```bash
# API Dependencies
npm install express cors helmet morgan compression
npm install jsonwebtoken bcryptjs zod
npm install @supabase/supabase-js prisma @prisma/client
npm install socket.io redis
npm install --save-dev @types/node @types/express typescript ts-node
npm install --save-dev jest @types/jest supertest nodemon

# Frontend Dependencies (in frontend directory)
cd ../frontend
npm create vite@latest . -- --template react-ts
npm install @supabase/supabase-js socket.io-client
npm install @tanstack/react-query zustand
npm install tailwindcss @headlessui/react
```

#### 3. Supabase Project Setup
```bash
# Install Supabase CLI
npm install -g @supabase/cli

# Initialize Supabase project
supabase init
supabase start

# Create database schema
supabase db diff --schema public
```

### Week 2: Database Schema Implementation

#### 1. Database Schema Creation
Create `/database/schema.sql`:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User classes enum
CREATE TYPE user_class_enum AS ENUM (
  'guest', 'visitor', 'group', 'citizen', 'pcitizen',
  'guide', 'official', 'builder', 'admin', 'director'
);

-- Object types enum
CREATE TYPE object_type_enum AS ENUM (
  'room', 'thing', 'exit', 'player'
);

-- Message types enum
CREATE TYPE message_type_enum AS ENUM (
  'say', 'pose', 'page', 'mail', 'channel', 'announce'
);

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
  profile JSONB DEFAULT '{}',
  
  -- Indexes
  CONSTRAINT users_username_length CHECK (length(username) >= 3),
  CONSTRAINT users_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Virtual objects table
CREATE TABLE virtual_objects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

-- Attributes table
CREATE TABLE attributes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  object_id UUID REFERENCES virtual_objects(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  value TEXT,
  flags TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(object_id, name)
);

-- Messages table
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID REFERENCES users(id),
  recipient_id UUID REFERENCES users(id),
  room_id UUID REFERENCES virtual_objects(id),
  channel_id UUID,
  message_type message_type_enum NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB DEFAULT '{}'
);

-- Channels table
CREATE TABLE channels (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  is_public BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  settings JSONB DEFAULT '{}'
);

-- Channel subscriptions table
CREATE TABLE channel_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  channel_id UUID REFERENCES channels(id) ON DELETE CASCADE,
  subscribed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  alias VARCHAR(50),
  UNIQUE(user_id, channel_id)
);

-- Sessions table
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  session_token VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT
);

-- Indexes for performance
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_online_status ON users(online_status);
CREATE INDEX idx_users_current_location ON users(current_location);

CREATE INDEX idx_virtual_objects_type ON virtual_objects(object_type);
CREATE INDEX idx_virtual_objects_owner ON virtual_objects(owner_id);
CREATE INDEX idx_virtual_objects_location ON virtual_objects(location_id);
CREATE INDEX idx_virtual_objects_zone ON virtual_objects(zone_id);

CREATE INDEX idx_attributes_object_id ON attributes(object_id);
CREATE INDEX idx_attributes_name ON attributes(name);

CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_recipient ON messages(recipient_id);
CREATE INDEX idx_messages_room ON messages(room_id);
CREATE INDEX idx_messages_channel ON messages(channel_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_messages_type ON messages(message_type);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_token ON sessions(session_token);
CREATE INDEX idx_sessions_expires_at ON sessions(expires_at);

-- Add foreign key constraint after table creation
ALTER TABLE users ADD CONSTRAINT fk_users_current_location 
  FOREIGN KEY (current_location) REFERENCES virtual_objects(id);

-- Row Level Security (RLS) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE virtual_objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE attributes ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies (to be refined)
CREATE POLICY "Users can view their own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id);
```

#### 2. Supabase Configuration
```bash
# Apply schema to Supabase
supabase db push

# Generate TypeScript types
supabase gen types typescript --local > types/supabase.ts
```

### Week 3: API Foundation

#### 1. Basic API Structure
Create `/api/src/app.ts`:

```typescript
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import { createServer } from 'http';
import { Server } from 'socket.io';

import { authRoutes } from './routes/auth';
import { userRoutes } from './routes/users';
import { objectRoutes } from './routes/objects';
import { communicationRoutes } from './routes/communication';
import { errorHandler } from './middleware/errorHandler';
import { setupWebSocket } from './websocket';

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL || "http://localhost:5173",
    credentials: true
  }
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || "http://localhost:5173",
  credentials: true
}));
app.use(compression());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/objects', objectRoutes);
app.use('/api/v1/communication', communicationRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Error handling
app.use(errorHandler);

// WebSocket setup
setupWebSocket(io);

export { app, server };
```

#### 2. Authentication System
Create `/api/src/routes/auth.ts`:

```typescript
import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { supabase } from '../lib/supabase';
import { validateRequest } from '../middleware/validation';

const router = Router();

// Validation schemas
const loginSchema = z.object({
  username: z.string().min(3).max(255),
  password: z.string().min(6).max(255)
});

const registerSchema = z.object({
  username: z.string().min(3).max(255),
  email: z.string().email().optional(),
  password: z.string().min(6).max(255)
});

// Login endpoint
router.post('/login', validateRequest(loginSchema), async (req, res) => {
  try {
    const { username, password } = req.body;

    // Find user
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('username', username)
      .single();

    if (error || !user) {
      return res.status(401).json({
        success: false,
        error: { code: 'INVALID_CREDENTIALS', message: 'Invalid username or password' }
      });
    }

    // Verify password
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      return res.status(401).json({
        success: false,
        error: { code: 'INVALID_CREDENTIALS', message: 'Invalid username or password' }
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        userId: user.id,
        username: user.username,
        userClass: user.user_class,
        powers: user.powers
      },
      process.env.JWT_SECRET!,
      { expiresIn: '24h' }
    );

    // Update last login
    await supabase
      .from('users')
      .update({ last_login: new Date().toISOString() })
      .eq('id', user.id);

    res.json({
      success: true,
      data: {
        token,
        user: {
          id: user.id,
          username: user.username,
          userClass: user.user_class,
          powers: user.powers
        }
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { code: 'SERVER_ERROR', message: 'Internal server error' }
    });
  }
});

// Register endpoint
router.post('/register', validateRequest(registerSchema), async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Check if user exists
    const { data: existingUser } = await supabase
      .from('users')
      .select('id')
      .eq('username', username)
      .single();

    if (existingUser) {
      return res.status(409).json({
        success: false,
        error: { code: 'USER_EXISTS', message: 'Username already exists' }
      });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 12);

    // Create user
    const { data: user, error } = await supabase
      .from('users')
      .insert({
        username,
        email,
        password_hash: passwordHash,
        user_class: 'visitor'
      })
      .select()
      .single();

    if (error) {
      return res.status(500).json({
        success: false,
        error: { code: 'CREATE_USER_FAILED', message: 'Failed to create user' }
      });
    }

    res.status(201).json({
      success: true,
      data: {
        user: {
          id: user.id,
          username: user.username,
          userClass: user.user_class
        }
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { code: 'SERVER_ERROR', message: 'Internal server error' }
    });
  }
});

export { router as authRoutes };
```

### Week 4: Migration Tools

#### 1. TinyMUSE Parser
Create `/scripts/migration/parser.py`:

```python
import re
import json
import uuid
from typing import Dict, List, Any

class TinyMUSEParser:
    def __init__(self):
        self.objects = {}
        self.users = {}
        self.attributes = {}
        self.current_object = None
        
    def parse_database(self, file_path: str) -> Dict[str, Any]:
        """Parse TinyMUSE database file"""
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # Split into object sections
        objects = re.split(r'\n(?=&\d+)', content)
        
        for obj_section in objects:
            if obj_section.strip():
                self.parse_object(obj_section)
        
        return {
            'objects': self.objects,
            'users': self.users,
            'attributes': self.attributes
        }
    
    def parse_object(self, obj_section: str):
        """Parse a single object section"""
        lines = obj_section.strip().split('\n')
        
        # Parse object header
        header_match = re.match(r'&(\d+)', lines[0])
        if not header_match:
            return
        
        obj_id = int(header_match.group(1))
        
        # Initialize object data
        obj_data = {
            'id': obj_id,
            'uuid': str(uuid.uuid4()),
            'name': '',
            'description': '',
            'location': -1,
            'zone': -1,
            'contents': -1,
            'exits': -1,
            'link': -1,
            'next': -1,
            'owner': -1,
            'flags': 0,
            'created_at': None,
            'modified_at': None,
            'attributes': {}
        }
        
        # Parse object properties
        line_idx = 1
        while line_idx < len(lines) and not lines[line_idx].startswith('>'):
            line = lines[line_idx].strip()
            
            if line_idx == 1:  # Name
                obj_data['name'] = line
            elif line_idx == 2:  # Location
                obj_data['location'] = self.parse_int(line)
            elif line_idx == 3:  # Zone
                obj_data['zone'] = self.parse_int(line)
            elif line_idx == 4:  # Contents
                obj_data['contents'] = self.parse_int(line)
            elif line_idx == 5:  # Exits
                obj_data['exits'] = self.parse_int(line)
            elif line_idx == 6:  # Link
                obj_data['link'] = self.parse_int(line)
            elif line_idx == 7:  # Next
                obj_data['next'] = self.parse_int(line)
            elif line_idx == 8:  # Owner
                obj_data['owner'] = self.parse_int(line)
            elif line_idx == 9:  # Flags
                obj_data['flags'] = self.parse_int(line)
            elif line_idx == 10:  # Created time
                obj_data['created_at'] = self.parse_timestamp(line)
            elif line_idx == 11:  # Modified time
                obj_data['modified_at'] = self.parse_timestamp(line)
            
            line_idx += 1
        
        # Parse attributes
        while line_idx < len(lines) and lines[line_idx].startswith('>'):
            attr_lines = []
            attr_lines.append(lines[line_idx])
            line_idx += 1
            
            # Get attribute ID and data
            while line_idx < len(lines) and not lines[line_idx].startswith('>') and lines[line_idx] != '<':
                attr_lines.append(lines[line_idx])
                line_idx += 1
            
            if attr_lines:
                self.parse_attribute(obj_data, attr_lines)
        
        # Determine object type and store
        obj_type = self.determine_object_type(obj_data['flags'])
        obj_data['object_type'] = obj_type
        
        if obj_type == 'player':
            self.users[obj_id] = obj_data
        else:
            self.objects[obj_id] = obj_data
    
    def parse_attribute(self, obj_data: Dict, attr_lines: List[str]):
        """Parse object attribute"""
        if not attr_lines:
            return
        
        # Parse attribute header
        header_match = re.match(r'>(\d+)', attr_lines[0])
        if not header_match:
            return
        
        attr_id = int(header_match.group(1))
        
        # Get attribute value
        if len(attr_lines) > 1:
            value = '\n'.join(attr_lines[1:])
        else:
            value = ''
        
        # Map attribute ID to name
        attr_name = self.get_attribute_name(attr_id)
        obj_data['attributes'][attr_name] = {
            'id': attr_id,
            'value': value,
            'flags': []
        }
    
    def determine_object_type(self, flags: int) -> str:
        """Determine object type from flags"""
        TYPE_ROOM = 0x1
        TYPE_THING = 0x2
        TYPE_EXIT = 0x4
        TYPE_PLAYER = 0x8
        
        if flags & TYPE_PLAYER:
            return 'player'
        elif flags & TYPE_ROOM:
            return 'room'
        elif flags & TYPE_EXIT:
            return 'exit'
        elif flags & TYPE_THING:
            return 'thing'
        else:
            return 'thing'  # Default
    
    def get_attribute_name(self, attr_id: int) -> str:
        """Map attribute ID to name"""
        attribute_map = {
            1: 'Osucc', 2: 'Ofail', 3: 'Fail', 4: 'Succ',
            5: 'Password', 6: 'Desc', 7: 'Sex', 8: 'Odrop',
            9: 'Drop', 10: 'Incoming', 11: 'Color', 12: 'Asucc',
            # Add more mappings as needed
        }
        return attribute_map.get(attr_id, f'attr_{attr_id}')
    
    def parse_int(self, value: str) -> int:
        """Parse integer value"""
        try:
            return int(value)
        except (ValueError, TypeError):
            return -1
    
    def parse_timestamp(self, value: str) -> str:
        """Parse timestamp value"""
        try:
            timestamp = int(value)
            if timestamp > 0:
                return datetime.fromtimestamp(timestamp).isoformat()
        except (ValueError, TypeError):
            pass
        return None

# Usage example
if __name__ == "__main__":
    parser = TinyMUSEParser()
    data = parser.parse_database("tinymuse.db")
    
    # Save parsed data
    with open("parsed_data.json", "w") as f:
        json.dump(data, f, indent=2, default=str)
```

#### 2. Database Migration Script
Create `/scripts/migration/migrate.py`:

```python
import json
import asyncio
from supabase import create_client, Client
import os
from datetime import datetime

class DatabaseMigrator:
    def __init__(self):
        self.supabase: Client = create_client(
            os.getenv('SUPABASE_URL'),
            os.getenv('SUPABASE_ANON_KEY')
        )
        
    async def migrate_data(self, parsed_data: dict):
        """Migrate parsed TinyMUSE data to Supabase"""
        print("Starting database migration...")
        
        # Migrate users first
        await self.migrate_users(parsed_data['users'])
        
        # Migrate objects
        await self.migrate_objects(parsed_data['objects'])
        
        # Migrate attributes
        await self.migrate_attributes(parsed_data)
        
        print("Migration completed successfully!")
    
    async def migrate_users(self, users: dict):
        """Migrate user objects"""
        print(f"Migrating {len(users)} users...")
        
        for user_id, user_data in users.items():
            try:
                # Prepare user data
                user_record = {
                    'username': user_data['name'],
                    'password_hash': user_data['attributes'].get('Password', {}).get('value', ''),
                    'user_class': self.map_user_class(user_data['flags']),
                    'powers': self.extract_powers(user_data),
                    'profile': {
                        'description': user_data['attributes'].get('Desc', {}).get('value', ''),
                        'sex': user_data['attributes'].get('Sex', {}).get('value', ''),
                        'legacy_id': user_id
                    }
                }
                
                # Insert user
                result = self.supabase.table('users').insert(user_record).execute()
                if result.data:
                    print(f"Migrated user: {user_data['name']}")
                
            except Exception as e:
                print(f"Error migrating user {user_data['name']}: {e}")
    
    async def migrate_objects(self, objects: dict):
        """Migrate virtual objects"""
        print(f"Migrating {len(objects)} objects...")
        
        for obj_id, obj_data in objects.items():
            try:
                # Prepare object data
                object_record = {
                    'object_type': obj_data['object_type'],
                    'name': obj_data['name'],
                    'description': obj_data['attributes'].get('Desc', {}).get('value', ''),
                    'flags': self.extract_flags(obj_data['flags']),
                    'object_data': {
                        'legacy_id': obj_id,
                        'location': obj_data['location'],
                        'zone': obj_data['zone'],
                        'contents': obj_data['contents'],
                        'exits': obj_data['exits'],
                        'link': obj_data['link']
                    }
                }
                
                # Insert object
                result = self.supabase.table('virtual_objects').insert(object_record).execute()
                if result.data:
                    print(f"Migrated object: {obj_data['name']}")
                
            except Exception as e:
                print(f"Error migrating object {obj_data['name']}: {e}")
    
    def map_user_class(self, flags: int) -> str:
        """Map TinyMUSE user class to new system"""
        # This is a simplified mapping - adjust based on actual flag values
        if flags & 0x1000:  # Example: WIZARD flag
            return 'admin'
        elif flags & 0x800:  # Example: BUILDER flag
            return 'builder'
        else:
            return 'visitor'
    
    def extract_powers(self, user_data: dict) -> list:
        """Extract user powers from TinyMUSE data"""
        powers = []
        # Extract powers based on flags and attributes
        # This is a simplified implementation
        return powers
    
    def extract_flags(self, flag_value: int) -> list:
        """Extract object flags from TinyMUSE flags"""
        flags = []
        # Map flag bits to flag names
        flag_map = {
            0x20: 'CHOWN_OK',
            0x40: 'DARK',
            0x100: 'STICKY',
            0x400: 'HAVEN',
            # Add more mappings
        }
        
        for bit, flag_name in flag_map.items():
            if flag_value & bit:
                flags.append(flag_name)
        
        return flags

# Usage
async def main():
    migrator = DatabaseMigrator()
    
    # Load parsed data
    with open('parsed_data.json', 'r') as f:
        data = json.load(f)
    
    await migrator.migrate_data(data)

if __name__ == "__main__":
    asyncio.run(main())
```

## Getting Started Checklist

### Prerequisites
- [ ] Node.js 18+ installed
- [ ] Python 3.9+ installed
- [ ] Git configured
- [ ] Supabase account created
- [ ] Code editor (VS Code recommended)

### Setup Steps
1. [ ] Clone repository and create project structure
2. [ ] Install dependencies (API and frontend)
3. [ ] Set up Supabase project
4. [ ] Create database schema
5. [ ] Implement basic API structure
6. [ ] Create migration tools
7. [ ] Set up development environment

### Environment Variables
Create `.env` file in `/api` directory:

```env
# Database
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
DATABASE_URL=your_database_url

# Authentication
JWT_SECRET=your_jwt_secret_key

# Application
NODE_ENV=development
PORT=3000
FRONTEND_URL=http://localhost:5173

# Redis (optional for caching)
REDIS_URL=redis://localhost:6379
```

### Development Commands
```bash
# API Development
cd api
npm run dev          # Start development server
npm run test         # Run tests
npm run build        # Build for production

# Frontend Development
cd frontend
npm run dev          # Start development server
npm run build        # Build for production
npm run preview      # Preview production build

# Database
supabase start       # Start local Supabase
supabase db push     # Push schema changes
supabase gen types   # Generate TypeScript types
```

### Next Steps
1. Implement authentication endpoints
2. Create user management APIs
3. Set up WebSocket communication
4. Build migration tools
5. Start frontend development

This implementation guide provides the foundation for beginning the VibeMUSE modernization project. Follow the phases outlined in the main development plan while using these practical implementation steps.