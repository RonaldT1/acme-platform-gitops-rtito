const express = require('express');
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

app.use(express.json());

app.use((req, res, next) => { // que cuando la respuesta se termine de enviar, se incremente el contador de métricas
  res.on('finish', () => {
    httpRequests.inc({
      method: req.method,
      route: req.path,
      status: res.statusCode
    });
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

app.get('/metrics', async (_req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
