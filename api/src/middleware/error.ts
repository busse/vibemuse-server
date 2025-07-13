import { Request, Response, NextFunction } from 'express';
import { env } from '../config/env';

// Custom error class
export class AppError extends Error {
  public statusCode: number;
  public isOperational: boolean;
  public code?: string;
  public details?: any;
  
  constructor(
    message: string, 
    statusCode: number = 500, 
    isOperational: boolean = true,
    code?: string,
    details?: any
  ) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.code = code;
    this.details = details;
    
    Error.captureStackTrace(this, this.constructor);
  }
}

// Common error types
export const createError = {
  badRequest: (message: string = 'Bad Request', details?: any) => 
    new AppError(message, 400, true, 'BAD_REQUEST', details),
  
  unauthorized: (message: string = 'Unauthorized') => 
    new AppError(message, 401, true, 'UNAUTHORIZED'),
  
  forbidden: (message: string = 'Forbidden') => 
    new AppError(message, 403, true, 'FORBIDDEN'),
  
  notFound: (message: string = 'Resource not found') => 
    new AppError(message, 404, true, 'NOT_FOUND'),
  
  conflict: (message: string = 'Conflict') => 
    new AppError(message, 409, true, 'CONFLICT'),
  
  unprocessableEntity: (message: string = 'Unprocessable Entity', details?: any) => 
    new AppError(message, 422, true, 'UNPROCESSABLE_ENTITY', details),
  
  tooManyRequests: (message: string = 'Too Many Requests') => 
    new AppError(message, 429, true, 'TOO_MANY_REQUESTS'),
  
  internalServer: (message: string = 'Internal Server Error') => 
    new AppError(message, 500, true, 'INTERNAL_SERVER_ERROR'),
  
  serviceUnavailable: (message: string = 'Service Unavailable') => 
    new AppError(message, 503, true, 'SERVICE_UNAVAILABLE')
};

// Error logging function
const logError = (error: AppError, req: Request): void => {
  const errorInfo = {
    timestamp: new Date().toISOString(),
    method: req.method,
    url: req.originalUrl,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    user: req.user?.id || 'anonymous',
    error: {
      message: error.message,
      statusCode: error.statusCode,
      code: error.code,
      stack: error.stack,
      details: error.details
    }
  };
  
  // Log to console (in production, this should go to a proper logging service)
  if (error.statusCode >= 500) {
    console.error('🔥 Server Error:', JSON.stringify(errorInfo, null, 2));
  } else if (error.statusCode >= 400) {
    console.warn('⚠️  Client Error:', JSON.stringify(errorInfo, null, 2));
  }
};

// Global error handler middleware
export const errorHandler = (
  error: Error | AppError, 
  req: Request, 
  res: Response, 
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  next: NextFunction
): void => {
  let appError: AppError;
  
  // Convert regular errors to AppError
  if (error instanceof AppError) {
    appError = error;
  } else {
    appError = new AppError(
      env.NODE_ENV === 'development' ? error.message : 'Internal Server Error',
      500,
      false
    );
  }
  
  // Log the error
  logError(appError, req);
  
  // Prepare error response
  const errorResponse: any = {
    error: {
      message: appError.message,
      code: appError.code || 'UNKNOWN_ERROR',
      statusCode: appError.statusCode
    },
    timestamp: new Date().toISOString(),
    path: req.originalUrl,
    method: req.method
  };
  
  // Include additional details in development
  if (env.NODE_ENV === 'development') {
    errorResponse.error.stack = appError.stack;
    if (appError.details) {
      errorResponse.error.details = appError.details;
    }
  }
  
  // Include details if they exist and are safe to expose
  if (appError.details && appError.statusCode < 500) {
    errorResponse.error.details = appError.details;
  }
  
  res.status(appError.statusCode).json(errorResponse);
};

// Async error wrapper
export const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<void>) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// 404 handler middleware
export const notFoundHandler = (req: Request, res: Response, next: NextFunction): void => {
  const error = createError.notFound(`Route ${req.method} ${req.originalUrl} not found`);
  next(error);
};

// Validation error handler
export const validationErrorHandler = (error: any, req: Request, res: Response, next: NextFunction): void => {
  if (error.name === 'ValidationError') {
    const validationError = createError.unprocessableEntity(
      'Validation failed',
      Object.values(error.errors).map((err: any) => ({
        field: err.path,
        message: err.message
      }))
    );
    next(validationError);
    return;
  }
  
  next(error);
};

// Database error handler
export const databaseErrorHandler = (error: any, req: Request, res: Response, next: NextFunction): void => {
  // PostgreSQL errors
  if (error.code) {
    switch (error.code) {
      case '23505': // Unique constraint violation
        const uniqueError = createError.conflict('Resource already exists');
        next(uniqueError);
        return;
      
      case '23503': // Foreign key constraint violation
        const foreignKeyError = createError.badRequest('Invalid reference');
        next(foreignKeyError);
        return;
      
      case '23502': // Not null constraint violation
        const notNullError = createError.badRequest('Required field missing');
        next(notNullError);
        return;
      
      default:
        if (env.NODE_ENV === 'development') {
          console.log('Database error code:', error.code);
        }
    }
  }
  
  next(error);
};

// JWT error handler
export const jwtErrorHandler = (error: any, req: Request, res: Response, next: NextFunction): void => {
  if (error.name === 'JsonWebTokenError') {
    const jwtError = createError.unauthorized('Invalid token');
    next(jwtError);
    return;
  }
  
  if (error.name === 'TokenExpiredError') {
    const expiredError = createError.unauthorized('Token expired');
    next(expiredError);
    return;
  }
  
  next(error);
};

// Combine all error handlers
export const setupErrorHandling = (app: any): void => {
  app.use(validationErrorHandler);
  app.use(databaseErrorHandler);
  app.use(jwtErrorHandler);
  app.use(notFoundHandler);
  app.use(errorHandler);
};

export default {
  AppError,
  createError,
  errorHandler,
  asyncHandler,
  notFoundHandler,
  setupErrorHandling
};