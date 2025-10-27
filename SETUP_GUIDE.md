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

