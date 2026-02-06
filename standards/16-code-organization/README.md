# Code Organization & Naming

> "Code is read 100x more than it's written."

---

## Foundational Principles

How you organize code affects everything.

### 1. **Interface-First Thinking**

Design file structure before implementation. What lives where?

### 2. **DRY (Don't Repeat Yourself)**

Shared code goes to shared/, utilities go to utils/, features are isolated.

### 3. **KISS (Keep It Simple, Stupid)**

Simple file structure beats clever organization every time.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Code Organization** includes:

1. **Project Structure** — Folders and files
2. **Module Organization** — What goes in each folder
3. **Naming Conventions** — PascalCase for components, camelCase for functions
4. **Import Organization** — Order matters
5. **Constants** — Where and how to define them

Good organization = easy to find code = fast changes.

---

## Goals

1. **Easy Navigation** — Find files quickly
2. **Clear Ownership** — Know what each folder does
3. **Modularity** — Features are isolated
4. **Reusability** — Shared code is discoverable
5. **Scalability** — Structure doesn't break with 1000 files

---

## Table of Contents

- [Foundational Principles](#foundational-principles)
- [Project Structure](#project-structure)
- [Module Organization](#module-organization)
- [Naming Conventions](#naming-conventions)
- [Import Organization](#import-organization)
- [Constants & Config](#constants--config)
- [Best Practices](#best-practices)

---

## Project Structure

### Standard React App Structure

```
src/
├── app/                    # App configuration & layout
│  ├── App.tsx
│  ├── RootLayout.tsx
│  └── theme.ts
├── modules/                # Feature modules (see below)
│  ├── user/
│  ├── dashboard/
│  └── settings/
├── core/                   # Shared configuration
│  ├── api/
│  │  └── client.ts        # Apollo/TanStack config
│  ├── auth/
│  │  └── useAuth.ts       # Auth hook
│  └── hooks/
│     ├── useFetch.ts
│     └── useLocalStorage.ts
├── shared/                 # Shared utilities
│  ├── components/
│  │  ├── Button.tsx
│  │  ├── Modal.tsx
│  │  └── Toast.tsx
│  ├── hooks/
│  │  └── useMediaQuery.ts
│  ├── utils/
│  │  ├── format.ts
│  │  └── validate.ts
│  └── types.ts            # Global types
├── assets/                 # Images, fonts, etc
│  ├── images/
│  ├── icons/
│  └── fonts/
└── main.tsx
```

### Dependency Flow (Never Break This!)

```
app/
  ↓
modules/ (modules can import from core & shared)
  ↓
core/ (core can import from shared only)
  ↓
shared/ (no external dependencies)
```

**Rule:** Code at higher levels should NOT import from lower levels.
❌ shared/ importing from modules/
✅ modules/ importing from shared/

---

## Module Organization

### Feature Module Structure

```
src/modules/user/
├── components/           # Module-specific components
│  ├── UserCard.tsx
│  ├── UserForm.tsx
│  └── UserList.tsx
├── hooks/               # Module-specific hooks
│  ├── useUser.ts
│  └── useUsers.ts
├── store/               # Module state (if needed)
│  └── userStore.ts
├── types.ts             # Module types
├── constants.ts         # Module constants
├── index.ts             # Public API (barrel export)
└── README.md            # Module documentation
```

### Barrel Export Pattern

```typescript
// src/modules/user/index.ts
// ✅ Only export what's public
export { UserCard } from "./components/UserCard";
export { UserProfile } from "./components/UserProfile";
export { useUser } from "./hooks/useUser";
export type { User, CreateUserInput } from "./types";

// Outside module can do:
import { UserCard, useUser } from "modules/user";

// Cannot do:
import { UserCardInternals } from "modules/user/components/UserCard";
// ^^^ Not exported, so not part of public API
```

### Shared Components Organization

```
src/shared/components/
├── Button/
│  ├── Button.tsx
│  ├── Button.test.tsx
│  ├── Button.stories.tsx
│  └── index.ts
├── Modal/
│  ├── Modal.tsx
│  ├── Modal.test.tsx
│  └── index.ts
└── Form/
   ├── TextInput.tsx
   ├── Checkbox.tsx
   └── index.ts
```

---

## Naming Conventions

### Component Files (PascalCase)

```typescript
// ✅ Component files
UserCard.tsx; // Component
UserForm.tsx; // Component
LoginPage.tsx; // Page component

// ❌ Don't do this
user - card.tsx; // Kebab case for components
userCard.tsx; // Camel case for components
```

### Function/Variable Names (camelCase)

```typescript
// ✅ Functions and utilities
const calculateTotal = (items: Item[]): number => { ... };
const formatDate = (date: Date): string => { ... };
const getUserById = async (id: number): Promise<User> => { ... };

// ❌ Don't do this
const CalculateTotal = (items: Item[]): number => { ... };
const calculate_total = (items: Item[]): number => { ... };
```

### Constants (UPPER_SNAKE_CASE)

```typescript
// ✅ Constants
const MAX_RETRIES = 3;
const API_BASE_URL = 'https://api.example.com';
const USER_ROLES = ['admin', 'user', 'viewer'] as const;

// ❌ Don't do this
const maxRetries = 3;
const MAX-RETRIES = 3;
```

### Type/Interface Names (PascalCase)

```typescript
// ✅ Types
type User = { id: number; name: string };
interface UserProfile {
  /* ... */
}
enum UserRole {
  Admin,
  User,
  Viewer,
}

// ❌ Don't do this
type user = {
  /* ... */
};
interface IUserProfile {
  /* ... */
}
```

### Boolean Variables (is/has prefix)

```typescript
// ✅ Clear intent
const isLoading = true;
const isError = false;
const hasPermission = true;
const isAuthenticated = false;

// ❌ Unclear
const loading = true;
const error = false;
const permission = true;
```

---

## Import Organization

### Standard Order

```typescript
// 1. React and external libraries (alphabetical)
import React, { useEffect, useState } from "react";
import { useQuery } from "@apollo/client";
import { useNavigate } from "react-router-dom";

// 2. App modules (core, shared, modules)
import { useAuth } from "core/hooks";
import { Button, Modal } from "shared/components";
import { UserCard } from "modules/user";

// 3. Local files (relative imports)
import { UserForm } from "./components/UserForm";
import { useUserStore } from "./store/userStore";
import type { User } from "./types";

// 4. Styles (last)
import styles from "./Dashboard.module.css";
```

### Path Aliases (Configure in tsconfig)

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "core/*": ["src/core/*"],
      "shared/*": ["src/shared/*"],
      "modules/*": ["src/modules/*"],
      "assets/*": ["src/assets/*"]
    }
  }
}
```

```typescript
// ✅ With path aliases (clean)
import { Button } from "shared/components";
import { useAuth } from "core/auth";

// ❌ Without path aliases (messy)
import { Button } from "../../../shared/components";
import { useAuth } from "../../core/auth";
```

---

## Constants & Config

### Local Constants

```typescript
// src/modules/dashboard/constants.ts
export const DASHBOARD_COLUMNS = 3;
export const MAX_ITEMS_PER_PAGE = 20;
export const CHART_COLORS = ["#FF6B6B", "#4ECDC4", "#45B7D1"];
```

### Global Constants

```typescript
// src/shared/constants.ts
export const APP_NAME = "My App";
export const APP_VERSION = "1.0.0";
export const SUPPORT_EMAIL = "support@example.com";
```

### Config Files

```typescript
// src/core/config.ts
export const config = {
  api: {
    baseUrl: process.env.REACT_APP_API_URL || "http://localhost:3000",
    timeout: 30000,
  },
  auth: {
    tokenKey: "authToken",
    expiresIn: 3600,
  },
  cache: {
    enabled: true,
    ttl: 5 * 60 * 1000,
  },
};

// Usage
import { config } from "core/config";
const baseUrl = config.api.baseUrl;
```

### Environment-Specific Config

```typescript
// src/core/config.ts
const getConfig = () => {
  const isDev = process.env.NODE_ENV === "development";
  const isProd = process.env.NODE_ENV === "production";

  return {
    debug: isDev,
    apiUrl: isDev ? "http://localhost:4000" : "https://api.example.com",
    sentryDSN: isProd ? process.env.REACT_APP_SENTRY_DSN : undefined,
  };
};

export const config = getConfig();
```

---

## Best Practices

1. **One Concept Per File** — Don't mix multiple features
2. **Clear Folder Names** — `components/` not `comp/`
3. **Index Files** — Export public API via index.ts
4. **Consistent Casing** — PascalCase for components, camelCase for functions
5. **Alphabetical Order** — Imports within groups
6. **Path Aliases** — Avoid relative imports
7. **Feature Isolation** — Modules shouldn't import other modules
8. **Type Files** — Group related types in types.ts
9. **Separate Tests** — component.test.tsx next to component.tsx
10. **Document Structure** — README in complex modules

---

## File Organization Checklist

- [ ] Components in `components/`
- [ ] Hooks in `hooks/`
- [ ] Types in `types.ts`
- [ ] Constants in `constants.ts`
- [ ] Public API in `index.ts`
- [ ] Import order standardized
- [ ] Path aliases configured
- [ ] No circular imports
- [ ] Tests next to source
- [ ] No dead code
