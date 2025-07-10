#!/bin/bash

# Prompt user for SonarQube version
read -p "Enter your SonarQube Developer Edition version (e.g., 10.2.0.68432): " version

# Construct the path to sonar.sh
SONAR_PATH=~/bin/sonarqube-$version/bin/macosx-universal-64/sonar.sh

# Check if sonar.sh exists
if [ -f "$SONAR_PATH" ]; then
    echo "Checking SonarQube server status..."
    $SONAR_PATH status
else
    echo "SonarQube script not found at $SONAR_PATH"
    echo "Please verify the version and installation path."
fi
