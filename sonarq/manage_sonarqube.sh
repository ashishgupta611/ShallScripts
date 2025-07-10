#!/bin/bash

# Prompt for SonarQube version
read -p "Enter your SonarQube Developer Edition version (e.g., 10.2.0.68432): " version

# Define the path to the sonar.sh script
SONAR_PATH=~/bin/sonarqube-$version/bin/macosx-universal-64/sonar.sh

# Check if sonar.sh exists
if [ ! -f "$SONAR_PATH" ]; then
  echo "Error: sonar.sh not found at $SONAR_PATH"
  exit 1
fi

# Prompt for action
echo "Choose an action:"
echo "1) Stop SonarQube"
echo "2) Restart SonarQube"
read -p "Enter your choice (1 or 2): " choice

case $choice in
  1)
    echo "Stopping SonarQube..."
    $SONAR_PATH stop
    ;;
  2)
    echo "Restarting SonarQube..."
    $SONAR_PATH restart
    ;;
  *)
    echo "Invalid choice. Please enter 1 or 2."
    exit 1
    ;;
esac
