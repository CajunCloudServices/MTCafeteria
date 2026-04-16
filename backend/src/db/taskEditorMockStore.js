const fs = require('fs');
const path = require('path');
const mockData = require('./mockData');

// Optional JSON file that persists mock-mode job/task edits across restarts.
// When TASK_EDITOR_PERSIST_PATH is set, the file is loaded on first use and
// rewritten after every mutation. Any IO failure is swallowed so development
// keeps working even if the path is not writable.
const PERSIST_PATH = (() => {
  const raw = process.env.TASK_EDITOR_PERSIST_PATH;
  if (typeof raw !== 'string' || raw.trim().length === 0) {
    return null;
  }
  return path.resolve(raw.trim());
})();

let loaded = false;

function toSerializableJob(job) {
  return {
    id: job.id,
    shiftId: job.shiftId,
    name: job.name,
  };
}

function toSerializableTask(task) {
  return {
    id: task.id,
    jobId: task.jobId,
    phase: task.phase,
    description: task.description,
    requiresCheckoff: task.requiresCheckoff !== false,
  };
}

function snapshot() {
  return {
    jobs: mockData.jobs.map(toSerializableJob),
    tasks: mockData.tasks.map(toSerializableTask),
  };
}

function saveSnapshot() {
  if (!PERSIST_PATH) return;
  try {
    fs.mkdirSync(path.dirname(PERSIST_PATH), { recursive: true });
    fs.writeFileSync(
      PERSIST_PATH,
      `${JSON.stringify(snapshot(), null, 2)}\n`,
      'utf8'
    );
  } catch (error) {
    // TODO: wire to a real logger once observability lands.
    console.warn(`[taskEditorMock] failed to persist overrides: ${error.message}`);
  }
}

function loadSnapshotIfPresent() {
  if (loaded || !PERSIST_PATH) {
    loaded = true;
    return;
  }
  loaded = true;
  try {
    if (!fs.existsSync(PERSIST_PATH)) return;
    const raw = fs.readFileSync(PERSIST_PATH, 'utf8');
    const parsed = JSON.parse(raw);
    if (!parsed || !Array.isArray(parsed.jobs) || !Array.isArray(parsed.tasks)) {
      return;
    }
    mockData.jobs.splice(
      0,
      mockData.jobs.length,
      ...parsed.jobs.map(toSerializableJob)
    );
    mockData.tasks.splice(
      0,
      mockData.tasks.length,
      ...parsed.tasks.map(toSerializableTask)
    );
  } catch (error) {
    console.warn(`[taskEditorMock] failed to load overrides: ${error.message}`);
  }
}

function ensureLoaded() {
  if (!loaded) {
    loadSnapshotIfPresent();
  }
}

function nextId(collection) {
  return collection.reduce((max, item) => Math.max(max, item.id || 0), 0) + 1;
}

module.exports = {
  ensureLoaded,
  saveSnapshot,
  nextId,
};
