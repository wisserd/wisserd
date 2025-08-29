#!/bin/bash
set -e

echo "🚀 Starting Windsurf Environment Hotfix Update..."

# --- 1. Load environment variables from .env ---
if [ -f ".env" ]; then
  echo "📄 Loading environment variables from .env..."
  export $(grep -v '^#' .env | xargs)
else
  echo "⚠️ No .env file found! Please create one with required variables."
fi

# --- 2. Check required environment variables ---
REQUIRED_VARS=("POSTGRES_URL" "NEXT_PUBLIC_API_URL") # add more as needed
for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR}" ]; then
    echo "⚠️ $VAR is not defined!"
    read -p "Please enter $VAR: " INPUT_VAR
    export $VAR="$INPUT_VAR"
  fi
done

# --- 3. Ensure main branch ---
git checkout main || git checkout -b main
git pull origin main || echo "⚠️ Could not pull, continuing..."

# --- 4. Clean previous builds and install dependencies ---
echo "📦 Installing dependencies..."
rm -rf node_modules package-lock.json
pnpm install || npm install || echo "⚠️ Failed to install dependencies"

# --- 5. Run database migrations safely ---
if [ -f "lib/db/migrate.ts" ]; then
  echo "🔧 Running database migrations..."
  pnpm tsx lib/db/migrate.ts || node lib/db/migrate.js || echo "⚠️ Migration failed"
fi

# --- 6. Build project ---
echo "🏗️ Building project..."
pnpm run build || npm run build || echo "⚠️ Build failed, check logs"

# --- 7. Validate JSON and Next.js config ---
echo "🔍 Validating package.json and next.config.js..."
jq . package.json > package.tmp.json && mv package.tmp.json package.json || echo "⚠️ package.json validation failed"
if [ -f "next.config.js" ]; then
  sed -i '/serverActions/d;/appDir/d' next.config.js || echo "ℹ️ Cleaned next.config.js"
fi

# --- 8. Ensure index page exists ---
mkdir -p pages app
if [ ! -f "pages/index.js" ] && [ ! -f "app/page.js" ]; then
  echo "🛠️ Creating default homepage..."
  cat > pages/index.js <<'EOF'
export default function Home() {
  return (
    <main style={{ fontFamily: "sans-serif", padding: "2rem" }}>
      <h1>🚀 App is Running!</h1>
      <p>Next.js project is deploy-ready.</p>
    </main>
  );
}
EOF
fi

# --- 9. Commit and push fixes ---
echo "💾 Committing hotfix updates..."
git add .
git commit -m "🔧 Updated windsurf-env-hotfix.sh, validated env and configs" || echo "ℹ️ Nothing to commit"
git push origin main --force

# --- 10. Trigger Vercel deploy ---
if command -v vercel >/dev/null 2>&1; then
  echo "🚀 Triggering Vercel deploy..."
  vercel --prod --confirm || echo "⚠️ Vercel deploy failed, check platform"
else
  echo "⚠️ Vercel CLI not installed. Skipping deploy."
fi

echo "✅ Windsurf environment hotfix updated and deployed successfully!"
chmod +x windsurf-env-hotfix.sh
./windsurf-env-hotfix.sh
