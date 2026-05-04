const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/api/hello', (req, res) => {
  const name = process.env.APP_ENV || 'world';
  res.json({ message: `Hello from ${name}` });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
