import express, { Request, Response } from 'express';
import cors from 'cors';
import { execFile } from 'child_process';
import path from 'path';

const app = express();
const port: number = 8000;

app.use(cors());

app.get('/', async (req: Request, res: Response) => {
  try {
    res.send(`Hello from TypeScript! Your hash`);
  } catch (err) {
    res.status(500).send("Error processing image");
  }
});

app.get('/compute', (req, res) => {
  const text = (req.query.text as string) || "default_data";
  const iterations = (req.query.iters as string) || "50000";

  // Path to the Rust binary we'll copy into the container
  const binaryPath = path.join(__dirname, '../backend/bin/encryptor');

  console.log(binaryPath, 'binaryPath');

  execFile(binaryPath, [text, iterations], (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error.message}`);
      return res.status(500).send("Computation failed");
    }
    res.send(`<pre>${stdout}</pre>`);
  });
});

import { spawn } from 'child_process';

app.get('/python', (req, res) => {
  const dataToSend = (req.query.data as string) || "hello_from_node";

  // Spawn the python process
  const pyProcess = spawn('python3', [path.join(__dirname, '../backend/python/analyze.py'), dataToSend]);

  let resultData = "";

  // Collect data from python stdout
  pyProcess.stdout.on('data', (data) => {
    resultData += data.toString();
  });

  // Handle the end of the process
  pyProcess.on('close', (code) => {
    if (code === 0) {
      try {
        const jsonResponse = JSON.parse(resultData);
        res.json({
          source: "Node.js API",
          python_output: jsonResponse
        });
      } catch (e) {
        res.status(500).send("Failed to parse Python output");
      }
    } else {
      res.status(500).send(`Python process exited with code ${code}`);
    }
  });
});

app.listen(port, () => {
  console.log(`TS Server running at http://localhost:${port}`);
});