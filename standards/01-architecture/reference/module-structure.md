# Module Structure

> Every module has a flat structure, a single barrel export (`index.ts`), and a clear public API.

---

## Structure

```
modules/<feature>/
├── index.ts              # Public API (required)
├── components/           # React components
├── hooks/                # Custom hooks
├── utils/                # Module-specific utilities
├── types/                # TypeScript types/interfaces
├── constants/            # Module-specific constants
├── store/                # Module-scoped state
└── api/                  # API endpoint calls
```

Not all modules need all categories. Start minimal, add as needed.

All modules live flat within `modules/`. No nested module hierarchies.

---

## Barrel Export

Each module must have exactly one `index.ts` at the root. This is its public API.

```typescript
// modules/auth/index.ts

// Components
export { LoginForm } from "./components/login-form";
export { UserAvatar } from "./components/user-avatar";

// Hooks
export { useAuth } from "./hooks/use-auth";

// Types
export type { User, AuthState } from "./types/user.type";

// Note: internal files like use-session.ts, token.ts are NOT exported
```

### Rules

1. **Import from index only** — never deep-import into a module's internals.
2. **Export types separately** — use `export type` for type-only exports.
3. **Group exports by category** — components, hooks, types, etc.
4. **Start minimal** — export only what consumers need. Add more when required.

```typescript
// Correct
import { useAuth } from "@/modules/auth";
import type { User } from "@/modules/auth";

// Wrong — bypasses public API
import { useAuth } from "@/modules/auth/hooks/use-auth";
import { useSession } from "@/modules/auth/hooks/use-session";
```

### Scope

Strict barrel export rules apply to `modules/` only. `core/` and `shared/` may use barrel files at their own discretion.

---

## Public vs Internal

| Export (public)                            | Keep internal                             |
| ------------------------------------------ | ----------------------------------------- |
| Components used by other modules or routes | Helper components used only within module |
| Hooks that provide module functionality    | Hooks for internal state management       |
| Types needed by consumers                  | Implementation detail types               |
| Constants needed externally                | Internal configuration                    |

---

## Anti-patterns

| Pattern                       | Problem                            | Correct approach            |
| ----------------------------- | ---------------------------------- | --------------------------- |
| Export everything             | No encapsulation, hard to refactor | Be selective, start minimal |
| Deep imports into module      | Tight coupling to internals        | Import from `index.ts` only |
| No type exports               | Consumers can't type their code    | Export necessary types      |
| Nested barrel files in module | Multiple sources of truth          | One `index.ts` per module   |

---

## See also

- [Layers](./layers.md) — modules layer specification
- [Dependency Rules](./dependency-rules.md) — cross-module imports
- [Splitting Modules](../guides/splitting-modules.md) — when a module grows too large
