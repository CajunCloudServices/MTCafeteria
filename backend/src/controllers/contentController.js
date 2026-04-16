const contentService = require('../services/contentService');

const LANDING_ITEM_REQUIRED_FIELDS = ['type', 'title', 'content', 'startDate', 'endDate'];

function validateLandingItemPayload(body) {
  const missing = LANDING_ITEM_REQUIRED_FIELDS.filter((field) => {
    const value = body?.[field];
    return value == null || String(value).trim().length === 0;
  });

  if (missing.length === 0) {
    return null;
  }

  return {
    message: `${LANDING_ITEM_REQUIRED_FIELDS.join(', ')} are required.`,
    missingFields: missing,
  };
}

async function listLandingItems(_req, res) {
  const items = await contentService.listLandingItems();
  return res.json(items);
}

async function createLandingItem(req, res) {
  const validationError = validateLandingItemPayload(req.body);
  if (validationError) {
    return res.status(400).json(validationError);
  }

  const { type, title, content, startDate, endDate } = req.body;
  const item = await contentService.createLandingItem({
    type,
    title,
    content,
    startDate,
    endDate,
    createdBy: req.user?.sub ?? null,
  });

  return res.status(201).json(item);
}

async function updateLandingItem(req, res) {
  const validationError = validateLandingItemPayload(req.body);
  if (validationError) {
    return res.status(400).json(validationError);
  }

  const { id } = req.params;
  const { type, title, content, startDate, endDate } = req.body;

  const updated = await contentService.updateLandingItem(id, {
    type,
    title,
    content,
    startDate,
    endDate,
  });

  if (!updated) {
    return res.status(404).json({ message: 'Landing item not found.' });
  }

  return res.json(updated);
}

async function deleteLandingItem(req, res) {
  const { id } = req.params;
  const removed = await contentService.deleteLandingItem(id);

  if (!removed) {
    return res.status(404).json({ message: 'Landing item not found.' });
  }

  return res.status(204).send();
}

module.exports = {
  listLandingItems,
  createLandingItem,
  updateLandingItem,
  deleteLandingItem,
};
