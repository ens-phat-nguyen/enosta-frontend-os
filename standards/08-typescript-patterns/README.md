# TypeScript Patterns

> "TypeScript catches bugs before your users do. Use it properly."

---

## Foundational Principles

Before diving into advanced TS, understand these principles:

### 1. **Interface-First Thinking**

Define types first, let implementation follow. Strong contracts prevent surprises.

### 2. **KISS (Keep It Simple, Stupid)**

Use simple types. Avoid over-complex generics that nobody understands.

### 3. **DRY (Don't Repeat Yourself)**

Extract type patterns into reusable utilities and helpers.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**TypeScript Patterns** are proven approaches for common typing problems. They prevent `any` types, improve IDE support, and catch bugs early.

Key areas:

- Strict configuration (non-negotiable)
- Common patterns (discriminated unions, generics)
- React-specific patterns (component props, hooks)
- Utility types mastery

---

## Goals

1. **Zero `any` Types** — Every value has a type
2. **Better IDE Support** — Autocomplete, navigation, refactoring
3. **Catch Bugs Early** — Type errors before runtime
4. **Self-Documenting** — Types serve as documentation
5. **Maintainability** — Refactoring with confidence

---

## Table of Contents

- [Foundational Principles](#foundational-principles)
- [Strict Config](#strict-config)
- [Common Patterns](#common-patterns)
- [React Patterns](#react-patterns)
- [Utility Types](#utility-types)
- [Best Practices](#best-practices)

---

## Strict Config

### tsconfig.json

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "noImplicitThis": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "node",
    "resolveJsonModule": true
  }
}
```

---

## Common Patterns

### 1. Discriminated Unions (Tagged Unions)

**Problem:** State can be in multiple forms. Type-safe way to handle it.

```typescript
// ❌ Bad: Hard to know when data is available
type ApiState = {
  loading: boolean;
  error: Error | null;
  data: User | null;
};

// ✅ Good: Discriminated union
type ApiState =
  | { status: 'loading' }
  | { status: 'error'; error: Error }
  | { status: 'success'; data: User };

// Using it
function render(state: ApiState) {
  switch (state.status) {
    case 'loading':
      return <Spinner />;
    case 'error':
      return <Error message={state.error.message} />;
    case 'success':
      return <User user={state.data} />; // data is guaranteed to exist
  }
}
```

### 2. Generic Constraints

```typescript
// ✅ Constrain generics to known types
function getValue<T extends { value: unknown }>(obj: T): T["value"] {
  return obj.value;
}

getValue({ value: "hello" }); // ✅
getValue({ name: "john" }); // ❌ Error: no 'value' property

// ✅ Function generics
function pipe<A, B, C>(f: (a: A) => B, g: (b: B) => C): (a: A) => C {
  return (a) => g(f(a));
}

const toString = (n: number) => n.toString();
const toUpperCase = (s: string) => s.toUpperCase();
const numToUpper = pipe(toString, toUpperCase);
```

### 3. Exhaustiveness Checking

```typescript
type Color = "red" | "green" | "blue";

function getHex(color: Color): string {
  switch (color) {
    case "red":
      return "#FF0000";
    case "green":
      return "#00FF00";
    case "blue":
      return "#0000FF";
    // ❌ Error if someone adds 'yellow' to Color
    default:
      const _exhaustive: never = color;
      return _exhaustive;
  }
}
```

---

## React Patterns

### Component Props Pattern

```typescript
import { ReactNode, FC } from 'react';

// ✅ Good: Explicit props interface
interface ButtonProps {
  children: ReactNode;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

const Button: FC<ButtonProps> = ({
  children,
  onClick,
  variant = 'primary',
  disabled = false
}) => {
  return (
    <button onClick={onClick} disabled={disabled}>
      {children}
    </button>
  );
};

// ✅ Good: Extend HTML attributes
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
}

const Input: FC<InputProps> = ({ label, ...rest }) => (
  <div>
    {label && <label>{label}</label>}
    <input {...rest} />
  </div>
);
```

### Hook Patterns

```typescript
// ✅ Generic hook
function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore =
        value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  };

  return [storedValue, setValue] as const; // const assertion for tuple type
}

// Using it
const [theme, setTheme] = useLocalStorage<"light" | "dark">("theme", "light");
```

---

## Utility Types

### Essential Utilities

```typescript
// Partial - make all fields optional
type PartialUser = Partial<User>;

// Required - make all fields required
type RequiredUser = Required<User>;

// Pick - select specific fields
type UserPreview = Pick<User, "id" | "name">;

// Omit - exclude specific fields
type UserWithoutEmail = Omit<User, "email">;

// Record - object with known keys
type ColorMap = Record<"red" | "green" | "blue", string>;
const colors: ColorMap = {
  red: "#FF0000",
  green: "#00FF00",
  blue: "#0000FF",
};

// Readonly - make fields immutable
type ReadonlyUser = Readonly<User>;

// ReturnType - extract function return type
type MyReturn = ReturnType<typeof fetchUser>;
```

---

## Best Practices

1. **Strict Mode Always** — Non-negotiable in tsconfig
2. **No `any` Types** — Use `unknown` if truly unknown, then narrow
3. **Discriminated Unions** — For state with multiple branches
4. **Exhaustiveness Checking** — Catch missing cases
5. **Generic Constraints** — Make contracts explicit
6. **Const Assertions** — For literal types and tuples
7. **Utility Types** — Don't repeat type definitions
8. **Extract to Interfaces** — Reusable type definitions in `shared/types`
