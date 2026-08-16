const express = require('express');
const cors = require('cors');
const promClient = require('prom-client');

const app = express();
const port = 8000;

app.use(cors()); // Defaults to origin: '*'

app.get('/', (req, res) => {
  res.send('service2!');
});

const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });
app.get('/metrics', async (req, res) => {
  res.setHeader('Content-Type', register.contentType);
  res.send(await register.metrics());
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
//