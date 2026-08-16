#!/bin/bash
# Update and install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Create app directory
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

# Create a simple server
cat <<EOF > index.js
const http = require('http');
const port = 8000;

const server = http.createServer((req, res) => {
  if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Health Check OK\n');
  } else {
    res.writeHead(404);
    res.end();
  }
});

server.listen(port, '0.0.0.0', () => {
  console.log('Server running on port ' + port);
});
EOF

# Start the server (using nohup for a simple background process)
nohup node index.js > output.log 2>&1 &