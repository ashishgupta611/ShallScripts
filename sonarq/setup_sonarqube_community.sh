#!/bin/bash

# Prompt for SonarQube Community Edition version
read -p "Enter the SonarQube Community Edition version (e.g., 10.2.0.68432): " VERSION

# Default to latest known version if empty
if [[ -z "$VERSION" ]]; then
  echo "Version number cannot be empty. Using default version 10.4.1.88267"
  VERSION=10.4.1.88267
fi

# Set up directories
mkdir -p ~/bin ~/tmp
cd ~/tmp || exit 1

# System tuning for macOS
echo "Applying macOS system tuning for Elasticsearch..."
sudo sysctl -w kern.maxfiles=131072
sudo sysctl -w kern.maxfilesperproc=131072
ulimit -n 131072

# Download SonarQube Community Edition
echo "Downloading SonarQube Community Edition version $VERSION..."
curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${VERSION}.zip

# Extract and move to bin
echo "Extracting SonarQube..."
unzip sonarqube-${VERSION}.zip
cp -R sonarqube-${VERSION} ~/bin/

# Install SonarScanner via Homebrew
echo "Installing SonarScanner..."
brew install sonar-scanner

# Start SonarQube server
echo "Starting SonarQube server..."
~/bin/sonarqube-${VERSION}/bin/macosx-universal-64/sonar.sh start

echo "SonarQube Community Edition setup complete."
echo "Access it at http://localhost:9000"
