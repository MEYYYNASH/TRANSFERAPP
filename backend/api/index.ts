import http from 'http';
import crypto from 'crypto';

interface PairingStore {
  [sessionId: string]: {
    qrToken: string;
    verificationCode: string;
    expiresAt: number;
    status: 'pending' | 'approved' | 'expired';
  };
}

const pairingSessions: PairingStore = {};

const PORT = process.env.PORT || 4000;

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const url = new URL(req.url || '/', `http://${req.headers.host}`);

  // Health check
  if (url.pathname === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', name: 'PIXELDROP Backend', timestamp: Date.now() }));
    return;
  }

  // 1. Create a 5-minute Pairing Session
  if (url.pathname === '/api/pairing/create' && req.method === 'POST') {
    const sessionId = crypto.randomUUID();
    const qrToken = crypto.randomBytes(16).toString('hex');
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes

    pairingSessions[sessionId] = {
      qrToken,
      verificationCode,
      expiresAt,
      status: 'pending',
    };

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ sessionId, qrToken, verificationCode, expiresAt }));
    return;
  }

  // 2. Validate QR / Verification Code
  if (url.pathname === '/api/pairing/verify' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => (body += chunk));
    req.on('end', () => {
      try {
        const { sessionId, verificationCode } = JSON.parse(body);
        const session = pairingSessions[sessionId];

        if (!session) {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Session not found' }));
          return;
        }

        if (Date.now() > session.expiresAt) {
          session.status = 'expired';
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Pairing session expired (5 min limit)' }));
          return;
        }

        if (session.verificationCode !== verificationCode) {
          res.writeHead(401, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Invalid verification code' }));
          return;
        }

        session.status = 'approved';
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'approved', message: 'Device paired successfully!' }));
      } catch (err: any) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Not found' }));
});

server.listen(PORT, () => {
  console.log(`PIXELDROP Backend running on port ${PORT}`);
});
