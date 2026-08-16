const express = require('express');
const cors = require('cors');
const promClient = require('prom-client');

const app = express();
const port = 8000;

app.use(cors()); // Defaults to origin: '*'

app.get('/', (req, res) => {
  console.log(`auth microservice`);
  res.send('Hello World v28!');
});

const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });
app.get('/metrics', async (req, res) => {
  res.setHeader('Content-Type', register.contentType);
  res.send(await register.metrics());
});

app.get('/healthz/readiness', (req, res) => {
  res.status(200).send('pod is healthy');
});


// A global array to store leaked memory so garbage collection can't clean it up
const memoryLeakLeakage = [];

app.get('/cause-oom', (req, res) => {
  res.send('Starting intentional memory explosion...');
  
  console.log('--- CRITICAL: Initiating memory leak execution loop ---');
  
  // Allocate heavy chunks of memory every 50ms
  setInterval(() => {
    const heavyChunk = new Array(1000000).fill('💣'); // Allocates millions of string characters
    memoryLeakLeakage.push(heavyChunk);
    
    // Log the current usage to stdout so you can watch it grow
    const memoryUsage = process.memoryUsage().heapUsed / 1024 / 1024;
    console.log(`Current Heap Usage: ${memoryUsage.toFixed(2)} MB`);
  }, 50);
});


app.get('/cause-cpu-spike', (req, res) => {
  res.send('Starting heavy CPU calculation loops...');
  console.log('--- CRITICAL: Initiating heavy CPU processing loop ---');
  
  const startTime = Date.now();
  // Loop intensely for 15 seconds to simulate high computational strain
  while (Date.now() - startTime < 15000) {
    Math.random() * Math.random(); 
  }
  
  console.log('--- CPU processing loop complete ---');
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
////