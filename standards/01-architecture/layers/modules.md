# Modules Layer

Project-specific code where most development happens. Each module is a self-contained unit that encapsulates related functionality.

---

## Characteristics

- **Self-contained** - A module contains everything it needs to function
- **Explicit interface** - External code interacts only through public API
- **Business logic lives here** - Domain rules, validation, feature-specific behavior
- **Changes frequently** - This is where active development happens

---

## What is a Module?

A module can be:

| Type | Description | Examples |
| ---- | ----------- | -------- |
| **Feature** | A distinct functional area | `auth`, `dashboard`, `checkout`, `user-profile` |
| **Cross-cutting** | Functionality used across features | `notifications`, `permissions`, `analytics` |

All modules live flat within `modules/` directory. No nested hierarchies.

---

## Module Structure

```plaintext
modules/
└── auth/
    ├── index.ts              # Public interface (barrel export)
    ├── components/
    │   ├── login-form.tsx
    │   └── user-avatar.tsx
    ├── hooks/
    │   ├── use-auth.ts       # Exported (public)
    │   └── use-session.ts    # Not exported (internal)
    ├── utils/
    │   └── token.ts          # Not exported (internal)
    ├── types/
    │   └── user.type.ts
    └── api/
        └── auth-api.ts       # API calls for this module
```

---

## Public Interface Pattern

The `index.ts` file defines what's public:

```typescript
// modules/auth/index.ts

// Components
export { LoginForm } from './components/login-form'
export { UserAvatar } from './components/user-avatar'

// Hooks
export { useAuth } from './hooks/use-auth'

// Types
export type { User, AuthState, LoginCredentials } from './types/user.type'

// Note: use-session.ts and token.ts are NOT exported
// They are internal implementation details
```

**Why this matters:**

- Looking at `index.ts` immediately shows what the module offers
- Internal structure can change without affecting consumers
- Forces intentional API design
- Clean imports: `@/modules/auth` instead of deep paths

> **Deep dive:** See [Barrel Exports Pattern](../patterns/barrel-exports.md)

---

## Import Rules

| Rule | Example |
| ---- | ------- |
| Import from module index | `import { useAuth } from '@/modules/auth'` |
| Use absolute imports | `@/modules/auth` not `../../modules/auth` |
| Import types explicitly | `import type { User } from '@/modules/auth'` |

**Never do:**

```typescript
// ❌ Deep import - bypasses public interface
import { useSession } from '@/modules/auth/hooks/use-session'
```

---

## When to Split a Module

### Signals to Split

| Signal | Example |
| ------ | ------- |
| Unrelated features coexist | `user` handles profile, billing, notifications |
| Large public interface | `index.ts` exports 15+ items |
| Generic naming | `utils`, `common`, `misc` |
| Circular dependencies | Module A ↔ Module B |
| Frequent merge conflicts | Multiple devs conflict on same module |
| Hard to explain | Can't describe in one sentence |

### How to Split

1. Identify distinct responsibilities
2. Create new modules for each
3. Move related code
4. Update original `index.ts` to re-export (temporary)
5. Gradually update consumers
6. Remove re-exports

**Example:**

```plaintext
BEFORE:
modules/user/
├── profile-card.tsx
├── settings-form.tsx
├── billing-info.tsx
└── ...

AFTER:
modules/user/           → Core user functionality
modules/user-settings/  → Settings feature
modules/billing/        → Billing feature
```

---

## Module Health Checklist

A healthy module:

```plaintext
[ ] All code serves a single, clear purpose
[ ] Name accurately describes contents
[ ] New developers understand scope quickly
[ ] Changes are localized (rarely affect other modules)
[ ] Can be explained in one sentence
```

---

## Common Module Categories

| Category | Typical Contents |
| -------- | ---------------- |
| `components/` | React components |
| `hooks/` | Custom hooks |
| `utils/` | Module-specific utilities |
| `types/` | TypeScript types/interfaces |
| `constants/` | Module-specific constants |
| `store/` | State management (e.g., Redux, Zustand) |

Not all modules need all categories. Start minimal, add as needed.

---

## Cross-Module Dependencies

When module A needs module B:

1. **First, try extracting to shared/** - If it's generic enough
2. **If not, import via public interface** - `import { x } from '@/modules/b'`

> **Detailed guidance:** See [Cross-Module Dependencies](../patterns/cross-module-deps.md)

---

## Related

- [Core Layer](./core.md) - For infrastructure setup
- [Shared Layer](./shared.md) - For reusable utilities
- [Barrel Exports Pattern](../patterns/barrel-exports.md) - Public interface details
