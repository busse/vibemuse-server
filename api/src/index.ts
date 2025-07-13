import { server } from './app';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: '../.env.local' });

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