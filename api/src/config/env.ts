import { z } from 'zod';
import dotenv from 'dotenv';

// Load environment variables from system environment only
// In production/CI environments, environment variables are provided by the system
dotenv.config();

// Environment validation schema
const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().transform(Number).default(3000),
  
  // Database configuration
  SUPABASE_URL: z.string().url(),
  SUPABASE_ANON_KEY: z.string().min(1),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),
  DATABASE_URL: z.string().url(),
  
  // Security configuration
  JWT_SECRET: z.string().min(32),
  ENCRYPTION_KEY: z.string().min(32),
  
  // CORS configuration  
  FRONTEND_URL: z.string().url(),
  CORS_ORIGINS: z.string(),
  
  // Rate limiting
  RATE_LIMIT_WINDOW_MS: z.string().transform(Number).default(900000), // 15 minutes
  RATE_LIMIT_MAX_REQUESTS: z.string().transform(Number).default(100),
  
  // WebSocket configuration
  WS_HEARTBEAT_INTERVAL: z.string().transform(Number).default(30000),
  WS_MAX_CONNECTIONS: z.string().transform(Number).default(1000),
  
  // Logging
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  LOG_FILE: z.string().default('logs/vibemuse.log'),
  
  // Optional configurations
  OPENAI_API_KEY: z.string().optional(),
  REDIS_URL: z.string().url().optional(),
  EMAIL_FROM: z.string().email().optional(),
  EMAIL_HOST: z.string().optional(),
  EMAIL_PORT: z.string().transform(Number).optional(),
});

// Validate environment variables
export const validateEnv = (): z.infer<typeof envSchema> => {
  try {
    return envSchema.parse(process.env);
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.error('❌ Invalid environment configuration:');
      error.issues.forEach((err) => {
        console.error(`  - ${err.path.join('.')}: ${err.message}`);
      });
      process.exit(1);
    }
    throw error;
  }
};

// Lazy environment validation - only validate when accessed
let _env: z.infer<typeof envSchema> | null = null;

export const env = new Proxy({} as z.infer<typeof envSchema>, {
  get(target, prop): any {
    if (!_env) {
      _env = validateEnv();
    }
    return _env[prop as keyof typeof _env];
  }
});

// Security configuration
export const SECURITY_CONFIG = {
  bcryptRounds: 12,
  jwtExpiresIn: '24h',
  jwtRefreshExpiresIn: '7d',
  sessionTimeout: 24 * 60 * 60 * 1000, // 24 hours in milliseconds
  maxLoginAttempts: 5,
  lockoutDuration: 15 * 60 * 1000, // 15 minutes in milliseconds
  
  // Headers security
  helmet: {
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", 'data:', 'https:'],
        connectSrc: ["'self'", env.SUPABASE_URL],
        fontSrc: ["'self'"],
        objectSrc: ["'none'"],
        mediaSrc: ["'self'"],
        frameSrc: ["'none'"],
      },
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true,
    },
  },
  
  // Rate limiting
  rateLimiting: {
    windowMs: env.RATE_LIMIT_WINDOW_MS,
    max: env.RATE_LIMIT_MAX_REQUESTS,
    message: {
      error: 'Too many requests',
      message: 'Rate limit exceeded. Please try again later.',
    },
    standardHeaders: true,
    legacyHeaders: false,
  },
  
  // CORS
  cors: {
    origin: env.CORS_ORIGINS.split(','),
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    exposedHeaders: ['X-Total-Count'],
  },
  
  // WebSocket
  websocket: {
    heartbeatInterval: env.WS_HEARTBEAT_INTERVAL,
    maxConnections: env.WS_MAX_CONNECTIONS,
    cors: {
      origin: env.CORS_ORIGINS.split(','),
      credentials: true,
    },
  },
} as const;

export default env;