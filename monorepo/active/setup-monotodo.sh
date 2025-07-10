#!/bin/bash

set -e

echo "📁 Creating root folder MonoToDo..."
mkdir MonoToDo && cd MonoToDo

echo "📦 Initializing Yarn workspace..."
yarn init -y

cat > package.json << EOL
{
  "name": "monotodo",
  "private": true,
  "workspaces": {
    "packages": ["common", "mobile", "web"],
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

mkdir common mobile web

######################################
# COMMON PACKAGE WITH REDUX LOGIC
######################################
echo "📁 Setting up shared common package with Redux logic..."
cd common
yarn init -y
jq '.name = "@todoapp/common"' package.json > tmp && mv tmp package.json

mkdir -p src/redux/slices

cat > src/redux/slices/todoSlice.ts << EOL
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

export interface Todo {
  id: number;
  text: string;
  done: boolean;
}

interface TodoState {
  todos: Todo[];
}

const initialState: TodoState = {
  todos: []
};

export const todoSlice = createSlice({
  name: 'todo',
  initialState,
  reducers: {
    addTodo: (state, action: PayloadAction<string>) => {
      const newTodo: Todo = {
        id: Date.now(),
        text: action.payload,
        done: false
      };
      state.todos.push(newTodo);
    },
    toggleTodo: (state, action: PayloadAction<number>) => {
      const todo = state.todos.find(t => t.id === action.payload);
      if (todo) todo.done = !todo.done;
    },
    removeTodo: (state, action: PayloadAction<number>) => {
      state.todos = state.todos.filter(t => t.id !== action.payload);
    }
  }
});

export const { addTodo, toggleTodo, removeTodo } = todoSlice.actions;
export default todoSlice.reducer;
EOL

cat > src/redux/store.ts << EOL
import { configureStore } from '@reduxjs/toolkit';
import todoReducer from './slices/todoSlice';

export const createAppStore = () =>
  configureStore({
    reducer: {
      todo: todoReducer
    }
  });

export type RootState = ReturnType<ReturnType<typeof createAppStore>['getState']>;
export type AppDispatch = ReturnType<typeof createAppStore>['dispatch'];
EOL

cd ..

######################################
# REACT NATIVE APP (MOBILE)
######################################
echo "📱 Setting up React Native app..."
npx @react-native-community/cli init mobile

cd mobile

rm -f package-lock.json

yarn add --dev typescript @types/react @types/react-native
yarn add @reduxjs/toolkit redux redux-thunk react-redux

mkdir -p src

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

mv index.js index.ts

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

cat > src/App.tsx << EOL
import React from 'react';
import { Provider } from 'react-redux';
import { createAppStore } from '@todoapp/common/redux/store';
import { View, Text, Button, FlatList } from 'react-native';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '@todoapp/common/redux/store';
import { addTodo, toggleTodo } from '@todoapp/common/redux/slices/todoSlice';

const store = createAppStore();

const TodoApp = () => {
  const todos = useSelector((state: RootState) => state.todo.todos);
  const dispatch = useDispatch();

  return (
    <View style={{ padding: 40 }}>
      <Button title="Add Todo" onPress={() => dispatch(addTodo('Buy Milk'))} />
      <FlatList
        data={todos}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <Text
            onPress={() => dispatch(toggleTodo(item.id))}
            style={{ fontSize: 20, marginVertical: 5, textDecorationLine: item.done ? 'line-through' : 'none' }}
          >
            {item.text}
          </Text>
        )}
      />
    </View>
  );
};

export default function App() {
  return (
    <Provider store={store}>
      <TodoApp />
    </Provider>
  );
}
EOL

cd ..

######################################
# NEXT.JS APP (WEB)
######################################
echo "🌐 Setting up Next.js app..."
npx create-next-app@latest web \
  --ts \
  --tailwind \
  --eslint \
  --turbopack \
  --app \
  --no-src-dir \
  --import-alias "@/*" \
  --no-interactive

cd web
rm -f package-lock.json

yarn add @reduxjs/toolkit react-redux redux-thunk

jq '.compilerOptions.paths = { "@todoapp/common": ["../common/src"] }' tsconfig.json > tmp && mv tmp tsconfig.json

mkdir -p app

cat > app/page.tsx << EOL
'use client';

import { Provider } from 'react-redux';
import { createAppStore } from '@todoapp/common/redux/store';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '@todoapp/common/redux/store';
import { addTodo, toggleTodo } from '@todoapp/common/redux/slices/todoSlice';

const store = createAppStore();

const TodoWeb = () => {
  const todos = useSelector((state: RootState) => state.todo.todos);
  const dispatch = useDispatch();

  return (
    <main style={{ padding: 20 }}>
      <h1>Todo List</h1>
      <button onClick={() => dispatch(addTodo('Read a book'))}>Add Todo</button>
      <ul>
        {todos.map((t) => (
          <li
            key={t.id}
            onClick={() => dispatch(toggleTodo(t.id))}
            style={{
              cursor: 'pointer',
              textDecoration: t.done ? 'line-through' : 'none',
              fontSize: 18
            }}
          >
            {t.text}
          </li>
        ))}
      </ul>
    </main>
  );
};

export default function Home() {
  return (
    <Provider store={store}>
      <TodoWeb />
    </Provider>
  );
}
EOL

cd ..

######################################
# FINAL INSTALL
######################################
echo "🧹 Cleaning up and installing dependencies..."
find . -name "package-lock.json" -exec rm -f {} \;
yarn install

echo "✅ MonoToDo full monorepo with shared Redux store is ready!"
