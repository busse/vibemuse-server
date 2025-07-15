import { Request, Response, NextFunction } from 'express';
import { z, ZodError } from 'zod';

// Generic request validation middleware
export const validateRequest = (schema: {
  body?: z.ZodSchema;
  query?: z.ZodSchema;
  params?: z.ZodSchema;
}) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    try {
      if (schema.body) {
        req.body = schema.body.parse(req.body);
      }
      
      if (schema.query) {
        req.query = schema.query.parse(req.query) as any;
      }
      
      if (schema.params) {
        req.params = schema.params.parse(req.params) as any;
      }
      
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        res.status(400).json({
          error: 'Validation Error',
          message: 'Invalid request data',
          details: error.issues.map(err => ({
            field: err.path.join('.'),
            message: err.message,
            code: err.code
          }))
        });
        return;
      }
      next(error);
    }
  };
};

// Common validation schemas
export const commonSchemas = {
  // ID parameter validation
  id: z.object({
    id: z.string().uuid('Invalid ID format')
  }),
  
  // Pagination query validation
  pagination: z.object({
    page: z.string().optional().transform(val => val ? Number(val) : 1),
    limit: z.string().optional().transform(val => val ? Number(val) : 10),
    sort: z.string().optional(),
    order: z.enum(['asc', 'desc']).default('asc')
  }),
  
  // Search query validation
  search: z.object({
    q: z.string().min(1).max(255),
    filters: z.string().optional()
  }),
  
  // Authentication validation
  credentials: z.object({
    email: z.string().email('Invalid email format'),
    password: z.string().min(8, 'Password must be at least 8 characters')
  }),
  
  // User registration validation
  registration: z.object({
    email: z.string().email('Invalid email format'),
    password: z.string()
      .min(8, 'Password must be at least 8 characters')
      .max(128, 'Password must be less than 128 characters')
      .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/, 
        'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'),
    username: z.string()
      .min(3, 'Username must be at least 3 characters')
      .max(30, 'Username must be less than 30 characters')
      .regex(/^[a-zA-Z0-9_-]+$/, 'Username can only contain letters, numbers, underscores, and hyphens'),
    firstName: z.string().min(1).max(50),
    lastName: z.string().min(1).max(50)
  }),
  
  // WebSocket message validation
  wsMessage: z.object({
    type: z.string().min(1).max(50),
    data: z.any(),
    timestamp: z.string().datetime().optional()
  }),
  
  // Game object validation
  gameObject: z.object({
    name: z.string().min(1).max(100),
    description: z.string().max(1000).optional(),
    location: z.string().uuid().optional(),
    properties: z.record(z.string(), z.any()).optional()
  }),
  
  // Chat message validation
  chatMessage: z.object({
    content: z.string().min(1).max(1000),
    channel: z.string().min(1).max(50),
    recipientId: z.string().uuid().optional()
  }),
  
  // Room creation validation
  roomCreation: z.object({
    name: z.string().min(1).max(100),
    description: z.string().max(1000).optional(),
    isPublic: z.boolean().default(true),
    maxCapacity: z.number().int().min(1).max(1000).default(100)
  })
};

// Input sanitization middleware
export const sanitizeInput = (req: Request, res: Response, next: NextFunction): void => {
  const sanitizeObject = (obj: any): any => {
    if (typeof obj === 'string') {
      // Remove potentially dangerous characters
      return obj.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
                .replace(/javascript:/gi, '')
                .replace(/on\w+\s*=/gi, '')
                .trim();
    }
    
    if (Array.isArray(obj)) {
      return obj.map(sanitizeObject);
    }
    
    if (obj && typeof obj === 'object') {
      const sanitized: any = {};
      for (const [key, value] of Object.entries(obj)) {
        sanitized[key] = sanitizeObject(value);
      }
      return sanitized;
    }
    
    return obj;
  };
  
  if (req.body) {
    req.body = sanitizeObject(req.body);
  }
  
  // Note: req.query is read-only in newer Express versions
  // We'll skip sanitizing query parameters to avoid errors
  // In production, query parameter sanitization should be handled at the route level
  
  next();
};

// Content type validation middleware
export const validateContentType = (expectedTypes: string[] = ['application/json']) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const contentType = req.get('Content-Type');
    
    if (req.method === 'POST' || req.method === 'PUT' || req.method === 'PATCH') {
      if (!contentType || !expectedTypes.some(type => contentType.includes(type))) {
        res.status(415).json({
          error: 'Unsupported Media Type',
          message: `Expected Content-Type to be one of: ${expectedTypes.join(', ')}`,
          received: contentType || 'none'
        });
        return;
      }
    }
    
    next();
  };
};

// Request size validation middleware
export const validateRequestSize = (maxSize: number = 10 * 1024 * 1024) => { // 10MB default
  return (req: Request, res: Response, next: NextFunction): void => {
    const contentLength = req.get('Content-Length');
    
    if (contentLength && parseInt(contentLength) > maxSize) {
      res.status(413).json({
        error: 'Request Entity Too Large',
        message: `Request size exceeds maximum allowed size of ${maxSize} bytes`,
        received: contentLength
      });
      return;
    }
    
    next();
  };
};

export default {
  validateRequest,
  commonSchemas,
  sanitizeInput,
  validateContentType,
  validateRequestSize
};