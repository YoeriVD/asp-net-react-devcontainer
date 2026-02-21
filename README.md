[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=YoeriVD_asp-net-react-devcontainer&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=YoeriVD_asp-net-react-devcontainer)

# ASP.NET Core + React DevContainer

A development container setup for ASP.NET Core 9.0 backend with React frontend and PostgreSQL database.

## Features

- **ASP.NET Core 9.0** - Backend API
- **React + Vite** - Frontend application  
- **PostgreSQL 16** - Database
- **Fish Shell with Starship Prompt** - Modern terminal experience with host config sharing
- **DevContainer Features** - No custom Dockerfile needed
  - Node.js LTS (via devcontainer feature)
  - Fish shell (via devcontainer feature)
  - Starship prompt (via devcontainer feature)

## Getting Started

1. Clone this repository (keep the default name `asp-net-react-devcontainer`)
2. Open this repository in VS Code
3. When prompted, click "Reopen in Container"
4. Wait for the container to build and initialize
5. The database will be created automatically on first run

> **Note**: If you clone the repository with a different name, you'll need to update the volume paths in `.devcontainer/compose.yml` to match your repository folder name.

## What's Included

- **VS Code Extensions:**
  - C# Dev Kit
  - PostgreSQL client with pre-configured connection
  - EditorConfig
  - Prettier

- **Terminal:**
  - Fish shell as default terminal
  - Starship prompt pre-configured
  - Host Fish and Starship configurations are automatically mounted and shared

- **Database:**
  - PostgreSQL 16 running in separate container
  - Database name: `ApplicationDB`
  - Connection string available as environment variable

## Development

The devcontainer will automatically:
- Install Node.js LTS
- Install Fish shell and Starship prompt
- Set Fish as the default shell
- Mount your host Fish configuration (`~/.config/fish`)
- Mount your host Starship configuration (`~/.config/starship.toml`)
- Restore .NET packages
- Install npm packages
- Initialize the PostgreSQL database

Connection string is available in the environment:
```
ConnectionStrings__DefaultConnection=Host=db;Database=ApplicationDB;Username=postgres;Password=P@ssw0rd
```

### Shell Configuration

The devcontainer automatically shares your host's Fish and Starship configurations:
- **Fish config**: `~/.config/fish` on your host is mounted to `/home/vscode/.config/fish` in the container (read-only)
- **Starship config**: `~/.config/starship.toml` on your host is mounted to `/home/vscode/.config/starship.toml` in the container (read-only)

This means your custom Fish functions, aliases, and Starship prompt styling will be available in the container without any additional setup.

> **Note**: The configurations are mounted as read-only to prevent accidental modifications from within the container.

> ⚠️ **Security Note**: The default password `P@ssw0rd` is intended for local development only. Never use this password or these credentials in production or any non-development environment.
