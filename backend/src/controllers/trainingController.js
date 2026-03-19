const trainingService = require('../services/trainingService');

async function listTrainings(req, res) {
  // Legacy prototype endpoint retained for older dashboard/panel flows.
  // The active detailed 2-minute training viewer is driven by the frontend's
  // manual local corpus, not by this API payload.
  const trainings = await trainingService.listTrainings();
  const today = new Date().toISOString().slice(0, 10);

  return res.json({
    today,
    trainings,
    todaysTraining: trainings.find((training) => training.assignedDate === today) || null,
  });
}

module.exports = {
  listTrainings,
};
