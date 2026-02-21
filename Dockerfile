FROM mcr.microsoft.com/devcontainers/dotnet:1-9.0-bookworm

# Install Node.js LTS
ARG NODE_VERSION="lts/*"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi