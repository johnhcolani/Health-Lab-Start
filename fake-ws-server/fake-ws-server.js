// fake-ws-server.js
const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 }, () => {
  console.log('Fake WS server listening on ws://localhost:8080');
});

wss.on('connection', (ws) => {
  console.log('Client connected');
  const id = setInterval(() => {
    const hr = 60 + Math.round(Math.random() * 40); // 60..100
    const spo2 = 95 + Math.round(Math.random() * 4); // 95..99
    const payload = JSON.stringify({ hr, spo2, ts: Date.now() });
    ws.send(payload);
  }, 1000);

  ws.on('close', () => {
    clearInterval(id);
    console.log('Client disconnected');
  });
});
