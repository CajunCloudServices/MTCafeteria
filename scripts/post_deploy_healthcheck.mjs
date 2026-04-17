import fs from 'node:fs';

const envFile = process.env.ENV_FILE;

function readEnvFile(filePath) {
  if (!filePath || !fs.existsSync(filePath)) {
    return {};
  }

  return Object.fromEntries(
    fs
      .readFileSync(filePath, 'utf8')
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter((line) => line && !line.startsWith('#') && line.includes('='))
      .map((line) => {
        const separatorIndex = line.indexOf('=');
        const key = line.slice(0, separatorIndex).trim();
        const value = line.slice(separatorIndex + 1).trim();
        return [key, value];
      })
  );
}

const fileEnv = readEnvFile(envFile);
const webPort = process.env.WEB_HOST_PORT || fileEnv.WEB_HOST_PORT || '3017';
const apiPort = process.env.API_HOST_PORT || fileEnv.API_HOST_PORT || '';

async function check(name, url) {
  let response;
  try {
    response = await fetch(url);
  } catch (error) {
    throw new Error(`${name} failed to connect: ${url}\n${error.message}`);
  }

  const text = await response.text();
  if (!response.ok) {
    throw new Error(`${name} failed: ${response.status} ${response.statusText}\n${text}`);
  }
  console.log(`${name}: OK -> ${url}`);
  console.log(text);
}

try {
  await check('web', `http://127.0.0.1:${webPort}/health`);
  await check('web readiness', `http://127.0.0.1:${webPort}/readyz`);
  await check('api via web proxy', `http://127.0.0.1:${webPort}/api/health`);
  if (apiPort) {
    await check('api direct', `http://127.0.0.1:${apiPort}/health`);
  }
} catch (error) {
  console.error(error.message);
  process.exit(1);
}
