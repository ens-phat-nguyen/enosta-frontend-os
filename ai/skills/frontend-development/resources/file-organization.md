# File Organization

Proper file and directory structure following **F4ST architecture** for maintainable, scalable frontend code.

> **Note:** This guide follows the [F4ST Architecture](../../../standards/01-architecture/) defined in Frontend OS.

---

## Architecture Overview

We use a **three-layer architecture** with strict dependency flow:

```
src/
├── shared/      # Pure utilities (no dependencies)
├── core/        # Foundation & configuration
└── modules/     # Business features

Dependencies flow: modules → core → shared
```

**Key Rule:** Upper layers import from lower layers only.

See [standards/01-architecture/](../../../standards/01-architecture/) for detailed documentation.

---

## Layer Definitions

### shared/ Layer (Pure Utilities)

**Purpose**: Reusable utilities with **zero dependencies** on other layers

**When to use:**

- Pure functions (formatDate, isEmail, etc.)
- Generic React hooks (useDebounce, useLocalStorage)
- Shared types (ApiResponse, Pagination)
- Constants (HTTP_STATUS, ROUTES)

**Structure:**

```
shared/
  utils/
    format-currency.ts       # Pure formatting functions
    format-date.ts
    index.ts
  hooks/
    use-debounce.ts          # Generic React hooks
    use-local-storage.ts
    index.ts
  types/
    api-response.type.ts     # Shared type definitions
    pagination.type.ts
    index.ts
  validators/
    is-email.ts              # Pure validation functions
    index.ts
  constants/
    http-status.ts           # Constants
    index.ts
  index.ts                   # Layer barrel export
```

**Examples:**

- `shared/utils/format-currency.ts` - Currency formatting
- `shared/hooks/use-debounce.ts` - Debounce hook
- `shared/types/api-response.type.ts` - API response types

### core/ Layer (Foundation)

**Purpose**: Project foundation, configuration, and external service integration

**When to use:**

- API client setup
- Router configuration
- State management providers
- UI library providers
- Global styles and theme

**Structure:**

```
core/
  api/
    client.ts                # API client singleton
    index.ts
  router/
    router.tsx               # Router configuration
    index.ts
  store/
    provider.tsx             # State management setup
    index.ts
  ui/
    provider.tsx             # UI library provider
    theme.ts                 # Theme configuration
    index.ts
  styles/
    main.css                 # Global styles
  index.ts                   # Layer barrel export
```

**Examples:**

- `core/api/client.ts` - Fetch/Axios client setup
- `core/router/router.tsx` - TanStack Router/React Router config
- `core/store/provider.tsx` - Zustand/Jotai provider

### modules/ Layer (Business Features)

**Purpose**: Business logic and feature-specific code

**When to use:**

- Feature has multiple related components
- Feature has domain-specific logic
- Feature needs API endpoints
- Business functionality

**Structure:**

```
modules/
  auth/
    components/
      login-form.tsx         # Feature components
      user-avatar.tsx
    hooks/
      use-auth.ts            # Feature hooks
      use-session.ts
    api/
      auth-api.ts            # Feature API calls
    types/
      user.type.ts           # Feature types
    utils/
      token.ts               # Feature-specific utilities
    index.ts                 # Public API (barrel export)

  dashboard/
    components/
      stat-card.tsx
      activity-feed.tsx
    hooks/
      use-dashboard-data.ts
    api/
      dashboard-api.ts
    types/
      dashboard.type.ts
    index.ts
```

**Examples:**

- `modules/auth/` - Authentication & authorization
- `modules/dashboard/` - Dashboard features
- `modules/users/` - User management

---

## Module Directory Structure (Detailed)

### Complete Module Example

Based on `modules/posts/` structure:

```
modules/
  posts/
    api/
      post-api.ts             # API service layer (GET, POST, PUT, DELETE)
      index.ts

    components/
      post-table.tsx          # Main container component
      post-form.tsx           # Form components
      post-card.tsx           # Display components
      index.ts

    hooks/
      use-posts.ts            # Data fetching hooks
      use-post-mutations.ts   # Mutations
      use-post-filters.ts     # Feature-specific hooks
      index.ts

    utils/
      post-helpers.ts         # Utility functions
      validation.ts           # Validation logic
      index.ts

    types/
      post.type.ts            # TypeScript types/interfaces
      index.ts

    index.ts                  # Public API exports
```

### Subdirectory Guidelines

#### api/ Directory

**Purpose**: Centralized API calls for the module

**Pattern:**

```typescript
// modules/users/api/user-api.ts
import { apiClient } from "@/core/api";
import type { User } from "../types";

export const userApi = {
  getUser: async (id: string) => {
    return apiClient.get<User>(`/users/${id}`);
  },
  createUser: async (data: Partial<User>) => {
    return apiClient.post<User>("/users", data);
  },
};
```

**Exports:**

```typescript
// modules/users/api/index.ts
export * from "./user-api";
```

#### components/ Directory

**Purpose**: Module-specific components

**Organization:**

- Flat structure if <5 components
- Subdirectories by responsibility if >5 components

**Examples:**

```
components/
  user-profile.tsx            # Main component
  user-avatar.tsx             # Supporting components
  user-settings.tsx

  # OR with subdirectories (if many components):
  forms/
    user-form.tsx
  cards/
    user-card.tsx
  lists/
    user-list.tsx
```

#### hooks/ Directory

**Purpose**: Custom hooks for the module

**Naming:**

- `use` prefix (camelCase)
- Descriptive of what they do

**Examples:**

```
hooks/
  use-users.ts                # Main data hook
  use-user-mutations.ts       # Mutations
  use-user-filters.ts         # Filters/search
```

#### utils/ Directory

**Purpose**: Utility functions specific to the module

**Examples:**

```
utils/
  user-helpers.ts             # General utilities
  user-validation.ts          # Validation logic
  user-formatters.ts          # Data formatters
```

#### types/ Directory

**Purpose**: TypeScript types and interfaces

**Files:**

```
types/
  user.type.ts                # Main types
  user-api.type.ts            # API-specific types (optional)
  index.ts                    # Exports
```

---

## Path Aliases Configuration

### Available Aliases

Configured in `tsconfig.json` and `vite.config.ts`:

| Alias       | Resolves To    | Use For            |
| ----------- | -------------- | ------------------ |
| `@/`        | `src/`         | Root-level imports |
| `@/shared`  | `src/shared/`  | Shared utilities   |
| `@/core`    | `src/core/`    | Core services      |
| `@/modules` | `src/modules/` | Business modules   |

### Usage Examples

```typescript
// ✅ PREFERRED - Use path aliases
import { formatDate } from "@/shared/utils";
import { apiClient } from "@/core/api";
import { useAuth } from "@/modules/auth";

// ✅ Layer-specific imports
import { useDebounce } from "@/shared/hooks";
import { HTTP_STATUS } from "@/shared/constants";
import type { ApiResponse } from "@/shared/types";

// ❌ AVOID - Relative paths across layers
import { formatDate } from "../../../shared/utils/format-date";
import { apiClient } from "../../core/api/client";
```

### When to Use Which Alias

**@/ (General Root)**:

```typescript
import { App } from "@/App";
import { routes } from "@/routes";
```

**@/shared (Shared Utilities)**:

```typescript
import { formatCurrency } from "@/shared/utils";
import { useLocalStorage } from "@/shared/hooks";
import type { Pagination } from "@/shared/types";
import { isEmail } from "@/shared/validators";
```

**@/core (Core Services)**:

```typescript
import { apiClient } from "@/core/api";
import { router } from "@/core/router";
import { StoreProvider } from "@/core/store";
```

**@/modules (Business Modules)**:

```typescript
import { useAuth, LoginForm } from "@/modules/auth";
import { useDashboard } from "@/modules/dashboard";
import type { User } from "@/modules/auth/types";
```

---

## File Naming Conventions

### Components

**Pattern**: kebab-case with `.tsx` extension (within modules/)
**Pattern**: PascalCase with `.tsx` extension (standalone/shared)

```
login-form.tsx              # Module component
user-avatar.tsx
dashboard-stats.tsx

Button.tsx                  # Shared component (if needed)
Modal.tsx
```

### Hooks

**Pattern**: camelCase with `use` prefix, `.ts` extension

```
use-auth.ts
use-users.ts
use-debounce.ts
use-local-storage.ts
```

### API Services

**Pattern**: kebab-case with `-api` suffix, `.ts` extension

```
auth-api.ts
user-api.ts
dashboard-api.ts
```

### Utilities

**Pattern**: kebab-case, `.ts` extension

```
format-date.ts
format-currency.ts
token-helpers.ts
validation.ts
```

### Types

**Pattern**: kebab-case with `.type.ts` extension

```
user.type.ts
api-response.type.ts
dashboard.type.ts
```

**Avoid:**

- camelCase: `userType.ts` ❌
- PascalCase: `UserType.ts` ❌ (unless using PascalCase consistently)
- No suffix: `user.ts` ❌ (ambiguous)

---

## When to Create a New Module

### Create New Module When:

- Multiple related components (>3)
- Has domain-specific logic
- Business feature or workflow
- Will grow over time
- Used across multiple routes

**Example:** `modules/auth/`

- Login, registration, password reset
- Auth state management
- Token handling
- User session logic

### Add to Existing Module When:

- Related to existing module
- Extends existing functionality
- Shares same domain
- Logical grouping

**Example:** Adding password-reset to auth module

### Add to shared/ When:

- Pure utility function
- No dependencies on core or modules
- Reusable across any project
- Generic React hook

**Example:** `shared/utils/slugify.ts`

### Add to core/ When:

- Foundation/infrastructure code
- External service configuration
- App-wide providers
- Global configuration

**Example:** `core/api/client.ts`

---

## Import Organization

### Import Order (Recommended)

```typescript
// 1. React and React-related
import React, { useState, useCallback, useMemo } from "react";
import { lazy } from "react";

// 2. Third-party libraries (alphabetical)
import { Box, Paper, Button, Grid } from "@mui/material";
import type { SxProps, Theme } from "@mui/material";
import { useQuery, useMutation } from "@tanstack/react-query";
import { useNavigate } from "@tanstack/react-router";

// 3. App layers (shared, core, modules)
import { formatDate, useDebounce } from "@/shared";
import type { ApiResponse } from "@/shared/types";
import { apiClient } from "@/core/api";
import { useAuth } from "@/modules/auth";

// 4. Relative imports (same module)
import { UserCard } from "./user-card";
import { useUserFilters } from "../hooks/use-user-filters";
import type { User } from "../types/user.type";
```

**Use single quotes** for all imports (project standard)

**Dependency Flow:**

- ✅ `modules/` can import from `core/` and `shared/`
- ✅ `core/` can import from `shared/` only
- ❌ `shared/` cannot import from `core/` or `modules/`
- ❌ `core/` cannot import from `modules/`

---

## Public API Pattern (Barrel Exports)

### module/index.ts

Export public API from module for clean imports:

```typescript
// modules/users/index.ts

// Export hooks (most common imports)
export { useUsers } from "./hooks/use-users";
export { useUserMutations } from "./hooks/use-user-mutations";

// Export components
export { UserList } from "./components/user-list";
export { UserCard } from "./components/user-card";

// Export API (if needed by other modules)
export { userApi } from "./api/user-api";

// Export types
export type { User, UserRole } from "./types/user.type";
```

**Usage:**

```typescript
// ✅ Clean import from module barrel
import { useUsers, UserList } from "@/modules/users";
import type { User } from "@/modules/users";

// ✅ Also OK - specific import
import { useUsers } from "@/modules/users/hooks/use-users";
```

### shared/index.ts

Export all shared utilities:

```typescript
// shared/index.ts
export * from "./utils";
export * from "./hooks";
export * from "./types";
export * from "./validators";
export * from "./constants";
```

### core/index.ts

Export core services:

```typescript
// core/index.ts
export * from "./api";
export * from "./router";
export * from "./store";
export * from "./ui";
```

---

## Directory Structure Visualization

```
src/
├── shared/                      # Pure utilities (no dependencies)
│   ├── utils/
│   │   ├── format-currency.ts
│   │   ├── format-date.ts
│   │   └── index.ts
│   ├── hooks/
│   │   ├── use-debounce.ts
│   │   ├── use-local-storage.ts
│   │   └── index.ts
│   ├── types/
│   │   ├── api-response.type.ts
│   │   └── index.ts
│   ├── validators/
│   │   ├── is-email.ts
│   │   └── index.ts
│   └── index.ts
│
├── core/                        # Foundation & configuration
│   ├── api/
│   │   ├── client.ts
│   │   └── index.ts
│   ├── router/
│   │   ├── router.tsx
│   │   └── index.ts
│   ├── store/
│   │   ├── provider.tsx
│   │   └── index.ts
│   ├── ui/
│   │   ├── provider.tsx
│   │   └── index.ts
│   └── index.ts
│
└── modules/                     # Business features
    ├── auth/
    │   ├── components/
    │   │   ├── login-form.tsx
    │   │   └── index.ts
    │   ├── hooks/
    │   │   ├── use-auth.ts
    │   │   └── index.ts
    │   ├── api/
    │   │   ├── auth-api.ts
    │   │   └── index.ts
    │   ├── types/
    │   │   ├── user.type.ts
    │   │   └── index.ts
    │   └── index.ts
    │
    ├── dashboard/
    │   ├── components/
    │   ├── hooks/
    │   ├── api/
    │   └── index.ts
    │
    └── users/
        ├── components/
        ├── hooks/
        ├── api/
        ├── types/
        └── index.ts
```

---

## Quick Decision Guide

**Where does my code belong?**

```
┌─ Is it a pure utility with NO dependencies?
│   └─ YES → shared/
│
├─ Is it project setup or external service config?
│   └─ YES → core/
│
└─ Is it tied to business logic or features?
    └─ YES → modules/
```

**Examples:**

- `formatDate()` → `shared/utils/`
- API client setup → `core/api/`
- User authentication → `modules/auth/`
- Debounce hook → `shared/hooks/`
- Router config → `core/router/`
- Dashboard stats → `modules/dashboard/`

---

## Summary

**Key Principles:**

1. **F4ST Architecture** - shared/, core/, modules/ with strict dependency flow
2. **Dependency Flow** - modules → core → shared (never reverse)
3. **Path Aliases** - Use `@/shared`, `@/core`, `@/modules` for clean imports
4. **Barrel Exports** - Public API via index.ts in each layer/module
5. **Consistent Naming** - kebab-case files, PascalCase components, camelCase functions
6. **Module Structure** - components/, hooks/, api/, types/, utils/ subdirectories

**See Also:**

- [Architecture Standards](../../../standards/01-architecture/) - Detailed F4ST documentation
- [Code Standards](../../../standards/code-standards.md) - Complete coding conventions
- [Component Patterns](./component-patterns.md) - Component structure patterns
- [Data Fetching](./data-fetching.md) - API service patterns
