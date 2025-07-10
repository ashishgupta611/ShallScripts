# ----------------------------
# Setup mobile (React Native)
# ----------------------------
echo "📱 Creating React Native mobile app..."

npx @react-native-community/cli init mobile

cd mobile

# Add TypeScript and related types
yarn add --dev typescript @types/react @types/react-native

# Create basic tsconfig.json
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

# Rename entry file to TypeScript
mv index.js index.ts

# Add Redux Toolkit, React Redux, Thunk
yarn add @reduxjs/toolkit redux redux-thunk react-redux

# Add reference to common package
yarn add @todoapp/common --dev

# Metro bundler config
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
