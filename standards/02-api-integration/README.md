# API Integration Guidelines

This document describes how data flows from backend to your components.

---

## The Big Picture

```plaintext
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   Backend                                                                   │
│   ───────                                                                   │
│   Provides API + Schema                                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   CI/CD Pipeline                                                            │
│   ──────────────                                                            │
│   Generate types from schema                                                │
│   Type-check fails = breaking change detected                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   core/api                                                                  │
│   ────────                                                                  │
│   • Makes API calls                                                         │
│   • Manages states: loading, error, success, fetching                       │
│   • Handles caching                                                         │
│   • Exports base functions/hooks                                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   modules/[name]/hooks                                                      │
│   ────────────────────                                                      │
│   • Transforms API response to internal types (adapter)                     │
│   • Handles missing or unexpected data (fail safe)                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   Components                                                                │
│   ──────────                                                                │
│   Use internal types only                                                   │
│   Don't know about API format                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Step 1: Backend Provides Schema

Backend must provide a schema (OpenAPI, GraphQL, etc.) for every API.

| Rule | Description |
| --- | --- |
| **Schema is required** | No schema = blocker. Escalate to team lead. |
| **Schema is the contract** | Frontend generates types from this schema. |

### Why?

- Frontend should not guess API structure
- Reduces bugs from wrong types
- Enables automatic type generation

---

## Step 2: CI/CD Generates Types

When backend updates the schema, CI/CD pipeline:

1. Generates new types from schema
2. Runs type-check on frontend code
3. If type-check fails → breaking change detected

```plaintext
Schema updated
      │
      ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Generate   │ ──▶ │ Type-check  │ ──▶ │   Result    │
│   types     │     │   frontend  │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
                          ┌───────────────────┴───────────────────┐
                          ▼                                       ▼
                    ┌─────────┐                             ┌─────────┐
                    │  Pass   │                             │  Fail   │
                    │         │                             │         │
                    └─────────┘                             └─────────┘
                         │                                       │
                         ▼                                       ▼
                   Types are synced                     Breaking change!
```

### When Breaking Change Happens

| Situation | Action |
| --- | --- |
| **Planned change** | Backend informed frontend before merge. Frontend adapts. |
| **Unplanned change** | Team decides together: hotfix frontend or revert backend. |

---

## Step 3: Core API Layer

Located in `core/api/`. This layer:

| Responsibility | Description |
| --- | --- |
| **Make API calls** | Send requests to backend |
| **Manage states** | Track loading, error, success, fetching |
| **Handle caching** | Store and reuse responses |
| **Export utilities** | Provide base functions/hooks for modules |

### API States

| State | Meaning |
| --- | --- |
| `loading` | First fetch. No data yet. |
| `fetching` | Fetching data (includes background refresh). May have old data. |
| `error` | Something went wrong. |
| `success` | Data is ready. |
| `data` | The actual response. Can exist while `fetching` is true. |

```plaintext
                    ┌─────────────────────┐
                    │        idle         │
                    │   (not started)     │
                    └──────────┬──────────┘
                               │
                          start fetch
                               │
                               ▼
                    ┌─────────────────────┐
                    │      loading        │◀─────────────────────┐
                    │   (first fetch)     │                      │
                    └──────────┬──────────┘                      │
                               │                                 │
              ┌────────────────┴────────────────┐                │
              │                                 │                │
         success                             error               │
              │                                 │                │
              ▼                                 ▼                │
   ┌─────────────────────┐           ┌─────────────────────┐     │
   │      success        │           │       error         │     │
   │   (data ready)      │           │  (something wrong)  │     │
   └──────────┬──────────┘           └──────────┬──────────┘     │
              │                                 │                │
              │              retry              │                │
              │◀────────────────────────────────┘                │
              │                                                  │
         refetch                                                 │
              │                                                  │
              ▼                                                  │
   ┌─────────────────────┐                                       │
   │     fetching        │───────────────────────────────────────┘
   │ (has data + refresh)│         (on error, may retry)
   └─────────────────────┘
```

### Key Difference: Loading vs Fetching

| State | Has old data? | When? |
| --- | --- | --- |
| `loading` | No | First time fetching |
| `fetching` | Yes | Refreshing, revalidating |

This allows showing old data while fetching new data in background.

---

## Step 4: Module Hooks (Adapter Layer)

Located in `modules/[name]/hooks/`. This layer:

| Responsibility | Description |
| --- | --- |
| **Transform data** | Convert API response to internal types |
| **Handle differences** | API format ≠ internal format? Fix it here. |
| **Fail safe** | Missing data? Use defaults. Don't crash. |

### The Adapter Pattern

```plaintext
API returns:                    Your code expects:
{                               {
  first_name: "John",    ──▶      firstName: "John",
  is_active: 1                    isActive: true
}                               }
```

All transformation happens in module hooks. Components never see API format.

### Fail Safe Principle

When API returns unexpected data, don't crash. Use defaults.

| Situation | Fail safe approach |
| --- | --- |
| Field is missing | Use default value |
| Wrong type | Convert or use default |
| Null value | Use fallback |

---

## Step 5: Components

Components only use **internal types**. They don't know:

- What the API response looks like
- How data is transformed
- Where data comes from

This keeps components simple and stable.

---

## Caching Concepts

Most libraries handle caching for you. But you should understand these concepts:

### Core Terms

| Term | Meaning | Example |
| --- | --- | --- |
| **Cache** | Stored data for reuse | Don't fetch again when returning to page |
| **Fresh** | Data is new, trustworthy | Just fetched 1 second ago |
| **Stale** | Data is old, may be outdated | Fetched 5 minutes ago |
| **Stale time** | How long until data becomes stale | "Consider fresh for 30 seconds" |
| **Cache time** | How long to keep data in cache | "Keep for 10 minutes after last use" |
| **Invalidation** | Mark cache as invalid | After user updates profile |
| **Revalidation** | Fetch fresh data | Background refresh |

### Cache Lifecycle

```plaintext
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   Fetch data                                                                │
│       │                                                                     │
│       ▼                                                                     │
│   ┌───────────────────────────────────────┐                                 │
│   │             FRESH                     │                                 │
│   │   Data is new. Use it directly.       │                                 │
│   └───────────────────┬───────────────────┘                                 │
│                       │                                                     │
│               after stale time                                              │
│                       │                                                     │
│                       ▼                                                     │
│   ┌───────────────────────────────────────┐                                 │
│   │             STALE                     │                                 │
│   │   Data may be old.                    │                                 │
│   │   Show it, but revalidate.            │                                 │
│   └───────────────────┬───────────────────┘                                 │
│                       │                                                     │
│               after cache time                                              │
│               (no one using it)                                             │
│                       │                                                     │
│                       ▼                                                     │
│   ┌───────────────────────────────────────┐                                 │
│   │            DELETED                    │                                 │
│   │   Data removed from cache.            │                                 │
│   │   Next request = fresh fetch.         │                                 │
│   └───────────────────────────────────────┘                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### When to Invalidate Cache

| Event | Action |
| --- | --- |
| User updates data | Invalidate related cache |
| User logs out | Clear all user-related cache |
| Time-sensitive data | Set short stale time |

---

## Summary

| Step | Location | Responsibility |
| --- | --- | --- |
| 1 | Backend | Provide schema (required) |
| 2 | CI/CD | Generate types, detect breaking changes |
| 3 | `core/api` | API calls, states, caching |
| 4 | `modules/[name]/hooks` | Transform data (adapter), fail safe |
| 5 | Components | Use internal types only |
