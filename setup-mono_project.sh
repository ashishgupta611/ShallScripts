#!/bin/bash

set -e

echo "📁 Creating root folder MonoToDo..."
mkdir MonoToDo && cd MonoToDo

echo "📦 Initializing Yarn workspace..."
yarn init -y

# Create root package.json
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

# Create .yarnrc.yml
echo "nodeLinker: node-modules" > .yarnrc.yml

# Create workspace folders
mkdir common mobile web

###########################################
# COMMON PACKAGE
###########################################
echo "📁 Setting up shared common package..."
cd common
yarn init -y

# Set package name
jq '.name = "@todoapp/common"' package.json > tmp && mv tmp package.json

mkdir src

# Add example shared file
cat > src/utils.ts << EOL
export const sharedUtil = () => "Shared utility function";
EOL

cd ..

###########################################
# REACT NATIVE (MOBILE)
###########################################
echo "📱 Creating React Native mobile app..."
npx @react-native-community/cli init mobile

cd mobile

# Remove auto-created package-lock.json if any
rm -f package-lock.json

# Add TypeScript
yarn add --dev typescript @types/react @types/react-native

# Create tsconfig.json
cat > tsconfig.json << EOL
{
  "compilerOptions": {
    "target": "esnext",
    "module": "commonjs",
    "strict": true,
    "jsx": "react",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "baseUrl": ".",
    "paths": {
      "@todoapp/common": ["../common/src"]
    }
  },
  "include": ["index.ts", "src"]
}
EOL

# Rename entry file
mv index.js index.ts

# Add Redux + Thunk
yarn add @reduxjs/toolkit redux redux-thunk react-redux

# Create Metro config
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

###########################################
# NEXT.JS (WEB)
###########################################
echo "🌐 Creating Next.js web app..."
yarn create next-app web --typescript --app --no-src-dir

cd web

# Remove auto-generated package-lock.json
rm -f package-lock.json

# Add Redux + Thunk
yarn add @reduxjs/toolkit redux redux-thunk react-redux

# Update tsconfig.json for path alias
jq '.compilerOptions.paths = { "@todoapp/common": ["../common/src"] }' tsconfig.json > tmp && mv tmp tsconfig.json

cd ..

###########################################
# FINAL INSTALL
###########################################
echo "📦 Installing all packages together..."
yarn install

# Remove all package-lock.json if any slipped through
find . -name "package-lock.json" -exec rm -f {} \;

echo "✅ MonoToDo monorepo setup complete!"
