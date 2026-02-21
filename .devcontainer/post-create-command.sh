#!/bin/bash

echo "Waiting for SQL Server to be ready..."
for i in {1..60}; do
    # Try different sqlcmd locations
    SQLCMD=""
    if command -v sqlcmd &> /dev/null; then
        SQLCMD="sqlcmd"
    elif [ -f /opt/mssql-tools18/bin/sqlcmd ]; then
        SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
    elif [ -f /opt/mssql-tools/bin/sqlcmd ]; then
        SQLCMD="/opt/mssql-tools/bin/sqlcmd"
    fi

    if [ -n "$SQLCMD" ]; then
        if $SQLCMD -C -S db -U sa -P "P@ssw0rd" -Q "SELECT 1" > /dev/null 2>&1; then
            echo "SQL Server is ready!"
            break
        fi
    fi
    echo "Waiting for SQL Server... ($i/60)"
    sleep 2
done

if [ -n "$SQLCMD" ]; then
    echo "Initializing database..."
    $SQLCMD -C -S db -U sa -P "P@ssw0rd" -i .devcontainer/mssql/setup.sql
else
    echo "Warning: sqlcmd not found. Database not initialized."
fi

echo "Restoring dotnet packages..."
dotnet restore

echo "Installing npm packages..."
npm --prefix react-app.client install

echo "Setup complete!"
