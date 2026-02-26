# Splitting Modules

> When and how to break a module into smaller ones.

---

## When to Split

| Signal                     | Example                                         |
| -------------------------- | ----------------------------------------------- |
| Unrelated features coexist | `user/` handles profile, billing, notifications |
| Large public API           | `index.ts` exports 15+ items                    |
| Generic naming             | `utils`, `common`, `misc`                       |
| Circular dependencies      | Module A and B import each other                |
| Frequent merge conflicts   | Multiple developers edit the same module        |
| Hard to explain            | Can't describe in one sentence                  |

---

## How to Split

1. Identify distinct responsibilities
2. Create new modules for each
3. Move related code
4. Update original `index.ts` to re-export temporarily
5. Update consumers gradually
6. Remove temporary re-exports

```
BEFORE:
modules/user/
├── profile-card.tsx
├── settings-form.tsx
├── billing-info.tsx
└── ...

AFTER:
modules/user/            → Core user functionality
modules/user-settings/   → Settings feature
modules/billing/         → Billing feature
```

---

## Module Health Checklist

```
[ ] All code serves a single, clear purpose
[ ] Name accurately describes contents
[ ] New developers understand scope quickly
[ ] Changes rarely affect other modules
[ ] Can be described in one sentence
```

---

## See also

- [Module Structure](../reference/module-structure.md) — structure and barrel exports
- [Dependency Rules](../reference/dependency-rules.md) — cross-module imports
