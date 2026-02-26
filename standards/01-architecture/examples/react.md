# Example: React + Vite

A complete example implementing the architecture with React ecosystem.

---

## Tech Stack

| Technology      | Purpose                   |
| --------------- | ------------------------- |
| Vite            | Build tool and dev server |
| TanStack Router | File-based routing        |
| Jotai           | Atomic state management   |
| Tailwind CSS    | Utility-first CSS         |
| HeroUI          | Component library         |

---

## Project Structure

```
src/
├── main.tsx
├── routes/                     # Routing layer
│   ├── layout.tsx
│   ├── page.tsx
│   ├── login/
│   │   └── page.tsx
│   └── dashboard/
│       ├── layout.tsx
│       ├── page.tsx
│       └── settings/
│           └── page.tsx
├── core/                       # Project infrastructure
│   ├── api/
│   │   └── client.ts
│   ├── router/
│   │   └── router.tsx
│   ├── store/
│   │   └── provider.tsx        # Jotai/Zustand Provider (global state)
│   ├── ui/
│   │   └── provider.tsx        # HeroUI Provider
│   └── styles/
│       └── main.css
├── modules/                    # Business features
│   ├── auth/
│   │   ├── index.ts
│   │   ├── components/
│   │   │   ├── login-form.tsx
│   │   │   └── user-avatar.tsx
│   │   ├── hooks/
│   │   │   └── use-auth.ts
│   │   ├── store/
│   │   │   └── auth.store.ts   # Module-scoped atoms
│   │   ├── types/
│   │   │   └── user.type.ts
│   │   └── api/
│   │       └── auth-api.ts
│   ├── dashboard/
│   │   ├── index.ts
│   │   ├── components/
│   │   │   ├── stat-card.tsx
│   │   │   └── activity-feed.tsx
│   │   ├── hooks/
│   │   │   └── use-dashboard-data.ts
│   │   └── store/
│   │       └── dashboard.store.ts
│   └── notifications/
│       ├── index.ts
│       ├── components/
│       │   └── notification-toast.tsx
│       ├── hooks/
│       │   └── use-notifications.ts
│       └── store/
│           └── notifications.store.ts
└── shared/                     # Portable utilities
    ├── utils/
    │   ├── format-currency.ts
    │   └── format-date.ts
    ├── hooks/
    │   ├── use-debounce.ts
    │   └── use-local-storage.ts
    ├── types/
    │   └── api-response.type.ts
    └── validators/
        └── is-email.ts
```

---

## Dependency Flow

```
routes/          → modules/, core/
modules/         → core/, shared/
core/            → shared/ only
shared/          → nothing
```

---

## See also

- [Layers](../reference/layers.md) — layer specifications
- [Module Structure](../reference/module-structure.md) — barrel exports and public API
