#!/usr/bin/env node

/**
 * Windsurf CLI for environment variables
 * Usage:
 *   node windsurf-env-cli.js add KEY VALUE [ENVIRONMENT]
 *   node windsurf-env-cli.js update KEY VALUE [ENVIRONMENT]
 *   node windsurf-env-cli.js pull [ENVIRONMENT]
 */

const fs = require('fs');
const fetch = require('node-fetch'); // Node 18+ has native fetch, remove require if using Node 18+

const WINDSURF_API_BASE = 'https://api.windsurf.com/v1';
const PROJECT_ID = process.env.WINDSURF_PROJECT_ID; // Set your project ID
const API_TOKEN = process.env.WINDSURF_API_TOKEN;   // Set your Windsurf API token

if (!PROJECT_ID || !API_TOKEN) {
  console.error('Please set WINDSURF_PROJECT_ID and WINDSURF_API_TOKEN environment variables.');
  process.exit(1);
}

const [,, command, key, value, environment = 'development'] = process.argv;

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
  if (!key || !value) return console.error('Add command requires KEY and VALUE');
  const result = await apiRequest('add', 'POST', { key, value, environment });
  console.log('Added:', result);
}

async function updateEnv() {
  if (!key || !value) return console.error('Update command requires KEY and VALUE');
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
    switch (command) {
      case 'add': await addEnv(); break;
      case 'update': await updateEnv(); break;
      case 'pull': await pullEnv(); break;
      default:
        console.log('Commands: add, update, pull');
        console.log('Example: node windsurf-env-cli.js add API_KEY abc123 development');
    }
  } catch (err) {
    console.error('Error:', err.message);
  }
})();
