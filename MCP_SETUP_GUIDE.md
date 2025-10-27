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

