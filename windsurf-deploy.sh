#!/bin/bash
# Windsurf Deploy Script - Fixes env issues, builds, and deploys

echo "🔹 Windsurf Deploy Script Starting..."

# 1. Ensure pnpm is installed
if ! command -v pnpm &> /dev/null
then
    echo "🔹 Installing pnpm..."
    npm install -g pnpm
fi

# 2. Load environment variables from .env
if [ -f ".env" ]; then
    echo "🔹 Loading environment variables from .env"
    export $(grep -v '^#' .env | xargs)
else
    echo "⚠️ No .env file found. Please create one with POSTGRES_URL, JWT_SECRET, etc."
    exit 1
fi

# 3. Sync environment variables with Vercel
echo "🔹 Syncing env variables with Vercel..."
vercel env add POSTGRES_URL production <<< "$POSTGRES_URL"
vercel env add JWT_SECRET production <<< "$JWT_SECRET"
vercel env add STRIPE_SECRET_KEY production <<< "$STRIPE_SECRET_KEY"
vercel env add STRIPE_PUBLIC_KEY production <<< "$STRIPE_PUBLIC_KEY"

# 4. Install dependencies
echo "🔹 Installing dependencies..."
pnpm install

# 5. Build the app
echo "🔹 Building the app..."
pnpm run build

# 6. Deploy to Vercel
echo "🔹 Deploying to Vercel..."
vercel --prod

echo "✅ Windsurf Deploy Complete!"
