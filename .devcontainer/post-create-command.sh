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

echo "Installing Starship prompt..."
# Install Starship if not already installed
if ! command -v starship &> /dev/null; then
    echo "Starship not found, installing..."
    # Download and verify the installation script executed successfully
    if curl -sS https://starship.rs/install.sh | sh -s -- -y > /dev/null 2>&1 && command -v starship &> /dev/null; then
        echo "Starship installed successfully"
    else
        echo "Warning: Failed to install Starship. Continuing without Starship prompt."
    fi
else
    echo "Starship is already installed"
fi

echo "Installing Fish shell..."
# Install Fish shell if not already installed
SKIP_FISH=false
if ! command -v fish &> /dev/null; then
    echo "Fish not found, installing..."
    if ! sudo apt-get update -qq; then
        echo "Warning: Failed to update package lists. Skipping Fish installation."
        SKIP_FISH=true
    elif ! sudo apt-get install -y fish; then
        echo "Warning: Failed to install Fish package. Skipping Fish configuration."
        SKIP_FISH=true
    else
        echo "Fish installed successfully"
    fi
fi

if [ "$SKIP_FISH" = false ]; then
    # Get Fish path for shell configuration
    FISH_PATH=$(command -v fish 2>/dev/null || true)
    if [ -z "$FISH_PATH" ]; then
        echo "Warning: Fish shell not found after installation. Skipping default shell configuration."
    else
        echo "Fish found at $FISH_PATH"
        
        # Initialize Starship for Fish if both are installed
        if command -v starship &> /dev/null; then
            echo "Configuring Starship for Fish..."
            # Create a local config file for Starship (separate from host-mounted config)
            mkdir -p /home/vscode/.config/fish/conf.d
            if [ ! -f /home/vscode/.config/fish/conf.d/starship.fish ]; then
                echo "starship init fish | source" > /home/vscode/.config/fish/conf.d/starship.fish
                if chown vscode:vscode /home/vscode/.config/fish/conf.d/starship.fish 2>/dev/null; then
                    echo "Added Starship initialization to Fish conf.d"
                else
                    echo "Warning: Created Starship config but failed to set ownership. File may have incorrect permissions."
                fi
            fi
        fi
        
        echo "Setting Fish as default shell..."
        # Add Fish to /etc/shells if not already there
        if ! grep -q "$FISH_PATH" /etc/shells; then
            echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
            echo "Added Fish to /etc/shells"
        fi
        if ! sudo chsh -s "$FISH_PATH" vscode; then
            echo "Warning: Failed to change default shell to Fish. Fish is in /etc/shells. You may need to run 'chsh -s \"$FISH_PATH\"' manually or check permissions."
        else
            echo "Successfully set Fish as default shell for vscode user"
        fi
    fi
fi

echo "Setup complete!"
