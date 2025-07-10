#!/bin/bash

# Set project name
PROJECT_NAME="alain_finance"

# Create project root
mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Initialize Yarn workspace
yarn init -y

# Add workspaces to package.json
jq '. + {
  "private": true,
  "workspaces": ["apps/*", "packages/*"]
}' package.json > tmp.json && mv tmp.json package.json

# Create base tsconfig
cat <<EOT > tsconfig.base.json
{
  "compilerOptions": {
    "target": "esnext",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "@shared/*": ["packages/shared/src/*"]
    }
  }
}
EOT

# Create folder structure
mkdir -p apps/mobile
mkdir -p apps/web
mkdir -p packages/shared/src

# Initialize shared package
cd packages/shared
yarn init -y
jq '. + {
  "name": "@shared",
  "version": "1.0.0",
  "main": "src/index.ts"
}' package.json > tmp.json && mv tmp.json package.json
echo 'export const hello = () => "Hello from shared!";' > src/index.ts
cd ../../

# Create React Native app using Expo
cd apps
npx create-expo-app mobile -t expo-template-blank-typescript
cd mobile
yarn add @reduxjs/toolkit react-redux redux-thunk redux-persist
yarn add @shared --dev
jq '. + {
  "compilerOptions": {
    "jsx": "react-native"
  },
  "extends": "../../tsconfig.base.json"
}' tsconfig.json > tmp.json && mv tmp.json tsconfig.json
cd ..

# Create Next.js app
npx create-next-app@latest web --typescript --app
cd web
yarn add @reduxjs/toolkit react-redux redux-thunk redux-persist
yarn add @shared --dev
jq '. + {
  "compilerOptions": {
    "jsx": "preserve",
    "module": "esnext",
    "moduleResolution": "node"
  },
  "extends": "../../tsconfig.base.json"
}' tsconfig.json > tmp.json && mv tmp.json tsconfig.json
cd ../../

# Install all dependencies
yarn install

echo "Monorepo setup complete in $PROJECT_NAME"
