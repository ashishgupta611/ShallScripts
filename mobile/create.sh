#!/bin/bash

# Store the current directory path in a variable
CURRENT_DIR=$(pwd)

# Check if parent folder path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <parent-folder-path> [project-name]"
  exit 1
fi

PARENT_FOLDER="$1"
PROJECT_NAME="${2:-AwesomeApp}"  # Default to "AwesomeApp" if not provided

# Create project directory if it doesn't exist
mkdir -p "$PARENT_FOLDER"
cd "$PARENT_FOLDER" || exit

# Create new React Native project
npx @react-native-community/cli@latest init "$PROJECT_NAME"

# Navigate into project directory
cd "$PROJECT_NAME" || exit

# Initialize a new npm project (if not already initialized)
if [ ! -f package.json ]; then
    npm init -y
fi

# Install required npm packages
npm install react-redux @reduxjs/toolkit redux-thunk @react-navigation/native @react-navigation/native-stack axios react-native-mmkv-storage

#Set path to send as parameter to script.
PATH_FOR_LOAD_SCRIPT="$(realpath "$PARENT_FOLDER")/$PROJECT_NAME"
echo "PATH_FOR_LOAD_SCRIPT= $PATH_FOR_LOAD_SCRIPT"

PROJECT_FOLDER_PATH=$(pwd)
echo "PROJECT FOLDER PATH= $PROJECT_FOLDER_PATH"

#Reset directory for new script execution.
cd "$CURRENT_DIR"
echo "Start load.sh from directory path: $CURRENT_DIR"

# Execute load.sh script
if [ -f "load.sh" ]; then
  chmod +x load.sh
  ./load.sh "$PATH_FOR_LOAD_SCRIPT"
else
  echo "load.sh not found. Please ensure it exists in the project directory."
fi
