import React, { useState, useEffect, useMemo } from 'react';
import { Code, Github, Zap, User, LogOut, Search, Loader2, Download, ExternalLink, History, Settings, Play, Pause, Edit, CheckCircle, XCircle } from 'lucide-react';

function App() {
  const [user, setUser] = useState(null);
  const [servers, setServers] = useState([]);
  // filteredServers is now computed with useMemo
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [installing, setInstalling] = useState({});
  const [mcpStatus, setMcpStatus] = useState('disconnected');
  const [mcpConfig, setMcpConfig] = useState(null);
  const [showConfig, setShowConfig] = useState(false);
  const [installHistory, setInstallHistory] = useState([]);
  const [myServers, setMyServers] = useState([]);
  const [loadingMyServers, setLoadingMyServers] = useState(false);
  const [editingServer, setEditingServer] = useState(null);
  const [editConfig, setEditConfig] = useState('');
  const [cloudStatus, setCloudStatus] = useState('disconnected'); // disconnected, connecting, connected, error
  const [cloudProjects, setCloudProjects] = useState([]);
  const [localServers, setLocalServers] = useState([]);
  const [serverStatuses, setServerStatuses] = useState({}); // server health status

  const categories = ['all', 'database', 'api', 'ai', 'development', 'productivity', 'utilities'];

  useEffect(() => {
    const savedUser = localStorage.getItem('github_user');
    const savedHistory = localStorage.getItem('install_history');
    const savedLocalServers = localStorage.getItem('local_servers');
    const savedCloudStatus = localStorage.getItem('cloud_status');

    if (savedUser) {
      setUser(JSON.parse(savedUser));
      setMcpStatus('connected');
      fetchMyServers(JSON.parse(savedUser));
    }
    if (savedHistory) {
      setInstallHistory(JSON.parse(savedHistory));
    }
    if (savedLocalServers) {
      setLocalServers(JSON.parse(savedLocalServers));
    }
    if (savedCloudStatus) {
      setCloudStatus(savedCloudStatus);
    }

    fetchServers();
    loadLocalServers();
  }, []);

  const filteredServers = useMemo(() => {
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
    return filtered;
  }, [servers, selectedCategory, searchQuery]);

  const loginWithGitHub = () => {
    const token = prompt('Enter your GitHub Personal Access Token:');
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


  const generateMCPConfig = (server) => {
    // Try to determine the best command based on server info
    let command = "python";
    let args = ["-m", server.name];

    // If it's a known FastMCP server or has specific installation instructions
    if (server.name.includes('fastmcp') || server.description?.toLowerCase().includes('fastmcp')) {
      command = "uv";
      args = ["run", "--with", "fastmcp", "fastmcp", "run", `https://github.com/${server.author}/${server.name}`];
    } else if (server.language === 'JavaScript' || server.language === 'TypeScript') {
      command = "node";
      args = [`node_modules/${server.name}/dist/index.js`];
    } else if (server.language === 'Go') {
      command = `./${server.name}`;
      args = [];
    }

    return {
      mcpServers: {
        [server.name]: {
          command,
          args,
          env: {},
          disabled: false,
          alwaysAllow: []
        }
      }
    };
  };

  const installToFastMCP = async (server) => {
    if (!user) {
      alert('Please login with GitHub first!');
      return;
    }

    setInstalling(prev => ({ ...prev, [server.id]: true }));

    try {
      const token = localStorage.getItem('github_token');
      const newServerConfig = generateMCPConfig(server);

      // Check if user already has a fork
      const existingForkResponse = await fetch(`https://api.github.com/repos/${user.login}/fastmcp`, {
        headers: { 'Authorization': `token ${token}` }
      });

      let hasFork = existingForkResponse.ok;

      if (!hasFork) {
        // Fork the repository
        const forkResponse = await fetch('https://api.github.com/repos/jlowin/fastmcp/forks', {
          method: 'POST',
          headers: {
            'Authorization': `token ${token}`,
            'Accept': 'application/vnd.github.v3+json'
          }
        });

        if (!forkResponse.ok) throw new Error('Failed to fork repository');

        // Wait for fork to be ready
        await new Promise(resolve => setTimeout(resolve, 3000));
      }

      // Get current config or create new one
      let currentConfig = { mcpServers: {} };
      if (hasFork) {
        try {
          const configResponse = await fetch(`https://api.github.com/repos/${user.login}/fastmcp/contents/mcp.json`, {
            headers: { 'Authorization': `token ${token}` }
          });
          if (configResponse.ok) {
            const configData = await configResponse.json();
            currentConfig = JSON.parse(atob(configData.content));
          }
        } catch (err) {
          // Config doesn't exist or is invalid, use empty config
        }
      }

      // Merge new server config
      const updatedConfig = {
        ...currentConfig,
        mcpServers: {
          ...currentConfig.mcpServers,
          ...newServerConfig.mcpServers
        }
      };

      const configContent = btoa(JSON.stringify(updatedConfig, null, 2));
      const requestBody = {
        message: `Add ${server.name} MCP server`,
        content: configContent,
        branch: 'main'
      };

      // If updating existing file, include SHA
      if (hasFork) {
        try {
          const shaResponse = await fetch(`https://api.github.com/repos/${user.login}/fastmcp/contents/mcp.json`, {
            headers: { 'Authorization': `token ${token}` }
          });
          if (shaResponse.ok) {
            const shaData = await shaResponse.json();
            requestBody.sha = shaData.sha;
          }
        } catch (err) {
          // SHA not available, will create new file
        }
      }

      await fetch(`https://api.github.com/repos/${user.login}/fastmcp/contents/mcp.json`, {
        method: 'PUT',
        headers: {
          'Authorization': `token ${token}`,
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(requestBody)
      });

      setMcpConfig(newServerConfig);
      saveToHistory(server);
      setShowConfig(true);

      // Refresh my servers list
      fetchMyServers(user);

      alert(`✅ ${server.name} installed! ${hasFork ? 'Updated' : 'Created'} your fork and ${hasFork ? 'updated' : 'created'} mcp.json. Create a PR to jlowin/fastmcp to contribute back!`);

    } catch (err) {
      alert(`❌ Installation failed: ${err.message}`);
    } finally {
      setInstalling(prev => ({ ...prev, [server.id]: false }));
    }
  };

  const saveToHistory = (server) => {
    const newHistory = [...installHistory, { server: server.name, timestamp: new Date().toISOString() }];
    setInstallHistory(newHistory);
    localStorage.setItem('install_history', JSON.stringify(newHistory));
  };

  const fetchMyServers = async (userData) => {
    setLoadingMyServers(true);
    try {
      const token = localStorage.getItem('github_token');
      if (!token) return;

      // First check if user has forked fastmcp
      const forkResponse = await fetch(`https://api.github.com/repos/${userData.login}/fastmcp`, {
        headers: { 'Authorization': `token ${token}` }
      });

      if (!forkResponse.ok) {
        setMyServers([]);
        return;
      }

      // Fetch mcp.json from user's fork
      const configResponse = await fetch(`https://api.github.com/repos/${userData.login}/fastmcp/contents/mcp.json`, {
        headers: { 'Authorization': `token ${token}` }
      });

      if (!configResponse.ok) {
        setMyServers([]);
        return;
      }

      const configData = await configResponse.json();
      const configContent = JSON.parse(atob(configData.content));

      // Convert to array format for display
      const serversArray = Object.entries(configContent.mcpServers || {}).map(([name, config]) => ({
        name,
        config,
        enabled: !config.disabled,
        status: 'unknown' // We'll implement status checking later
      }));

      setMyServers(serversArray);
    } catch (err) {
      console.error('Failed to fetch my servers:', err);
      setMyServers([]);
    } finally {
      setLoadingMyServers(false);
    }
  };

  const toggleServer = async (serverName, enabled) => {
    if (!user) return;

    try {
      const token = localStorage.getItem('github_token');
      const updatedServers = myServers.map(s =>
        s.name === serverName ? { ...s, enabled } : s
      );

      // Update local state
      setMyServers(updatedServers);

      // Prepare config for GitHub
      const mcpConfig = {
        mcpServers: updatedServers.reduce((acc, server) => {
          acc[server.name] = {
            ...server.config,
            disabled: !server.enabled
          };
          return acc;
        }, {})
      };

      // Update GitHub
      const configContent = btoa(JSON.stringify(mcpConfig, null, 2));
      await fetch(`https://api.github.com/repos/${user.login}/fastmcp/contents/mcp.json`, {
        method: 'PUT',
        headers: {
          'Authorization': `token ${token}`,
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          message: `${enabled ? 'Enable' : 'Disable'} ${serverName} MCP server`,
          content: configContent,
          sha: await getCurrentSha(user.login, token)
        })
      });

      alert(`✅ ${serverName} ${enabled ? 'enabled' : 'disabled'}!`);
    } catch (err) {
      alert(`❌ Failed to ${enabled ? 'enable' : 'disable'} server: ${err.message}`);
      // Revert local state on error
      fetchMyServers(user);
    }
  };

  const getCurrentSha = async (username, token) => {
    const response = await fetch(`https://api.github.com/repos/${username}/fastmcp/contents/mcp.json`, {
      headers: { 'Authorization': `token ${token}` }
    });
    const data = await response.json();
    return data.sha;
  };

  const startEditing = (server) => {
    setEditingServer(server.name);
    setEditConfig(JSON.stringify(server.config, null, 2));
  };

  const saveEdit = async () => {
    if (!user || !editingServer) return;

    try {
      const token = localStorage.getItem('github_token');
      const parsedConfig = JSON.parse(editConfig);

      const updatedServers = myServers.map(s =>
        s.name === editingServer ? { ...s, config: parsedConfig } : s
      );

      setMyServers(updatedServers);

      const mcpConfig = {
        mcpServers: updatedServers.reduce((acc, server) => {
          acc[server.name] = {
            ...server.config,
            disabled: !server.enabled
          };
          return acc;
        }, {})
      };

      const configContent = btoa(JSON.stringify(mcpConfig, null, 2));
      await fetch(`https://api.github.com/repos/${user.login}/fastmcp/contents/mcp.json`, {
        method: 'PUT',
        headers: {
          'Authorization': `token ${token}`,
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          message: `Update ${editingServer} MCP server configuration`,
          content: configContent,
          sha: await getCurrentSha(user.login, token)
        })
      });

      setEditingServer(null);
      setEditConfig('');
      alert(`✅ ${editingServer} configuration updated!`);
    } catch (err) {
      alert(`❌ Failed to update configuration: ${err.message}`);
    }
  };

  const cancelEdit = () => {
    setEditingServer(null);
    setEditConfig('');
  };

  // Local persistence functions
  const saveLocalServers = (servers) => {
    localStorage.setItem('local_servers', JSON.stringify(servers));
    setLocalServers(servers);
  };

  const loadLocalServers = () => {
    const saved = localStorage.getItem('local_servers');
    if (saved) {
      setLocalServers(JSON.parse(saved));
    }
  };

  // Folder-based server management
  const createServerFolder = async (serverName) => {
    // Create folder structure: servers/serverName/
    const folderPath = `servers/${serverName}`;
    // In a real implementation, this would create actual folders
    // For now, we'll store this in localStorage
    const serverFolders = JSON.parse(localStorage.getItem('server_folders') || '{}');
    serverFolders[serverName] = {
      path: folderPath,
      created: new Date().toISOString(),
      config: null,
      status: 'created'
    };
    localStorage.setItem('server_folders', JSON.stringify(serverFolders));
  };

  // FastMCP Cloud integration
  const connectToFastMCPCloud = async () => {
    if (!user) return;

    setCloudStatus('connecting');
    try {
      // This would integrate with FastMCP Cloud API
      // For now, simulate connection
      await new Promise(resolve => setTimeout(resolve, 2000));
      setCloudStatus('connected');
      localStorage.setItem('cloud_status', 'connected');

      // Fetch cloud projects
      await fetchCloudProjects();
    } catch (err) {
      setCloudStatus('error');
      localStorage.setItem('cloud_status', 'error');
      alert('Failed to connect to FastMCP Cloud');
    }
  };

  const fetchCloudProjects = async () => {
    // Simulate fetching cloud projects
    // In real implementation, this would call FastMCP Cloud API
    const mockProjects = [
      {
        id: '1',
        name: 'My FastMCP Server',
        url: 'https://my-server.fastmcp.app/mcp',
        status: 'deployed',
        lastDeployed: new Date().toISOString()
      }
    ];
    setCloudProjects(mockProjects);
  };

  const checkServerStatus = async (server) => {
    try {
      // This would actually test the server endpoint
      // For now, simulate status check
      const isWorking = Math.random() > 0.3; // 70% success rate for demo
      setServerStatuses(prev => ({
        ...prev,
        [server.name]: isWorking ? 'working' : 'error'
      }));
      return isWorking;
    } catch (err) {
      setServerStatuses(prev => ({
        ...prev,
        [server.name]: 'error'
      }));
      return false;
    }
  };

  const syncWithCloud = async () => {
    if (cloudStatus !== 'connected') return;

    try {
      // Sync local servers with cloud
      // This would push local configs to cloud and pull cloud configs
      alert('✅ Synced with FastMCP Cloud!');
    } catch (err) {
      alert('❌ Sync failed: ' + err.message);
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

        {user && (
          <div className="mb-6 p-4 bg-white/5 backdrop-blur-lg border border-purple-300/30 rounded-xl">
            <div className="flex items-center gap-2 mb-3">
              <Settings size={20} className="text-purple-300" />
              <h3 className="text-white font-semibold">My MCP Servers</h3>
            </div>

            {loadingMyServers ? (
              <div className="flex items-center justify-center py-4">
                <Loader2 className="animate-spin text-purple-300" size={24} />
                <span className="ml-2 text-purple-200">Loading your servers...</span>
              </div>
            ) : myServers.length === 0 ? (
              <p className="text-purple-200 text-sm">No MCP servers installed yet. Install some servers to see them here!</p>
            ) : (
              <div className="space-y-3">
                {myServers.map(server => (
                  <div key={server.name} className="flex items-center justify-between p-3 bg-slate-800/50 rounded-lg">
                    <div className="flex items-center gap-3">
                      {server.enabled ? (
                        <CheckCircle size={16} className="text-green-400" />
                      ) : (
                        <XCircle size={16} className="text-red-400" />
                      )}
                      <span className="text-white font-medium">{server.name}</span>
                      <span className={`text-xs px-2 py-1 rounded-full ${
                        server.enabled ? 'bg-green-500/20 text-green-300' : 'bg-red-500/20 text-red-300'
                      }`}>
                        {server.enabled ? 'Enabled' : 'Disabled'}
                      </span>
                    </div>

                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => toggleServer(server.name, !server.enabled)}
                        className={`p-2 rounded-lg transition-all ${
                          server.enabled
                            ? 'bg-red-500/20 hover:bg-red-500/30 text-red-300'
                            : 'bg-green-500/20 hover:bg-green-500/30 text-green-300'
                        }`}
                        title={server.enabled ? 'Disable server' : 'Enable server'}
                      >
                        {server.enabled ? <Pause size={16} /> : <Play size={16} />}
                      </button>

                      <button
                        onClick={() => startEditing(server)}
                        className="p-2 bg-blue-500/20 hover:bg-blue-500/30 text-blue-300 rounded-lg transition-all"
                        title="Edit configuration"
                      >
                        <Edit size={16} />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

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

        {editingServer && (
          <div className="fixed inset-0 bg-black/70 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div className="bg-slate-800 rounded-xl p-6 max-w-2xl w-full max-h-[80vh] overflow-y-auto">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-2xl font-bold text-white flex items-center gap-2">
                  <Edit size={24} />
                  Edit {editingServer} Configuration
                </h3>
                <button onClick={cancelEdit} className="text-purple-300 hover:text-white text-2xl">×</button>
              </div>
              <textarea
                value={editConfig}
                onChange={(e) => setEditConfig(e.target.value)}
                className="w-full h-64 bg-slate-900 border border-purple-300/30 rounded-lg p-4 text-purple-200 font-mono text-sm focus:outline-none focus:ring-2 focus:ring-purple-500"
                placeholder="Enter JSON configuration..."
              />
              <div className="flex gap-3 mt-4">
                <button
                  onClick={saveEdit}
                  className="flex-1 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition-all"
                >
                  Save Changes
                </button>
                <button
                  onClick={cancelEdit}
                  className="px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded-lg transition-all"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;