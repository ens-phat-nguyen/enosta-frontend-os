# Decision Framework

This guide helps you make architectural decisions when writing new code.

---

## The Main Question: Where Does My Code Belong?

```plaintext
START
  │
  ├─ Is it already in shared/ or core/?
  │   └─ YES → Use existing code. Do not duplicate.
  │
  ├─ Is it project setup or external service configuration?
  │   └─ YES → core/
  │       Examples: Router setup, API client, theme config
  │
  ├─ Is it tied to a specific business domain or feature?
  │   └─ YES → modules/
  │       Examples: Order validation, user permissions, dashboard
  │
  ├─ Does it manage state specific to this project?
  │   └─ YES → modules/
  │       Examples: Shopping cart, notification queue
  │
  ├─ Does it depend on other modules?
  │   └─ YES → modules/
  │       Code that imports from modules/ cannot be in shared/
  │
  ├─ Can it be copied to another project and work immediately?
  │   └─ YES → shared/
  │       Examples: formatDate(), useDebounce(), isEmail()
  │
  └─ Still unsure?
      └─ Default to modules/
         Easier to move from module to shared than reverse.
```

---

## Quick Decision Tables

### Components

| Component Type | Location | Example |
| -------------- | -------- | ------- |
| UI primitives (design system) | `core/ui/` | `Spinner`, `Button`, `Modal` |
| Business-specific | `modules/<feature>/components/` | `OrderCard`, `UserBadge` |

### Hooks

| Hook Type | Location | Example |
| --------- | -------- | ------- |
| Generic, reusable | `shared/hooks/` | `useDebounce`, `useLocalStorage` |
| Feature-specific | `modules/<feature>/hooks/` | `useAuth`, `useCart` |
| Infrastructure | `core/` | Provider hooks (rare) |

### Utilities

| Utility Type | Location | Example |
| ------------ | -------- | ------- |
| Pure, generic | `shared/utils/` | `formatCurrency`, `slugify` |
| Business logic | `modules/<feature>/utils/` | `calculateOrderTotal` |
| Config-dependent | `core/` or `modules/` | Depends on what it configures |

### Types

| Type Category | Location | Example |
| ------------- | -------- | ------- |
| Generic patterns | `shared/types/` | `Nullable<T>`, `ApiResponse<T>` |
| Business entities | `modules/<feature>/types/` | `Order`, `User`, `Product` |

---

## Common Scenarios

### "I need a utility that formats dates"

```plaintext
Q: Does it have business rules?
   - "Show relative time for last 24h, then absolute" → modules/ (business rule)
   - "Format to ISO string" → shared/ (generic)
```

### "I need a hook for form validation"

```plaintext
Q: What kind of validation?
   - "Email format, required fields" → shared/ (generic)
   - "Order must have valid shipping address for country" → modules/ (business)
```

### "I need a component for displaying user info"

```plaintext
Q: What does it display?
   - Generic loading/avatar component → core/ui/ (design system)
   - "User name with role badge and permissions" → modules/ (business)
```

### "I need to call an API"

```plaintext
- API client setup → core/api/
- Specific endpoint calls → modules/<feature>/api/
```

---

## Red Flags

Watch for these signs that code is in the wrong place:

| Red Flag | Problem | Solution |
| -------- | ------- | -------- |
| `shared/` imports from `core/` or `modules/` | Dependency violation | shared/ has NO dependencies |
| `core/` imports from `modules/` | Dependency violation | core/ can only import from shared/ |
| Business type in `shared/types/` | Not portable | Move to module |
| Generic util in `modules/` | Could be reused | Move to shared/ |
| Module imports from 5+ modules | Too many dependencies | Review boundaries |

---

## When You're Still Unsure

1. **Ask:** "If I delete this feature, what happens to this code?"
   - Code becomes useless → it belongs with the feature (modules/)
   - Code still useful → might belong in shared/

2. **Ask:** "Could a different project use this exact code?"
   - Yes, without changes → shared/
   - Yes, but needs project config → modules/ or core/
   - No → modules/

3. **Default to modules/** - It's easier to promote code to shared/ later than to untangle dependencies.

---

## Related

- [Core Layer](../layers/core.md)
- [Shared Layer](../layers/shared.md)
- [Modules Layer](../layers/modules.md)
