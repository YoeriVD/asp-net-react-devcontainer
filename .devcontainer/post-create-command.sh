#!/bin/bash

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
