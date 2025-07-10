#!/bin/bash

echo "🔧 SonarQube Cleanup Script for macOS"
read -p "Enter the SonarQube Developer Edition version to clean up (e.g., 10.2.0.68432): " VERSION

# Validate input
if [[ -z "$VERSION" ]]; then
  echo "Version number cannot be empty."
  VERSION=2025.3.1.109879
fi

# Validate input
if [[ -z "$VERSION" ]]; then
  echo "Version number cannot be empty."
  exit 1
fi

HOME_DIR="$HOME"
BIN_DIR="$HOME_DIR/bin"
TMP_DIR="$HOME_DIR/tmp"
SONARQUBE_DIR="$BIN_DIR/sonarqube-$VERSION"
SCANNER_DIR="$BIN_DIR/sonar-scanner"
SONAR_SCRIPT="$SONARQUBE_DIR/bin/macosx-universal-64/sonar.sh"

# Stop SonarQube server if running
if [ -f "$SONAR_SCRIPT" ]; then
    echo "Stopping SonarQube server..."
    "$SONAR_SCRIPT" stop
else
    echo "SonarQube server script not found. Skipping stop step."
fi

# Remove SonarQube directory
if [ -d "$SONARQUBE_DIR" ]; then
    echo "Removing SonarQube directory: $SONARQUBE_DIR"
    rm -rf "$SONARQUBE_DIR"
else
    echo "SonarQube directory not found. Skipping removal."
fi

# Remove temporary files
if [ -d "$TMP_DIR" ]; then
    echo "Removing temporary directory: $TMP_DIR"
    rm -rf "$TMP_DIR"
else
    echo "Temporary directory not found. Skipping removal."
fi

# Remove SonarScanner via Homebrew if installed
if command -v brew >/dev/null 2>&1; then
    if brew list sonar-scanner >/dev/null 2>&1; then
        echo "Uninstalling SonarScanner via Homebrew..."
        brew uninstall sonar-scanner
    else
        echo "SonarScanner not installed via Homebrew. Skipping."
    fi
else
    echo "Homebrew not found. Skipping SonarScanner uninstall via Homebrew."
fi

# Remove manually installed SonarScanner directory
if [ -d "$SCANNER_DIR" ]; then
    echo "Removing manually installed SonarScanner directory: $SCANNER_DIR"
    rm -rf "$SCANNER_DIR"
else
    echo "Manual SonarScanner directory not found. Skipping removal."
fi

echo "✅ SonarQube cleanup completed."
