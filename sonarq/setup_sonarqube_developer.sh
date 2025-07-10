#!/bin/bash

# Prompt for SonarQube Developer Edition version
read -p "Enter the SonarQube Developer Edition version (e.g., 10.2.0.68432): " VERSION

# Validate input
if [[ -z "$VERSION" ]]; then
  echo "Version number cannot be empty."
  exit 1
fi

# Set up directories
mkdir -p ~/bin ~/tmp
cd ~/tmp || exit

# System tuning for macOS
echo "Applying macOS system tuning for Elasticsearch..."
sudo sysctl -w kern.maxfiles=131072
sudo sysctl -w kern.maxfilesperproc=131072
ulimit -n 131072

# Download SonarQube Developer Edition
echo "Downloading SonarQube Developer Edition version $VERSION..."
curl -O https://binaries.sonarsource.com/CommercialDistribution/sonarqube-developer/sonarqube-${VERSION}.zip

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

echo "SonarQube Developer Edition setup complete."
echo "Access it at http://localhost:9000"
