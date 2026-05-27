const express = require('express');
const { trace } = require('@opentelemetry/api');
const app = express();
const PORT = process.env.PORT || 3000;

const client = require('prom-client'); // Day 9: PcfMetrics
const register = new client.Registry(); // Metrics Container

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

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/api/hello', (req, res) => {
  const name = process.env.APP_ENV || 'world';
  res.json({ message: `Hello from ${name}` });
});

app.get('/api/slow', async (_req, res) => {
  await new Promise((resolve) => setTimeout(resolve, 800));
  res.json({ message: 'Slow response completed', delay_ms: 800 });
});

app.get('/metrics', async (_req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
