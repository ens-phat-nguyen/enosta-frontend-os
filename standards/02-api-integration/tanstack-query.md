# TanStack Query Implementation Guide

This guide shows how to apply [API Integration Guidelines](./README.md) using TanStack Query (v5).

> **Version Note:** This guide is for TanStack Query v5. Key changes from v4: [1]
>
> - `isLoading` renamed to `isPending`
> - `isInitialLoading` renamed to `isLoading`
> - `cacheTime` renamed to `gcTime`
> - `onSuccess`, `onError`, `onSettled` callbacks removed from `useQuery`
> - Single object signature for all hooks (no more multiple overloads)

---

## Quick Reference

### State Mapping

| Our Concept | TanStack Query API | Description |
| --- | --- | --- |
| `loading` | `isLoading` | First fetch, no data yet (`isPending && isFetching`) [[2]] |
| `fetching` | `isFetching` | Any fetch in progress [[3]] |
| `error` | `isError`, `error` | Error state and object [[2]] |
| `success` | `isSuccess` | Data is ready [[2]] |
| `data` | `data` | The response data [[3]] |

### Additional States (v5)

| State | Description |
| --- | --- |
| `isPending` | No data yet (no cache). Different from `isLoading`. [[4]] |
| `isLoading` | `isPending && isFetching` - First fetch in progress [[4]] |
| `isFetching` | Any fetch (initial or background) [[5]] |
| `isRefetching` | Background refetch (`isFetching && !isPending`) [[5]] |

### Cache Mapping

| Our Concept | TanStack Query Option | Description |
| --- | --- | --- |
| Stale time | `staleTime` | How long data stays fresh (default: 0) [[6]] |
| Cache time | `gcTime` | How long unused data stays in cache (default: 5min) [[7]] |
| Revalidation | `refetchOnWindowFocus`, `refetchOnReconnect` | When to refetch [[6]] |
| Invalidation | `queryClient.invalidateQueries()` | Mark cache as stale [[8]] |

---

## Setup in Core Layer

Location: `core/api/`

### Basic Setup

```typescript
// core/api/client.ts
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60, // 1 minute
      gcTime: 1000 * 60 * 5, // 5 minutes
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});
```

> 📖 See: QueryClient Reference [9]

```typescript
// core/api/provider.tsx
import { QueryClientProvider } from '@tanstack/react-query';
import { queryClient } from './client';

export function ApiProvider({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}
```

> 📖 See: Quick Start [10]

---

## Module Hooks (Adapter Layer)

Location: `modules/[name]/hooks/`

### Pattern: Custom Hook with Adapter

```typescript
// modules/user/hooks/use-user.ts

import { get } from 'lodash-es';  // Use `get` for safe access

import { useQuery } from '@tanstack/react-query';
import { fetcher } from '@/core/api';

// Internal type (what your components use)
type User = {
  id: string;
  firstName: string;
  lastName: string;
  isActive: boolean;
}

// Adapter: transform API response to internal type
function adaptUser(apiResponse: unknown): User {
  return {
    id: get(apiResponse, 'id', ''),
    firstName: get(apiResponse, 'first_name', 'Unknown'),
    lastName: get(apiResponse, 'last_name', ''),
    isActive: Boolean(get(apiResponse, 'is_active', false)),
  };
}

// Custom hook
export function useUser(userId: string) {
  const { data, error, isPending, isFetching, isError, isSuccess } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetcher(`/api/users/${userId}`),
    select: adaptUser, // Transform data here
  });

  return {
    user: data,
    isLoading: isPending && isFetching,
    isFetching,
    isError,
    isSuccess,
    error,
  };
}
```

> 📖 See: useQuery Reference [3]

### Using `select` for Transformation

TanStack Query has built-in `select` option for data transformation:

```typescript
import { get } from 'lodash-es';  // Use `get` for safe access

export function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetcher(`/api/users/${userId}`),
    select: (apiResponse) => ({
      id: get(apiResponse, 'id', ''),
      firstName: get(apiResponse, 'first_name', 'Unknown'),
      lastName: get(apiResponse, 'last_name', ''),
      isActive: Boolean(get(apiResponse, 'is_active', false)),
    }),
  });
}
```

> 📖 See: useQuery Reference [3]

### Fail Safe in Adapter

```typescript
function adaptUser(apiResponse: unknown): User {
  return {
    // Required field with fallback
    id: get(apiResponse, 'id', ''),

    // String fields with defaults
    firstName: get(apiResponse, 'first_name', 'Unknown'),
    lastName: get(apiResponse, 'last_name', ''),

    // Boolean conversion (API might return 0/1)
    isActive: Boolean(get(apiResponse, 'is_active', false)),

    // Nested object with fallback
    address: get(apiResponse, 'address', null),

    // Array with fallback
    roles: get(apiResponse, 'roles', []),
  };
}
```

---

## State Handling

### Understanding isPending vs isLoading vs isFetching

```plaintext
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   isPending    = No data in cache                               │
│   isFetching   = Request in flight                              │
│   isLoading    = isPending && isFetching (first load)           │
│   isRefetching = !isPending && isFetching (background refresh)  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

> 📖 See: Fetch Status [4]

```typescript
export function useUser(userId: string) {
  const query = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetcher(`/api/users/${userId}`),
    select: adaptUser,
  });

  return {
    user: query.data,

    // First load - show skeleton/spinner
    isLoading: query.isLoading,

    // Background refresh - show subtle indicator
    isRefetching: query.isFetching && !query.isPending,

    // Any fetch in progress
    isFetching: query.isFetching,

    isError: query.isError,
    error: query.error,
  };
}
```

### Usage in Component

```tsx
function UserProfile({ userId }: { userId: string }) {
  const { user, isLoading, isRefetching, isError } = useUser(userId);

  if (isLoading) {
    return <Skeleton />;
  }

  if (isError) {
    return <ErrorMessage />;
  }

  return (
    <div>
      {isRefetching && <RefreshIndicator />}
      <h1>{user.firstName} {user.lastName}</h1>
    </div>
  );
}
```

---

## Cache Operations

### Invalidation

```typescript
import { useQueryClient } from '@tanstack/react-query';

export function useUserActions() {
  const queryClient = useQueryClient();

  const refreshUser = (userId: string) => {
    // Invalidate specific query
    queryClient.invalidateQueries({ queryKey: ['user', userId] });
  };

  const refreshAllUsers = () => {
    // Invalidate all queries starting with 'user'
    queryClient.invalidateQueries({ queryKey: ['user'] });
  };

  return { refreshUser, refreshAllUsers };
}
```

> 📖 See: Query Invalidation [8]

### Optimistic Update with Mutation

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query';

export function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ userId, updates }: { userId: string; updates: Partial<User> }) =>
      fetch(`/api/users/${userId}`, {
        method: 'PATCH',
        body: JSON.stringify(updates),
      }).then((res) => res.json()),

    onMutate: async ({ userId, updates }) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['user', userId] });

      // Snapshot previous value
      const previousUser = queryClient.getQueryData(['user', userId]);

      // Optimistic update
      queryClient.setQueryData(['user', userId], (old: any) => ({
        ...old,
        ...updates,
      }));

      return { previousUser };
    },

    onError: (err, { userId }, context) => {
      // Rollback on error
      queryClient.setQueryData(['user', userId], context?.previousUser);
    },

    onSettled: (data, error, { userId }) => {
      // Refetch after mutation
      queryClient.invalidateQueries({ queryKey: ['user', userId] });
    },
  });
}
```

> 📖 See: Optimistic Updates [11]

---

## Summary

| Layer | File | Responsibility |
| --- | --- | --- |
| Core | `core/api/client.ts` | QueryClient config |
| Core | `core/api/fetcher.ts` | Base fetch function |
| Core | `core/api/provider.tsx` | QueryClientProvider |
| Module | `modules/[name]/hooks/use-*.ts` | Custom hooks with adapters |

---

## References

- [1] Migration Guide (v4 → v5): <https://tanstack.com/query/latest/docs/framework/react/guides/migrating-to-v5>
- [2] Query Basics: <https://tanstack.com/query/latest/docs/framework/react/guides/queries#query-basics>
- [3] useQuery Reference: <https://tanstack.com/query/latest/docs/framework/react/reference/useQuery>
- [4] Fetch Status: <https://tanstack.com/query/latest/docs/framework/react/guides/queries#fetchstatus>
- [5] Background Fetching: <https://tanstack.com/query/latest/docs/framework/react/guides/background-fetching-indicators>
- [6] Important Defaults: <https://tanstack.com/query/latest/docs/framework/react/guides/important-defaults>
- [7] Caching: <https://tanstack.com/query/latest/docs/framework/react/guides/caching>
- [8] Query Invalidation: <https://tanstack.com/query/latest/docs/framework/react/guides/query-invalidation>
- [9] QueryClient: <https://tanstack.com/query/latest/docs/reference/QueryClient>
- [10] Quick Start: <https://tanstack.com/query/latest/docs/framework/react/quick-start>
- [11] Optimistic Updates: <https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates>
- [12] useMutation Reference: <https://tanstack.com/query/latest/docs/framework/react/reference/useMutation>

[1]: https://tanstack.com/query/latest/docs/framework/react/guides/migrating-to-v5
[2]: https://tanstack.com/query/latest/docs/framework/react/guides/queries#query-basics
[3]: https://tanstack.com/query/latest/docs/framework/react/reference/useQuery
[4]: https://tanstack.com/query/latest/docs/framework/react/guides/queries#fetchstatus
[5]: https://tanstack.com/query/latest/docs/framework/react/guides/background-fetching-indicators
[6]: https://tanstack.com/query/latest/docs/framework/react/guides/important-defaults
[7]: https://tanstack.com/query/latest/docs/framework/react/guides/caching
[8]: https://tanstack.com/query/latest/docs/framework/react/guides/query-invalidation
[9]: https://tanstack.com/query/latest/docs/reference/QueryClient
[10]: https://tanstack.com/query/latest/docs/framework/react/quick-start
[11]: https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates
[12]: https://tanstack.com/query/latest/docs/framework/react/reference/useMutation
