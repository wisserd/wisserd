#!/usr/bin/env node

const fs = require('fs');
const fetch = require('node-fetch'); // Remove if using Node 18+ native fetch

const WINDSURF_API_BASE = 'https://api.windsurf.com/v1';
const PROJECT_ID = process.env.WINDSURF_PROJECT_ID;
const API_TOKEN = process.env.WINDSURF_API_TOKEN;

if (!PROJECT_ID || !API_TOKEN) {
  console.error('Please set WINDSURF_PROJECT_ID and WINDSURF_API_TOKEN in your environment variables.');
  process.exit(1);
}

const [,, cmd, key, value, environment = 'development'] = process.argv;

async function apiRequest(endpoint, method = 'GET', body = null) {
  const res = await fetch(`${WINDSURF_API_BASE}/projects/${PROJECT_ID}/env/${endpoint}`, {
    method,
    headers: {
      'Authorization': `Bearer ${API_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: body ? JSON.stringify(body) : null
  });
  if (!res.ok) throw new Error(`Error ${res.status}: ${await res.text()}`);
  return res.json();
}

async function addEnv() {
  if (!key || !value) return console.error('Add requires KEY and VALUE');
  const result = await apiRequest('add', 'POST', { key, value, environment });
  console.log('Added:', result);
}

async function updateEnv() {
  if (!key || !value) return console.error('Update requires KEY and VALUE');
  const result = await apiRequest('update', 'PUT', { key, value, environment });
  console.log('Updated:', result);
}

async function pullEnv() {
  const envVars = await apiRequest(`list?environment=${environment}`);
  let content = '';
  envVars.forEach(({ key, value }) => content += `${key}=${value}\n`);
  fs.writeFileSync('.env.local', content);
  console.log(`Pulled ${envVars.length} variables to .env.local`);
}

(async () => {
  try {
    switch (cmd) {
      case 'add': await addEnv(); break;
      case 'update': await updateEnv(); break;
      case 'pull': await pullEnv(); break;
      default:
        console.log('Commands: add, update, pull');
        console.log('Example: windsurf env add API_KEY abc123 development');
    }
  } catch (err) {
    console.error('Error:', err.message);
  }
})();
