-- VibeMUSE Initial Seed Data
-- Created: 2024-07-13
-- This file contains initial data for the VibeMUSE system

-- Insert initial channels
INSERT INTO channels (id, name, description, is_public, settings) VALUES
  (uuid_generate_v4(), 'ooc', 'Out of Character discussion channel', true, '{"color": "#3B82F6", "max_history": 100}'),
  (uuid_generate_v4(), 'newbie', 'Help channel for new users', true, '{"color": "#10B981", "max_history": 50}'),
  (uuid_generate_v4(), 'admin', 'Administrative channel', false, '{"color": "#EF4444", "max_history": 200}'),
  (uuid_generate_v4(), 'building', 'World building discussion', true, '{"color": "#F59E0B", "max_history": 100}');

-- Create initial world objects
-- The Void (root room)
INSERT INTO virtual_objects (id, object_type, name, description, owner_id, location_id, zone_id, flags, object_data) VALUES
  (uuid_generate_v4(), 'room', 'The Void', 'You are floating in an endless void of darkness. This is the root of all reality in VibeMUSE.', null, null, null, '{"no_cleanup", "permanent"}', '{"exits": [], "coordinates": {"x": 0, "y": 0, "z": 0}}');

-- Central Plaza (main starting room)
INSERT INTO virtual_objects (id, object_type, name, description, owner_id, location_id, zone_id, flags, object_data) VALUES
  (uuid_generate_v4(), 'room', 'Central Plaza', 'A bustling central plaza with fountains and benches. This is where new users typically start their journey. Paths lead off in all directions to various areas of the world.', null, null, null, '{"no_cleanup", "permanent", "public"}', '{"exits": [], "coordinates": {"x": 10, "y": 10, "z": 0}}');

-- Create some initial attributes for demonstration
-- Note: object_id would need to be populated with actual UUIDs from the objects above
-- This is a placeholder structure showing how attributes work

-- Initial system configuration
INSERT INTO attributes (object_id, name, value, flags) VALUES
  ((SELECT id FROM virtual_objects WHERE name = 'The Void'), 'system_root', 'true', '{"system", "permanent"}'),
  ((SELECT id FROM virtual_objects WHERE name = 'Central Plaza'), 'welcome_message', 'Welcome to VibeMUSE! Type ''help'' for assistance.', '{"system"}'),
  ((SELECT id FROM virtual_objects WHERE name = 'Central Plaza'), 'player_limit', '50', '{"system"}');

-- System announcement
INSERT INTO messages (id, sender_id, recipient_id, room_id, channel_id, message_type, content, metadata) VALUES
  (uuid_generate_v4(), null, null, null, (SELECT id FROM channels WHERE name = 'ooc'), 'channel', 'VibeMUSE system initialized. Welcome to the modernized TinyMUSE experience!', '{"system": true, "priority": "high"}');