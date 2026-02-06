# SWR Implementation Guide

This guide shows how to apply [API Integration Guidelines](./README.md) using SWR.

---

## Quick Reference

### State Mapping

| Our Concept | SWR API | Description |
| --- | --- | --- |
| `loading` | `isLoading` | First fetch, no data yet [[1]] |
| `fetching` | `isValidating` | Any fetch in progress (includes background refresh) [[1]] |
| `error` | `error` | Error object if request failed [[2]] |
| `success` | `!isLoading && !error` | Data is ready |
| `data` | `data` | The response data [[1]] |

### Cache Mapping

| Our Concept | SWR Option | Description |
| --- | --- | --- |
| Stale time | `dedupingInterval` | Time to dedupe requests (default: 2s) [[3]] |
| Cache time | `provider` | Custom cache provider [[4]] |
| Revalidation | `revalidateOnFocus`, `revalidateOnReconnect` | When to refetch [[5]] |
| Invalidation | `mutate()` | Manually update or refetch [[6]] |

---

## Setup in Core Layer

Location: `core/api/`

### Basic Setup

```typescript
// core/api/fetcher.ts
export const fetcher = async (url: string) => {
  const response = await fetch(url);

  if (!response.ok) {
    throw new Error('Request failed');
  }

  return response.json();
};
```

```typescript
// core/api/provider.tsx
import { SWRConfig } from 'swr';
import { fetcher } from './fetcher';

export function ApiProvider({ children }: { children: React.ReactNode }) {
  return (
    <SWRConfig
      value={{
        fetcher,
        revalidateOnFocus: false,
        dedupingInterval: 2000,
      }}
    >
      {children}
    </SWRConfig>
  );
}
```

> 📖 See: Global Configuration [7]

---

## Module Hooks (Adapter Layer)

Location: `modules/[name]/hooks/`

### Pattern: Custom Hook with Adapter

```typescript
// modules/user/hooks/use-user.ts
import useSWR from 'swr';

// Internal type (what your components use)
type User = {
  id: string;
  firstName: string;
  lastName: string;
  isActive: boolean;
}

// Adapter: transform API response to internal type
function adaptUser(apiResponse: any): User {
  return {
    id: apiResponse.id,
    firstName: apiResponse.first_name ?? 'Unknown',
    lastName: apiResponse.last_name ?? '',
    isActive: Boolean(apiResponse.is_active),
  };
}

// Custom hook
export function useUser(userId: string) {
  const { data, error, isLoading, isValidating } = useSWR(
    `/api/users/${userId}`
  );

  return {
    user: data ? adaptUser(data) : undefined,
    isLoading,
    isFetching: isValidating,
    isError: !!error,
    error,
  };
}
```

> 📖 See: Getting Started [8]

### Fail Safe in Adapter

```typescript
function adaptUser(apiResponse: any): User {
  return {
    // Required field with fallback
    id: apiResponse.id ?? '',

    // String fields with defaults
    firstName: apiResponse.first_name ?? 'Unknown',
    lastName: apiResponse.last_name ?? '',

    // Boolean conversion (API might return 0/1)
    isActive: Boolean(apiResponse.is_active),

    // Nested object with fallback
    address: apiResponse.address ?? null,

    // Array with fallback
    roles: Array.isArray(apiResponse.roles) ? apiResponse.roles : [],
  };
}
```

---

## State Handling

### Loading vs Fetching

```typescript
export function useUser(userId: string) {
  const { data, isLoading, isValidating } = useSWR(`/api/users/${userId}`);

  return {
    user: data ? adaptUser(data) : undefined,

    // First load - show skeleton/spinner
    isLoading,

    // Background refresh - show subtle indicator
    isFetching: isValidating,

    // Has data and refreshing
    isRefreshing: !isLoading && isValidating,
  };
}
```

> 📖 See: Understanding SWR [9]

### Usage in Component

```tsx
function UserProfile({ userId }: { userId: string }) {
  const { user, isLoading, isFetching, isError } = useUser(userId);

  if (isLoading) {
    return <Skeleton />;
  }

  if (isError) {
    return <ErrorMessage />;
  }

  return (
    <div>
      {isFetching && <RefreshIndicator />}
      <h1>{user.firstName} {user.lastName}</h1>
    </div>
  );
}
```

---

## Cache Operations

### Manual Revalidation

```typescript
import { useSWRConfig } from 'swr';

export function useUserActions() {
  const { mutate } = useSWRConfig();

  const refreshUser = (userId: string) => {
    // Revalidate specific key
    mutate(`/api/users/${userId}`);
  };

  const refreshAllUsers = () => {
    // Revalidate all keys matching pattern
    mutate((key) => typeof key === 'string' && key.startsWith('/api/users'));
  };

  return { refreshUser, refreshAllUsers };
}
```

> 📖 See: Mutation [6]

### Optimistic Update

```typescript
export function useUpdateUser() {
  const { mutate } = useSWRConfig();

  const updateUser = async (userId: string, updates: Partial<User>) => {
    // Optimistic update
    mutate(
      `/api/users/${userId}`,
      async (currentData: any) => {
        // Call API
        const response = await fetch(`/api/users/${userId}`, {
          method: 'PATCH',
          body: JSON.stringify(updates),
        });
        return response.json();
      },
      {
        optimisticData: (currentData: any) => ({
          ...currentData,
          ...updates,
        }),
        rollbackOnError: true,
      }
    );
  };

  return { updateUser };
}
```

> 📖 See: Optimistic Updates [10]

---

## Summary

| Layer | File | Responsibility |
| --- | --- | --- |
| Core | `core/api/fetcher.ts` | Base fetch function |
| Core | `core/api/provider.tsx` | SWR global config |
| Module | `modules/[name]/hooks/use-*.ts` | Custom hooks with adapters |

---

## References

- [1] API Return Values: <https://swr.vercel.app/docs/api#return-values>
- [2] Error Handling: <https://swr.vercel.app/docs/error-handling>
- [3] API Options: <https://swr.vercel.app/docs/api#options>
- [4] Cache Provider: <https://swr.vercel.app/docs/advanced/cache>
- [5] Revalidation: <https://swr.vercel.app/docs/revalidation>
- [6] Mutation: <https://swr.vercel.app/docs/mutation>
- [7] Global Configuration: <https://swr.vercel.app/docs/global-configuration>
- [8] Getting Started: <https://swr.vercel.app/docs/getting-started>
- [9] Understanding SWR: <https://swr.vercel.app/docs/advanced/understanding>
- [10] Optimistic Updates: <https://swr.vercel.app/docs/mutation#optimistic-updates>

[1]: https://swr.vercel.app/docs/api#return-values
[2]: https://swr.vercel.app/docs/error-handling
[3]: https://swr.vercel.app/docs/api#options
[4]: https://swr.vercel.app/docs/advanced/cache
[5]: https://swr.vercel.app/docs/revalidation
[6]: https://swr.vercel.app/docs/mutation
[7]: https://swr.vercel.app/docs/global-configuration
[8]: https://swr.vercel.app/docs/getting-started
[9]: https://swr.vercel.app/docs/advanced/understanding
[10]: https://swr.vercel.app/docs/mutation#optimistic-updates
