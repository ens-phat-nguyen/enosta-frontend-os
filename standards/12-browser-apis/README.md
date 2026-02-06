# Browser APIs & Local Storage

> "The browser has powerful APIs. Know when to use them."

---

## Foundational Principles

Storage and browser APIs need careful thought:

### 1. **Interface-First Thinking**

Decide what data needs persistence before choosing storage. How much data? How sensitive? How long?

### 2. **KISS (Keep It Simple, Stupid)**

Use `localStorage` for simple data. Use IndexedDB for complex data. Don't over-engineer.

### 3. **DRY (Don't Repeat Yourself)**

Extract storage helpers into reusable hooks.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Browser Storage & APIs** includes:

1. **localStorage** — Simple key-value, persists forever
2. **sessionStorage** — Key-value, cleared on tab close
3. **IndexedDB** — Large database in browser
4. **Web Workers** — Background computation
5. **Service Workers** — Offline caching

Choose the right tool for the problem.

---

## Goals

1. **Choose Correctly** — Match storage to use case
2. **Persist Data** — Users don't lose state
3. **Sync Across Tabs** — Handle storage events
4. **Handle Errors** — Storage quota exceeded
5. **Performance** — Avoid blocking operations

---

## Table of Contents

- [Foundational Principles](#foundational-principles)
- [Storage Decision Tree](#storage-decision-tree)
- [localStorage](#localstorage)
- [sessionStorage](#sessionstorage)
- [IndexedDB](#indexeddb)
- [Web Workers](#web-workers)
- [Best Practices](#best-practices)

---

## Storage Decision Tree

```
Do you need to store data?
├─ No → Don't store anything
├─ Yes, but only for this session
│  └─ sessionStorage (browser closes = cleared)
├─ Yes, persist long-term
│  ├─ Small data (< 5MB)?
│  │  └─ localStorage (simple, synchronous)
│  └─ Large data (> 5MB) or complex queries?
│     └─ IndexedDB (database, async)
└─ Sensitive data?
   └─ ❌ Don't store in browser (use secure HttpOnly cookies)
```

---

## localStorage

### Simple Key-Value Storage

```typescript
// ✅ Store simple data
localStorage.setItem("theme", "dark");
localStorage.setItem("user", JSON.stringify({ id: 1, name: "John" }));

// ✅ Retrieve
const theme = localStorage.getItem("theme");
const user = JSON.parse(localStorage.getItem("user") || "{}");

// ✅ Remove
localStorage.removeItem("theme");
localStorage.clear(); // Remove all
```

### Reusable Hook

```typescript
// ✅ Extract into custom hook
const useLocalStorage = <T>(key: string, initialValue: T) => {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(error);
      return initialValue;
    }
  });

  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore =
        value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  };

  return [storedValue, setValue] as const;
};

// Usage
const [theme, setTheme] = useLocalStorage("theme", "light");
```

### Listen for Changes (Across Tabs)

```typescript
// ✅ User changes theme in another tab
const useLocalStorageSync = <T>(key: string) => {
  const [value, setValue] = useState<T | null>(null);

  useEffect(() => {
    const handleStorageChange = (e: StorageEvent) => {
      if (e.key === key) {
        setValue(e.newValue ? JSON.parse(e.newValue) : null);
      }
    };

    window.addEventListener("storage", handleStorageChange);
    return () => window.removeEventListener("storage", handleStorageChange);
  }, [key]);

  return value;
};
```

### Limitations

```typescript
// ❌ localStorage only stores strings
localStorage.setItem("number", 123); // Stored as "123"
localStorage.setItem("date", new Date()); // Stored as "[object Object]"

// ✅ Stringify before storing
localStorage.setItem("date", JSON.stringify(new Date()));
```

---

## sessionStorage

### When to Use

```typescript
// ✅ sessionStorage: Data only needed this session
sessionStorage.setItem("searchQuery", "react hooks");
sessionStorage.setItem("scrollPosition", "500");

// Cleared when browser tab closes
// Not shared across tabs
```

### Practical Example

```typescript
// ✅ Save form draft for current session
const useDraftForm = (formId: string) => {
  const [values, setValues] = useState(() => {
    const draft = sessionStorage.getItem(`draft_${formId}`);
    return draft ? JSON.parse(draft) : {};
  });

  const saveDraft = (data: unknown) => {
    setValues(data);
    sessionStorage.setItem(`draft_${formId}`, JSON.stringify(data));
  };

  return { values, saveDraft };
};
```

---

## IndexedDB

### Why IndexedDB?

- localStorage is synchronous (can block)
- localStorage limited to ~5-10MB
- IndexedDB is async (non-blocking)
- IndexedDB supports queries, indexes
- IndexedDB has no size limit (usually 50MB+)

### Using Dexie (Recommended)

```typescript
import Dexie, { Table } from "dexie";

interface Todo {
  id?: number;
  title: string;
  completed: boolean;
  createdAt: Date;
}

class TodoDB extends Dexie {
  todos!: Table<Todo>;

  constructor() {
    super("TodoDB");
    this.version(1).stores({
      todos: "++id, createdAt", // ++ = auto-increment, index on createdAt
    });
  }
}

const db = new TodoDB();

// Add
await db.todos.add({
  title: "Learn Dexie",
  completed: false,
  createdAt: new Date(),
});

// Query
const completed = await db.todos.where("completed").equals(true).toArray();

// Update
await db.todos.update(1, { completed: true });

// Delete
await db.todos.delete(1);

// Clear all
await db.todos.clear();
```

### React Hook with Dexie

```typescript
const useTodos = () => {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadTodos = async () => {
      const data = await db.todos.toArray();
      setTodos(data);
      setLoading(false);
    };

    loadTodos();

    // Listen for changes
    const subscription = liveQuery(() => db.todos.toArray()).subscribe((data) =>
      setTodos(data || []),
    );

    return () => subscription.unsubscribe();
  }, []);

  return { todos, loading };
};
```

---

## Web Workers

### When to Use Web Workers

```typescript
// ✅ Web Workers for heavy computation
// Main thread sends data → Worker processes → Worker returns result
// Main thread never blocks

// Without Worker: Blocks UI while processing
const processLargeData = (data: number[]) => {
  let sum = 0;
  for (let i = 0; i < data.length; i++) {
    sum += Math.sqrt(data[i]); // Expensive computation
  }
  return sum;
};

// With Worker: Runs in background
const worker = new Worker("worker.js");
worker.postMessage(largeDataArray);
worker.onmessage = (e) => {
  console.log("Result:", e.data);
};
```

### Worker Code

```typescript
// worker.ts
self.onmessage = (event: MessageEvent<number[]>) => {
  const data = event.data;
  let sum = 0;
  for (let i = 0; i < data.length; i++) {
    sum += Math.sqrt(data[i]);
  }
  self.postMessage(sum);
};
```

### Using Worker in React

```typescript
const useWorker = (computation: (data: unknown) => unknown) => {
  const [result, setResult] = useState(null);
  const workerRef = useRef<Worker | null>(null);

  useEffect(() => {
    // Create worker from function
    const blob = new Blob(
      [`self.onmessage = (e) => self.postMessage((${computation})(e.data))`],
      { type: "application/javascript" },
    );
    workerRef.current = new Worker(URL.createObjectURL(blob));

    return () => {
      workerRef.current?.terminate();
    };
  }, [computation]);

  const process = (data: unknown) => {
    workerRef.current?.postMessage(data);
  };

  useEffect(() => {
    if (!workerRef.current) return;

    workerRef.current.onmessage = (e) => {
      setResult(e.data);
    };
  }, []);

  return [result, process] as const;
};
```

---

## Best Practices

1. **Choose Correct Storage** — localStorage for small, sessionStorage for temporary, IndexedDB for large
2. **Async for Large Data** — Use IndexedDB, not localStorage for big datasets
3. **Handle Quota Exceeded** — Gracefully degrade when storage full
4. **Encrypt Sensitive Data** — Never store passwords, API keys in browser
5. **Version Your Storage** — Plan for data migration
6. **Listen to Storage Events** — Sync across browser tabs
7. **Use Web Workers** — Prevent blocking main thread
8. **Dexie for IndexedDB** — Much better API than raw IndexedDB
9. **Test Storage Availability** — Not all browsers/modes support storage
10. **Clear Old Data** — Periodically clean up stale data

---

## Storage Limits

| Storage        | Limit   | Persistent | Sync      |
| -------------- | ------- | ---------- | --------- |
| localStorage   | 5-10 MB | Yes        | Manual    |
| sessionStorage | 5-10 MB | No         | Manual    |
| IndexedDB      | 50+ MB  | Yes        | Automatic |
| Cookies        | 4 KB    | Yes        | Automatic |
