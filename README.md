[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=YoeriVD_asp-net-react-devcontainer&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=YoeriVD_asp-net-react-devcontainer)

# ASP.NET Core + React DevContainer

A development container setup for ASP.NET Core 9.0 backend with React frontend and SQL Server database.

## Features

- **ASP.NET Core 9.0** - Backend API
- **React + Vite** - Frontend application  
- **SQL Server 2022** - Database
- **DevContainer Features** - No custom Dockerfile needed
  - Node.js LTS (via devcontainer feature)
  - MSSQL command-line tools (via devcontainer feature)

## Getting Started

1. Open this repository in VS Code
2. When prompted, click "Reopen in Container"
3. Wait for the container to build and initialize
4. The database will be created automatically on first run

## What's Included

- **VS Code Extensions:**
  - C# Dev Kit
  - MSSQL extension with pre-configured connection
  - EditorConfig
  - Prettier

- **Database:**
  - SQL Server 2022 running in separate container
  - Database name: `ApplicationDB`
  - Connection string available as environment variable

## Development

The devcontainer will automatically:
- Install Node.js LTS
- Install MSSQL tools
- Restore .NET packages
- Install npm packages
- Initialize the database

Connection string is available in the environment:
```
ConnectionStrings__DefaultConnection=Server=db;Database=ApplicationDB;User=sa;Password=P@ssw0rd;TrustServerCertificate=True
```

> ⚠️ **Security Note**: The default password `P@ssw0rd` is intended for local development only. Never use this password or these credentials in production or any non-development environment.
