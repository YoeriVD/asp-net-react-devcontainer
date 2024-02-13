FROM mcr.microsoft.com/devcontainers/dotnet:1-8.0-bookworm

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
# RUN dotnet tool install -g dotnet-ef
ENV PATH $PATH:/root/.dotnet/tools

# Install packages so they are cached

COPY react-app.client/package*.json /workspaces/asp-net-react-devcontainer/react-app.client/
RUN cd /workspaces/asp-net-react-devcontainer/react-app.client && npm ci

COPY react-app.Server/react-app.Server.csproj /workspaces/asp-net-react-devcontainer/react-app.Server/
# 3 times restore hack to solve issue "It might have been deleted since NuGet restore. Otherwise, NuGet restore might have only partially completed."
RUN cd /workspaces/asp-net-react-devcontainer/react-app.Server && dotnet restore && dotnet restore && dotnet restore