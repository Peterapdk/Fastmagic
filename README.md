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
