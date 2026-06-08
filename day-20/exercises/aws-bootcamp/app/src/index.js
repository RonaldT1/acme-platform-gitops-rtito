const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const items = [
  { id: 1, name: 'camera', category: 'media' },
  { id: 2, name: 'microphone', category: 'audio' }
];
let trace = { getActiveSpan: () => undefined };

try {
  ({ trace } = require('@opentelemetry/api'));
} catch {
  // Keep request handling alive when OTEL is not injected in the runtime.
}

const client = require('prom-client');
const register = new client.Registry();

client.collectDefaultMetrics({ register });

const httpRequests = new client.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status']
});

register.registerMetric(httpRequests);

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request latency in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.025, 0.05, 0.1, 0.25, 0.5, 1, 2, 5]
});

register.registerMetric(httpRequestDuration);

app.use(express.json());

app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer();

  res.on('finish', () => {
    const route = req.route?.path || req.path;
    const span = trace.getActiveSpan();
    const spanContext = span?.spanContext();

    const labels = {
      method: req.method,
      route,
      status: res.statusCode
    };

    httpRequests.inc(labels);
    end(labels);

    console.log(
      `trace_id=${spanContext?.traceId || 'unknown'} span_id=${spanContext?.spanId || 'unknown'} method=${req.method} route=${route} status=${res.statusCode}`
    );
  });

  next();
});

app.get('/healthz', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/api/hello', (req, res) => {
  const name = process.env.APP_ENV || 'world';
  res.json({ message: `Hello from ${name}` });
});

app.get('/api/version', (_req, res) => {
  res.json({ version: process.env.API_VERSION || 'v1' });
});

app.get('/api/slow', async (_req, res) => {
  await new Promise((resolve) => setTimeout(resolve, 800));
  res.json({ message: 'Slow response completed', delay_ms: 800 });
});

app.get('/api/items', (_req, res) => {
  res.json({ items });
});

app.post('/api/login', (req, res) => {
  const { user } = req.body || {};

  if (!user) {
    return res.status(400).json({ error: 'user is required' });
  }

  return res.status(200).json({
    message: 'login request accepted',
    user
  });
});

app.delete('/api/items/:id', (req, res) => {
  const itemId = Number(req.params.id);
  const item = items.find((entry) => entry.id === itemId);

  if (!item) {
    return res.status(404).json({ error: 'item not found' });
  }

  return res.status(200).json({
    message: 'item deleted',
    id: itemId
  });
});

app.get('/metrics', async (_req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
