const { Roles } = require('../config/roles');

const sharedSessionUser = {
  sub: 0,
  email: 'shared-session@mtc.local',
  role: Roles.SUPERVISOR,
};

function requireAuth(req, res, next) {
  req.user = sharedSessionUser;
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
