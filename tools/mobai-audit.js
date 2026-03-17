#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const API_BASE = process.env.MOBAI_API_BASE || 'http://127.0.0.1:8686/api/v1';

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith('--')) continue;
    const key = token.slice(2);
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      args[key] = true;
      continue;
    }
    args[key] = next;
    i += 1;
  }
  return args;
}

function nowStamp() {
  return new Date().toISOString().replace(/[:.]/g, '-');
}

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function writeJson(filePath, value) {
  fs.writeFileSync(filePath, JSON.stringify(value, null, 2));
}

async function req(method, endpoint, body) {
  const response = await fetch(`${API_BASE}${endpoint}`, {
    method,
    headers: { 'Content-Type': 'application/json' },
    body: body ? JSON.stringify(body) : undefined,
  });
  if (!response.ok) {
    const text = await response.text();
    throw new Error(`${method} ${endpoint} failed: ${response.status} ${text}`);
  }
  return response.json();
}

function loadMatrix(repoRoot) {
  const p = path.join(repoRoot, 'tools', 'mobai', 'path-matrix.json');
  return JSON.parse(fs.readFileSync(p, 'utf8'));
}

function loadTemplate(repoRoot, relPath, fallback = '') {
  const p = path.join(repoRoot, relPath);
  if (!fs.existsSync(p)) return fallback;
  return fs.readFileSync(p, 'utf8');
}

async function main() {
  const args = parseArgs(process.argv);
  const repoRoot = process.cwd();
  const appUrl = args.url || 'http://localhost:51336';
  const viewport = args.viewport || 'mobile_web';

  const devicesPayload = await req('GET', '/devices');
  const devices = Array.isArray(devicesPayload) ? devicesPayload : devicesPayload.data || [];
  const device = args.device
    ? devices.find((d) => d.id === args.device)
    : devices.find((d) => d.platform === 'ios' && d.virtual) || devices[0];

  if (!device) {
    throw new Error('No MobAI device available.');
  }

  const stamp = nowStamp();
  const runDir = path.join(repoRoot, 'artifacts', 'mobai', stamp);
  const screenshotsDir = path.join(runDir, 'screenshots');
  const beforeAfterDir = path.join(runDir, 'before-after');
  ensureDir(screenshotsDir);
  ensureDir(beforeAfterDir);

  const matrix = loadMatrix(repoRoot);
  writeJson(path.join(runDir, 'path-matrix.snapshot.json'), matrix);

  const issuesTemplate = loadTemplate(repoRoot, 'tools/mobai/issues.template.json', '[]');
  fs.writeFileSync(path.join(runDir, 'issues.json'), issuesTemplate);

  const flowTemplate = loadTemplate(repoRoot, 'tools/mobai/flow-notes.template.md', '# MobAI Audit Run Notes\n');
  const flowNotes = `${flowTemplate}\n\n## Auto-captured\n- Device: ${device.name} (${device.id})\n- App URL: ${appUrl}\n- Viewport: ${viewport}\n- Stamp: ${stamp}\n`;
  fs.writeFileSync(path.join(runDir, 'flow-notes.md'), flowNotes);

  // Capture baseline screen and UI tree from current device context.
  const screenshotPayload = await req('GET', `/devices/${device.id}/screenshot`);
  writeJson(path.join(runDir, 'baseline-screenshot.json'), screenshotPayload);
  if (screenshotPayload && screenshotPayload.path && fs.existsSync(screenshotPayload.path)) {
    fs.copyFileSync(
      screenshotPayload.path,
      path.join(screenshotsDir, 'baseline.png')
    );
  }

  const uiTreePayload = await req('GET', `/devices/${device.id}/ui-tree`);
  writeJson(path.join(runDir, 'baseline-ui-tree.json'), uiTreePayload);

  // Optional browser navigation endpoint (best-effort; depends on bridge/webview state).
  let navError = null;
  try {
    const navigatePayload = await req('POST', `/devices/${device.id}/web/navigate`, { url: appUrl });
    writeJson(path.join(runDir, 'web-navigate.json'), navigatePayload);
  } catch (error) {
    navError = String(error.message || error);
  }

  const manifest = {
    runDir,
    device,
    appUrl,
    viewport,
    navError,
    createdAt: new Date().toISOString(),
  };
  writeJson(path.join(runDir, 'run-manifest.json'), manifest);

  console.log(runDir);
  if (navError) {
    console.log(`WARN: web navigation endpoint unavailable: ${navError}`);
  }
}

main().catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
