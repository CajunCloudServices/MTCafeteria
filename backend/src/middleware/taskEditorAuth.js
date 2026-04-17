function getConfiguredPassword() {
  const value = process.env.TASK_EDITOR_PASSWORD;
  if (typeof value === 'string' && value.length > 0) {
    return value;
  }
  return '';
}

function extractProvidedPassword(req) {
  const header = req.get('x-task-editor-password');
  if (typeof header === 'string' && header.length > 0) {
    return header;
  }
  const auth = req.get('authorization');
  if (typeof auth === 'string' && auth.toLowerCase().startsWith('task-editor ')) {
    return auth.slice('task-editor '.length).trim();
  }
  return '';
}

function requireTaskEditorPassword(req, res, next) {
  const configuredPassword = getConfiguredPassword();
  if (!configuredPassword) {
    res.status(503).json({ message: 'Task editor password is not configured.' });
    return;
  }

  const provided = extractProvidedPassword(req);
  if (!provided) {
    res.status(401).json({ message: 'Task editor password required.' });
    return;
  }
  if (provided !== configuredPassword) {
    res.status(403).json({ message: 'Incorrect task editor password.' });
    return;
  }
  next();
}

module.exports = {
  requireTaskEditorPassword,
  getConfiguredPassword,
};
