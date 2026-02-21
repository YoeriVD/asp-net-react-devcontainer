#!/bin/bash

echo "Restoring dotnet packages"
dotnet restore

echo "Installing npm packages"
npm --prefix react-app.client install

echo "Setup complete!"