# Shared Layer

The foundation layer containing pure, portable utilities with no dependencies. This is the base layer that all other layers can import from.

---

## Characteristics

- **Zero dependencies** - Cannot import from `core/` or `modules/`
- **Portability** - Code can be copied to any project and work immediately
- **No business logic** - Should not contain domain-specific rules
- **Pure when possible** - Prefer pure functions without side effects
- **Well-tested** - Shared code is used widely, reliability is critical

---

## Categories

| Category | Description | Examples |
| -------- | ----------- | -------- |
| **Utils** | Pure utility functions | `format-currency.ts`, `format-date.ts`, `slugify.ts`, `deep-clone.ts` |
| **Hooks** | Generic React hooks | `use-debounce.ts`, `use-local-storage.ts`, `use-media-query.ts` |
| **Types** | Shared type definitions | `api-response.type.ts`, `pagination.type.ts`, `nullable.type.ts` |
| **Constants** | Application-wide constants | `http-status.ts`, `keyboard-keys.ts`, `regex-patterns.ts` |
| **Validators** | Generic validation functions | `is-email.ts`, `is-url.ts`, `is-phone-number.ts` |

> **Note:** UI components belong in `core/ui/`, not here. Components typically need theme/design tokens which creates dependencies.

---

## Example Structure

```plaintext
shared/
├── utils/
│   ├── format-currency.ts
│   ├── format-date.ts
│   ├── deep-clone.ts
│   └── index.ts
├── hooks/
│   ├── use-debounce.ts
│   ├── use-local-storage.ts
│   ├── use-media-query.ts
│   └── index.ts
├── types/
│   ├── api-response.type.ts
│   ├── pagination.type.ts
│   └── index.ts
├── constants/
│   ├── http-status.ts
│   └── index.ts
├── validators/
│   ├── is-email.ts
│   └── index.ts
└── index.ts
```

---

## Guidelines

### Do

- Keep each utility focused on one thing
- Write comprehensive tests for shared code
- Use descriptive, specific names
- Export through barrel files

### Don't

- Create "junk drawer" files (`misc.ts`, `helpers.ts`, `utils.ts`)
- Import from `core/` or `modules/` - shared has NO dependencies
- Put project-specific configuration here
- Put UI components here - they belong in `core/ui/`

---

## Dependency Rule

```plaintext
shared/ → imports from NOTHING (completely portable)
```

This is the foundation layer. Both `core/` and `modules/` can import from here.

---

## The Portability Test

Before adding code to shared, ask:

```plaintext
Can I copy this file to a completely different project
and use it immediately without modifications?

YES → shared/
NO  → modules/
```

---

## Examples: Shared vs Module

| Code | Layer | Reasoning |
| ---- | ----- | --------- |
| `formatCurrency(amount, locale)` | **Shared** | Pure function, works anywhere |
| `formatOrderTotal(order)` | **Module** | Depends on Order type, has business rules |
| `useDebounce(value, delay)` | **Shared** | Generic hook, no project logic |
| `useAuth()` | **Module** | Tied to project's auth system |
| `validateEmail(email)` | **Shared** | Standard email validation |
| `validateCheckoutForm(form)` | **Module** | Business-specific validation |
| `Spinner`, `Button`, `Modal` | **Core** | UI components need theme/design tokens |
| `OrderCard` component | **Module** | Business-specific component |
| `Pagination` type | **Shared** | Generic pattern |
| `Order` type | **Module** | Business entity |

---

## Common Mistakes

| Mistake | Problem | Solution |
| ------- | ------- | -------- |
| `formatPrice()` that imports `Order` type | Creates hidden dependency on modules | Make it generic: `formatCurrency(amount, currency)` |
| `useApi()` hook with hardcoded endpoints | Not portable to other projects | Keep generic, pass config as params |
| Putting all types in `shared/types` | Business types don't belong here | Only generic types like `Nullable<T>`, `ApiResponse<T>` |

---

## When Shared Gets Too Big

If `shared/` grows large, consider:

1. **Grouping by domain** (still within shared):

    ```plaintext
    shared/
    ├── date/          # All date-related utils
    ├── string/        # String manipulation
    └── form/          # Form utilities
    ```

2. **Extracting to internal package** (for monorepos):

    ```plaintext
    packages/
    └── common-utils/  # Becomes a proper package
    ```

---

## Related

- [Core Layer](./core.md) - For infrastructure setup
- [Modules Layer](./modules.md) - For business features
