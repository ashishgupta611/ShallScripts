#!/bin/bash

# Exit if any command fails
set -e

# Create root folder
mkdir MonoToDo && cd MonoToDo

echo "Initializing Yarn workspace monorepo..."

# Init root package
yarn init -y

# Configure Yarn workspaces and nohoist in package.json
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

# Create .yarnrc.yml to use node_modules linker
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
echo "Creating React Native app..."
npx react-native init mobile --template react-native-template-typescript

# Move contents inside proper mobile folder
mv mobile temp_mobile
rm -rf mobile
mkdir mobile
mv temp_mobile/* mobile/
rm -rf temp_mobile

cd mobile
yarn add @reduxjs/toolkit redux redux-thunk react-redux
yarn add @todoapp/common --dev

# Setup alias in tsconfig.json
jq '.compilerOptions.paths = { "@todoapp/common": ["../common/src"] }' tsconfig.json > temp && mv temp tsconfig.json

# Metro config to support monorepo
cat > metro.config.js << EOL
const path = require('path');
const { getDefaultConfig } = require('expo/metro-config');

const defaultConfig = getDefaultConfig(__dirname);

defaultConfig.resolver.nodeModulesPaths = [
  path.resolve(__dirname, 'node_modules'),
  path.resolve(__dirname, '../node_modules'),
];
defaultConfig.watchFolders = [
  path.resolve(__dirname, '../common'),
];

module.exports = defaultConfig;
EOL

cd ..

# ----------------------------
# Setup web (Next.js)
# ----------------------------
echo "Creating Next.js app..."
yarn create next-app web --typescript --app --eslint --tailwind --no-experimental-app --no-src-dir

cd web
yarn add @reduxjs/toolkit redux redux-thunk react-redux
yarn add @todoapp/common --dev

# Update tsconfig.json
jq '.compilerOptions.paths = { "@todoapp/common": ["../common/src"] }' tsconfig.json > temp && mv temp tsconfig.json

cd ..

# ----------------------------
# Final Install
# ----------------------------
echo "Installing all workspace dependencies..."
yarn install

echo "✅ MonoToDo monorepo setup completed!"
