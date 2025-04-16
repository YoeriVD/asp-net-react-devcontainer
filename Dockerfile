FROM mcr.microsoft.com/devcontainers/dotnet:1-9.0-bookworm as base

# Install SQL Tools: SQLPackage and sqlcmd
COPY .devcontainer/mssql/installSQLtools.sh installSQLtools.sh
RUN bash ./installSQLtools.sh \
     && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="--lts"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# Install dotnet tools
RUN dotnet tool install -g dotnet-ef
ENV PATH $PATH:/root/.dotnet/tools

FROM base as build
# Install packages so they are cached
WORKDIR /workspaces/asp-net-react-devcontainer
COPY react-app.client/package*.json react-app.client/
RUN cd react-app.client && npm ci

COPY react-app.Server/react-app.Server.csproj react-app.Server/
COPY react-app.client/react-app.client.esproj react-app.client/
RUN cd react-app.Server && dotnet restore

COPY . .

RUN cd react-app.Server/ && ls && dotnet publish -c Release --no-restore -o /app/publish