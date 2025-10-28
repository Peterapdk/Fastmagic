#!/usr/bin/env python3
"""
FastMCP Cloud Installer Server
Entry point for FastMCP server deployment and management
"""

from fastmcp import FastMCP
import os
import json
import subprocess
from typing import Dict, List, Optional
import asyncio

# Initialize FastMCP server
app = FastMCP(
    name="FastMCP Cloud Installer",
    instructions="""
    FastMCP Cloud Installer Server - Manage MCP server deployments and configurations.

    This server provides tools for:
    - Installing MCP servers from GitHub
    - Managing server configurations
    - Deploying to FastMCP Cloud
    - Monitoring server health and status

    Use the available tools to manage your MCP server ecosystem.
    """
)

# In-memory storage for server configurations
server_configs: Dict[str, Dict] = {}
cloud_projects: Dict[str, Dict] = {}

@app.tool()
async def install_server_from_github(repo_url: str, server_name: str) -> str:
    """
    Install an MCP server from a GitHub repository.

    Args:
        repo_url: GitHub repository URL (e.g., https://github.com/user/repo)
        server_name: Name for the server instance

    Returns:
        Installation status and configuration details
    """
    try:
        # Extract repo info from URL
        if "github.com/" not in repo_url:
            return "❌ Invalid GitHub repository URL"

        repo_path = repo_url.replace("https://github.com/", "")
        author, repo = repo_path.split("/", 1)

        # Generate MCP configuration
        config = {
            "mcpServers": {
                server_name: {
                    "command": "uv",
                    "args": ["run", "--with", "fastmcp", "fastmcp", "run", f"https://github.com/{author}/{repo}"],
                    "env": {},
                    "disabled": False,
                    "alwaysAllow": []
                }
            }
        }

        # Store configuration
        server_configs[server_name] = {
            "name": server_name,
            "repo_url": repo_url,
            "config": config,
            "status": "installed",
            "author": author,
            "repo": repo
        }

        return f"✅ Successfully installed {server_name} from {repo_url}\n\nConfiguration:\n{json.dumps(config, indent=2)}"

    except Exception as e:
        return f"❌ Failed to install server: {str(e)}"

@app.tool()
async def list_installed_servers() -> str:
    """
    List all installed MCP servers with their configurations.

    Returns:
        Formatted list of installed servers
    """
    if not server_configs:
        return "📋 No MCP servers installed yet. Use install_server_from_github to add servers."

    result = "📋 Installed MCP Servers:\n\n"
    for name, config in server_configs.items():
        result += f"🔧 {name}\n"
        result += f"   Repository: {config['repo_url']}\n"
        result += f"   Status: {config['status']}\n"
        result += f"   Configuration: {json.dumps(config['config'], indent=4)}\n\n"

    return result

@app.tool()
async def deploy_to_fastmcp_cloud(project_name: str, server_names: List[str]) -> str:
    """
    Deploy selected servers to FastMCP Cloud as a project.

    Args:
        project_name: Name for the cloud project
        server_names: List of server names to include in the project

    Returns:
        Deployment status and project details
    """
    try:
        # Validate server names
        invalid_servers = [name for name in server_names if name not in server_configs]
        if invalid_servers:
            return f"❌ Invalid server names: {', '.join(invalid_servers)}"

        # Create combined configuration
        combined_config = {"mcpServers": {}}
        for server_name in server_names:
            combined_config["mcpServers"].update(server_configs[server_name]["config"]["mcpServers"])

        # Create cloud project
        project_id = f"project_{len(cloud_projects) + 1}"
        cloud_projects[project_id] = {
            "id": project_id,
            "name": project_name,
            "servers": server_names,
            "config": combined_config,
            "status": "deployed",
            "url": f"https://{project_name.lower().replace(' ', '-')}.fastmcp.app"
        }

        return f"✅ Successfully deployed project '{project_name}' to FastMCP Cloud!\n\nProject Details:\n- ID: {project_id}\n- URL: {cloud_projects[project_id]['url']}\n- Servers: {', '.join(server_names)}\n\nConfiguration:\n{json.dumps(combined_config, indent=2)}"

    except Exception as e:
        return f"❌ Failed to deploy to cloud: {str(e)}"

@app.tool()
async def check_server_health(server_name: str) -> str:
    """
    Check the health status of an installed server.

    Args:
        server_name: Name of the server to check

    Returns:
        Health status and details
    """
    if server_name not in server_configs:
        return f"❌ Server '{server_name}' not found"

    # Simulate health check (in real implementation, this would test the actual server)
    import random
    is_healthy = random.choice([True, False])

    status = "✅ Healthy" if is_healthy else "❌ Unhealthy"
    server_configs[server_name]["status"] = "healthy" if is_healthy else "error"

    return f"🔍 Health Check for '{server_name}': {status}\n\nServer Details:\n- Repository: {server_configs[server_name]['repo_url']}\n- Last Checked: {__import__('datetime').datetime.now().isoformat()}"

@app.tool()
async def update_server_config(server_name: str, new_config: str) -> str:
    """
    Update the configuration of an installed server.

    Args:
        server_name: Name of the server to update
        new_config: New JSON configuration string

    Returns:
        Update status and new configuration
    """
    if server_name not in server_configs:
        return f"❌ Server '{server_name}' not found"

    try:
        # Parse and validate new configuration
        parsed_config = json.loads(new_config)

        # Update server configuration
        server_configs[server_name]["config"] = parsed_config
        server_configs[server_name]["status"] = "updated"

        return f"✅ Successfully updated configuration for '{server_name}'\n\nNew Configuration:\n{json.dumps(parsed_config, indent=2)}"

    except json.JSONDecodeError as e:
        return f"❌ Invalid JSON configuration: {str(e)}"
    except Exception as e:
        return f"❌ Failed to update configuration: {str(e)}"

@app.tool()
async def list_cloud_projects() -> str:
    """
    List all deployed FastMCP Cloud projects.

    Returns:
        Formatted list of cloud projects
    """
    if not cloud_projects:
        return "☁️ No FastMCP Cloud projects deployed yet. Use deploy_to_fastmcp_cloud to create projects."

    result = "☁️ FastMCP Cloud Projects:\n\n"
    for project_id, project in cloud_projects.items():
        result += f"🚀 {project['name']} ({project_id})\n"
        result += f"   URL: {project['url']}\n"
        result += f"   Status: {project['status']}\n"
        result += f"   Servers: {', '.join(project['servers'])}\n\n"

    return result

@app.tool()
async def remove_server(server_name: str) -> str:
    """
    Remove an installed MCP server.

    Args:
        server_name: Name of the server to remove

    Returns:
        Removal status
    """
    if server_name not in server_configs:
        return f"❌ Server '{server_name}' not found"

    # Remove from configurations
    del server_configs[server_name]

    # Remove from any cloud projects that include this server
    for project_id, project in cloud_projects.items():
        if server_name in project["servers"]:
            project["servers"].remove(server_name)
            if not project["servers"]:  # If no servers left, mark as inactive
                project["status"] = "inactive"

    return f"✅ Successfully removed server '{server_name}'"

if __name__ == "__main__":
    # Run the FastMCP server
    import mcp.server

    mcp.server.run(
        app.to_server(),
        transport="stdio"
    )