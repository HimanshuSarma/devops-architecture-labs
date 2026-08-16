const express = require('express');
const cors = require('cors');

const app = express();
const port = 8000;

app.use(cors()); // Defaults to origin: '*'

app.get('/', (req, res) => {
  res.send('Hello World v2.!');
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
