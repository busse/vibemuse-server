-- VibeMUSE Initial Database Schema
-- Created: 2024-07-13
-- Phase 1: Foundation & Database Setup

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
  
  -- Constraints
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

-- Add foreign key constraint for users.current_location
ALTER TABLE users ADD CONSTRAINT fk_users_current_location 
  FOREIGN KEY (current_location) REFERENCES virtual_objects(id);

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

-- Row Level Security (RLS) - Enable for all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE virtual_objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE attributes ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE channel_subscriptions ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies
CREATE POLICY "Users can view their own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view public user data" ON users
  FOR SELECT USING (true);

-- Virtual objects policies
CREATE POLICY "Users can view objects they own" ON virtual_objects
  FOR SELECT USING (auth.uid() = owner_id);

CREATE POLICY "Users can modify objects they own" ON virtual_objects
  FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Users can view public objects" ON virtual_objects
  FOR SELECT USING (true);

-- Messages policies
CREATE POLICY "Users can view messages they sent" ON messages
  FOR SELECT USING (auth.uid() = sender_id);

CREATE POLICY "Users can view messages sent to them" ON messages
  FOR SELECT USING (auth.uid() = recipient_id);

CREATE POLICY "Users can insert messages" ON messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- Sessions policies
CREATE POLICY "Users can view their own sessions" ON sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own sessions" ON sessions
  FOR UPDATE USING (auth.uid() = user_id);

-- Channel policies
CREATE POLICY "Users can view public channels" ON channels
  FOR SELECT USING (is_public = true);

CREATE POLICY "Users can view channel subscriptions" ON channel_subscriptions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their channel subscriptions" ON channel_subscriptions
  FOR ALL USING (auth.uid() = user_id);

-- Update triggers for timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_virtual_objects_updated_at BEFORE UPDATE ON virtual_objects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_attributes_updated_at BEFORE UPDATE ON attributes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Real-time configuration
-- Enable realtime for key tables
ALTER PUBLICATION supabase_realtime ADD TABLE users;
ALTER PUBLICATION supabase_realtime ADD TABLE virtual_objects;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE channels;
ALTER PUBLICATION supabase_realtime ADD TABLE channel_subscriptions;