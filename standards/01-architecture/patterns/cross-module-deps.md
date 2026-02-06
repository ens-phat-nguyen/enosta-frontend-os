# Cross-Module Dependencies

When one module needs functionality from another module, follow these guidelines to maintain clean architecture.

---

## Decision Priority

When module A needs something from module B, consider these options in order:

```plaintext
1. Extract to shared/     ← Preferred (eliminates dependency)
2. Import via public API  ← Acceptable (creates explicit dependency)
3. Duplicate code         ← Last resort (only for trivial code)
```

---

## Option 1: Extract to Shared (Preferred)

If the functionality is generic enough, move it to `shared/`.

**Before:**

```plaintext
modules/auth/utils/validate-email.ts  ← used by modules/checkout
```

**After:**

```plaintext
shared/validators/is-email.ts  ← used by both modules
```

**When to extract:**

- The code has no business logic
- It could work in any project
- Multiple modules need it

---

## Option 2: Import via Public Interface

If the functionality is genuinely business-specific, import through the public API.

```typescript
// modules/checkout/components/checkout-form.tsx

import { useAuth } from '@/modules/auth'
import type { User } from '@/modules/auth'

export function CheckoutForm() {
  const { user } = useAuth()
  // ...
}
```

**Rules:**

- Always import from index, never deep paths
- Document significant dependencies
- Watch for circular dependencies

---

## Circular Dependencies

**Problem:** Module A imports from B, and B imports from A.

```plaintext
modules/auth/ ──imports──► modules/user/
      ▲                          │
      └────────imports───────────┘

This is forbidden.
```

**Solutions:**

| Solution | When to use |
| -------- | ----------- |
| Extract shared code | Common functionality exists |
| Merge modules | They're actually one concept |
| Introduce third module | Need orchestration layer |
| Use events/callbacks | Loose coupling needed |

**Example - Extract shared utility:**

```plaintext
BEFORE (circular):
cart/ uses formatPrice() from checkout/
checkout/ uses getCartTotal() from cart/

AFTER (resolved):
shared/utils/format-price.ts   ← extract generic formatter
cart/                          ← uses shared formatter
checkout/                      ← uses shared formatter, imports cart via public API
```

**Example - Merge modules:**

```plaintext
BEFORE (circular):
auth/ ↔ user/   (tightly coupled, constantly importing each other)

AFTER (resolved):
modules/auth/   ← merge into one module, they're the same concern
```

---

## Dependency Direction

Prefer dependencies that flow toward "core" modules:

```plaintext
Good dependency direction:
checkout/ ──► cart/ ──► product/
                   ──► auth/

Avoid "leaf" modules depending on each other:
settings/ ◄──► notifications/  ← Problematic
```

---

## Documenting Dependencies

For significant cross-module dependencies, add a comment in `index.ts`:

```typescript
// modules/checkout/index.ts

/**
 * Checkout Module
 *
 * Dependencies:
 * - @/modules/auth (user authentication)
 * - @/modules/cart (cart state)
 * - @/modules/product (product data)
 */

export { CheckoutForm } from './components/checkout-form'
// ...
```

---

## Warning Signs

| Sign | Problem | Action |
| ---- | ------- | ------ |
| Many modules depend on one module | That module is too big | Consider splitting it |
| Module imports from 5+ other modules | Too many dependencies | Review boundaries |
| Circular dependency detected | Architecture violation | Refactor immediately |
| Deep imports happening | Bypassing public API | Enforce via ESLint |

---

## Dependency Visualization

Periodically review module dependencies:

```bash
# Using madge or similar tool
npx madge --image graph.svg src/modules
```

A healthy dependency graph:

- Has clear direction (mostly top-down)
- Has no cycles
- Has few highly-connected nodes

---

## Related

- [Modules Layer](../layers/modules.md) - Module structure
- [Shared Layer](../layers/shared.md) - When to extract to shared
- [Barrel Exports](./barrel-exports.md) - Public interface pattern
