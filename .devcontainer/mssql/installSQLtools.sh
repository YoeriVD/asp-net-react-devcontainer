#!/bin/bash
echo "Installing mssql-tools"
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc

#Download appropriate package for the OS version
#Choose only ONE of the following, corresponding to your OS version

# #Debian 9
# curl https://packages.microsoft.com/config/debian/9/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

# #Debian 10
# curl https://packages.microsoft.com/config/debian/10/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

# #Debian 11
# curl https://packages.microsoft.com/config/debian/11/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

# #Debian 12
# curl https://packages.microsoft.com/config/debian/12/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

#Manual version
# see https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver16&tabs=debian18-install%2Cdebian17-install%2Cdebian8-install%2Credhat7-13-install%2Crhel7-offline#error-the-following-signatures-couldnt-be-verified-because-the-public-key-is-not-available
echo 'deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/debian/12/prod bookworm main' | sudo tee /etc/apt/sources.list.d/msprod.list


sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18
# optional: for bcp and sqlcmd
sudo ACCEPT_EULA=Y apt-get install -y mssql-tools18
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc

echo "Installing sqlpackage"
curl -sSL -o sqlpackage.zip "https://aka.ms/sqlpackage-linux"
mkdir /opt/sqlpackage
unzip sqlpackage.zip -d /opt/sqlpackage
rm sqlpackage.zip
chmod a+x /opt/sqlpackage/sqlpackage
