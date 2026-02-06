# Debugging & Developer Experience

> "Good debugging saves more time than good typing."

---

## Foundational Principles

Debugging is a core skill. Make it easier.

### 1. **KISS (Keep It Simple, Stupid)**

Use simple logging first. DevTools second. Debugger last.

### 2. **DRY (Don't Repeat Yourself)**

Extract logging and debugging helpers into utilities.

### 3. **Interface-First Thinking**

Design easy-to-debug code: pure functions, clear data flow, typed data.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Debugging** includes:

1. **Console Logging** — Simple, effective
2. **React DevTools** — Component inspection
3. **Network Tab** — API debugging
4. **Debugger** — Step-through debugging
5. **Error Monitoring** — Production errors (Sentry)
6. **Performance Profiling** — Find bottlenecks

Good debugging tools prevent bad code.

---

## Goals

1. **Fast Problem Identification** — Find issues quickly
2. **Reproducible Debugging** — Understand context
3. **Production Monitoring** — Know what breaks
4. **Performance Insight** — Find bottlenecks
5. **Developer Experience** — Make debugging smooth

---

## Table of Contents

- [Foundational Principles](#foundational-principles)
- [Console Logging](#console-logging)
- [React DevTools](#react-devtools)
- [Network Debugging](#network-debugging)
- [Debugger](#debugger)
- [Error Monitoring](#error-monitoring)
- [Performance Profiling](#performance-profiling)
- [Best Practices](#best-practices)

---

## Console Logging

### Strategic Logging Levels

```typescript
// 🟦 log: General information
console.log("User logged in", userId);

// 🟩 info: Important events
console.info("Payment processed", { amount, transactionId });

// 🟨 warn: Unexpected but recoverable
console.warn("API timeout, retrying...", apiUrl);

// 🔴 error: Errors that impact functionality
console.error("Payment failed", error);

// 🟪 debug: Detailed debugging info
console.debug("Apollo cache:", apolloCache);
```

### Reusable Logger Utility

```typescript
// ✅ Extract logging logic
const logger = {
  info: (message: string, data?: unknown) => {
    if (process.env.NODE_ENV === "development") {
      console.log(`[INFO] ${message}`, data);
    }
  },
  error: (message: string, error: Error) => {
    console.error(`[ERROR] ${message}`, error);
    // Send to Sentry in production
    if (process.env.NODE_ENV === "production") {
      Sentry.captureException(error);
    }
  },
  warn: (message: string, data?: unknown) => {
    console.warn(`[WARN] ${message}`, data);
  },
  debug: (message: string, data?: unknown) => {
    if (process.env.DEBUG === "true") {
      console.log(`[DEBUG] ${message}`, data);
    }
  },
};

// Usage
logger.info("Component mounted", { userId });
logger.error("Failed to fetch user", error);
```

### Structured Logging

```typescript
// ✅ Log with structured data
const logEvent = (event: string, properties: Record<string, unknown>) => {
  console.log(
    JSON.stringify({
      timestamp: new Date().toISOString(),
      event,
      properties,
      url: window.location.href,
    }),
  );
};

logEvent("user_signup", {
  userId: 123,
  method: "email",
  duration: 45,
});

// Easier to parse in logs and analytics
```

### Group Related Logs

```typescript
// ✅ Group related logs together
console.group("Form Submission");
console.log("Values:", formData);
console.log("Validation:", validationErrors);
console.log("Submit started at:", timestamp);
console.groupEnd();

// Output:
// Form Submission
//   Values: {...}
//   Validation: {...}
//   Submit started at: 2024-01-15T10:30:00Z
```

---

## React DevTools

### Component Inspection

```typescript
// ✅ React DevTools shows props and state
const UserProfile = ({ userId }: { userId: number }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  // React DevTools shows:
  // - userId prop
  // - user state
  // - loading state
  // - hooks
};

// Browser: Install "React Developer Tools" extension
// Right-click → Inspect → React tab
// Click component → see props, state, hooks
```

### Highlight Component Updates

```typescript
// Profiler tab → record → interact → see which components re-render
// Useful for finding unnecessary renders
```

### Trace Component Render

```typescript
// ✅ Trace why component rendered
const UserCard = memo(({ user }: { user: User }) => {
  console.trace('UserCard rendered because...'); // Shows call stack
  return <div>{user.name}</div>;
});

// Profiler tab shows render time and what caused it
```

---

## Network Debugging

### Monitor GraphQL Requests

```typescript
// Apollo DevTools shows all queries/mutations
// Network tab shows request/response payloads

// Browser: Install "Apollo Client DevTools" extension
// Browser → DevTools → Apollo tab
// See all GraphQL operations in real-time
```

### Intercept Requests

```typescript
// ✅ Log all network requests
const logNetworkActivity = (url: string, init?: RequestInit) => {
  const startTime = performance.now();

  return fetch(url, init)
    .then((response) => {
      const duration = performance.now() - startTime;
      logger.debug(`Fetch: ${url}`, {
        status: response.status,
        duration: `${duration.toFixed(2)}ms`,
      });
      return response;
    })
    .catch((error) => {
      logger.error(`Fetch failed: ${url}`, error);
      throw error;
    });
};

// Monkey-patch fetch during development
if (process.env.NODE_ENV === "development") {
  const originalFetch = window.fetch;
  window.fetch = (url, init) => logNetworkActivity(String(url), init);
}
```

### Check CORS Errors

```
Network tab → see failed requests → check CORS headers
Request headers: Origin, Authorization
Response headers: Access-Control-Allow-Origin, Access-Control-Allow-Headers

If CORS error: Backend needs to allow requests from your domain
```

---

## Debugger

### VS Code Debugging

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Chrome",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}/src",
      "sourceMapPathOverride": {
        "webpack:///./src/*": "${webspaceFolder}/src/*"
      }
    }
  ]
}
```

### Breakpoints

```typescript
// ✅ Set breakpoint: Click line number in VS Code
// When paused, use console to inspect variables
debugger; // OR add this to code (pauses when DevTools open)

const calculateTotal = (items: Item[]) => {
  debugger; // Pauses here when DevTools open
  return items.reduce((sum, item) => sum + item.price, 0);
};
```

### Step Through Code

```
F10 - Step over (next line)
F11 - Step into (enter function)
Shift+F11 - Step out (exit function)
F9 - Continue to next breakpoint
```

---

## Error Monitoring

### Sentry Integration

```typescript
import * as Sentry from "@sentry/react";

// Initialize in app
Sentry.init({
  dsn: process.env.REACT_APP_SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
  beforeSend(event, hint) {
    // Filter out errors
    if (event.exception) {
      const error = hint.originalException;
      if (error instanceof TypeError && error.message.includes("Network")) {
        return null; // Don't send network errors
      }
    }
    return event;
  },
});

// Wrap components
export default Sentry.withProfiler(App);

// Capture errors manually
try {
  riskyOperation();
} catch (error) {
  Sentry.captureException(error);
}
```

### Custom Error Tracking

```typescript
// ✅ Track errors in production
const trackError = (error: Error, context: Record<string, unknown>) => {
  logger.error(error.message, error);

  if (process.env.NODE_ENV === "production") {
    Sentry.captureException(error, {
      contexts: {
        app: context,
      },
    });
  }
};

// Usage
try {
  await mutateUser({ id, name });
} catch (error) {
  trackError(error as Error, {
    userId: user.id,
    action: "update_user",
    timestamp: new Date(),
  });
}
```

---

## Performance Profiling

### React Profiler API

```typescript
import { Profiler, ProfilerOnRenderCallback } from 'react';

const onRenderCallback: ProfilerOnRenderCallback = (
  id,
  phase,
  actualDuration,
  baseDuration,
  startTime,
  commitTime
) => {
  console.log(`${id} (${phase}) took ${actualDuration}ms`);
};

<Profiler id="UserCard" onRender={onRenderCallback}>
  <UserCard />
</Profiler>
```

### Measure Component Performance

```typescript
// ✅ Custom hook to measure render time
const useMeasureRender = (componentName: string) => {
  useEffect(() => {
    const startTime = performance.now();
    return () => {
      const duration = performance.now() - startTime;
      console.log(`${componentName} rendered in ${duration.toFixed(2)}ms`);
    };
  }, [componentName]);
};

const SlowComponent = () => {
  useMeasureRender('SlowComponent');
  return <div>{/* ... */}</div>;
};
```

### Use Chrome DevTools Profiler

```
1. Open DevTools → Performance tab
2. Click Record
3. Interact with app
4. Stop Recording
5. Analyze flame chart → Find slow functions
```

---

## Best Practices

1. **Log Strategically** — Not every line, key events only
2. **Use Log Levels** — info, warn, error serve purposes
3. **Structured Data** — Log objects with context
4. **React DevTools** — First stop for component debugging
5. **Network Tab** — Check API requests/responses
6. **Debugger First** — Better than logging for complex issues
7. **Error Monitoring** — Never miss production errors
8. **Performance Profiling** — Measure, don't guess
9. **Source Maps** — Enable in production (with Sentry)
10. **Clean Logs** — Remove debug logs before committing

---

## Debugging Checklist

- [ ] Console errors empty
- [ ] Network requests successful
- [ ] React DevTools shows correct props
- [ ] No yellow/red warnings
- [ ] Sentry integrated in production
- [ ] Error boundaries in place
- [ ] Source maps enabled
- [ ] Profiler data analyzed
