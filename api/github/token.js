export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { token } = req.body;

  if (!token) {
    return res.status(400).json({ error: 'Token is required' });
  }

  try {
    // Validate token by fetching user data
    const response = await fetch('https://api.github.com/user', {
      headers: {
        'Authorization': `token ${token}`,
        'Accept': 'application/vnd.github.v3+json'
      }
    });

    if (!response.ok) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    const userData = await response.json();

    res.status(200).json({
      valid: true,
      user: {
        login: userData.login,
        id: userData.id,
        avatar_url: userData.avatar_url
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to validate token' });
  }
}
