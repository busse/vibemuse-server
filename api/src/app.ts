import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { env, SECURITY_CONFIG } from './config/env';
import { sanitizeInput, validateContentType, validateRequestSize } from './middleware/validation';
import { setupErrorHandling } from './middleware/error';

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: SECURITY_CONFIG.websocket.cors,
  maxHttpBufferSize: 1e6, // 1MB
  connectionStateRecovery: {
    maxDisconnectionDuration: 2 * 60 * 1000, // 2 minutes
    skipMiddlewares: true,
  }
});

// Security middleware
app.use(helmet(SECURITY_CONFIG.helmet));
app.use(cors({
  origin: SECURITY_CONFIG.cors.origin,
  credentials: SECURITY_CONFIG.cors.credentials,
  methods: [...SECURITY_CONFIG.cors.methods],
  allowedHeaders: [...SECURITY_CONFIG.cors.allowedHeaders],
  exposedHeaders: [...SECURITY_CONFIG.cors.exposedHeaders],
}));
app.use(compression());

// Rate limiting
const limiter = rateLimit(SECURITY_CONFIG.rateLimiting);
app.use('/api/', limiter);

// Logging
app.use(morgan('combined'));

// Request parsing with security
app.use(validateRequestSize());
app.use(validateContentType());
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// Input sanitization
app.use(sanitizeInput);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
    environment: env.NODE_ENV
  });
});

// API routes
app.get('/api/v1/test', (req, res) => {
  res.json({
    message: 'VibeMUSE API is working!',
    timestamp: new Date().toISOString(),
    supabase: {
      url: env.SUPABASE_URL,
      configured: !!(env.SUPABASE_URL && env.SUPABASE_ANON_KEY)
    },
    security: {
      rateLimit: {
        windowMs: SECURITY_CONFIG.rateLimiting.windowMs,
        max: SECURITY_CONFIG.rateLimiting.max
      },
      cors: SECURITY_CONFIG.cors.origin
    }
  });
});

// WebSocket connection handling with security
const connectedUsers = new Map<string, { userId?: string; connectedAt: Date }>();

io.on('connection', (socket) => {
  const connectionInfo: { userId?: string; connectedAt: Date } = {
    connectedAt: new Date(),
    userId: undefined
  };
  
  connectedUsers.set(socket.id, connectionInfo);
  
  // Connection limit check
  if (connectedUsers.size > SECURITY_CONFIG.websocket.maxConnections) {
    socket.emit('error', {
      code: 'MAX_CONNECTIONS_REACHED',
      message: 'Maximum connections reached'
    });
    socket.disconnect();
    return;
  }
  
  console.log('User connected:', socket.id);
  
  // Authentication handler
  socket.on('authenticate', (data) => {
    // TODO: Implement proper JWT token verification for WebSocket
    // For now, just log the authentication attempt
    console.log('Authentication attempt:', data);
    
    // Simulate authentication
    if (data.token) {
      connectionInfo.userId = data.userId;
      socket.emit('authenticated', { success: true });
    } else {
      socket.emit('authentication_error', { message: 'Invalid token' });
    }
  });
  
  socket.on('disconnect', () => {
    connectedUsers.delete(socket.id);
    console.log('User disconnected:', socket.id);
  });
  
  // Test event with validation
  socket.on('test', (data) => {
    // Basic input validation
    if (!data || typeof data !== 'object') {
      socket.emit('error', {
        code: 'INVALID_DATA',
        message: 'Invalid data format'
      });
      return;
    }
    
    socket.emit('test_response', {
      message: 'Test received',
      data,
      timestamp: new Date().toISOString()
    });
  });
  
  // Heartbeat mechanism
  const heartbeatInterval = setInterval(() => {
    socket.emit('heartbeat', { timestamp: new Date().toISOString() });
  }, SECURITY_CONFIG.websocket.heartbeatInterval);
  
  socket.on('disconnect', () => {
    clearInterval(heartbeatInterval);
  });
});

// Error handling
setupErrorHandling(app);

export { app, server, io };
export default server;