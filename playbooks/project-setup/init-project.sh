#!/bin/bash

# Project Initialization Script
# Creates F4ST architecture structure for new frontend projects
# Usage: ./init-project.sh [project-name]

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get project name
PROJECT_NAME=${1:-"my-app"}

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}  Frontend OS - Project Initialization${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""
echo -e "Project name: ${GREEN}${PROJECT_NAME}${NC}"
echo ""

# Create base directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo -e "${YELLOW}Creating F4ST architecture structure...${NC}"
echo ""

# Create src directory structure
mkdir -p src/{shared,core,modules}

# === SHARED LAYER (Pure utilities, no dependencies) ===
echo -e "${GREEN}✓${NC} Creating shared/ layer..."
mkdir -p src/shared/{utils,hooks,types,validators,constants}

# Shared utils
cat > src/shared/utils/format-currency.ts << 'EOF'
/**
 * Format number as currency
 * @example formatCurrency(1234.56) // "$1,234.56"
 */
export const formatCurrency = (amount: number, currency = 'USD'): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(amount);
};
EOF

cat > src/shared/utils/format-date.ts << 'EOF'
/**
 * Format date to locale string
 * @example formatDate(new Date()) // "Jan 1, 2024"
 */
export const formatDate = (date: Date | string, options?: Intl.DateTimeFormatOptions): string => {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  return dateObj.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    ...options,
  });
};
EOF

cat > src/shared/utils/index.ts << 'EOF'
export * from './format-currency';
export * from './format-date';
EOF

# Shared hooks
cat > src/shared/hooks/use-debounce.ts << 'EOF'
import { useEffect, useState } from 'react';

/**
 * Debounce a value with configurable delay
 * @example const debouncedSearch = useDebounce(searchTerm, 500);
 */
export const useDebounce = <T>(value: T, delay = 500): T => {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
};
EOF

cat > src/shared/hooks/use-local-storage.ts << 'EOF'
import { useState, useEffect } from 'react';

/**
 * Persist state in localStorage
 * @example const [theme, setTheme] = useLocalStorage('theme', 'light');
 */
export const useLocalStorage = <T>(key: string, initialValue: T) => {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Error loading localStorage key "${key}":`, error);
      return initialValue;
    }
  });

  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(`Error setting localStorage key "${key}":`, error);
    }
  };

  return [storedValue, setValue] as const;
};
EOF

cat > src/shared/hooks/index.ts << 'EOF'
export * from './use-debounce';
export * from './use-local-storage';
EOF

# Shared types
cat > src/shared/types/api-response.type.ts << 'EOF'
export interface ApiResponse<T> {
  data: T;
  message?: string;
  success: boolean;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    totalPages: number;
  };
}

export interface ApiError {
  message: string;
  code?: string;
  statusCode: number;
}
EOF

cat > src/shared/types/index.ts << 'EOF'
export * from './api-response.type';
EOF

# Shared validators
cat > src/shared/validators/is-email.ts << 'EOF'
/**
 * Validate email format
 * @example isEmail('test@example.com') // true
 */
export const isEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};
EOF

cat > src/shared/validators/index.ts << 'EOF'
export * from './is-email';
EOF

# Shared constants
cat > src/shared/constants/http-status.ts << 'EOF'
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  INTERNAL_SERVER_ERROR: 500,
} as const;
EOF

cat > src/shared/constants/index.ts << 'EOF'
export * from './http-status';
EOF

# Shared barrel export
cat > src/shared/index.ts << 'EOF'
export * from './utils';
export * from './hooks';
export * from './types';
export * from './validators';
export * from './constants';
EOF

# === CORE LAYER (Foundation & configuration) ===
echo -e "${GREEN}✓${NC} Creating core/ layer..."
mkdir -p src/core/{api,router,store,ui}

# Core API
cat > src/core/api/client.ts << 'EOF'
import type { ApiResponse, ApiError } from '@/shared/types';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

class ApiClient {
  private baseURL: string;

  constructor(baseURL: string) {
    this.baseURL = baseURL;
  }

  private async request<T>(
    endpoint: string,
    options?: RequestInit
  ): Promise<ApiResponse<T>> {
    try {
      const response = await fetch(`${this.baseURL}${endpoint}`, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...options?.headers,
        },
      });

      if (!response.ok) {
        const error: ApiError = {
          message: `HTTP ${response.status}: ${response.statusText}`,
          statusCode: response.status,
        };
        throw error;
      }

      const data = await response.json();
      return {
        data,
        success: true,
      };
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  async get<T>(endpoint: string, options?: RequestInit) {
    return this.request<T>(endpoint, { ...options, method: 'GET' });
  }

  async post<T>(endpoint: string, body?: unknown, options?: RequestInit) {
    return this.request<T>(endpoint, {
      ...options,
      method: 'POST',
      body: JSON.stringify(body),
    });
  }

  async put<T>(endpoint: string, body?: unknown, options?: RequestInit) {
    return this.request<T>(endpoint, {
      ...options,
      method: 'PUT',
      body: JSON.stringify(body),
    });
  }

  async delete<T>(endpoint: string, options?: RequestInit) {
    return this.request<T>(endpoint, { ...options, method: 'DELETE' });
  }
}

export const apiClient = new ApiClient(API_BASE_URL);
EOF

cat > src/core/api/index.ts << 'EOF'
export * from './client';
EOF

# Core router (placeholder)
cat > src/core/router/router.tsx << 'EOF'
// Router configuration
// TODO: Configure your router (React Router, TanStack Router, etc.)

export const routes = [];
EOF

cat > src/core/router/index.ts << 'EOF'
export * from './router';
EOF

# Core store (placeholder)
cat > src/core/store/provider.tsx << 'EOF'
import { ReactNode } from 'react';

// State management provider
// TODO: Configure your state management (Zustand, Jotai, Redux, etc.)

interface StoreProviderProps {
  children: ReactNode;
}

export const StoreProvider = ({ children }: StoreProviderProps) => {
  return <>{children}</>;
};
EOF

cat > src/core/store/index.ts << 'EOF'
export * from './provider';
EOF

# Core UI (placeholder)
cat > src/core/ui/provider.tsx << 'EOF'
import { ReactNode } from 'react';

// UI library provider
// TODO: Configure your UI library (AntD, ShadcnUI, MUI, etc.)

interface UIProviderProps {
  children: ReactNode;
}

export const UIProvider = ({ children }: UIProviderProps) => {
  return <>{children}</>;
};
EOF

cat > src/core/ui/index.ts << 'EOF'
export * from './provider';
EOF

# Core barrel export
cat > src/core/index.ts << 'EOF'
export * from './api';
export * from './router';
export * from './store';
export * from './ui';
EOF

# === MODULES LAYER (Business features) ===
echo -e "${GREEN}✓${NC} Creating modules/ layer..."
mkdir -p src/modules/auth/{components,hooks,api,types}

# Auth module example
cat > src/modules/auth/types/user.type.ts << 'EOF'
export interface User {
  id: string;
  email: string;
  name: string;
  role: 'admin' | 'user' | 'guest';
  createdAt: Date;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}
EOF

cat > src/modules/auth/types/index.ts << 'EOF'
export * from './user.type';
EOF

cat > src/modules/auth/api/auth-api.ts << 'EOF'
import { apiClient } from '@/core/api';
import type { LoginCredentials, User } from '../types';

export const authApi = {
  login: async (credentials: LoginCredentials) => {
    return apiClient.post<{ user: User; token: string }>('/auth/login', credentials);
  },

  logout: async () => {
    return apiClient.post('/auth/logout');
  },

  getCurrentUser: async () => {
    return apiClient.get<User>('/auth/me');
  },
};
EOF

cat > src/modules/auth/api/index.ts << 'EOF'
export * from './auth-api';
EOF

cat > src/modules/auth/hooks/use-auth.ts << 'EOF'
import { useState, useEffect } from 'react';
import { authApi } from '../api';
import type { User, LoginCredentials } from '../types';

export const useAuth = () => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check authentication on mount
    authApi.getCurrentUser()
      .then(response => setUser(response.data))
      .catch(() => setUser(null))
      .finally(() => setIsLoading(false));
  }, []);

  const login = async (credentials: LoginCredentials) => {
    setIsLoading(true);
    try {
      const response = await authApi.login(credentials);
      setUser(response.data.user);
      return response;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    await authApi.logout();
    setUser(null);
  };

  return {
    user,
    isLoading,
    isAuthenticated: !!user,
    login,
    logout,
  };
};
EOF

cat > src/modules/auth/hooks/index.ts << 'EOF'
export * from './use-auth';
EOF

cat > src/modules/auth/components/login-form.tsx << 'EOF'
import { useState } from 'react';
import { useAuth } from '../hooks';

export const LoginForm = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const { login, isLoading } = useAuth();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await login({ email, password });
    } catch (error) {
      console.error('Login failed:', error);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <h2>Login</h2>
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        required
      />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        required
      />
      <button type="submit" disabled={isLoading}>
        {isLoading ? 'Logging in...' : 'Login'}
      </button>
    </form>
  );
};
EOF

cat > src/modules/auth/components/index.ts << 'EOF'
export * from './login-form';
EOF

# Auth module barrel export (public API)
cat > src/modules/auth/index.ts << 'EOF'
// Public API - only export what other modules need
export { useAuth } from './hooks';
export { LoginForm } from './components';
export type { User, LoginCredentials, AuthState } from './types';
EOF

# === ROOT FILES ===
echo -e "${GREEN}✓${NC} Creating root files..."

# Main entry point
cat > src/main.tsx << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import { App } from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# App component
cat > src/App.tsx << 'EOF'
import { StoreProvider } from '@/core/store';
import { UIProvider } from '@/core/ui';
import { LoginForm } from '@/modules/auth';

export const App = () => {
  return (
    <StoreProvider>
      <UIProvider>
        <div className="app">
          <h1>Welcome to Frontend OS</h1>
          <LoginForm />
        </div>
      </UIProvider>
    </StoreProvider>
  );
};
EOF

# Basic CSS
cat > src/index.css << 'EOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: system-ui, -apple-system, sans-serif;
  line-height: 1.5;
}

.app {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
EOF

# TypeScript config
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,

    /* Path aliases */
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/shared/*": ["./src/shared/*"],
      "@/core/*": ["./src/core/*"],
      "@/modules/*": ["./src/modules/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

cat > tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOF

# Vite config
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@/shared': path.resolve(__dirname, './src/shared'),
      '@/core': path.resolve(__dirname, './src/core'),
      '@/modules': path.resolve(__dirname, './src/modules'),
    },
  },
});
EOF

# Package.json
cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "private": true,
  "version": "0.0.1",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@vitejs/plugin-react": "^4.2.0",
    "eslint": "^8.0.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.0",
    "typescript": "^5.0.0",
    "vite": "^5.0.0"
  }
}
EOF

# HTML entry point
cat > index.html << EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>$PROJECT_NAME</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

# .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules
.pnp
.pnp.js

# Testing
coverage

# Production
dist
build

# Misc
.DS_Store
*.pem

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Local env files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Editor
.vscode/*
!.vscode/extensions.json
.idea

# Cache
.eslintcache
EOF

# README
cat > README.md << EOF
# $PROJECT_NAME

Frontend project following the F4ST architecture.

## Architecture

This project uses a three-layer architecture:

- **shared/** - Pure utilities with no dependencies
- **core/** - Foundation and configuration
- **modules/** - Business features

See [Frontend OS](https://github.com/your-org/enosta-frontend-os) for complete documentation.

## Getting Started

\`\`\`bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
\`\`\`

## Project Structure

\`\`\`
src/
├── shared/      # Pure utilities (formatDate, useDebounce, etc.)
├── core/        # Foundation (API client, router, state)
└── modules/     # Features (auth, dashboard, etc.)
    └── auth/
        ├── components/
        ├── hooks/
        ├── api/
        ├── types/
        └── index.ts  # Public API
\`\`\`

## Development Guidelines

- Follow [Code Standards](https://github.com/your-org/enosta-frontend-os/standards/code-standards.md)
- Review [Architecture Decisions](https://github.com/your-org/enosta-frontend-os/standards/01-architecture/)
- Use AI agents from [Frontend OS](https://github.com/your-org/enosta-frontend-os/ai/)
EOF

echo ""
echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}  ✓ Project initialized successfully!${NC}"
echo -e "${GREEN}==================================================${NC}"
echo ""
echo "Next steps:"
echo ""
echo "  cd $PROJECT_NAME"
echo "  npm install"
echo "  npm run dev"
echo ""
echo "Project structure:"
echo ""
echo "  src/"
echo "  ├── shared/     (Pure utilities)"
echo "  ├── core/       (Foundation)"
echo "  └── modules/    (Features)"
echo ""
echo "Documentation: https://github.com/your-org/enosta-frontend-os"
echo ""
