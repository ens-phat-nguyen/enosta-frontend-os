# Apollo Client Implementation Guide

This guide shows how to apply [API Integration Guidelines](./README.md) using Apollo Client for GraphQL APIs.

---

## Quick Reference

### State Mapping

| Our Concept | Apollo Client API | Description |
| --- | --- | --- |
| `loading` | `loading` | First fetch, no data yet [[1]] |
| `fetching` | `networkStatus === 1, 2, 3, 4` | Any network activity [[2]] |
| `error` | `error` | Error object if request failed [[3]] |
| `success` | `!loading && !error` | Data is ready |
| `data` | `data` | The response data [[1]] |

### Network Status Values

| Value | Name | Description |
| --- | --- | --- |
| 1 | `loading` | Initial loading [[2]] |
| 2 | `setVariables` | Variables changed [[2]] |
| 3 | `fetchMore` | Fetching more data [[2]] |
| 4 | `refetch` | Refetching [[2]] |
| 6 | `poll` | Polling [[4]] |
| 7 | `ready` | Ready, no fetching [[2]] |
| 8 | `error` | Error occurred [[2]] |

### Cache Mapping

| Our Concept | Apollo Client | Description |
| --- | --- | --- |
| Cache | `InMemoryCache` | Normalized cache [[5]] |
| Stale time | `fetchPolicy` | Controls cache behavior [[6]] |
| Invalidation | `refetchQueries`, `cache.evict()` | Remove or refetch [[7]] |
| Revalidation | `refetch()` | Manual refetch [[8]] |

### Fetch Policies

| Policy | Description |
| --- | --- |
| `cache-first` | Use cache if available, else fetch (default) [[6]] |
| `cache-and-network` | Use cache immediately, then fetch [[6]] |
| `network-only` | Always fetch, update cache [[6]] |
| `cache-only` | Only use cache, never fetch [[6]] |
| `no-cache` | Always fetch, don't cache [[6]] |

---

## Setup in Core Layer

Location: `core/api/`

### Basic Setup

```typescript
// core/api/client.ts
import { ApolloClient, InMemoryCache, HttpLink } from '@apollo/client';

export const apolloClient = new ApolloClient({
  link: new HttpLink({
    uri: '/graphql',
  }),
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'cache-and-network',
    },
  },
});
```

> 📖 See: Get Started [9]

```typescript
// core/api/provider.tsx
import { ApolloProvider } from '@apollo/client';
import { apolloClient } from './client';

export function ApiProvider({ children }: PropsWithChildren) {
  return (
    <ApolloProvider client={apolloClient}>
      {children}
    </ApolloProvider>
  );
}
```

> 📖 See: ApolloProvider [10]

---

## Module Hooks (Adapter Layer)

Location: `modules/[name]/hooks/`

### Pattern: Custom Hook with Adapter

```typescript
// modules/user/hooks/use-user.ts
import { useQuery, gql } from '@apollo/client';

// GraphQL Query
const GET_USER = gql`
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      first_name
      last_name
      is_active
    }
  }
`;

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
  const { data, loading, error, networkStatus, refetch } = useQuery(GET_USER, {
    variables: { id: userId },
    notifyOnNetworkStatusChange: true, // Get updates for refetch
  });

  return {
    user: data?.user ? adaptUser(data.user) : undefined,
    isLoading: loading && !data,
    isFetching: networkStatus === 1 || networkStatus === 4,
    isRefetching: networkStatus === 4,
    isError: !!error,
    error,
    refetch,
  };
}
```

> 📖 See: useQuery Hook [11]

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
  const { data, loading, networkStatus } = useQuery(GET_USER, {
    variables: { id: userId },
    notifyOnNetworkStatusChange: true,
  });

  return {
    user: data?.user ? adaptUser(data.user) : undefined,

    // First load - show skeleton/spinner
    isLoading: loading && !data,

    // Any network activity
    isFetching: networkStatus < 7,

    // Background refresh - show subtle indicator
    isRefetching: networkStatus === 4,
  };
}
```

> 📖 See: Network Status [2]

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

### Refetch Queries After Mutation

```typescript
import { useMutation, gql } from '@apollo/client';

const UPDATE_USER = gql`
  mutation UpdateUser($id: ID!, $input: UserInput!) {
    updateUser(id: $id, input: $input) {
      id
      first_name
      last_name
    }
  }
`;

export function useUpdateUser() {
  const [updateUser, { loading, error }] = useMutation(UPDATE_USER, {
    refetchQueries: ['GetUser'], // Refetch after mutation
  });

  return {
    updateUser: (userId: string, updates: Partial<User>) =>
      updateUser({
        variables: {
          id: userId,
          input: {
            first_name: updates.firstName,
            last_name: updates.lastName,
          },
        },
      }),
    isLoading: loading,
    error,
  };
}
```

> 📖 See: Refetch After Mutation [12]

### Optimistic Update

```typescript
export function useUpdateUser() {
  const [updateUser] = useMutation(UPDATE_USER, {
    optimisticResponse: ({ id, input }) => ({
      __typename: 'Mutation',
      updateUser: {
        __typename: 'User',
        id,
        first_name: input.first_name,
        last_name: input.last_name,
      },
    }),
  });

  return { updateUser };
}
```

> 📖 See: Optimistic UI [13]

### Manual Cache Update

```typescript
import { useApolloClient } from '@apollo/client';

export function useUserActions() {
  const client = useApolloClient();

  const clearUserCache = (userId: string) => {
    client.cache.evict({ id: `User:${userId}` });
    client.cache.gc(); // Garbage collect
  };

  const clearAllCache = () => {
    client.clearStore();
  };

  return { clearUserCache, clearAllCache };
}
```

> 📖 See: Cache Eviction [14]

---

## Type Safety with GraphQL Codegen

For better type safety, use GraphQL Code Generator:

```typescript
// After running codegen, types are generated

import { useGetUserQuery } from '@/generated/graphql';

export function useUser(userId: string) {
  const { data, loading, error } = useGetUserQuery({
    variables: { id: userId },
  });

  return {
    // data.user is now fully typed
    user: data?.user ? adaptUser(data.user) : undefined,
    isLoading: loading,
    isError: !!error,
  };
}
```

> 📖 See: GraphQL Code Generator [15]

---

## Summary

| Layer | File | Responsibility |
| --- | --- | --- |
| Core | `core/api/client.ts` | ApolloClient config |
| Core | `core/api/provider.tsx` | ApolloProvider |
| Module | `modules/[name]/hooks/use-*.ts` | Custom hooks with adapters |
| Module | `modules/[name]/graphql/*.graphql` | GraphQL queries/mutations |

---

## References

- [1] useQuery Result: <https://www.apollographql.com/docs/react/data/queries#result>
- [2] Network Status: <https://www.apollographql.com/docs/react/data/queries#inspecting-loading-states>
- [3] Error Handling: <https://www.apollographql.com/docs/react/data/error-handling>
- [4] Polling: <https://www.apollographql.com/docs/react/data/queries#polling>
- [5] Caching Overview: <https://www.apollographql.com/docs/react/caching/overview>
- [6] Fetch Policies: <https://www.apollographql.com/docs/react/data/queries#setting-a-fetch-policy>
- [7] Refetching Overview: <https://www.apollographql.com/docs/react/data/refetching>
- [8] Refetch Function: <https://www.apollographql.com/docs/react/data/queries#refetching>
- [9] Get Started: <https://www.apollographql.com/docs/react/get-started>
- [10] ApolloProvider: <https://www.apollographql.com/docs/react/api/react/hooks#apolloprovider>
- [11] useQuery Hook: <https://www.apollographql.com/docs/react/api/react/hooks#usequery>
- [12] Refetch After Mutation: <https://www.apollographql.com/docs/react/data/mutations#refetching-queries>
- [13] Optimistic UI: <https://www.apollographql.com/docs/react/performance/optimistic-ui>
- [14] Cache Eviction: <https://www.apollographql.com/docs/react/caching/garbage-collection#cacheevict>
- [15] GraphQL Code Generator: <https://the-guild.dev/graphql/codegen/docs/guides/react-vue>

[1]: https://www.apollographql.com/docs/react/data/queries#result
[2]: https://www.apollographql.com/docs/react/data/queries#inspecting-loading-states
[3]: https://www.apollographql.com/docs/react/data/error-handling
[4]: https://www.apollographql.com/docs/react/data/queries#polling
[5]: https://www.apollographql.com/docs/react/caching/overview
[6]: https://www.apollographql.com/docs/react/data/queries#setting-a-fetch-policy
[7]: https://www.apollographql.com/docs/react/data/refetching
[8]: https://www.apollographql.com/docs/react/data/queries#refetching
[9]: https://www.apollographql.com/docs/react/get-started
[10]: https://www.apollographql.com/docs/react/api/react/hooks#apolloprovider
[11]: https://www.apollographql.com/docs/react/api/react/hooks#usequery
[12]: https://www.apollographql.com/docs/react/data/mutations#refetching-queries
[13]: https://www.apollographql.com/docs/react/performance/optimistic-ui
[14]: https://www.apollographql.com/docs/react/caching/garbage-collection#cacheevict
[15]: https://the-guild.dev/graphql/codegen/docs/guides/react-vue
