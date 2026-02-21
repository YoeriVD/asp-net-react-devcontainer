#!/bin/bash

# Wait for PostgreSQL to be ready (max 3 minutes)
MAX_RETRIES=90
echo "Waiting for PostgreSQL to be ready..."
POSTGRES_READY=false
for i in $(seq 1 $MAX_RETRIES); do
    if PGPASSWORD=P@ssw0rd psql -h db -U postgres -d ApplicationDB -c "SELECT 1" > /dev/null 2>&1; then
        echo "PostgreSQL is ready!"
        POSTGRES_READY=true
        break
    fi
    echo "Waiting for PostgreSQL... ($i/$MAX_RETRIES)"
    sleep 2
done

if [ "$POSTGRES_READY" = false ]; then
    echo "Warning: PostgreSQL did not become ready within timeout period."
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

echo "Setting Fish as default shell..."
# Find Fish shell path and set as default if it exists
FISH_PATH=$(command -v fish 2>/dev/null || true)
if [ -n "$FISH_PATH" ]; then
    echo "Fish found at $FISH_PATH, setting as default shell..."
    sudo chsh -s "$FISH_PATH" vscode
else
    echo "Warning: Fish shell not found. Skipping default shell configuration."
fi

echo "Setup complete!"
