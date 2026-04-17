const jwt = require('jsonwebtoken');
const env = require('../config/env');
const { Roles } = require('../config/roles');

function extractBearerToken(req) {
  const header = req.headers?.authorization;
  if (typeof header !== 'string') return null;
  const match = header.match(/^Bearer\s+(.+)$/i);
  if (!match) return null;
  const token = match[1].trim();
  return token.length > 0 ? token : null;
}

function setAuthenticatedUser(req, decoded) {
  req.user = {
    sub: decoded.sub ?? null,
    email: decoded.email ?? null,
    role: decoded.role ?? Roles.EMPLOYEE,
  };
}

function attachUserIfPresent(req, _res, next) {
  const token = extractBearerToken(req);
  if (!token) {
    req.user = null;
    return next();
  }

  try {
    const decoded = jwt.verify(token, env.jwtSecret);
    setAuthenticatedUser(req, decoded);
  } catch (_error) {
    req.user = null;
  }
  return next();
}

function requireAuth(req, res, next) {
  const token = extractBearerToken(req);
  if (!token) {
    return res.status(401).json({ message: 'Authentication required.' });
  }

  try {
    const decoded = jwt.verify(token, env.jwtSecret);
    setAuthenticatedUser(req, decoded);
    return next();
  } catch (_error) {
    return res.status(401).json({ message: 'Invalid or expired token.' });
  }
}

function requireRole(allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ message: 'Authentication required.' });
    }
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Access denied for this role.' });
    }
    return next();
  };
}

module.exports = {
  attachUserIfPresent,
  extractBearerToken,
  requireAuth,
  requireRole,
};
