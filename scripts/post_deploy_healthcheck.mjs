const webPort = process.env.WEB_HOST_PORT || '3017';
const apiPort = process.env.API_HOST_PORT || '4013';

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
  await check('api via web proxy', `http://127.0.0.1:${webPort}/api/health`);
  await check('api direct', `http://127.0.0.1:${apiPort}/health`);
} catch (error) {
  console.error(error.message);
  process.exit(1);
}
