# Monorepo Patterns

> "Monorepos are not for everyone. Know when to use them."

---

## Foundational Principles

Monorepos are powerful but expensive.

### 1. **Interface-First Thinking**

Decide monorepo structure before first commit. How will packages relate?

### 2. **KISS (Keep It Simple, Stupid)**

Monorepo complexity is the cost. Benefits must exceed cost.

### 3. **DRY (Don't Repeat Yourself)**

Shared code is the main reason to use monorepo.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Monorepo Patterns** includes:

1. **When to Use** — Monorepo vs multi-repo
2. **Structure** — How to organize packages
3. **Build Tools** — Nx, Turborepo
4. **Shared Packages** — Code reuse
5. **Dependency Management** — Complexity multiplies

One repository with many projects.

---

## Goals

1. **Shared Code** — Easy reuse across projects
2. **Atomic Changes** — Fix issues in one commit
3. **Version Alignment** — All packages compatible
4. **Team Scalability** — Multiple teams, one repo
5. **Build Optimization** — Smart caching and parallelization

---

## Table of Contents

- [Foundational Principles](#foundational-principles)
- [When to Use Monorepo](#when-to-use-monorepo)
- [Monorepo Structure](#monorepo-structure)
- [Build Tools](#build-tools)
- [Shared Packages](#shared-packages)
- [Dependency Management](#dependency-management)
- [Best Practices](#best-practices)

---

## When to Use Monorepo

### ✅ Use Monorepo If

```
Your situation:
├─ Multiple related projects (web, mobile, backend)
├─ Heavy code sharing between projects
├─ Coordinated releases needed
├─ Single team owning multiple projects
└─ Atomic changes across projects important
```

**Examples:**

- Frontend web + mobile + design system
- Main app + admin + public site
- SDK + examples + documentation

### ❌ Don't Use Monorepo If

```
Your situation:
├─ Completely independent projects
├─ Different teams with different schedules
├─ Separate deployment cycles
├─ No shared code between projects
└─ High autonomy needed per team
```

**Examples:**

- Portfolio site (separate from main app)
- Legacy systems (no planned integration)
- Third-party integrations (decoupled APIs)

---

## Monorepo Structure

### Typical Layout

```
my-monorepo/
├── packages/
│  ├── ui-library/          # Shared React components
│  │  ├── src/
│  │  ├── package.json
│  │  └── tsconfig.json
│  ├── shared-utils/        # Shared utilities
│  │  ├── src/
│  │  └── package.json
│  └── graphql-types/       # Shared GraphQL types
│     ├── schema.graphql
│     └── package.json
├── apps/
│  ├── web/                 # React app
│  │  ├── src/
│  │  ├── package.json
│  │  └── next.config.js
│  ├── admin/               # Admin dashboard
│  │  ├── src/
│  │  └── package.json
│  └── mobile/              # React Native
│     ├── src/
│     └── package.json
├── package.json            # Root manifest
├── nx.json                 # Nx config
├── tsconfig.json           # Root TypeScript
└── README.md
```

### Path Aliases

```json
// Root tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@repo/ui": ["packages/ui-library/src"],
      "@repo/utils": ["packages/shared-utils/src"],
      "@repo/types": ["packages/graphql-types/src"]
    }
  }
}
```

```typescript
// Usage in any app
import { Button } from "@repo/ui";
import { formatDate } from "@repo/utils";
import type { User } from "@repo/types";
```

### Package Configuration

```json
// packages/ui-library/package.json
{
  "name": "@repo/ui",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "vitest"
  },
  "dependencies": {
    "react": "^18.0.0"
  }
}
```

---

## Build Tools

### Nx (Recommended for Complex Monorepos)

```json
// nx.json
{
  "extends": "nx/presets/npm.json",
  "nxCloudAccessToken": "token",
  "targetDefaults": {
    "build": {
      "cache": true,
      "inputs": ["src/**"],
      "outputs": ["dist"]
    }
  },
  "projects": {
    "@repo/ui": {
      "projectType": "library",
      "sourceRoot": "packages/ui-library/src"
    },
    "web": {
      "projectType": "application",
      "sourceRoot": "apps/web/src"
    }
  }
}
```

```bash
# Build only affected apps
nx run-many --target=build --affected

# Run tests in parallel
nx run-many --target=test --all

# Visualize dependency graph
nx graph
```

### Turborepo (Simpler Alternative)

```json
// turbo.json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist"]
    },
    "test": {
      "outputs": [],
      "cache": false
    }
  }
}
```

```bash
# Build only changed packages
turbo run build --filter=[HEAD^]

# Run in parallel with caching
turbo run build
```

### pnpm Workspaces (Lightweight)

```yaml
# pnpm-workspace.yaml
packages:
  - "packages/*"
  - "apps/*"
```

```bash
# Install workspace
pnpm install

# Add dependency to specific package
pnpm --filter @repo/ui add react
```

---

## Shared Packages

### Component Library

```typescript
// packages/ui-library/src/index.ts
export { Button } from "./Button";
export { Modal } from "./Modal";
export { Form } from "./Form";
export type { ButtonProps, ModalProps } from "./types";
```

```typescript
// apps/web/src/App.tsx
import { Button, Modal } from '@repo/ui';

export const App = () => {
  return (
    <div>
      <Button onClick={() => {}}>Click me</Button>
      <Modal open={true}>Modal content</Modal>
    </div>
  );
};
```

### Shared Utilities

```typescript
// packages/shared-utils/src/index.ts
export { formatDate } from "./date";
export { validateEmail } from "./validation";
export { parseError } from "./errors";
export type { ValidationError } from "./types";
```

### Shared Types

```graphql
# packages/graphql-types/schema.graphql
type User {
  id: ID!
  email: String!
  name: String!
}

type Query {
  user(id: ID!): User
}
```

```typescript
// Generate types from schema
import type { User, Query } from "@repo/types";
```

---

## Dependency Management

### Version Alignment

```json
// Root package.json
{
  "name": "my-monorepo",
  "workspaces": ["packages/*", "apps/*"],
  "dependencies": {
    "react": "^18.2.0",
    "typescript": "^5.0.0"
  },
  "devDependencies": {
    "nx": "latest"
  }
}
```

```bash
# All packages use same React version
# Prevents version conflicts and code duplication
```

### Internal Dependencies

```json
// apps/web/package.json
{
  "name": "web",
  "dependencies": {
    "@repo/ui": "*",
    "@repo/utils": "*"
  }
}

// Wildcard ensures always latest from workspace
```

### Lock Files

```bash
# Single lock file for all packages
# Ensures consistent versions across monorepo

# pnpm-lock.yaml
# OR
# package-lock.json (if using npm)
```

---

## Best Practices

1. **Clear Ownership** — Each package has owner/team
2. **Independent Versioning** — Each package versions separately
3. **Build Graph** — Track dependencies between packages
4. **CI/CD Optimization** — Only build affected packages
5. **Clear Exports** — Index files define public API
6. **Type Safety** — Shared types prevent bugs
7. **Test Packages** — Unit test each package
8. **Documentation** — README in each package
9. **No Circular Dependencies** — Prevent builds from failing
10. **Review Policy** — Who approves changes to shared code

---

## Monorepo Checklist

- [ ] Decision: Monorepo vs multi-repo documented
- [ ] Structure defined (packages/, apps/, etc.)
- [ ] Build tool selected (Nx, Turborepo, pnpm)
- [ ] Path aliases configured
- [ ] Shared packages identified
- [ ] Version strategy decided
- [ ] CI/CD optimized for monorepo
- [ ] Ownership clear for each package
- [ ] No circular dependencies
- [ ] Documentation for onboarding

---

## When to Split into Multi-Repo

```
Migration triggers:
├─ Team growth (different teams → separate repos)
├─ Release cycles (different schedules → separate repos)
├─ Technology divergence (Node + Python → separate repos)
├─ Organizational structure (different departments → separate repos)
└─ Deployment needs (independent scaling → separate repos)
```

**Process:**

1. Extract package into separate repo
2. Publish to npm (or private registry)
3. Update dependencies in main monorepo
4. Migrate CI/CD pipelines
5. Archive old package folder

Monorepo is tool. Use it when it helps, not always.
