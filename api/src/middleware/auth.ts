import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '../config/env';

// Extend Request type to include user
export interface AuthenticatedUser {
  id: string;
  email: string;
  username: string;
  role: string;
  permissions: string[];
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthenticatedUser;
    }
  }
}

// JWT token verification middleware
export const authenticateToken = (req: Request, res: Response, next: NextFunction): void => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
  
  if (!token) {
    res.status(401).json({
      error: 'Authentication Required',
      message: 'Access token is required'
    });
    return;
  }
  
  try {
    const decoded = jwt.verify(token, env.JWT_SECRET) as jwt.JwtPayload & {
      sub: string;
      email: string;
      username: string;
      role: string;
      permissions: string[];
    };
    req.user = {
      id: decoded.sub,
      email: decoded.email,
      username: decoded.username,
      role: decoded.role || 'user',
      permissions: decoded.permissions || []
    };
    next();
  } catch (error: unknown) {
    if (error instanceof jwt.TokenExpiredError) {
      res.status(401).json({
        error: 'Token Expired',
        message: 'Access token has expired'
      });
      return;
    }
    
    if (error instanceof jwt.JsonWebTokenError) {
      res.status(401).json({
        error: 'Invalid Token',
        message: 'Access token is invalid'
      });
      return;
    }
    
    res.status(500).json({
      error: 'Authentication Error',
      message: 'Failed to authenticate token'
    });
  }
};

// Optional authentication middleware (doesn't fail if no token)
export const optionalAuth = (req: Request, res: Response, next: NextFunction): void => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (token) {
    try {
      const decoded = jwt.verify(token, env.JWT_SECRET) as jwt.JwtPayload & {
        sub: string;
        email: string;
        username: string;
        role: string;
        permissions: string[];
      };
      req.user = {
        id: decoded.sub,
        email: decoded.email,
        username: decoded.username,
        role: decoded.role || 'user',
        permissions: decoded.permissions || []
      };
    } catch {
      // Ignore authentication errors for optional auth
    }
  }
  
  next();
};

// Role-based authorization middleware
export const requireRole = (requiredRole: string | string[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({
        error: 'Authentication Required',
        message: 'User must be authenticated'
      });
      return;
    }
    
    const roles = Array.isArray(requiredRole) ? requiredRole : [requiredRole];
    
    if (!roles.includes(req.user.role)) {
      res.status(403).json({
        error: 'Insufficient Permissions',
        message: `Required role: ${roles.join(' or ')}`,
        userRole: req.user.role
      });
      return;
    }
    
    next();
  };
};

// Permission-based authorization middleware
export const requirePermission = (requiredPermission: string | string[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({
        error: 'Authentication Required',
        message: 'User must be authenticated'
      });
      return;
    }
    
    const permissions = Array.isArray(requiredPermission) ? requiredPermission : [requiredPermission];
    
    const hasPermission = permissions.some(permission => 
      req.user?.permissions.includes(permission)
    );
    
    if (!hasPermission) {
      res.status(403).json({
        error: 'Insufficient Permissions',
        message: `Required permission: ${permissions.join(' or ')}`,
        userPermissions: req.user.permissions
      });
      return;
    }
    
    next();
  };
};

// Admin-only middleware
export const requireAdmin = requireRole('admin');

// Moderator or admin middleware
export const requireModerator = requireRole(['moderator', 'admin']);

// Self or admin access middleware (for user-specific endpoints)
export const requireSelfOrAdmin = (req: Request, res: Response, next: NextFunction): void => {
  if (!req.user) {
    res.status(401).json({
      error: 'Authentication Required',
      message: 'User must be authenticated'
    });
    return;
  }
  
  const targetUserId = req.params.id || req.params.userId;
  
  if (req.user.id === targetUserId || req.user.role === 'admin') {
    next();
  } else {
    res.status(403).json({
      error: 'Insufficient Permissions',
      message: 'Can only access own resources or admin required'
    });
  }
};

// Rate limiting per user
export const userRateLimit = (maxRequests: number = 100, windowMs: number = 15 * 60 * 1000) => {
  const userRequests = new Map<string, { count: number; resetTime: number }>();
  
  return (req: Request, res: Response, next: NextFunction): void => {
    const userId = req.user?.id || req.ip || 'anonymous';
    const now = Date.now();
    const userLimit = userRequests.get(userId);
    
    if (!userLimit || now > userLimit.resetTime) {
      userRequests.set(userId, {
        count: 1,
        resetTime: now + windowMs
      });
      next();
      return;
    }
    
    if (userLimit.count >= maxRequests) {
      res.status(429).json({
        error: 'Rate Limit Exceeded',
        message: 'Too many requests from this user',
        retryAfter: Math.ceil((userLimit.resetTime - now) / 1000)
      });
      return;
    }
    
    userLimit.count++;
    next();
  };
};

// JWT token generation utility
export const generateTokens = (user: AuthenticatedUser): { accessToken: string; refreshToken: string } => {
  const accessToken = jwt.sign(
    {
      sub: user.id,
      email: user.email,
      username: user.username,
      role: user.role,
      permissions: user.permissions
    },
    env.JWT_SECRET,
    { expiresIn: '24h' }
  );
  
  const refreshToken = jwt.sign(
    { sub: user.id },
    env.JWT_SECRET,
    { expiresIn: '7d' }
  );
  
  return { accessToken, refreshToken };
};

export default {
  authenticateToken,
  optionalAuth,
  requireRole,
  requirePermission,
  requireAdmin,
  requireModerator,
  requireSelfOrAdmin,
  userRateLimit,
  generateTokens
};