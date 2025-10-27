#!/bin/bash
# Quick Start Helper Script

echo "🚀 FastMCP Installer - Quick Start"
echo "==================================="
echo ""

# Check if in project directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Run this from the fastmcp-installer directory"
    exit 1
fi

# Check for .env file
if [ ! -f ".env" ]; then
    echo "⚠️  No .env file found. Creating from template..."
    cp .env.example .env
    echo ""
    echo "📝 Please edit .env file with your GitHub OAuth credentials:"
    echo "   1. Go to https://github.com/settings/developers"
    echo "   2. Create a new OAuth App"
    echo "   3. Add your Client ID and Secret to .env"
    echo ""
    read -p "Press Enter when ready to continue..."
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    echo "✅ Dependencies installed!"
    echo ""
fi

# Ask what to do
echo "What would you like to do?"
echo ""
echo "1) Run development server (localhost)"
echo "2) Build for production"
echo "3) Deploy to GitHub Pages"
echo "4) Deploy to Vercel"
echo "5) Setup GitHub OAuth App (opens browser)"
echo "6) Exit"
echo ""
read -p "Choose an option (1-6): " choice

case $choice in
    1)
        echo ""
        echo "🌐 Starting development server..."
        echo "📱 Open http://localhost:3000 in your browser"
        echo ""
        npm run dev
        ;;
    2)
        echo ""
        echo "🔨 Building for production..."
        npm run build
        echo "✅ Build complete! Check dist/ folder"
        ;;
    3)
        echo ""
        echo "🚀 Deploying to GitHub Pages..."
        npm run deploy
        echo "✅ Deployed! Check your GitHub Pages URL"
        ;;
    4)
        echo ""
        echo "🚀 Deploying to Vercel..."
        if ! command -v vercel &> /dev/null; then
            echo "Installing Vercel CLI..."
            npm i -g vercel
        fi
        vercel --prod
        ;;
    5)
        echo ""
        echo "🔐 Opening GitHub OAuth App setup..."
        if command -v xdg-open &> /dev/null; then
            xdg-open "https://github.com/settings/developers"
        elif command -v open &> /dev/null; then
            open "https://github.com/settings/developers"
        else
            echo "Please visit: https://github.com/settings/developers"
        fi
        ;;
    6)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac
