#!/bin/bash

# Check if parent folder path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <parent-folder-path>"
  exit 1
fi

PARENT_FOLDER_PATH="$1"
cd "$PARENT_FOLDER_PATH" || exit

# Define the parent folder
PARENT_FOLDER="app"

# Define child folders
CHILD_FOLDERS=("components" "hooks" "styles" "utils" "services" "assets" "middlewares" "configs" "navigation" "store" "helpers" "constants")

# Create the parent folder
mkdir -p $PARENT_FOLDER

# Navigate into the parent folder
cd $PARENT_FOLDER || exit

# Create child folders
for folder in "${CHILD_FOLDERS[@]}"; do
    mkdir -p "$folder"
done

# Confirmation message
echo "Project setup complete! Folders and dependencies are ready."