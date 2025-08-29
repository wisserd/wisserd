// db-check.js
import pg from 'pg';

const { Client } = pg;

async function checkDatabase() {
  const dbUrl = process.env.POSTGRES_URL;

  if (!dbUrl) {
    console.error("❌ ERROR: POSTGRES_URL is not defined in your environment variables.");
    console.error("➡️  Fix: Add POSTGRES_URL in your .env file or Vercel Project Settings.");
    process.exit(1);
  }

  const client = new Client({ connectionString: dbUrl });

  try {
    await client.connect();
    console.log("✅ SUCCESS: Connected to PostgreSQL!");
    const res = await client.query('SELECT NOW() as now');
    console.log(`📅 Database time: ${res.rows[0].now}`);
  } catch (err) {
    console.error("❌ ERROR: Could not connect to PostgreSQL.");
    console.error("➡️  Check your connection string, database host, and firewall settings.");
    console.error(err.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

checkDatabase();
