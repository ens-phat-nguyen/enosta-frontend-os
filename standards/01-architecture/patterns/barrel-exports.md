# Barrel Exports Pattern

A barrel export is an `index.ts` file that re-exports selected items from a module, creating a clear public interface.

---

## Why Use Barrel Exports

| Benefit | Description |
| ------- | ----------- |
| **Clear boundaries** | `index.ts` shows exactly what the module offers |
| **Refactor safety** | Internal file structure can change without breaking consumers |
| **Intentional API** | Forces developers to think about what should be public |
| **Clean imports** | `@/modules/auth` instead of `@/modules/auth/hooks/use-auth` |

---

## Basic Structure

```plaintext
modules/auth/
├── index.ts              # ← Public interface
├── components/
│   ├── login-form.tsx    # Exported
│   └── auth-modal.tsx    # Internal
├── hooks/
│   ├── use-auth.ts       # Exported
│   └── use-session.ts    # Internal
└── utils/
    └── token.ts          # Internal
```

```typescript
// modules/auth/index.ts

// Components
export { LoginForm } from './components/login-form'

// Hooks
export { useAuth } from './hooks/use-auth'

// Types
export type { User, AuthState } from './types/user.type'
```

---

## Rules

### 1. Only Import from Index

```typescript
// ✅ Correct
import { useAuth } from '@/modules/auth'
import type { User } from '@/modules/auth'

// ❌ Wrong - bypasses public interface
import { useAuth } from '@/modules/auth/hooks/use-auth'
import { useSession } from '@/modules/auth/hooks/use-session'
```

### 2. Export Types Separately

```typescript
// ✅ Explicit type exports
export type { User, AuthState } from './types/user.type'

// ❌ Avoid mixing with value exports when possible
export { User } from './types/user.type'  // Ambiguous
```

### 3. Group Exports by Category

```typescript
// modules/dashboard/index.ts

// ─── Components ───────────────────────────
export { DashboardLayout } from './components/dashboard-layout'
export { StatCard } from './components/stat-card'
export { ActivityFeed } from './components/activity-feed'

// ─── Hooks ────────────────────────────────
export { useDashboardData } from './hooks/use-dashboard-data'
export { useWidgets } from './hooks/use-widgets'

// ─── Types ────────────────────────────────
export type { DashboardConfig, Widget } from './types'
```

---

## What to Export vs Keep Internal

| Export (Public) | Keep Internal |
| --------------- | ------------- |
| Components used by other modules | Helper components used only within module |
| Hooks that provide module functionality | Hooks for internal state management |
| Types needed by consumers | Implementation detail types |
| Constants needed externally | Internal configuration |

**Rule of thumb:** Start with minimal exports. Add more only when needed.

---

## One Barrel Per Module

Each module has exactly **one `index.ts`** at the root level. No nested barrels.

```plaintext
modules/dashboard/
├── index.ts                    # ← Only barrel file
├── components/
│   ├── stat-card.tsx          # No index.ts here
│   └── activity-feed.tsx
└── hooks/
    └── use-dashboard-data.ts   # No index.ts here
```

```typescript
// modules/dashboard/index.ts
export { StatCard } from './components/stat-card'
export { ActivityFeed } from './components/activity-feed'
export { useDashboardData } from './hooks/use-dashboard-data'
```

**Why no nested barrels:**

- Forces modules to stay small and focused
- Single source of truth for public API
- Simpler mental model
- If a module needs nested barrels, it's probably too big → split it

---

## Common Mistakes

| Mistake | Problem | Solution |
| ------- | ------- | -------- |
| Export everything | No encapsulation, hard to refactor | Be selective, start minimal |
| Deep imports allowed | Tight coupling, fragile code | Enforce index-only imports via ESLint |
| No type exports | Consumers can't type their code | Always export necessary types |
| Circular re-exports | Build errors, confusing dependencies | Review dependency graph |

---

## Related

- [Modules Layer](../layers/modules.md) - Module structure overview
- [Cross-Module Dependencies](./cross-module-deps.md) - When modules need each other
