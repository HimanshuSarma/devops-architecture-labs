import express from 'express';
import cors from 'cors';
import promClient from 'prom-client';
import * as k8s from '@kubernetes/client-node';

const kc = new k8s.KubeConfig();
kc.loadFromCluster();
const k8sApi = kc.makeApiClient(k8s.CoreV1Api);

const app = express();
const port = 8000;

app.use(cors()); // Defaults to origin: '*'

app.get('/', (req, res) => {
  res.send('k8s-automation v1!');
});

app.get('/list-pods', async (req, res) => {
  try {
    // Attempt to get pods from all namespaces
    const response = await k8sApi.listPodForAllNamespaces();
    
    // FIX: The items array is directly on the response or response.body depending on version structure
    // Let's use a safe check that works for both styles:
    const items = response.items || (response.body && response.body.items);
    
    if (!items) {
      return res.status(500).json({ success: false, message: "Unexpected API response structure", raw: response });
    }

    const podNames = items.map(pod => pod.metadata.name);
    res.json({ success: true, pods: podNames });
  } catch (error) {
    // Capture and return the RBAC failure details
    res.status(error.statusCode || 500).json({
      success: false,
      message: error.message,
      body: error.body || error
    });
  }
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
