import { server } from './app';
import dotenv from 'dotenv';

// Load environment variables from system environment only  
// In production/CI environments, environment variables are provided by the system
dotenv.config();

const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`🚀 VibeMUSE API Server running on port ${PORT}`);
  console.log(`📊 Health check: http://0.0.0.0:${PORT}/health`);
  console.log(`🔍 Test endpoint: http://0.0.0.0:${PORT}/api/v1/test`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📡 WebSocket enabled`);
  console.log(`🗄️ Supabase URL: ${process.env.SUPABASE_URL || 'Not configured'}`);
  console.log(`📝 Logs: ${process.env.LOG_LEVEL || 'debug'} level`);
});