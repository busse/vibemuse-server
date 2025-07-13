#!/bin/bash

# VibeMUSE Development Environment Setup Script
# This script sets up the development environment for VibeMUSE

set -e

echo "🚀 Setting up VibeMUSE development environment..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ and try again."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Check if Supabase CLI is available
if ! command -v npx &> /dev/null; then
    echo "❌ npx is not available. Please install a recent version of Node.js/npm."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Install API dependencies
echo "📦 Installing API dependencies..."
cd api
npm install

# Build the project
echo "🔨 Building the project..."
npm run build

echo "✅ API setup complete"

# Go back to root
cd ..

# Create logs directory
mkdir -p logs

# Copy environment file if it doesn't exist
if [ ! -f .env.local ]; then
    echo "📝 Creating .env.local from template..."
    cp .env.example .env.local
    echo "⚠️  Please update .env.local with your actual configuration values"
fi

# Start Supabase (if available)
echo "🗄️  Starting Supabase local development..."
if npx supabase start; then
    echo "✅ Supabase started successfully"
    
    # Run migrations
    echo "🔄 Running database migrations..."
    npx supabase db push
    
    # Generate TypeScript types
    echo "📝 Generating TypeScript types..."
    npx supabase gen types typescript --local > types/supabase.ts
    
    echo "✅ Database setup complete"
else
    echo "⚠️  Could not start Supabase locally. Please check your Docker setup."
    echo "   You can still run the API server, but database features will be limited."
fi

echo ""
echo "🎉 Development environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env.local with your configuration"
echo "2. Run 'npm run dev' in the api directory to start the development server"
echo "3. Visit http://localhost:3000/health to check the API status"
echo "4. Visit http://localhost:54323 to access Supabase Studio (if running)"
echo ""
echo "For more information, see the README.md file."