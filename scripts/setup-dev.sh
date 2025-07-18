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
if [ ! -f .env ]; then
    echo "📝 Creating .env from template..."
    cp .env.example .env
    echo "⚠️  Please update .env with your actual cloud configuration values"
    echo "⚠️  Make sure to configure your cloud Supabase database settings"
fi

echo ""
echo "🎉 Development environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env with your cloud Supabase configuration"
echo "2. Ensure your Supabase project is properly configured in the cloud"
echo "3. Run 'npm run dev' in the api directory to start the development server"
echo "4. Visit the configured PORT to check the API status"
echo ""
echo "Note: This setup only supports cloud Supabase databases."
echo "Local development database support has been removed."
echo ""
echo "For more information, see the README.md file."