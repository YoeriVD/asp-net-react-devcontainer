# ASP.NET React DevContainer Project

## Project Overview
This is a full-stack web application using ASP.NET Core 9.0 backend with a React (TypeScript + Vite) frontend, designed to run in a development container with MS SQL Server database support.

## Repository Structure

### Key Directories
- `react-app.Server/` - ASP.NET Core 9.0 Web API backend
- `react-app.client/` - React frontend with TypeScript and Vite
- `.devcontainer/` - DevContainer configuration files
- `.github/workflows/` - CI/CD workflows

### Important Files
- `react-app.sln` - .NET solution file (root)
- `compose.yml` - Docker Compose configuration for devcontainer
- `Dockerfile` - Container image definition
- `react-app.Server/react-app.Server.csproj` - Backend project file (.NET 9.0)
- `react-app.client/package.json` - Frontend dependencies and scripts
- `react-app.client/vite.config.ts` - Vite configuration
- `.devcontainer/devcontainer.json` - DevContainer settings
- `.devcontainer/post-create-command.sh` - Post-creation setup script

## Technology Stack

### Backend
- **Runtime**: .NET 9.0
- **Framework**: ASP.NET Core Web API
- **Database**: MS SQL Server 2025
- **API Documentation**: Swashbuckle (Swagger)

### Frontend
- **Runtime**: Node.js v24.13.0, npm 11.6.2
- **Framework**: React 19.0
- **Language**: TypeScript 5.2+
- **Build Tool**: Vite 7.0
- **Linter**: ESLint 9.39.2

## Build and Development

### Prerequisites
Before building, always ensure dependencies are installed:
1. **Backend**: Always run `dotnet restore` first
2. **Frontend**: Always run `npm --prefix react-app.client install` or `cd react-app.client && npm install`

### Build Commands

#### Complete Build Process (Recommended Order)
```bash
# 1. Restore .NET dependencies
dotnet restore

# 2. Install npm packages for frontend
npm --prefix react-app.client install

# 3. Build the entire solution
dotnet build

# 4. Build frontend separately (if needed)
cd react-app.client && npm run build
```

#### Production Build
```bash
dotnet publish -c Release --no-restore
```

### Running the Application

The application uses SPA proxy for development:
- Backend runs on default ASP.NET Core ports
- Frontend Vite dev server runs on https://localhost:5173
- The backend proxies to the frontend during development

### Testing

```bash
# Run all tests
dotnet test --verbosity normal
```

**Note**: Currently, there are no test projects in this repository. The `dotnet test` command will complete successfully but won't run any tests.

### Linting

#### Frontend Linting
**IMPORTANT**: The frontend uses ESLint 9.x which has a configuration issue. The project has `.eslintrc.cjs` but ESLint 9 expects `eslint.config.js`. The lint command in package.json currently fails.

```bash
# Lint command (currently broken - needs migration)
cd react-app.client && npm run lint
```

**Known Issue**: ESLint configuration needs migration from `.eslintrc.cjs` to `eslint.config.js` format for ESLint 9.x compatibility.

## DevContainer Environment

### Database Configuration
- **Server**: db,1433
- **Database**: ApplicationDB
- **User**: sa
- **Password**: P@ssw0rd
- **Connection String**: `Server=db;Database=ApplicationDB;User=sa;Password=P@ssw0rd`

### Post-Create Command
The `.devcontainer/post-create-command.sh` script automatically:
1. Initializes MS SQL database
2. Restores .NET packages
3. Installs npm packages
4. Sets proper permissions for node_modules, bin, and obj directories

### HTTPS Certificates
The devcontainer is configured to use HTTPS certificates. Certificates should be generated and placed at:
- Path: `/https/aspnetapp.pfx`
- Password: "password"

## CI/CD Workflows

### .NET Build Workflow (`.github/workflows/dotnet.yml`)
Runs on pushes and PRs to main branch:
1. Setup .NET 9.0.x
2. `dotnet restore`
3. `dotnet publish -c Release --no-restore`
4. `dotnet test --verbosity normal`

### Docker Image Workflow (`.github/workflows/docker-image.yml`)
Builds Docker images (configuration not viewed in detail)

## Project Configuration

### Backend Configuration Files
- `appsettings.json` - Production settings
- `appsettings.Development.json` - Development-specific settings

### Frontend Configuration Files
- `tsconfig.json` - TypeScript compiler configuration
- `tsconfig.node.json` - TypeScript config for Node.js tools
- `vite.config.ts` - Vite bundler configuration
- `.eslintrc.cjs` - ESLint rules (legacy format, needs migration)

## Common Development Patterns

### SPA Integration
The backend project references the frontend as an `esproj`:
```xml
<ProjectReference Include="..\react-app.client\react-app.client.esproj">
  <ReferenceOutputAssembly>false</ReferenceOutputAssembly>
</ProjectReference>
```

### Environment Variables
Key environment variables in devcontainer:
- `ASPNETCORE_Kestrel__Certificates__Default__Password`: "password"
- `ASPNETCORE_Kestrel__Certificates__Default__Path`: "/https/aspnetapp.pfx"
- `ConnectionStrings__DefaultConnection`: "Server=db;Database=ApplicationDB;User=sa;Password=P@ssw0rd"

## Validation Steps

Before submitting changes:
1. Run `dotnet restore` to ensure all .NET dependencies are resolved
2. Run `dotnet build` to verify the solution builds without errors
3. Run `dotnet test --verbosity normal` to ensure tests pass (even if no tests exist)
4. If modifying frontend code, run `npm --prefix react-app.client install` and verify no critical errors
5. Check that the CI workflow commands work: `dotnet publish -c Release --no-restore`

## Known Issues and Workarounds

1. **ESLint Configuration**: The frontend uses ESLint 9.x but has a legacy `.eslintrc.cjs` file. Running `npm run lint` fails. To fix, migrate to `eslint.config.js` format.

2. **No Tests**: The repository has no test projects currently. `dotnet test` completes successfully but runs zero tests.

3. **npm Vulnerabilities**: After `npm install`, there are typically 12 vulnerabilities reported. These are in development dependencies and don't require immediate action unless updating packages.

## Quality Gates
The project uses SonarCloud for code quality monitoring.

## Best Practices for Changes

1. **Always restore dependencies first** - Run `dotnet restore` before building
2. **Install npm packages** - Run `npm install` in react-app.client before frontend work
3. **Build before testing** - Ensure `dotnet build` succeeds before running tests
4. **Respect the SPA proxy setup** - Frontend runs on port 5173, backend proxies to it
5. **Use the DevContainer** - The project is optimized for DevContainer development
6. **Check permissions** - If you encounter permission errors with node_modules or bin/obj directories, the post-create script should fix them
7. **Database connection** - When working in devcontainer, use connection string with server="db" not "localhost"
