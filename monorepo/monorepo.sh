#!/bin/bash

set -e

echo "📦 Creating MonoToDo monorepo folder..."
mkdir MonoToDo && cd MonoToDo

echo "🔧 Initializing Yarn workspace..."
yarn init -y

# Create root package.json with workspaces and nohoist
cat > package.json << EOL
{
  "name": "monotodo",
  "private": true,
  "workspaces": {
    "packages": [
      "common",
      "mobile",
      "web"
    ],
    "nohoist": [
      "**/react-native",
      "**/react-native/**",
      "**/expo",
      "**/expo/**"
    ]
  }
}
EOL

echo "nodeLinker: node-modules" > .yarnrc.yml

# Create folders
mkdir common mobile web

# ----------------------------
# Setup common package
# ----------------------------
cd common
yarn init -y
jq '.name="@todoapp/common"' package.json > temp && mv temp package.json

mkdir src

cat > src/index.ts << EOL
export const sharedUtil = () => "Shared logic here";
EOL

cd ..

# ----------------------------
# Setup mobile (React Native)
# ----------------------------
echo "📱 Creating React Native mobile app using new CLI..."
npx @react-native-community/cli init mobile --template react-native-template-typescript

# Rename app name inside mobile package.json
cd mobile
yarn add @reduxjs/toolkit redux redux-thunk react-redux
yarn add @todoapp/common --dev

# Setup tsconfig path mapping (adjust if needed)
npx -y tsconfig-paths -v || echo "🔔 Please manually update tsconfig.json for path aliases."

# Setup metro.config.js
cat > metro.config.js << EOL
const path = require("path");
const { getDefaultConfig } = require("metro-config");

module.exports = (async () => {
  const config = await getDefaultConfig();
  config.watchFolders = [path.resolve(__dirname, "../common")];
  config.resolver.extraNodeModules = {
    ...config.resolver.extraNodeModules,
    "@todoapp/common": path.resolve(__dirname, "../common/src")
  };
  return config;
})();
EOL

cd ..

# ----------------------------
# Setup web (Next.js)
# ----------------------------
echo "🌐 Creating Next.js web app..."
yarn create next-app web --typescript --app

cd web
yarn add @reduxjs/toolkit redux redux-thunk react-redux
yarn add @todoapp/common --dev

# Update tsconfig.json for alias
jq '.compilerOptions.paths = { "@todoapp/common": ["../common/src"] }' tsconfig.json > temp && mv temp tsconfig.json

cd ..

# ----------------------------
# Install all packages
# ----------------------------
echo "📦 Installing all dependencies..."
yarn install

echo "✅ MonoToDo monorepo setup is complete!"
