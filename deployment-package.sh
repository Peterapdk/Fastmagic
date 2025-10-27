# Create comprehensive README.md
cat > README.md << 'EOF'
# FastMCP Cloud Installer v2.0 - GitHub MCP Edition

One-click installation of MCP servers with GitHub MCP Server automation.

## 🎯 Features

- ✅ **GitHub MCP Server Integration** - Automated Git operations via MCP
- ✅ **GitHub Token Authentication** - Secure repository access
- ✅ **Official mcpservers.org Integration** - Access verified MCP servers
- ✅ **FastMCP Cloud Direct Integration** - Auto-generate mcp.json configs
- 🔍 **Advanced Search & Filtering** - Find servers by category
- 📜 **Installation History** - Track what you've installed
- 🔄 **Automatic PR Creation** - Fork, update, and submit PRs via MCP
- 🎨 **Beautiful UI** - Modern design with glassmorphism effects
- ⚡ **MCP Status Indicator** - Real-time connection status

## 🚀 Quick Start

### Prerequisites

1. Node.js 18+ installed
2. GitHub Personal Access Token
3. (Optional) Claude API access for MCP automation

### Setup GitHub Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes:
   - `repo` (Full control of private repositories)
   - `user` (Read user profile data)
4. Generate and copy your token

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/fastmcp-installer.git
cd fastmcp-installer

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Add your GitHub token to .env
echo "GITHUB_PERSONAL_ACCESS_TOKEN=your_token_here" >> .env

# Start development server
npm run dev
```

Open http://localhost:3000 and login with your GitHub token.

## 📖 How It Works

### GitHub MCP Server Integration

This app uses the official GitHub MCP server (`@modelcontextprotocol/server-github`) to automate Git operations:

1. **Authentication**: User provides GitHub token
2. **MCP Connection**: App connects to GitHub MCP server with token
3. **Installation Flow**:
   - User clicks "Install" on a server
   - App sends request to Claude API with GitHub MCP tools
   - MCP server handles:
     - Repository forking
     - File creation/updates
     - Commits
     - Pull request creation
4. **Result**: Fully automated installation with PR created

### Architecture

```
User Interface (React)
    ↓
Claude API with GitHub MCP
    ↓
GitHub MCP Server (@modelcontextprotocol/server-github)
    ↓
GitHub API (via token)
    ↓
FastMCP Cloud Repository
```

## 🔧 Configuration

### Environment Variables

```env
# GitHub Token (Required)
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxxxxxxxxxxxx

# FastMCP Repository
VITE_FASTMCP_REPO=jlowin/fastmcp

# MCP Servers API
VITE_MCP_SERVERS_API=https://mcpservers.org/api/servers
```

### MCP Server Configuration

The app automatically configures the GitHub MCP server:

```javascript
{
  mcp_servers: {
    github: {
      command: "npx",
      args: ["-y", "@modelcontextprotocol/server-github"],
      env: {
        GITHUB_PERSONAL_ACCESS_TOKEN: "your_token"
      }
    }
  }
}
```

## 📦 Installation Modes

### 1. MCP-Powered Installation (Automatic)

When GitHub MCP server is connected:
- ✅ Automatic repository forking
- ✅ Automatic mcp.json updates
- ✅ Automatic commits
- ✅ Automatic PR creation
- ✅ Status updates in real-time

### 2. Direct Installation (Fallback)

If MCP server is unavailable:
- ✅ Fork repository via GitHub API
- ✅ Update mcp.json manually
- ✅ User creates PR manually
- ⚠️ More steps required

## 🛠️ Development

### Run Locally

```bash
npm run dev
```

### Build for Production

```bash
npm run build
```

### Test MCP Connection

```bash
# Install GitHub MCP server globally
npm install -g @modelcontextprotocol/server-github

# Test it
npx @modelcontextprotocol/server-github
```

## 🌐 Deploy

### GitHub Pages

```bash
npm run deploy
```

### Vercel

```bash
npm i -g vercel
vercel --prod
```

### Netlify

```bash
npm i -g netlify-cli
netlify deploy --prod
```

## 🔐 Security

- Tokens stored in localStorage (browser-based)
- Never commit .env file
- Use token with minimal required scopes
- Regularly rotate tokens
- Monitor token usage on GitHub

## 🐛 Troubleshooting

### MCP Server Shows "Disconnected"

**Cause**: GitHub token not provided or invalid

**Solution**:
1. Check token in localStorage
2. Verify token has correct scopes
3. Ensure token hasn't expired
4. Re-login with fresh token

### Installation Fails

**Cause**: Various issues (rate limits, permissions, etc.)

**Solution**:
1. Check GitHub token permissions
2. Verify repository access
3. Check GitHub API rate limits
4. Try fallback installation mode

### CORS Errors

**Cause**: Direct Claude API calls from browser

**Solution**:
1. Use serverless function proxy
2. Deploy backend for API calls
3. Configure CORS headers properly

## 📋 MCP Server Commands

The GitHub MCP server supports these operations:

- `create_repository` - Create new repo
- `fork_repository` - Fork existing repo
- `create_or_update_file` - Add/update files
- `push_files` - Commit and push changes
- `create_pull_request` - Create PR
- `get_file_contents` - Read files
- `search_repositories` - Find repos
- `create_issue` - Create issues
- `list_commits` - View history

## 🎓 Learn More

- [GitHub MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/github)
- [Model Context Protocol](https://modelcontextprotocol.io)
- [FastMCP Cloud](https://github.com/jlowin/fastmcp)
- [MCP Servers Registry](https://mcpservers.org)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## 📄 License

MIT License - Free to use for any purpose

## 🙏 Acknowledgments

- Anthropic for Model Context Protocol
- FastMCP team for the framework
- GitHub MCP server contributors
- MCP community

---

**Made with ❤️ for the MCP community**
EOF#!/bin/bash
# FastMCP Cloud Installer v2 - With GitHub MCP Server
# Includes GitHub OAuth, mcpservers.org integration, FastMCP config, and MCP automation

echo "🚀 FastMCP Cloud Installer v2 - GitHub MCP Edition"
echo "===================================================="

# Create project structure
echo "📁 Creating project structure..."
mkdir -p fastmcp-installer
cd fastmcp-installer

# Create package.json
cat > package.json << 'EOF'
{
  "name": "fastmcp-installer",
  "version": "2.0.0",
  "description": "One-click MCP server installer for FastMCP Cloud with GitHub OAuth",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "deploy": "npm run build && gh-pages -d dist"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "lucide-react": "^0.263.1"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^4.3.9",
    "gh-pages": "^5.0.0",
    "autoprefixer": "^10.4.14",
    "postcss": "^8.4.24",
    "tailwindcss": "^3.3.2"
  }
}
EOF

# Create vite.config.js
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  base: '/fastmcp-installer/',
  server: {
    port: 3000
  }
})
EOF

# Create tailwind.config.js
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

# Create postcss.config.js
cat > postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# Create index.html
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>FastMCP Cloud Installer</title>
    <meta name="description" content="One-click installation of MCP servers with GitHub OAuth integration">
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

# Create src directory
mkdir -p src

# Create src/main.jsx
cat > src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

# Create src/index.css
cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  padding: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New', monospace;
}
EOF

# Copy the React app component from artifact
echo "Note: Copy the App.jsx content from the artifact into src/App.jsx"

# Create .env.example for GitHub OAuth and MCP
cat > .env.example << 'EOF'
# GitHub OAuth Configuration
VITE_GITHUB_CLIENT_ID=your_github_client_id_here
VITE_GITHUB_CLIENT_SECRET=your_github_client_secret_here
VITE_REDIRECT_URI=http://localhost:3000/callback

# FastMCP Configuration
VITE_FASTMCP_REPO=jlowin/fastmcp
VITE_MCP_SERVERS_API=https://mcpservers.org/api/servers

# GitHub MCP Server Configuration
# Get your token at: https://github.com/settings/tokens
# Required scopes: repo, user
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token_here
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*

node_modules
dist
dist-ssr
*.local
.env

# Editor directories and files
.vscode/*
!.vscode/extensions.json
.idea
.DS_Store
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?
EOF

# Create comprehensive README.md
cat > README.md << 'EOF'
# FastMCP Cloud Installer v2.0

One-click installation of MCP servers from mcpservers.org into FastMCP Cloud with GitHub OAuth integration.

## 🎯 Features

- ✅ **GitHub OAuth Authentication** - Secure login and repository access
- ✅ **Official mcpservers.org Integration** - Access verified MCP servers
- ✅ **FastMCP Cloud Direct Integration** - Auto-generate mcp.json configs
- 🔍 **Advanced Search & Filtering** - Find servers by category
- 📜 **Installation History** - Track what you've installed
- 🔄 **Automatic PR Creation** - Fork, update, and submit PRs automatically
- 🎨 **Beautiful UI** - Modern design with glassmorphism effects

## 🚀 Quick Start

### Prerequisites

1. Node.js 18+ installed
2. GitHub account
3. GitHub OAuth App (for authentication)

### Setup GitHub OAuth App

1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in the details:
   - **Application name:** FastMCP Cloud Installer
   - **Homepage URL:** `http://localhost:3000` (for development)
   - **Authorization callback URL:** `http://localhost:3000/callback`
4. Click "Register application"
5. Copy the **Client ID** and generate a **Client Secret**

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/fastmcp-installer.git
cd fastmcp-installer

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Edit .env and add your GitHub OAuth credentials
# VITE_GITHUB_CLIENT_ID=your_client_id
# VITE_GITHUB_CLIENT_SECRET=your_client_secret
nano .env

# Start development server
npm run dev
```

### Deploy to GitHub Pages

```bash
# Build and deploy
npm run deploy
```

## 📖 Usage Guide

### 1. Authentication

- Click "Login with GitHub" button
- Authorize the application
- You'll be redirected back with access

### 2. Browse Servers

- Use search bar to find specific servers
- Filter by category (database, api, ai, etc.)
- View server details, stars, and descriptions

### 3. Install a Server

- Click "Install" on any server
- The app will:
  1. Fork the FastMCP Cloud repository
  2. Generate proper mcp.json configuration
  3. Commit the changes
  4. Create a Pull Request
  5. Show you the configuration preview

### 4. Deploy Your Instance

After installation:
```bash
# In your forked FastMCP repository
pip install git+https://github.com/AUTHOR/SERVER_REPO.git

# Deploy to your preferred platform
# (Railway, Render, Vercel, etc.)
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file with:

```env
VITE_GITHUB_CLIENT_ID=your_github_client_id
VITE_GITHUB_CLIENT_SECRET=your_github_client_secret
VITE_REDIRECT_URI=http://localhost:3000/callback
VITE_FASTMCP_REPO=jlowin/fastmcp
VITE_MCP_SERVERS_API=https://mcpservers.org/api/servers
```

### FastMCP Configuration Format

The installer generates configurations in this format:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "python",
      "args": ["-m", "server-name"],
      "env": {},
      "disabled": false,
      "alwaysAllow": []
    }
  }
}
```

## 🏗️ Project Structure

```
fastmcp-installer/
├── src/
│   ├── App.jsx          # Main application component
│   ├── main.jsx         # React entry point
│   └── index.css        # Global styles
├── public/              # Static assets
├── .github/
│   └── workflows/
│       └── deploy.yml   # GitHub Actions for deployment
├── package.json
├── vite.config.js
├── tailwind.config.js
└── README.md
```

## 🔐 Security Notes

- Never commit `.env` file to repository
- GitHub tokens are stored in localStorage (use with caution)
- OAuth tokens have limited scope (repo access only)
- Always review PRs before merging

## 🛠️ Development

### Run locally

```bash
npm run dev
```

### Build for production

```bash
npm run build
```

### Preview production build

```bash
npm run preview
```

## 📦 GitHub OAuth Callback Handler

Create `src/Callback.jsx`:

```jsx
import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

export default function Callback() {
  const navigate = useNavigate();

  useEffect(() => {
    const handleCallback = async () => {
      const params = new URLSearchParams(window.location.search);
      const code = params.get('code');
      const state = params.get('state');
      
      const savedState = localStorage.getItem('github_oauth_state');
      
      if (state !== savedState) {
        console.error('State mismatch');
        navigate('/');
        return;
      }

      // Exchange code for token
      const response = await fetch('/api/github/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code })
      });

      const data = await response.json();
      
      if (data.access_token) {
        localStorage.setItem('github_token', data.access_token);
        
        // Fetch user data
        const userResponse = await fetch('https://api.github.com/user', {
          headers: {
            Authorization: `token ${data.access_token}`
          }
        });
        
        const user = await userResponse.json();
        localStorage.setItem('github_user', JSON.stringify(user));
      }

      navigate('/');
    };

    handleCallback();
  }, [navigate]);

  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="text-center">
        <h2 className="text-2xl mb-4">Authenticating...</h2>
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600 mx-auto"></div>
      </div>
    </div>
  );
}
```

## 🌐 Backend API (Optional)

For production, create a backend to securely handle OAuth:

```javascript
// api/github/token.js (Vercel serverless function)
export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { code } = req.body;

  const response = await fetch('https://github.com/login/oauth/access_token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json'
    },
    body: JSON.stringify({
      client_id: process.env.GITHUB_CLIENT_ID,
      client_secret: process.env.GITHUB_CLIENT_SECRET,
      code
    })
  });

  const data = await response.json();
  res.status(200).json(data);
}
```

## 🐛 Troubleshooting

### GitHub OAuth Issues

- Ensure callback URL matches exactly in GitHub OAuth App settings
- Check that Client ID and Secret are correct
- Verify redirect URI in `.env` file

### API Rate Limits

- GitHub API has rate limits (60 req/hour unauthenticated, 5000 authenticated)
- Authenticated requests use your OAuth token

### CORS Issues

- For local development, you may need a proxy
- In production, use serverless functions or backend API

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - feel free to use this project for any purpose.

## 🔗 Links

- [FastMCP Cloud](https://github.com/jlowin/fastmcp)
- [MCP Servers](https://mcpservers.org)
- [Model Context Protocol](https://modelcontextprotocol.io)
- [GitHub OAuth Documentation](https://docs.github.com/en/apps/oauth-apps)

## 🙏 Acknowledgments

- Anthropic for the Model Context Protocol
- FastMCP team for the excellent framework
- MCP community for the server registry

---

Made with ❤️ for the MCP community
EOF

# Create GitHub Actions workflow
mkdir -p .github/workflows
cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Build
        env:
          VITE_GITHUB_CLIENT_ID: ${{ secrets.VITE_GITHUB_CLIENT_ID }}
        run: npm run build
        
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          path: ./dist

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v2
EOF

# Create API directory for serverless functions
mkdir -p api/github
cat > api/github/token.js << 'EOF'
// Serverless function for GitHub OAuth token exchange
// Deploy to Vercel, Netlify, or similar platform

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { code } = req.body;

    if (!code) {
      return res.status(400).json({ error: 'Code is required' });
    }

    const response = await fetch('https://github.com/login/oauth/access_token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json'
      },
      body: JSON.stringify({
        client_id: process.env.GITHUB_CLIENT_ID,
        client_secret: process.env.GITHUB_CLIENT_SECRET,
        code
      })
    });

    const data = await response.json();

    if (data.error) {
      return res.status(400).json({ error: data.error_description });
    }

    res.status(200).json(data);
  } catch (error) {
    console.error('OAuth error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
EOF

# Create vercel.json for Vercel deployment
cat > vercel.json << 'EOF'
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "framework": "vite",
  "env": {
    "VITE_GITHUB_CLIENT_ID": "@github-client-id"
  }
}
EOF

# Create SETUP_GUIDE.md
cat > SETUP_GUIDE.md << 'EOF'
# FastMCP Cloud Installer - Complete Setup Guide

## Step 1: GitHub OAuth App Setup

### Create OAuth App

1. Go to https://github.com/settings/developers
2. Click "OAuth Apps" → "New OAuth App"
3. Fill in:
   ```
   Application name: FastMCP Cloud Installer
   Homepage URL: https://YOUR_USERNAME.github.io/fastmcp-installer
   Authorization callback URL: https://YOUR_USERNAME.github.io/fastmcp-installer/callback
   ```
4. Register the app
5. Copy your **Client ID**
6. Generate and copy a **Client Secret**

### For Local Development

Use these URLs instead:
- Homepage URL: `http://localhost:3000`
- Callback URL: `http://localhost:3000/callback`

## Step 2: Configure Environment Variables

### Local Development

```bash
cp .env.example .env
nano .env
```

Add your credentials:
```env
VITE_GITHUB_CLIENT_ID=your_client_id_here
VITE_GITHUB_CLIENT_SECRET=your_client_secret_here
VITE_REDIRECT_URI=http://localhost:3000/callback
```

### GitHub Pages Deployment

1. Go to repository Settings → Secrets and variables → Actions
2. Add repository secret:
   - Name: `VITE_GITHUB_CLIENT_ID`
   - Value: Your GitHub OAuth Client ID

**Note:** Don't add the client secret to GitHub Actions - handle OAuth exchange via serverless function

## Step 3: Deploy Backend (For OAuth Token Exchange)

### Option A: Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
vercel

# Add environment variables
vercel env add GITHUB_CLIENT_ID
vercel env add GITHUB_CLIENT_SECRET

# Deploy to production
vercel --prod
```

### Option B: Netlify

```bash
# Install Netlify CLI
npm i -g netlify-cli

# Login
netlify login

# Deploy
netlify deploy

# Add environment variables in Netlify dashboard
```

### Option C: Railway

1. Connect your GitHub repository
2. Add environment variables in Railway dashboard
3. Deploy automatically on push

## Step 4: Update Frontend Configuration

Update `src/App.jsx` with your backend URL:

```javascript
const exchangeCodeForToken = async (code) => {
  const response = await fetch('YOUR_BACKEND_URL/api/github/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ code })
  });
  return response.json();
};
```

## Step 5: Deploy Frontend

### GitHub Pages

```bash
npm run deploy
```

### Vercel (Full Stack)

```bash
vercel --prod
```

### Netlify

```bash
netlify deploy --prod
```

## Step 6: Test the Application

1. Open your deployed URL
2. Click "Login with GitHub"
3. Authorize the application
4. Try installing an MCP server
5. Check that PR is created successfully

## Troubleshooting

### OAuth Redirect Issues

- Ensure callback URL matches exactly (including trailing slash)
- Check browser console for errors
- Verify OAuth app is active

### API Rate Limits

- Use authenticated requests (automatic after login)
- Consider caching server list
- Implement request throttling

### CORS Errors

- Ensure backend has proper CORS headers
- Use serverless function proxy
- Check browser network tab for details

### Build Errors

```bash
# Clear cache
rm -rf node_modules package-lock.json
npm install
npm run build
```

## Production Checklist

- [ ] GitHub OAuth App configured with production URLs
- [ ] Environment variables set in deployment platform
- [ ] Backend deployed and responding
- [ ] Frontend deployed successfully
- [ ] Test OAuth flow end-to-end
- [ ] Test server installation creates PR
- [ ] Monitor error logs
- [ ] Set up analytics (optional)

## Security Best Practices

1. Never commit `.env` file
2. Use environment variables for secrets
3. Implement rate limiting
4. Validate all inputs
5. Use HTTPS everywhere
6. Review OAuth scopes regularly
7. Monitor for unusual activity

## Support

- GitHub Issues: Report bugs and request features
- Documentation: Check README.md
- Community: Join MCP Discord/Forum

EOF

echo ""
echo "✅ Enhanced project structure created!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Review SETUP_GUIDE.md for complete setup instructions"
echo ""
echo "2. Set up GitHub OAuth App:"
echo "   - Visit https://github.com/settings/developers"
echo "   - Create new OAuth App"
echo "   - Get Client ID and Secret"
echo ""
echo "3. Configure environment:"
echo "   cd fastmcp-installer"
echo "   cp .env.example .env"
echo "   # Edit .env with your OAuth credentials"
echo ""
echo "4. Install and run locally:"
echo "   npm install"
echo "   npm run dev"
echo ""
echo "5. Deploy to GitHub:"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Initial commit: FastMCP Installer v2'"
echo "   gh repo create fastmcp-installer --public --source=. --push"
echo ""
echo "6. Enable GitHub Pages:"
echo "   - Go to Settings → Pages"
echo "   - Select 'GitHub Actions' as source"
echo "   - Add VITE_GITHUB_CLIENT_ID secret"
echo ""
echo "7. Deploy backend (Vercel/Netlify/Railway) for OAuth"
echo ""
echo "🎉 Your FastMCP Installer v2 is ready!"
echo "📖 Read SETUP_GUIDE.md for detailed instructions"

# Create quick-start.sh helper script
cat > quick-start.sh << 'QUICKSTART'
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
QUICKSTART

chmod +x quick-start.sh

echo ""
# Create MCP_SETUP_GUIDE.md
cat > MCP_SETUP_GUIDE.md << 'EOF'
# GitHub MCP Server Setup Guide

## Overview

This guide explains how to set up and use the GitHub MCP server for automated repository operations.

## What is GitHub MCP Server?

The GitHub MCP server (`@modelcontextprotocol/server-github`) is an official MCP implementation that provides:
- Repository management (create, fork, clone)
- File operations (read, write, update, delete)
- Git operations (commit, push, pull)
- Pull request management
- Issue tracking
- Branch management

## Installation Methods

### Method 1: NPX (Recommended for Production)

The app uses `npx` to run the MCP server on-demand:

```javascript
{
  command: "npx",
  args: ["-y", "@modelcontextprotocol/server-github"],
  env: {
    GITHUB_PERSONAL_ACCESS_TOKEN: "your_token"
  }
}
```

**Pros:**
- No installation required
- Always uses latest version
- Automatic updates
- No global dependencies

**Cons:**
- Slightly slower first run
- Requires internet connection

### Method 2: Global Installation

Install the MCP server globally:

```bash
npm install -g @modelcontextprotocol/server-github
```

Then configure:

```javascript
{
  command: "mcp-server-github",
  args: [],
  env: {
    GITHUB_PERSONAL_ACCESS_TOKEN: "your_token"
  }
}
```

### Method 3: Local Project Installation

Add to your project:

```bash
npm install @modelcontextprotocol/server-github
```

Configure:

```javascript
{
  command: "node",
  args: ["node_modules/@modelcontextprotocol/server-github/dist/index.js"],
  env: {
    GITHUB_PERSONAL_ACCESS_TOKEN: "your_token"
  }
}
```

## GitHub Token Setup

### Creating a Token

1. Visit https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name: "FastMCP Installer"
4. Expiration: Choose appropriate duration
5. Select scopes:

**Required Scopes:**
- ✅ `repo` - Full control of repositories
  - `repo:status` - Access commit status
  - `repo_deployment` - Access deployment status
  - `public_repo` - Access public repositories
  - `repo:invite` - Access repository invitations
- ✅ `user` - Read user profile data
  - `read:user` - Read user profile
  - `user:email` - Access user email

**Optional Scopes:**
- `workflow` - Update GitHub Actions workflows
- `write:packages` - Upload packages
- `delete:packages` - Delete packages

6. Generate token
7. Copy token immediately (shown only once)

### Storing the Token

**Development:**
```bash
# In .env file
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxxxxxxxxxxxx
```

**Production:**
- Use environment variables
- Use secrets management (Vercel, Netlify, etc.)
- Never commit to repository
- Rotate regularly

### Token Security Best Practices

1. **Minimal Scopes**: Only use required scopes
2. **Expiration**: Set reasonable expiration dates
3. **Rotation**: Rotate tokens every 90 days
4. **Monitoring**: Check token usage on GitHub
5. **Revocation**: Revoke immediately if compromised
6. **Storage**: Use secure storage (not plaintext)

## Using the MCP Server via Claude API

The FastMCP Installer uses Claude API to communicate with the GitHub MCP server:

```javascript
const response = await fetch('https://api.anthropic.com/v1/messages', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 4000,
    tools: [{
      type: "computer_use_20241022",
      name: "mcp",
      mcp_servers: {
        github: {
          command: "npx",
          args: ["-y", "@modelcontextprotocol/server-github"],
          env: {
            GITHUB_PERSONAL_ACCESS_TOKEN: token
          }
        }
      }
    }],
    messages: [
      {
        role: "user",
        content: "Fork the repository jlowin/fastmcp"
      }
    ]
  })
});
```

## MCP Server Operations

### 1. Fork Repository

```javascript
content: `Fork the repository ${owner}/${repo} to ${username}'s account`
```

### 2. Create/Update File

```javascript
content: `In repository ${username}/${repo}, create or update file ${path} with content: ${content}`
```

### 3. Commit Changes

```javascript
content: `Commit changes to ${username}/${repo} with message: ${message}`
```

### 4. Create Pull Request

```javascript
content: `Create pull request from ${username}:${branch} to ${owner}:main with title: ${title} and body: ${body}`
```

### 5. Combined Workflow

```javascript
content: `
1. Fork repository ${owner}/${repo}
2. Create file ${path} with content: ${content}
3. Commit with message: ${message}
4. Create pull request with title: ${title}
`
```

## Testing MCP Connection

### Manual Test

```bash
# Set token
export GITHUB_PERSONAL_ACCESS_TOKEN=your_token

# Run MCP server
npx @modelcontextprotocol/server-github

# Server should start and show available tools
```

### Programmatic Test

```javascript
async function testMCPConnection(token) {
  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 1000,
        tools: [{
          type: "computer_use_20241022",
          name: "mcp",
          mcp_servers: {
            github: {
              command: "npx",
              args: ["-y", "@modelcontextprotocol/server-github"],
              env: { GITHUB_PERSONAL_ACCESS_TOKEN: token }
            }
          }
        }],
        messages: [{ 
          role: "user", 
          content: "List available GitHub tools" 
        }]
      })
    });
    
    const data = await response.json();
    console.log('MCP Connection:', data.content);
    return true;
  } catch (error) {
    console.error('MCP Connection Failed:', error);
    return false;
  }
}
```

## Troubleshooting

### Error: "GitHub token not found"

**Solution:**
- Verify token in environment variables
- Check token is not expired
- Ensure token has correct format (starts with `ghp_`)

### Error: "Permission denied"

**Solution:**
- Verify token scopes include `repo`
- Check if repository is private (needs `repo` scope)
- Confirm token hasn't been revoked

### Error: "Rate limit exceeded"

**Solution:**
- GitHub API has rate limits:
  - 5000 requests/hour (authenticated)
  - 60 requests/hour (unauthenticated)
- Wait for rate limit reset
- Implement caching
- Use conditional requests

### Error: "MCP server not responding"

**Solution:**
- Check internet connection
- Verify npx can download packages
- Try global installation instead
- Check firewall settings

### Error: "Fork already exists"

**Solution:**
- Check if repository is already forked
- Use existing fork
- Delete old fork and retry

## Advanced Configuration

### Custom MCP Server Path

```javascript
{
  command: "/usr/local/bin/mcp-server-github",
  args: ["--verbose"],
  env: {
    GITHUB_PERSONAL_ACCESS_TOKEN: token,
    GITHUB_API_URL: "https://api.github.com"
  }
}
```

### Multiple GitHub Accounts

```javascript
{
  mcp_servers: {
    github_personal: {
      command: "npx",
      args: ["-y", "@modelcontextprotocol/server-github"],
      env: { GITHUB_PERSONAL_ACCESS_TOKEN: token1 }
    },
    github_work: {
      command: "npx",
      args: ["-y", "@modelcontextprotocol/server-github"],
      env: { GITHUB_PERSONAL_ACCESS_TOKEN: token2 }
    }
  }
}
```

### Logging and Debugging

```javascript
{
  command: "npx",
  args: ["-y", "@modelcontextprotocol/server-github"],
  env: {
    GITHUB_PERSONAL_ACCESS_TOKEN: token,
    DEBUG: "true",
    LOG_LEVEL: "debug"
  }
}
```

## Best Practices

1. **Token Management**
   - Use different tokens for dev/prod
   - Set appropriate expiration
   - Monitor token usage
   - Rotate regularly

2. **Error Handling**
   - Always catch errors
   - Provide fallback methods
   - Log errors for debugging
   - Show user-friendly messages

3. **Rate Limiting**
   - Implement request throttling
   - Cache responses when possible
   - Use conditional requests
   - Monitor rate limit headers

4. **Security**
   - Never log tokens
   - Use HTTPS only
   - Validate all inputs
   - Sanitize file paths

5. **Performance**
   - Batch operations when possible
   - Use webhooks for long operations
   - Implement retry logic
   - Cache server list

## Resources

- [GitHub MCP Server Repo](https://github.com/modelcontextprotocol/servers/tree/main/src/github)
- [GitHub API Documentation](https://docs.github.com/en/rest)
- [MCP Specification](https://spec.modelcontextprotocol.io)
- [Token Permissions Guide](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps)

## Support

- GitHub Issues: Report MCP server bugs
- Community Discord: Get help from community
- Documentation: Check official MCP docs
- Stack Overflow: Search for solutions

EOF