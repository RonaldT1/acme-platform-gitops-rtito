const express = require('express');
const { getParam } = require('./config');
const app = express();
const PORT = process.env.PORT || 3000;

let appConfig = {};

async function init() {
  try {
    appConfig.env = await getParam('/bootcamp/INVALID_PARAM'); // this will throw an error
    console.log(`Config loaded: env=${appConfig.env}`);
  } catch (err) {
    console.error('Failed to load config from SSM:', err.message);
    process.exit(1); // fail fast
  }
}

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    env: appConfig.env,
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.get('/api/hello', (req, res) => {
  res.json({
    message: `Hello from ${appConfig.env}`,
    version: process.env.APP_VERSION || 'unknown'
  });
});

process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

init().then(() => {
  app.listen(PORT, () => console.log(`Server on port ${PORT}`));
});
