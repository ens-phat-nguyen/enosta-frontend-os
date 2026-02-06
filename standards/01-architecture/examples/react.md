# React Example - F4ST Architecture

A complete example implementing the F4ST architecture with React ecosystem.

---

## Tech Stack

| Technology | Purpose |
| ---------- | ------- |
| **Vite** | Build tool & dev server |
| **TanStack Router** | File-based routing |
| **Jotai** | Atomic state management |
| **Tailwind CSS** | Utility-first CSS |
| **HeroUI** | Component library |

---

## Project Structure

```plaintext
src/
├── main.tsx                    # App entry point
├── app/                        # App configuration
│   └── tanstack-router/
│       └── route-tree.gen.ts   # Auto-generated route tree
├── routes/                     # TanStack Router file-based routes
│   ├── layout.tsx              # Root layout (routeToken)
│   ├── page.tsx                # Home page (indexToken)
│   ├── login/
│   │   └── page.tsx
│   └── dashboard/
│       ├── layout.tsx          # Dashboard layout
│       ├── page.tsx            # Dashboard index
│       └── settings/
│           └── page.tsx
├── shared/                     # Pure utilities (no dependencies)
│   ├── utils/
│   │   ├── format-currency.ts
│   │   ├── format-date.ts
│   │   └── index.ts
│   ├── hooks/
│   │   ├── use-debounce.ts
│   │   ├── use-local-storage.ts
│   │   └── index.ts
│   ├── types/
│   │   ├── api-response.type.ts
│   │   └── index.ts
│   ├── validators/
│   │   ├── is-email.ts
│   │   └── index.ts
│   └── index.ts
├── core/                       # Foundation & configuration
│   ├── api/
│   │   ├── client.ts
│   │   └── index.ts
│   ├── router/
│   │   ├── router.tsx
│   │   └── index.ts
│   ├── store/
│   │   ├── provider.tsx
│   │   └── index.ts
│   ├── ui/
│   │   ├── provider.tsx
│   │   └── index.ts
│   └── styles/
│       └── main.css
│   
└── modules/                       # Business features
    ├── auth/
    │   ├── components/
    │   │   ├── login-form.tsx
    │   │   └── user-avatar.tsx
    │   ├── hooks/
    │   │   └── use-auth.ts
    │   ├── store/
    │   │   └── auth.store.ts
    │   ├── types/
    │   │   └── user.type.ts
    │   ├── api/
    │   │   └── auth-api.ts
    │   └── index.ts
    ├── dashboard/
    │   ├── components/
    │   │   ├── stat-card.tsx
    │   │   └── activity-feed.tsx
    │   ├── hooks/
    │   │   └── use-dashboard-data.ts
    │   ├── store/
    │   │   └── dashboard.store.ts
    │   └── index.ts
    └── notifications/
        ├── components/
        │   └── notification-toast.tsx
        ├── hooks/
        │   └── use-notifications.ts
        ├── store/
        │   └── notifications.store.ts
        └── index.ts
```

---

## Layer Mapping

### Shared Layer

| Category | Files | Purpose |
| -------- | ----- | ------- |
| **Utils** | `format-currency.ts`, `format-date.ts` | Pure formatting functions |
| **Hooks** | `use-debounce.ts`, `use-local-storage.ts` | Generic React hooks |
| **Types** | `api-response.type.ts` | `ApiResponse<T>`, `PaginatedResponse<T>`, `ApiError` |
| **Validators** | `is-email.ts` | Pure validation functions |

### Core Layer

| Category | Files | Purpose |
| -------- | ----- | ------- |
| **API** | `client.ts` | Fetch-based API client singleton |
| **Router** | `router.tsx` | TanStack Router instance + type registration |
| **Store** | `provider.tsx` | Jotai Provider wrapper |
| **UI** | `providers.tsx` | HeroUI Provider with router integration |
| **Styles** | `main.css` | Tailwind imports + CSS variables |

### Modules Layer

| Module | Components | Hooks | Store |
| ------ | ---------- | ----- | ----- |
| **auth** | `LoginForm`, `UserAvatar` | `useAuth` | `auth.store.ts` |
| **dashboard** | `StatCard`, `ActivityFeed` | `useDashboardData` | `dashboard.store.ts` |
| **notifications** | `NotificationToast` | `useNotifications` | `notifications.store.ts` |

---

## Dependency Flow

```plaintext
┌─────────────────────────────────────────────────────────────┐
│                        routes/                               │
│  (TanStack Router file-based routing)                       │
│  Imports from: modules/, core/                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        modules/                              │
│  auth/, dashboard/, notifications/                          │
│  Imports from: core/, shared/                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                         core/                                │
│  api/, router/, store/, ui/, styles/                        │
│  Imports from: shared/ only                                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        shared/                               │
│  utils/, hooks/, types/, validators/                        │
│  Imports from: NOTHING (portable)                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Related

- [Architecture Overview](../README.md)
- [Core Layer](../layers/core.md)
- [Shared Layer](../layers/shared.md)
- [Modules Layer](../layers/modules.md)
