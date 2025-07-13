# VibeMUSE Security Guidelines

## Overview

This document outlines security practices, guidelines, and procedures for the VibeMUSE modernization project. Security is a critical aspect of our platform, especially given the multi-user nature of the application.

## Security Architecture

### Authentication & Authorization

**JWT-based Authentication:**
- Access tokens expire in 24 hours
- Refresh tokens expire in 7 days
- Role-based access control (RBAC)
- Permission-based authorization

**Password Security:**
- Minimum 8 characters required
- Must contain uppercase, lowercase, numbers, and special characters
- Hashed using bcrypt with 12 rounds
- Account lockout after 5 failed attempts

**Session Management:**
- Secure session handling with JWT
- Session timeout after 24 hours of inactivity
- Proper session invalidation on logout

### API Security

**Input Validation:**
- All inputs validated using Zod schemas
- Input sanitization to prevent XSS
- Content-Type validation
- Request size limits (1MB default)

**Rate Limiting:**
- Global rate limiting: 100 requests per 15-minute window
- Per-user rate limiting for authenticated endpoints
- WebSocket connection limits: 1000 concurrent connections

**Security Headers:**
- Comprehensive Content Security Policy (CSP)
- HTTP Strict Transport Security (HSTS)
- X-Frame-Options, X-Content-Type-Options
- Referrer-Policy and other security headers

### Database Security

**Supabase Integration:**
- Row Level Security (RLS) policies
- Service role key separation
- Connection pooling and limits
- Parameterized queries to prevent SQL injection

**Data Protection:**
- Sensitive data encryption at rest
- Secure key management
- Regular security audits

### WebSocket Security

**Connection Security:**
- Authentication required for WebSocket connections
- Connection rate limiting
- Heartbeat mechanism for connection validation
- Message size and frequency limits

**Message Validation:**
- All WebSocket messages validated
- Input sanitization
- Type checking and schema validation

## Security Measures Implemented

### 1. Environment Configuration Security

```typescript
// Environment validation with Zod
const envSchema = z.object({
  JWT_SECRET: z.string().min(32),
  ENCRYPTION_KEY: z.string().min(32),
  // ... other validations
});
```

### 2. Request Validation Middleware

```typescript
// Input validation and sanitization
app.use(validateRequestSize());
app.use(validateContentType());
app.use(sanitizeInput);
```

### 3. Authentication Middleware

```typescript
// JWT token verification
app.use('/api/protected', authenticateToken);
app.use('/api/admin', requireAdmin);
```

### 4. Error Handling

```typescript
// Secure error handling that doesn't expose sensitive information
app.use(errorHandler);
```

## Security Best Practices

### For Developers

1. **Never commit secrets to version control**
   - Use `.env.local` for local development
   - Use environment variables for production
   - Review commits for accidentally included secrets

2. **Input Validation**
   - Always validate user inputs
   - Use Zod schemas for comprehensive validation
   - Sanitize inputs to prevent XSS

3. **Error Handling**
   - Don't expose sensitive information in error messages
   - Log security events appropriately
   - Use proper HTTP status codes

4. **Database Interactions**
   - Use parameterized queries
   - Implement proper access controls
   - Validate all database inputs

5. **Authentication**
   - Implement proper session management
   - Use secure password hashing
   - Implement account lockout mechanisms

### For Operations

1. **Environment Security**
   - Use strong, unique secrets for each environment
   - Rotate secrets regularly
   - Use proper secret management tools

2. **Monitoring**
   - Monitor for suspicious activity
   - Log security events
   - Set up alerts for security violations

3. **Updates**
   - Keep dependencies updated
   - Monitor security advisories
   - Apply security patches promptly

## Security Testing

### Automated Security Scanning

**Dependency Scanning:**
```bash
npm audit
npm audit fix
```

**Static Code Analysis:**
```bash
npm run lint
npm run type-check
```

### Manual Security Testing

1. **Authentication Testing**
   - Test token expiration
   - Test invalid tokens
   - Test role-based access

2. **Input Validation Testing**
   - Test with malicious inputs
   - Test boundary conditions
   - Test input sanitization

3. **Rate Limiting Testing**
   - Test rate limit enforcement
   - Test bypass attempts
   - Test recovery after limits

## Incident Response

### Security Incident Procedure

1. **Detection**
   - Monitor logs for security events
   - Automated alerting for suspicious activity
   - User reports of security issues

2. **Response**
   - Immediately assess the severity
   - Contain the incident
   - Document all actions taken

3. **Recovery**
   - Fix the vulnerability
   - Restore normal operations
   - Update security measures

4. **Post-Incident**
   - Conduct post-mortem analysis
   - Update security procedures
   - Communicate with stakeholders

### Reporting Security Issues

If you discover a security vulnerability:

1. **Do NOT** create a public GitHub issue
2. **Do NOT** discuss the vulnerability publicly
3. **DO** email security concerns to the project maintainers
4. **DO** provide detailed information about the vulnerability
5. **DO** allow reasonable time for response and fix

## Compliance and Standards

### Security Standards

- **OWASP Top 10** compliance
- **CWE/SANS Top 25** vulnerability prevention
- **NIST Cybersecurity Framework** alignment

### Privacy Considerations

- **GDPR** compliance for European users
- **CCPA** compliance for California users
- **Data minimization** principles
- **User consent** management

## Security Roadmap

### Phase 1: Foundation (Current)
- [x] Environment validation
- [x] Input validation framework
- [x] Authentication middleware
- [x] Error handling
- [x] Rate limiting
- [x] Security headers

### Phase 2: Enhanced Security
- [ ] OAuth2 integration
- [ ] Multi-factor authentication
- [ ] Advanced rate limiting
- [ ] Security monitoring
- [ ] Audit logging

### Phase 3: Advanced Features
- [ ] End-to-end encryption
- [ ] Advanced threat detection
- [ ] Security analytics
- [ ] Penetration testing
- [ ] Security certification

## Security Configuration

### Required Environment Variables

```bash
# Security essentials
JWT_SECRET=your-super-secret-jwt-key-here (min 32 chars)
ENCRYPTION_KEY=your-encryption-key-here (min 32 chars)

# Database security
SUPABASE_URL=your-supabase-url
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# CORS and rate limiting
CORS_ORIGINS=http://localhost:5173,https://yourdomain.com
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# WebSocket security
WS_MAX_CONNECTIONS=1000
WS_HEARTBEAT_INTERVAL=30000
```

### Security Checklist

- [ ] Environment variables validated
- [ ] Secrets properly managed
- [ ] Input validation implemented
- [ ] Authentication working
- [ ] Authorization enforced
- [ ] Rate limiting active
- [ ] Security headers configured
- [ ] Error handling secure
- [ ] Logging implemented
- [ ] Dependencies updated
- [ ] Security tests passing

## Additional Resources

- [OWASP Security Guide](https://owasp.org/www-project-top-ten/)
- [Node.js Security Checklist](https://nodejs.org/en/guides/security/)
- [Express.js Security Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
- [Supabase Security Documentation](https://supabase.com/docs/guides/auth/security)

---

**Last Updated:** July 2025  
**Next Review:** Phase 1 Completion  
**Maintained By:** VibeMUSE Development Team