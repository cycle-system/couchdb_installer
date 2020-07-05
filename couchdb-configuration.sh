#!/bin/bash

# Install dependencies and couchdb

sudo apt-get install -y apt-transport-https gnupg ca-certificates
echo "deb https://apache.bintray.com/couchdb-deb bionic main" | sudo tee -a /etc/apt/sources.list.d/couchdb.list

# Install the CouchDB repository key

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8756C4F765C9AC3CB6B85D62379CE192D401AB61

# Update the repository cache and install the package

sudo apt update
sudo apt install -y couchdb

# Configure environment variable
# ! INFO : This will added two times the env varible if run twice.

echo '' >> ~/.bashrc
echo '#Add couchdb to environment variables' >> ~/.bashrc
echo '' >> ~/.bashrc
echo 'export PATH=$PATH:/opt/couchdb/bin' >> ~/.bashrc
source ~/.bashrc
