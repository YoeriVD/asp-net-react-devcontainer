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

echo "Installing Fish shell..."
# Install Fish shell if not already installed
if ! command -v fish &> /dev/null; then
    echo "Fish not found, installing..."
    if sudo apt-get update -qq && sudo apt-get install -y fish; then
        echo "Fish installed successfully"
    else
        echo "Error: Failed to install Fish. Skipping shell configuration."
        echo "Setup complete!"
        exit 0
    fi
else
    echo "Fish is already installed"
fi

echo "Setting Fish as default shell..."
# Find Fish shell path and set as default if it exists
FISH_PATH=$(command -v fish 2>/dev/null || true)
if [ -n "$FISH_PATH" ]; then
    echo "Fish found at $FISH_PATH, setting as default shell..."
    # Add Fish to /etc/shells if not already there
    if ! grep -q "$FISH_PATH" /etc/shells; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
        echo "Added Fish to /etc/shells"
    fi
    if ! sudo chsh -s "$FISH_PATH" vscode; then
        echo "Warning: Failed to change default shell to Fish. Fish is in /etc/shells. You may need to run 'chsh -s \"$FISH_PATH\"' manually or check permissions."
    fi
else
    echo "Warning: Fish shell not found. Skipping default shell configuration."
fi

echo "Setup complete!"
