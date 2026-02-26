# Layers

> Four layers with a strict downward dependency flow.

---

## Routes

Page routing and layout composition. Organizes file-based routing (e.g. TanStack Router, Next.js) or code-based route definitions.

| Property         | Value                                  |
| ---------------- | -------------------------------------- |
| **Imports from** | `modules/`, `core/`, `shared/`         |
| **Imported by**  | Nothing (top-level entry)              |
| **Contains**     | Page components, layouts, route guards |
| **Changes**      | When adding or restructuring pages     |

```
routes/
├── layout.tsx
├── page.tsx
├── login/
│   └── page.tsx
└── dashboard/
    ├── layout.tsx
    ├── page.tsx
    └── settings/
        └── page.tsx
```

---

## Modules

Business features. Each module is a self-contained unit with an explicit public interface.

| Property         | Value                                                                   |
| ---------------- | ----------------------------------------------------------------------- |
| **Imports from** | `core/`, `shared/`                                                      |
| **Imported by**  | `routes/`, other modules (via public API)                               |
| **Contains**     | Components, hooks, utils, types, API calls, store (module-scoped state) |
| **Changes**      | Frequently — this is where most development happens                     |

```
modules/
├── auth/
│   ├── index.ts          # Public API (barrel export, required)
│   ├── components/
│   ├── hooks/
│   ├── store/            # Module-scoped state
│   ├── types/
│   └── api/
├── dashboard/
└── notifications/
```

**Barrel exports are required** for modules. See [Module Structure](./module-structure.md).

---

## Core

Project-specific infrastructure. Configured once, used everywhere.

| Property         | Value                                                |
| ---------------- | ---------------------------------------------------- |
| **Imports from** | `shared/` only                                       |
| **Imported by**  | `routes/`, `modules/`                                |
| **Contains**     | Framework setup, external integrations, global state |
| **Changes**      | Rarely — modifications affect the entire application |

Common categories:

| Category       | Examples                                               |
| -------------- | ------------------------------------------------------ |
| Routing        | Router configuration, navigation utilities             |
| API            | HTTP client, interceptors, generated queries/mutations |
| UI             | Component library setup, theme, design tokens          |
| Styling        | Global styles, CSS framework setup                     |
| State          | Global store setup, persistence, hydration             |
| Environment    | Env variables, feature flags, runtime config           |
| Error Handling | Error boundaries, error reporting (Sentry, etc.)       |
| i18n           | Internationalization setup, locale config              |
| Analytics      | Tracking setup (GA, Mixpanel, Segment)                 |
| Real-time      | WebSocket client, connection management                |

> Not all applications need every category. Start with what you need.

```
core/
├── api/
│   └── client.ts
├── router/
│   └── router.tsx
├── store/
│   └── provider.tsx      # Global state provider
├── ui/
│   └── provider.tsx
└── styles/
    └── main.css
```

---

## Shared

Pure, portable utilities with zero project dependencies. Can be copied to any project and work immediately.

| Property         | Value                                      |
| ---------------- | ------------------------------------------ |
| **Imports from** | Nothing                                    |
| **Imported by**  | `routes/`, `modules/`, `core/`             |
| **Contains**     | Utils, hooks, types, constants, validators |
| **Changes**      | Occasionally                               |

| Category   | Examples                                                       |
| ---------- | -------------------------------------------------------------- |
| Utils      | `formatCurrency()`, `formatDate()`, `slugify()`, `deepClone()` |
| Hooks      | `useDebounce()`, `useLocalStorage()`, `useMediaQuery()`        |
| Types      | `Nullable<T>`, `ApiResponse<T>`, `PaginatedResponse<T>`        |
| Constants  | HTTP status codes, keyboard keys, regex patterns               |
| Validators | `isEmail()`, `isUrl()`, `isPhoneNumber()`                      |

```
shared/
├── utils/
│   ├── format-currency.ts
│   └── format-date.ts
├── hooks/
│   ├── use-debounce.ts
│   └── use-local-storage.ts
├── types/
│   └── api-response.type.ts
├── constants/
│   └── http-status.ts
└── validators/
    └── is-email.ts
```

> UI components belong in `core/ui/`, not here. Components typically depend on theme/design tokens.

---

## Anti-patterns

| Pattern                                      | Problem                  | Correct approach                    |
| -------------------------------------------- | ------------------------ | ----------------------------------- |
| `shared/` imports from `core/` or `modules/` | Dependency violation     | `shared/` has zero dependencies     |
| `core/` imports from `modules/`              | Dependency violation     | `core/` imports from `shared/` only |
| Business type in `shared/types/`             | Not portable             | Move to `modules/<feature>/types/`  |
| Generic util in `modules/`                   | Could be reused          | Move to `shared/`                   |
| UI components in `shared/`                   | Need theme/design tokens | Move to `core/ui/`                  |

---

## See also

- [Module Structure](./module-structure.md) — barrel exports and public API
- [Dependency Rules](./dependency-rules.md) — cross-module imports
- [Placing Code](../guides/placing-code.md) — deciding where code belongs
