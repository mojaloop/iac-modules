#!/usr/bin/env node

import { createServer } from 'node:http';
import { URL } from 'node:url';

const KETO_READ_URL = process.env.KETO_READ_URL || 'http://keto-read.ory.svc.cluster.local';
const PORT = process.env.PORT || 3000;

const server = createServer(async (req, res) => {
    if (req.url === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'ok' }));
        return;
    }

    if (req.method !== 'POST') {
        res.writeHead(405, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Method not allowed' }));
        return;
    }

    try {
        const chunks = [];
        for await (const chunk of req) {
            chunks.push(chunk);
        }
        const body = Buffer.concat(chunks).toString();
        const requestData = JSON.parse(body);

        const ketoResponse = await fetch(`${KETO_READ_URL}/relation-tuples/batch/check`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(requestData),
        });

        const ketoData = await ketoResponse.json();
        const results = ketoData.results || [];
        const hasAllowed = results.some(result => result.allowed === true);
        
        if (hasAllowed) {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ authorized: true, results }));
        } else {
            res.writeHead(403, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ authorized: false, results }));
        }
        
    } catch (error) {
        console.error('Proxy error:', error);
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Internal server error' }));
    }
});

server.listen(PORT, () => {
    console.log(`Keto auth proxy listening on port ${PORT}`);
    console.log(`Proxying to: ${KETO_READ_URL}`);
});

process.on('SIGINT', () => {
    console.log('\nShutting down gracefully...');
    server.close(() => {
        process.exit(0);
    });
});
