#!/bin/bash
# Windsurf Deploy Script - Fixes env issues, builds, deploys, and generates secrets

echo "🔹 Windsurf Deploy Script Starting..."

# 1. Ensure pnpm is installed
if ! command -v pnpm &> /dev/null
then
    echo "🔹 Installing pnpm..."
    npm install -g pnpm
fi

# 2. Load environment variables from .env if it exists
if [ -f ".env" ]; then
    echo "🔹 Loading environment variables from .env"
    export $(grep -v '^#' .env | xargs)
else
    echo "⚠️ No .env file found. Creating temporary environment..."
fi

# 3. Generate missing secrets
generate_secret() {
    openssl rand -base64 32
}

[ -z "$JWT_SECRET" ] && export JWT_SECRET=$(generate_secret) && echo "🔑 Generated JWT_SECRET"
[ -z "$STRIPE_SECRET_KEY" ] && export STRIPE_SECRET_KEY="sk_test_$(openssl rand -hex 16)" && echo "🔑 Generated STRIPE_SECRET_KEY"
[ -z "$STRIPE_PUBLIC_KEY" ] && export STRIPE_PUBLIC_KEY="pk_test_$(openssl rand -hex 16)" && echo "🔑 Generated STRIPE_PUBLIC_KEY"

# 4. Ensure POSTGRES_URL is set
if [ -z "$POSTGRES_URL" ]; then
    echo "❌ ERROR: POSTGRES_URL is not defined!"
    echo "➡️  Set POSTGRES_URL in your .env file or Vercel Project Settings."
    exit 1
fi
echo "✅ POSTGRES_URL is set."

# 5. Sync environment variables with Vercel
echo "🔹 Syncing env variables with Vercel..."
vercel env add POSTGRES_URL production <<< "$POSTGRES_URL"
vercel env add JWT_SECRET production <<< "$JWT_SECRET"
vercel env add STRIPE_SECRET_KEY production <<< "$STRIPE_SECRET_KEY"
vercel env add STRIPE_PUBLIC_KEY production <<< "$STRIPE_PUBLIC_KEY"

# 6. Install dependencies
echo "🔹 Installing dependencies..."
pnpm install

# 7. Build the app
echo "🔹 Building the app..."
pnpm run build

# 8. Deploy to Vercel
echo "🔹 Deploying to Vercel..."
vercel --prod

echo "🎉 Windsurf Deploy Complete!"
