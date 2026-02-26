# Dependency Rules

> Upper layers import from lower layers. Never the reverse.

---

## Allowed Imports

| Layer      | Can import from                                    |
| ---------- | -------------------------------------------------- |
| `routes/`  | `modules/`, `core/`, `shared/`                     |
| `modules/` | `core/`, `shared/`, other modules (via public API) |
| `core/`    | `shared/` only                                     |
| `shared/`  | Nothing                                            |

---

## Cross-Module Imports

When module A needs something from module B, use this priority:

| Priority | Option                | When to use                             |
| -------- | --------------------- | --------------------------------------- |
| 1        | Extract to `shared/`  | The code is generic and portable        |
| 2        | Import via public API | The code is genuinely business-specific |
| 3        | Duplicate             | Last resort, only for trivial code      |

```typescript
// Correct — import via public API
import { useAuth } from "@/modules/auth";
import type { User } from "@/modules/auth";

// Wrong — deep import
import { useSession } from "@/modules/auth/hooks/use-session";
```

---

## Circular Dependencies

Module A imports from B, and B imports from A. **This is forbidden.**

| Solution                         | When to use                  |
| -------------------------------- | ---------------------------- |
| Extract shared code to `shared/` | Common functionality exists  |
| Merge modules                    | They're actually one concept |
| Introduce a third module         | Need an orchestration layer  |
| Use events/callbacks             | Loose coupling needed        |

---

## Store Dependencies

| Store type   | Location                   | Scope                                  |
| ------------ | -------------------------- | -------------------------------------- |
| Global state | `core/store/`              | App-wide (auth status, theme, locale)  |
| Module state | `modules/<feature>/store/` | Module-scoped (cart items, form state) |

Module stores can read from global state. Global state must not import from module stores.

---

## Anti-patterns

| Pattern                           | Problem                | Correct approach                           |
| --------------------------------- | ---------------------- | ------------------------------------------ |
| `shared/` imports from `core/`    | Dependency violation   | `shared/` has zero dependencies            |
| `core/` imports from `modules/`   | Dependency violation   | `core/` imports from `shared/` only        |
| Module imports from 5+ modules    | Too many dependencies  | Review boundaries, extract to shared       |
| Circular dependency               | Architecture violation | Refactor immediately (see solutions above) |
| Deep imports bypassing public API | Tight coupling         | Import from `index.ts` only                |

---

## See also

- [Layers](./layers.md) — layer specifications
- [Module Structure](./module-structure.md) — public API and barrel exports
- [Placing Code](../guides/placing-code.md) — deciding where code belongs
