# Error Handling & Error Boundaries

> "Every error you don't handle gracefully is a bad user experience waiting to happen."

---

## Foundational Principles

Before implementing error handling, understand these principles:

### 1. **Interface-First Thinking**

Design error states as first-class UI concerns. How should users recover from errors?

### 2. **KISS (Keep It Simple, Stupid)**

Handle errors at the appropriate level. Don't let errors bubble up silently.

### 3. **DRY (Don't Repeat Yourself)**

Create reusable error handling patterns and boundary components.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Error Handling** encompasses three areas:

1. **React Error Boundaries** — Catch rendering errors in component trees
2. **Async Error Handling** — Handle promise rejections, network errors, API failures
3. **User Communication** — Show meaningful error messages, enable recovery

Bad error handling leads to:

- Blank screens (user doesn't know what happened)
- Lost work (form data disappears)
- Silent failures (error logged but user unaware)
- Frustration (no way to recover)

---

## Goals

1. **Prevent White Screens** — Always show something meaningful
2. **Enable Recovery** — Let users retry or take alternative action
3. **Provide Context** — Show what went wrong and why
4. **Log Appropriately** — Send errors to monitoring (Sentry, etc.)
5. **Consistent UX** — Predictable error handling across app

---

## Table of Contents

- [Foundational Principles](#foundational-principles)
- [Key Concepts](#key-concepts)
- [Error Boundaries](#error-boundaries)
- [Async Error Handling](#async-error-handling)
- [User Communication](#user-communication)
- [Error Monitoring](#error-monitoring)
- [Best Practices](#best-practices)

---

## Key Concepts

### Three Types of Errors

| Type              | Cause                               | Solution                          |
| ----------------- | ----------------------------------- | --------------------------------- |
| **Render Errors** | Component logic fails               | Error Boundary catches it         |
| **Async Errors**  | API calls fail, promises reject     | Try-catch, .catch(), error states |
| **User Errors**   | Invalid form input, network timeout | User feedback, retry logic        |

---

## Error Boundaries

### Class Component Pattern

```typescript
import React, { ReactNode } from 'react';
import * as Sentry from '@sentry/react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

class ErrorBoundary extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // Log to monitoring service
    Sentry.captureException(error, { contexts: { react: errorInfo } });
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div style={{ padding: '20px', textAlign: 'center' }}>
            <h2>Oops! Something went wrong</h2>
            <p>{this.state.error?.message}</p>
            <button onClick={() => window.location.reload()}>
              Reload Page
            </button>
          </div>
        )
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
```

### Where to Place Error Boundaries

```typescript
// At app level (catch global errors)
<ErrorBoundary>
  <App />
</ErrorBoundary>

// At route level (isolate errors per page)
<ErrorBoundary>
  <UserDashboard />
</ErrorBoundary>

// At feature level (prevent cascading failures)
<ErrorBoundary fallback={<UserListFallback />}>
  <UserList />
</ErrorBoundary>
```

---

## Async Error Handling

### API Call Pattern

```typescript
import { useState } from 'react';

interface State {
  data: User | null;
  error: Error | null;
  loading: boolean;
}

function UserProfile({ id }: { id: string }) {
  const [state, setState] = useState<State>({
    data: null,
    error: null,
    loading: false
  });

  const fetchUser = async () => {
    setState({ data: null, error: null, loading: true });

    try {
      const response = await fetch(`/api/users/${id}`);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const user = await response.json();
      setState({ data: user, error: null, loading: false });
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Unknown error');
      setState({ data: null, error, loading: false });

      // Log to monitoring
      console.error('Failed to fetch user:', error);
    }
  };

  if (state.loading) return <div>Loading...</div>;
  if (state.error) {
    return (
      <div>
        <p>Error: {state.error.message}</p>
        <button onClick={fetchUser}>Retry</button>
      </div>
    );
  }
  if (!state.data) return <div>No data</div>;

  return <div>{state.data.name}</div>;
}
```

### With Apollo Client

```typescript
function UserProfile({ id }: { id: string }) {
  const { data, loading, error, refetch } = useQuery(GET_USER, {
    variables: { id },
    errorPolicy: 'all' // Don't throw, return errors in 'error' field
  });

  if (loading) return <div>Loading...</div>;

  if (error) {
    return (
      <div>
        <p>Error: {error.message}</p>
        <button onClick={() => refetch()}>Retry</button>
      </div>
    );
  }

  return <div>{data?.user?.name}</div>;
}
```

---

## User Communication

### Error Message Guidelines

✅ **Good:**

- "Network connection failed. Check your internet and try again."
- "Email already in use. Try logging in instead."
- "Session expired. Please log in again."

❌ **Bad:**

- "Error: 500"
- "ECONNREFUSED"
- (blank error screen)

### Toast Notifications for Errors

```typescript
import { toast } from 'sonner'; // or your toast library

function UpdateUserForm({ id }: { id: string }) {
  const [updateUser, { loading }] = useMutation(UPDATE_USER_MUTATION, {
    onError: (error) => {
      toast.error(`Failed to update: ${error.message}`);
    },
    onSuccess: () => {
      toast.success('Profile updated successfully');
    }
  });

  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      updateUser({ variables: { id, ... } });
    }}>
      {/* form fields */}
    </form>
  );
}
```

---

## Error Monitoring

### Setup Sentry

```typescript
// pages/_app.tsx or app.tsx
import * as Sentry from '@sentry/react';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
});

export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}

export const getServerSideProps = Sentry.getServerSideProps();
```

### Capture Custom Errors

```typescript
import * as Sentry from "@sentry/react";

try {
  riskyOperation();
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      feature: "checkout",
      user_action: "payment",
    },
    extra: {
      amount: 99.99,
      currency: "USD",
    },
  });
}
```

---

## Best Practices

1. **Error Boundaries at Multiple Levels** — App level, route level, feature level
2. **Always Handle Async Errors** — Never let promises hang silently
3. **User-Friendly Messages** — Avoid technical jargon in UI
4. **Recovery Paths** — Always provide a way to retry or recover
5. **Log with Context** — Include user info, feature context, action taken
6. **Monitor in Production** — Use Sentry or similar service
7. **Test Error States** — Mock API failures and test error UI
8. **No Error Swallowing** — Don't silently fail; always inform the user
