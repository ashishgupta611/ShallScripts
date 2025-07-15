#!/bin/bash

# === CONFIGURATION ===
# Fill these before running the script

AZURE_ORG_URL="https://dev.azure.com/YOUR_ORG"         # e.g., https://dev.azure.com/mycompany
PROJECT_NAME="YOUR_PROJECT"                            # e.g., my-project
REPO_NAME="YOUR_REPO"                                  # e.g., my-repo
PAT="YOUR_PERSONAL_ACCESS_TOKEN"                       # ⚠️ Keep this secret

# Branch to push
BRANCH_NAME="main"  # or master / develop etc.

# === SCRIPT ===
AZURE_REPO_URL="${AZURE_ORG_URL}/${PROJECT_NAME}/_git/${REPO_NAME}"

# Encode PAT for use in URL
ENCODED_PAT=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${PAT}'))")

# Authenticated remote URL using PAT
REMOTE_URL="https://${ENCODED_PAT}@dev.azure.com/${PROJECT_NAME}/_git/${REPO_NAME}"

echo "Adding Azure DevOps remote..."
git remote add azure "$REMOTE_URL"

echo "Pushing branch '$BRANCH_NAME' to Azure DevOps..."
git push -u azure "$BRANCH_NAME"

# Optionally set credential helper to cache PAT (macOS)
git config --global credential.helper osxkeychain

echo "✅ Done. Your local repo is connected to Azure DevOps."
