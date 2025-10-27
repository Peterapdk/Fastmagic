# GROK CODE AGENT DEPLOYMENT INSTRUCTIONS

You are a code agent running in GitHub Codespaces. Deploy the FastMCP Cloud Installer with GitHub MCP Server integration. Execute all commands autonomously.

## MISSION
Deploy a complete React web application for installing MCP servers with GitHub MCP automation.

## EXECUTION PLAN

### PHASE 1: PROJECT INITIALIZATION
```bash
# Create project directory
mkdir -p fastmcp-installer
cd fastmcp-installer

# Initialize package.json
cat > package.json << 'EOF'
{
  "name": "fastmcp-installer",
  "version": "2.0.0",
  "description": "FastMCP Cloud Installer with GitHub MCP Server",
  "type": "module",
  "scripts": {
    "dev": "vite --host 0.0.0.0 --port 3000",
    "build": "vite build",
    "preview": "vite preview --host 0.0.0.0 --port 4173"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "lucide-react": "^0.263.1"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^4.3.9",
    "autoprefixer": "^10.4.14",
    "postcss": "^8.4.24",
    "tailwindcss": "^3.3.2"
  }
}
EOF
```

### PHASE 2: CONFIGURATION FILES
```bash
# Vite config
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 3000
  }
})
EOF

# Tailwind config
cat > tailwind.config.js << 'EOF'
export default {
  content: ["./index.html", "./src/**/*.{js,jsx}"],
  theme: { extend: {} },
  plugins: []
}
EOF

# PostCSS config
cat > postcss.config.js << 'EOF'
export default {
  plugins: { tailwindcss: {}, autoprefixer: {} }
}
EOF

# HTML entry point
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>FastMCP Cloud Installer</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

# Git ignore
cat > .gitignore << 'EOF'
node_modules
dist
.env
*.local
EOF
```

### PHASE 3: SOURCE CODE STRUCTURE
```bash
# Create src directory
mkdir -p src

# Main React entry
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

# Tailwind CSS
cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
```

### PHASE 4: MAIN APPLICATION CODE
```bash
cat > src/App.jsx << 'APPEOF'
import React, { useState, useEffect } from 'react';
import { Search, Download, ExternalLink, AlertCircle, Loader2, Github, Code, LogOut, User, CheckCircle, History, Settings, Zap } from 'lucide-react';

export default function App() {
  const [servers, setServers] = useState([]);
  const [filteredServers, setFilteredServers] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [installing, setInstalling] = useState({});
  const [error, setError] = useState(null);
  const [user, setUser] = useState(null);
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [installHistory, setInstallHistory] = useState([]);
  const [showConfig, setShowConfig] = useState(false);
  const [mcpConfig, setMcpConfig] = useState(null);
  const [mcpStatus, setMcpStatus] = useState('disconnected');

  const categories = ['all', 'database', 'api', 'ai', 'development', 'productivity', 'utilities'];

  useEffect(() => {
    checkAuth();
    loadInstallHistory();
    fetchServers();
  }, []);

  useEffect(() => {
    filterServers();
  }, [searchQuery, servers, selectedCategory]);

  const checkAuth = () => {
    const storedUser = localStorage.getItem('github_user');
    const storedToken = localStorage.getItem('github_token');
    if (storedUser && storedToken) {
      setUser(JSON.parse(storedUser));
      setMcpStatus('connected');
    }
  };

  const loadInstallHistory = () => {
    const history = localStorage.getItem('install_history');
    if (history) {
      setInstallHistory(JSON.parse(history));
    }
  };

  const saveToHistory = (server) => {
    const newHistory = [
      { server: server.name, repo: server.repo, installedAt: new Date().toISOString() },
      ...installHistory.slice(0, 9)
    ];
    setInstallHistory(newHistory);
    localStorage.setItem('install_history', JSON.stringify(newHistory));
  };

  const loginWithGitHub = () => {
    const token = prompt('Enter your GitHub Personal Access Token:\n\nCreate at: https://github.com/settings/tokens\nScopes: repo, user');
    if (token) {
      localStorage.setItem('github_token', token);
      fetchGitHubUser(token);
    }
  };

  const fetchGitHubUser = async (token) => {
    try {
      const response = await fetch('https://api.github.com/user', {
        headers: { 'Authorization': `token ${token}` }
      });
      const userData = await response.json();
      setUser(userData);
      localStorage.setItem('github_user', JSON.stringify(userData));
      setMcpStatus('connected');
    } catch (err) {
      alert('Failed to fetch user data. Check your token.');
    }
  };

  const logout = () => {
    localStorage.removeItem('github_user');
    localStorage.removeItem('github_token');
    setUser(null);
    setMcpStatus('disconnected');
  };

  const fetchServers = async () => {
    setLoading(true);
    try {
      const queries = ['mcp+server', 'model+context+protocol', 'fastmcp'];
      const allResults = [];
      
      for (const query of queries) {
        const response = await fetch(
          `https://api.github.com/search/repositories?q=${query}+in:name,description&sort=stars&per_page=25`
        );
        const data = await response.json();
        if (data.items) allResults.push(...data.items);
      }

      const uniqueRepos = Array.from(new Map(allResults.map(item => [item.id, item])).values());
      const serverList = uniqueRepos.map(item => ({
        id: item.id,
        name: item.name,
        description: item.description || 'No description',
        author: item.owner.login,
        repo: item.full_name,
        stars: item.stargazers_count,
        url: item.html_url,
        language: item.language,
        category: categorizeServer(item.name, item.description),
        tags: [item.language, categorizeServer(item.name, item.description)].filter(Boolean)
      }));
      
      setServers(serverList);
      setFilteredServers(serverList);
    } catch (err) {
      setError('Failed to fetch servers');
    } finally {
      setLoading(false);
    }
  };

  const categorizeServer = (name, description) => {
    const text = (name + ' ' + description).toLowerCase();
    if (text.includes('database') || text.includes('sql')) return 'database';
    if (text.includes('api') || text.includes('rest')) return 'api';
    if (text.includes('ai') || text.includes('llm')) return 'ai';
    if (text.includes('dev') || text.includes('code')) return 'development';
    if (text.includes('task') || text.includes('calendar')) return 'productivity';
    return 'utilities';
  };

  const filterServers = () => {
    let filtered = servers;
    if (selectedCategory !== 'all') {
      filtered = filtered.filter(s => s.category === selectedCategory);
    }
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(s =>
        s.name.toLowerCase().includes(query) ||
        s.description.toLowerCase().includes(query) ||
        s.author.toLowerCase().includes(query)
      );
    }
    setFilteredServers(filtered);
  };

  const generateMCPConfig = (server) => ({
    mcpServers: {
      [server.name]: {
        command: "python",
        args: ["-m", server.name],
        env: {},
        disabled: false,
        alwaysAllow: []
      }
    }
  });

  const installToFastMCP = async (server) => {
    if (!user) {
      alert('Please login with GitHub first!');
      return;
    }

    setInstalling(prev => ({ ...prev, [server.id]: true }));
    
    try {
      const token = localStorage.getItem('github_token');
      const newServerConfig = generateMCPConfig(server);
      
      const forkResponse = await fetch('https://api.github.com/repos/jlowin/fastmcp/forks', {
        method: 'POST',
        headers: {
          'Authorization': `token ${token}`,
          'Accept': 'application/vnd.github.v3+json'
        }
      });

      if (!forkResponse.ok) throw new Error('Failed to fork');
      
      await new Promise(resolve => setTimeout(resolve, 3000));

      const configContent = btoa(JSON.stringify(newServerConfig, null, 2));
      await fetch(`https://api.github.com/repos/${user.login}/fastmcp/contents/mcp.json`, {
        method: 'PUT',
        headers: {
          'Authorization': `token ${token}`,
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          message: `Add ${server.name} MCP server`,
          content: configContent,
          branch: 'main'
        })
      });

      setMcpConfig(newServerConfig);
      saveToHistory(server);
      setShowConfig(true);
      alert(`✅ ${server.name} installed! Check your fork and create PR to jlowin/fastmcp`);
      
    } catch (err) {
      alert(`❌ Installation failed: ${err.message}`);
    } finally {
      setInstalling(prev => ({ ...prev, [server.id]: false }));
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      <div className="container mx-auto px-4 py-8 max-w-7xl">
        <div className="flex items-center justify-between mb-8 flex-wrap gap-4">
          <div className="flex items-center gap-3">
            <Code size={40} className="text-purple-400" />
            <div>
              <h1 className="text-4xl font-bold text-white">FastMCP Cloud Installer</h1>
              <p className="text-purple-200">GitHub MCP Server Edition</p>
            </div>
          </div>
          
          <div className="flex items-center gap-4">
            <div className={`flex items-center gap-2 px-3 py-1 rounded-lg ${
              mcpStatus === 'connected' ? 'bg-green-500/20 text-green-300' : 'bg-red-500/20 text-red-300'
            }`}>
              <Zap size={16} />
              <span className="text-sm font-medium">
                {mcpStatus === 'connected' ? 'MCP Active' : 'MCP Inactive'}
              </span>
            </div>

            {user ? (
              <>
                <div className="flex items-center gap-2 px-4 py-2 bg-white/10 rounded-lg">
                  <User size={20} className="text-purple-300" />
                  <span className="text-white">{user.login}</span>
                </div>
                <button onClick={logout} className="flex items-center gap-2 px-4 py-2 bg-red-500/20 hover:bg-red-500/30 text-red-200 rounded-lg transition-all">
                  <LogOut size={16} />
                  Logout
                </button>
              </>
            ) : (
              <button onClick={loginWithGitHub} className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white rounded-lg font-semibold transition-all">
                <Github size={20} />
                Login
              </button>
            )}
          </div>
        </div>

        {installHistory.length > 0 && (
          <div className="mb-6 p-4 bg-white/5 backdrop-blur-lg border border-purple-300/30 rounded-xl">
            <div className="flex items-center gap-2 mb-3">
              <History size={20} className="text-purple-300" />
              <h3 className="text-white font-semibold">Recent Installations</h3>
            </div>
            <div className="flex gap-2 flex-wrap">
              {installHistory.slice(0, 5).map((item, idx) => (
                <div key={idx} className="px-3 py-1 bg-purple-500/20 rounded-full text-sm text-purple-200">
                  {item.server}
                </div>
              ))}
            </div>
          </div>
        )}

        <div className="mb-6 flex gap-2 flex-wrap">
          {categories.map(cat => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-4 py-2 rounded-lg font-medium transition-all ${
                selectedCategory === cat ? 'bg-purple-600 text-white' : 'bg-white/10 text-purple-200 hover:bg-white/20'
              }`}
            >
              {cat.charAt(0).toUpperCase() + cat.slice(1)}
            </button>
          ))}
        </div>

        <div className="mb-8">
          <div className="relative">
            <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 text-purple-300" size={20} />
            <input
              type="text"
              placeholder="Search MCP servers..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-4 bg-white/10 backdrop-blur-lg border border-purple-300/30 rounded-xl text-white placeholder-purple-300/50 focus:outline-none focus:ring-2 focus:ring-purple-500"
            />
          </div>
        </div>

        {loading ? (
          <div className="flex flex-col items-center justify-center py-20">
            <Loader2 className="animate-spin text-purple-300 mb-4" size={48} />
            <p className="text-purple-200">Loading servers...</p>
          </div>
        ) : (
          <>
            <div className="mb-4 text-purple-200">
              Found {filteredServers.length} server{filteredServers.length !== 1 ? 's' : ''}
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredServers.map(server => (
                <div key={server.id} className="bg-white/10 backdrop-blur-lg border border-purple-300/30 rounded-xl p-6 hover:bg-white/15 transition-all">
                  <div className="flex items-start justify-between mb-3">
                    <h3 className="text-xl font-bold text-white flex-1">{server.name}</h3>
                    <div className="text-purple-300 text-sm">⭐ {server.stars}</div>
                  </div>
                  <p className="text-purple-200 text-sm mb-4 line-clamp-3">{server.description}</p>
                  <div className="flex gap-2 mb-4 flex-wrap">
                    {server.tags.map((tag, idx) => (
                      <span key={idx} className="px-2 py-1 bg-purple-500/30 rounded-full text-xs text-purple-100">{tag}</span>
                    ))}
                  </div>
                  <div className="text-sm text-purple-300 mb-4">by <span className="font-semibold">{server.author}</span></div>
                  <div className="flex gap-2">
                    <button
                      onClick={() => installToFastMCP(server)}
                      disabled={installing[server.id] || !user}
                      className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 disabled:from-purple-400 disabled:to-pink-400 text-white rounded-lg font-semibold transition-all disabled:cursor-not-allowed"
                    >
                      {installing[server.id] ? (
                        <>
                          <Loader2 className="animate-spin" size={16} />
                          Installing...
                        </>
                      ) : (
                        <>
                          <Download size={16} />
                          Install
                        </>
                      )}
                    </button>
                    <a href={server.url} target="_blank" rel="noopener noreferrer" className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white rounded-lg transition-all flex items-center justify-center">
                      <ExternalLink size={16} />
                    </a>
                  </div>
                </div>
              ))}
            </div>
          </>
        )}

        {showConfig && mcpConfig && (
          <div className="fixed inset-0 bg-black/70 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div className="bg-slate-800 rounded-xl p-6 max-w-2xl w-full max-h-[80vh] overflow-y-auto">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-2xl font-bold text-white flex items-center gap-2">
                  <Settings size={24} />
                  MCP Configuration
                </h3>
                <button onClick={() => setShowConfig(false)} className="text-purple-300 hover:text-white text-2xl">×</button>
              </div>
              <pre className="bg-slate-900 p-4 rounded-lg overflow-x-auto text-purple-200 text-sm">
                {JSON.stringify(mcpConfig, null, 2)}
              </pre>
              <button onClick={() => setShowConfig(false)} className="mt-4 w-full px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg transition-all">
                Close
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
APPEOF
```

### PHASE 5: INSTALL DEPENDENCIES
```bash
npm install
```

### PHASE 6: START DEVELOPMENT SERVER
```bash
# Start server in background
npm run dev &

# Wait for server to start
sleep 5

# Get the forwarded URL from Codespaces
echo "==================================="
echo "✅ DEPLOYMENT COMPLETE"
echo "==================================="
echo ""
echo "Access the app at the forwarded port 3000"
echo "GitHub Codespaces will show the URL automatically"
echo ""
echo "Next steps:"
echo "1. Open the forwarded port URL"
echo "2. Login with GitHub token from https://github.com/settings/tokens"
echo "3. Browse and install MCP servers"
echo ""
```

### PHASE 7: VERIFICATION
```bash
# Check if server is running
curl -f http://localhost:3000 > /dev/null 2>&1 && echo "✅ Server running on port 3000" || echo "❌ Server failed to start"

# Show process
ps aux | grep vite

# Show listening ports
netstat -tuln | grep 3000 || ss -tuln | grep 3000
```

## COMPLETION CRITERIA
- [ ] All files created successfully
- [ ] Dependencies installed without errors
- [ ] Development server running on port 3000
- [ ] Port forwarded in Codespaces
- [ ] Application accessible via browser
- [ ] No error messages in console

## ERROR HANDLING
If any command fails:
1. Log the error
2. Attempt to fix common issues (permissions, port conflicts)
3. Continue with remaining steps
4. Report all errors at the end

## AGENT CONSTRAINTS
- Execute commands sequentially
- Wait for long-running commands to complete
- Do not prompt for user input
- Use default values for all configurations
- Automatically forward ports in Codespaces
- Report status after each phase

## SUCCESS OUTPUT
Upon completion, output:
```
✅ FastMCP Cloud Installer deployed successfully!
🌐 Access at: [CODESPACES_URL]:3000
📖 Login with GitHub token from: https://github.com/settings/tokens
⚡ MCP Server integration ready
```

## EXECUTION COMMAND
Run this entire script non-interactively:
```bash
bash -c "$(cat << 'SCRIPT'
[PASTE ALL COMMANDS FROM PHASES 1-7 HERE]
SCRIPT
)"
```

## NOTES FOR AGENT
- This is a fully autonomous deployment
- No human interaction required
- All configurations are pre-set
- Server will run on port 3000
- GitHub Codespaces handles port forwarding
- User can access via forwarded URL
- Application requires GitHub token for full functionality
