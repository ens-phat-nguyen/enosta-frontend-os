# Quick Commands Reference

Quick command reference for project initialization and common tasks.

---

## Project Initialization

### Initialize New Project

```bash
# Using the automated script
cd playbooks/project-setup
./init-project.sh my-project-name

# Navigate to project
cd my-project-name

# Install dependencies
npm install

# Start development
npm run dev
```

### Manual Structure Creation (if needed)

```bash
# Create base directories
mkdir -p src/{shared,core,modules}

# Shared layer
mkdir -p src/shared/{utils,hooks,types,validators,constants}

# Core layer
mkdir -p src/core/{api,router,store,ui}

# Example module
mkdir -p src/modules/auth/{components,hooks,api,types}
```

---

## Module Management

### Create New Module

```bash
# Full module structure
mkdir -p src/modules/MODULE_NAME/{components,hooks,api,types,utils}

# Create barrel export
cat > src/modules/MODULE_NAME/index.ts << 'EOF'
export * from './hooks';
export * from './components';
export type * from './types';
EOF
```

### Example: Users Module

```bash
mkdir -p src/modules/users/{components,hooks,api,types}

# Create files
touch src/modules/users/types/user.type.ts
touch src/modules/users/api/user-api.ts
touch src/modules/users/hooks/use-users.ts
touch src/modules/users/components/user-list.tsx

# Create barrel export
cat > src/modules/users/index.ts << 'EOF'
export { useUsers } from './hooks/use-users';
export { UserList } from './components/user-list';
export type { User } from './types/user.type';
EOF
```

---

## Shared Utilities

### Add Shared Utility

```bash
# Create utility
touch src/shared/utils/UTILITY_NAME.ts

# Export from barrel
echo "export * from './UTILITY_NAME';" >> src/shared/utils/index.ts
```

### Example: Slugify Utility

```bash
# Create file
cat > src/shared/utils/slugify.ts << 'EOF'
export const slugify = (text: string): string => {
  return text
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '');
};
EOF

# Export
echo "export * from './slugify';" >> src/shared/utils/index.ts
```

### Add Shared Hook

```bash
# Create hook
touch src/shared/hooks/use-HOOK_NAME.ts

# Export from barrel
echo "export * from './use-HOOK_NAME';" >> src/shared/hooks/index.ts
```

---

## Core Services

### Add Core Service

```bash
# Create service directory
mkdir -p src/core/SERVICE_NAME

# Create service file
touch src/core/SERVICE_NAME/SERVICE_NAME.ts
touch src/core/SERVICE_NAME/index.ts

# Export
echo "export * from './SERVICE_NAME';" > src/core/SERVICE_NAME/index.ts
echo "export * from './SERVICE_NAME';" >> src/core/index.ts
```

### Example: Analytics Service

```bash
mkdir -p src/core/analytics

cat > src/core/analytics/tracker.ts << 'EOF'
export const tracker = {
  track: (event: string, data?: Record<string, unknown>) => {
    console.log('Track:', event, data);
  },
};
EOF

echo "export * from './tracker';" > src/core/analytics/index.ts
echo "export * from './analytics';" >> src/core/index.ts
```

---

## Type Definitions

### Add Shared Type

```bash
# Create type file
touch src/shared/types/TYPE_NAME.type.ts

# Export from barrel
echo "export * from './TYPE_NAME.type';" >> src/shared/types/index.ts
```

### Example: Pagination Type

```bash
cat > src/shared/types/pagination.type.ts << 'EOF'
export interface Pagination {
  page: number;
  pageSize: number;
  total: number;
  totalPages: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: Pagination;
}
EOF

echo "export * from './pagination.type';" >> src/shared/types/index.ts
```

---

## Component Creation

### Create Component with Test

```bash
# In module components directory
touch src/modules/MODULE_NAME/components/ComponentName.tsx
touch src/modules/MODULE_NAME/components/ComponentName.test.tsx

# Or in shared components
mkdir -p src/shared/components/ComponentName
touch src/shared/components/ComponentName/ComponentName.tsx
touch src/shared/components/ComponentName/ComponentName.test.tsx
touch src/shared/components/ComponentName/index.ts
```

---

## Git & Version Control

### Initialize Git

```bash
git init
git add .
git commit -m "feat: initialize project with F4ST architecture"
```

### Conventional Commits

```bash
# Feature
git commit -m "feat: add user management module"

# Bug fix
git commit -m "fix: resolve login form validation"

# Refactor
git commit -m "refactor: extract auth logic to hook"

# Documentation
git commit -m "docs: update README with setup instructions"

# Tests
git commit -m "test: add tests for user-api"

# Chore
git commit -m "chore: update dependencies"
```

---

## NPM Scripts

### Development

```bash
# Start dev server
npm run dev

# Type check
npm run type-check

# Lint
npm run lint

# Build
npm run build

# Preview production build
npm run preview
```

---

## Testing

### Setup Vitest

```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom jsdom
```

### Add Test Script

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage"
  }
}
```

### Run Tests

```bash
# Watch mode
npm test

# Run once
npm test -- --run

# With UI
npm run test:ui

# Coverage
npm run test:coverage
```

---

## Path Aliases

### Verify Aliases Work

```bash
# TypeScript check
npx tsc --noEmit

# Search for alias usage
grep -r "@/" src/
grep -r "@/shared" src/
grep -r "@/core" src/
grep -r "@/modules" src/
```

---

## Structure Validation

### Check Directory Structure

```bash
# Tree view (if tree is installed)
tree src -L 3

# Or with ls
ls -R src/

# Count files by layer
find src/shared -type f | wc -l
find src/core -type f | wc -l
find src/modules -type f | wc -l
```

### Check Dependencies

```bash
# Find imports in shared (should be none)
grep -r "from '@/core" src/shared/
grep -r "from '@/modules" src/shared/

# Find imports in core (should only import from shared)
grep -r "from '@/modules" src/core/
```

---

## Cleanup

### Remove Unused Files

```bash
# Find unused exports (requires eslint)
npm run lint -- --fix

# Remove empty directories
find src -type d -empty -delete
```

---

## Copy to New Project

### Copy Frontend OS Config

```bash
# Copy Copilot instructions
cp path/to/frontend-os/ai/copilot-instructions-template.md .github/copilot-instructions.md

# Copy ESLint config (if available)
cp path/to/frontend-os/.eslintrc.json .

# Copy Prettier config (if available)
cp path/to/frontend-os/.prettierrc .
```

---

## Troubleshooting Commands

### TypeScript Issues

```bash
# Restart TS server (VS Code)
# Cmd+Shift+P → "TypeScript: Restart TS Server"

# Clear TypeScript cache
rm -rf node_modules/.cache
```

### Build Issues

```bash
# Clear all caches
rm -rf node_modules dist .vite

# Reinstall
npm install
```

### Port Already in Use

```bash
# Find process using port 5173
lsof -i :5173

# Kill process
kill -9 <PID>

# Or use different port
npm run dev -- --port 3000
```

---

## Quick References

### Module Template

```typescript
// src/modules/example/index.ts
export { useExample } from "./hooks/use-example";
export { ExampleComponent } from "./components/example-component";
export type { Example } from "./types/example.type";
```

### Utility Template

```typescript
// src/shared/utils/example.ts
/**
 * Example utility function
 * @param input - Input parameter
 * @returns Processed output
 */
export const exampleUtil = (input: string): string => {
  return input.toLowerCase();
};
```

### Hook Template

```typescript
// src/shared/hooks/use-example.ts
import { useState, useEffect } from "react";

export const useExample = () => {
  const [value, setValue] = useState("");

  useEffect(() => {
    // Effect logic
  }, []);

  return { value, setValue };
};
```

---

**Keep this file handy for quick reference during development!**
