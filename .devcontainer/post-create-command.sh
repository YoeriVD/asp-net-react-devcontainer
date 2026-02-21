#!/bin/bash

# Install mssql-tools if not already installed
echo "Checking for mssql-tools installation..."
if ! command -v sqlcmd &> /dev/null && [ ! -f /opt/mssql-tools18/bin/sqlcmd ] && [ ! -f /opt/mssql-tools/bin/sqlcmd ]; then
    echo "Installing mssql-tools..."
    
    # Install prerequisites
    sudo apt-get update
    sudo apt-get install -y curl apt-transport-https gnupg lsb-release
    
    # Import the Microsoft repository GPG key
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
    
    # Add the Microsoft SQL Server repository
    UBUNTU_VERSION=$(lsb_release -rs)
    curl -sSL "https://packages.microsoft.com/config/ubuntu/${UBUNTU_VERSION}/prod.list" | sudo tee /etc/apt/sources.list.d/mssql-release.list || \
    curl -sSL "https://packages.microsoft.com/config/ubuntu/22.04/prod.list" | sudo tee /etc/apt/sources.list.d/mssql-release.list
    
    # Update package lists
    sudo apt-get update
    
    # Install mssql-tools18 (latest version with encryption support)
    ACCEPT_EULA=Y sudo apt-get install -y mssql-tools18 unixodbc-dev
    
    # Add mssql-tools to PATH permanently
    echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
    export PATH="$PATH:/opt/mssql-tools18/bin"
    
    echo "mssql-tools installed successfully!"
else
    echo "mssql-tools already installed."
fi

# Detect sqlcmd location once before the retry loop
SQLCMD=""
if command -v sqlcmd &> /dev/null; then
    SQLCMD="sqlcmd"
elif [ -f /opt/mssql-tools18/bin/sqlcmd ]; then
    SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
elif [ -f /opt/mssql-tools/bin/sqlcmd ]; then
    SQLCMD="/opt/mssql-tools/bin/sqlcmd"
fi

# Wait for SQL Server to be ready (max 3 minutes)
MAX_RETRIES=90
echo "Waiting for SQL Server to be ready..."
SQL_READY=false
for i in $(seq 1 $MAX_RETRIES); do
    if [ -n "$SQLCMD" ]; then
        if $SQLCMD -C -S db -U sa -P "P@ssw0rd" -Q "SELECT 1" > /dev/null 2>&1; then
            echo "SQL Server is ready!"
            SQL_READY=true
            break
        fi
    fi
    echo "Waiting for SQL Server... ($i/$MAX_RETRIES)"
    sleep 2
done

if [ "$SQL_READY" = true ]; then
    echo "Initializing database..."
    $SQLCMD -C -S db -U sa -P "P@ssw0rd" -i .devcontainer/mssql/setup.sql
elif [ -n "$SQLCMD" ]; then
    echo "Error: SQL Server did not become ready within timeout period."
    exit 1
else
    echo "Warning: sqlcmd not found. Database not initialized."
fi

echo "Restoring dotnet packages..."
dotnet restore

echo "Installing npm packages..."
npm --prefix react-app.client install

echo "Setting permissions..."
sudo chown -R vscode node_modules 2>/dev/null || true
sudo chown -R vscode react-app.client/node_modules 2>/dev/null || true
sudo chown -R vscode react-app.Server/bin 2>/dev/null || true
sudo chown -R vscode react-app.Server/obj 2>/dev/null || true

echo "Setup complete!"
