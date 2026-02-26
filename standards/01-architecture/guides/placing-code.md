# Placing Code

> Where does my new code belong?

---

## Decision Flow

```
START
  │
  ├─ Already exists in shared/ or core/?
  │   └─ YES → Use it. Do not duplicate.
  │
  ├─ Is it a page or layout?
  │   └─ YES → routes/
  │
  ├─ Is it project infrastructure or external service config?
  │   └─ YES → core/
  │       Examples: Router, API client, theme, global store
  │
  ├─ Is it tied to a business domain or feature?
  │   └─ YES → modules/
  │       Examples: Order validation, user permissions, dashboard
  │
  ├─ Can it be copied to another project and work immediately?
  │   └─ YES → shared/
  │       Examples: formatDate(), useDebounce(), isEmail()
  │
  └─ Still unsure?
      └─ Default to modules/
         Easier to promote to shared/ later than to untangle dependencies.
```

---

## Quick Reference

### Components

| Type                         | Location                        | Example                      |
| ---------------------------- | ------------------------------- | ---------------------------- |
| Page / Layout                | `routes/`                       | `dashboard/page.tsx`         |
| UI primitive (design system) | `core/ui/`                      | `Button`, `Modal`, `Spinner` |
| Business-specific            | `modules/<feature>/components/` | `OrderCard`, `UserBadge`     |

### Hooks

| Type              | Location                   | Example                          |
| ----------------- | -------------------------- | -------------------------------- |
| Generic, reusable | `shared/hooks/`            | `useDebounce`, `useLocalStorage` |
| Feature-specific  | `modules/<feature>/hooks/` | `useAuth`, `useCart`             |
| Infrastructure    | `core/`                    | Provider hooks                   |

### Utilities

| Type             | Location                   | Example                     |
| ---------------- | -------------------------- | --------------------------- |
| Pure, generic    | `shared/utils/`            | `formatCurrency`, `slugify` |
| Business logic   | `modules/<feature>/utils/` | `calculateOrderTotal`       |
| Config-dependent | `core/`                    | Logger, env helpers         |

### Types

| Type              | Location                   | Example                         |
| ----------------- | -------------------------- | ------------------------------- |
| Generic patterns  | `shared/types/`            | `Nullable<T>`, `ApiResponse<T>` |
| Business entities | `modules/<feature>/types/` | `Order`, `User`, `Product`      |

### State

| Type          | Location                   | Example                    |
| ------------- | -------------------------- | -------------------------- |
| Global        | `core/store/`              | Auth status, theme, locale |
| Module-scoped | `modules/<feature>/store/` | Cart items, form draft     |

---

## Tiebreaker Questions

If still unsure after the decision flow:

1. **"If I delete this feature, does this code become useless?"**
   - Yes → `modules/`
   - No → `shared/` or `core/`

2. **"Could a different project use this exact code without changes?"**
   - Yes → `shared/`
   - No → `modules/` or `core/`

---

## See also

- [Layers](../reference/layers.md) — layer specifications
- [Dependency Rules](../reference/dependency-rules.md) — what can import what
