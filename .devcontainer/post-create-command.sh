bash .devcontainer/mssql/postCreateCommand.sh 'P@ssw0rd' './bin/Debug/' './.devcontainer/mssql/'

cd react-app.client
npm i
cd ..
dotnet restore