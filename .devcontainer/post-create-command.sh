bash .devcontainer/mssql/postCreateCommand.sh 'P@ssw0rd' './bin/Debug/' './.devcontainer/mssql/'

echo "Setting permissions"
# sudo chown vscode /home/vscode/.npm
sudo chown vscode /workspaces/asp-net-react-devcontainer/react-app.client/node_modules
sudo chown vscode /workspaces/asp-net-react-devcontainer/react-app.Server/bin
sudo chown vscode /workspaces/asp-net-react-devcontainer/react-app.Server/obj

echo "Restoring dotnet packages"
dotnet restore
# dotnet tool restore
# dotnet ef database update

echo "Restoring npm packages"
npm --prefix react-app.client install
