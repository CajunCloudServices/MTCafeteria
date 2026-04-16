const jwt = require('jsonwebtoken');
const env = require('../config/env');
const { Roles } = require('../config/roles');

// The pilot runs as a shared operational session instead of a per-user login.
// This object is attached to every request unless a caller supplies a valid
// JWT (supervisor / manager tools may still issue and present tokens). The
// role defaults to Student Manager so admin-only landing mutations succeed
// while still reflecting supervisor-equivalent capability for everything else.
//
// For Postgres deployments, set `SHARED_SESSION_USER_ID` to a real seeded
// user id (for example, the `manager@mtc.local` user created by seed.sql) so
// operations that insert rows with `submitted_by_user_id`/`created_by` do not
// violate FK constraints. Mock mode ignores the id.
const parsedSharedUserId = Number.parseInt(process.env.SHARED_SESSION_USER_ID || '', 10);
const sharedSessionUser = Object.freeze({
  sub: Number.isFinite(parsedSharedUserId) ? parsedSharedUserId : null,
  email: process.env.SHARED_SESSION_EMAIL || 'shared-session@mtc.local',
  role: process.env.SHARED_SESSION_ROLE || Roles.STUDENT_MANAGER,
});

function extractBearerToken(req) {
  const header = req.headers?.authorization;
  if (typeof header !== 'string') return null;
  const match = header.match(/^Bearer\s+(.+)$/i);
  if (!match) return null;
  const token = match[1].trim();
  return token.length > 0 ? token : null;
}

function requireAuth(req, _res, next) {
  const token = extractBearerToken(req);
  if (token) {
    try {
      const decoded = jwt.verify(token, env.jwtSecret);
      req.user = {
        sub: decoded.sub ?? null,
        email: decoded.email ?? null,
        role: decoded.role ?? Roles.EMPLOYEE,
      };
      return next();
    } catch (_error) {
      // Fall through to shared session. The pilot never hard-fails on auth so
      // an expired/bad token never locks the shared app out of content reads.
    }
  }
  req.user = { ...sharedSessionUser };
  return next();
}

function requireRole(allowedRoles) {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Access denied for this role.' });
    }
    return next();
  };
}

module.exports = {
  requireAuth,
  requireRole,
};
