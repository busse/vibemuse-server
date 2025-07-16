import { server } from './app';
import dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';

// Load environment variables - try local file first, fallback to system environment
const envPath = path.resolve(__dirname, '../../.env.local');
if (fs.existsSync(envPath)) {
  dotenv.config({ path: envPath });
} else {
  // In CI environments, environment variables are provided by the system
  // No need to load from file, just use process.env
  dotenv.config();
}

const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`🚀 VibeMUSE API Server running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🔍 Test endpoint: http://localhost:${PORT}/api/v1/test`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📡 WebSocket enabled`);
  console.log(`🗄️ Supabase URL: ${process.env.SUPABASE_URL || 'Not configured'}`);
  console.log(`📝 Logs: ${process.env.LOG_LEVEL || 'debug'} level`);
});