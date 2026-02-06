# Component Patterns & Composition

> "Components are the building blocks of React. Build them right."

---

## Foundational Principles

Before structuring components, understand these principles:

### 1. **Interface-First Thinking**

Design component contracts (props, events) before implementation. Think about how it will be used.

### 2. **KISS (Keep It Simple, Stupid)**

Smaller, focused components are easier to test and reuse.

### 3. **DRY (Don't Repeat Yourself)**

Extract common component patterns into reusable base components.

### 4. **YAGNI (You Aren't Gonna Need It)**

Don't make components "flexible" for features you don't have yet.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Component Patterns** are proven structures for common component problems:

- Container vs Presentational (smart vs dumb components)
- Render Props and Higher-Order Components
- Compound Components (coordinated children)
- Custom Hooks (logic extraction)

Good component design = Easy to test, reuse, and maintain.

---

## Goals

1. **Reusability** — Use components across multiple places
2. **Testability** — Easy to test in isolation
3. **Composability** — Combine components like building blocks
4. **Clarity** — Props and behavior are obvious
5. **Maintainability** — Easy to understand and modify

---

## Table of Contents

- [Foundational Principles](#foundational-principles)
- [Component Organization](#component-organization)
- [Composition Patterns](#composition-patterns)
- [Prop Patterns](#prop-patterns)
- [Performance Patterns](#performance-patterns)
- [Best Practices](#best-practices)

---

## Component Organization

### File Structure

```
src/modules/users/
├── components/
│   ├── UserCard.tsx        (presentational)
│   ├── UserForm.tsx        (presentational)
│   └── UserList.tsx        (container)
├── hooks/
│   ├── useUser.ts          (data fetching)
│   └── useUserFilters.ts   (local state)
├── types.ts                (TypeScript interfaces)
└── index.ts                (barrel export)
```

### Export Patterns

```typescript
// ✅ Good: Barrel export in index.ts
export { UserCard } from "./components/UserCard";
export { UserList } from "./components/UserList";
export { useUser } from "./hooks/useUser";
export type { User, UserFilters } from "./types";

// Using it
import { UserCard, useUser } from "@/modules/users";
```

---

## Composition Patterns

### 1. Container vs Presentational

```typescript
// ✅ Presentational: Pure input → output, no side effects
interface UserCardProps {
  user: User;
  onEdit?: () => void;
}

const UserCard: FC<UserCardProps> = ({ user, onEdit }) => (
  <div>
    <h2>{user.name}</h2>
    <p>{user.email}</p>
    {onEdit && <button onClick={onEdit}>Edit</button>}
  </div>
);

// ✅ Container: Fetches data, manages state, passes to presentational
const UserListContainer: FC = () => {
  const { data: users, loading } = useQuery(GET_USERS);
  const [selectedId, setSelectedId] = useState<string | null>(null);

  if (loading) return <Spinner />;

  return (
    <div>
      {users?.map(user => (
        <UserCard
          key={user.id}
          user={user}
          onEdit={() => setSelectedId(user.id)}
        />
      ))}
    </div>
  );
};
```

**Benefits:**

- ✅ Easy to test presentational components
- ✅ Can reuse components with different data sources
- ✅ Clear separation of concerns

### 2. Compound Components

```typescript
// ✅ Components work together with shared context
interface AccordionContextType {
  expandedItem: string | null;
  setExpandedItem: (id: string) => void;
}

const AccordionContext = createContext<AccordionContextType | undefined>(undefined);

const Accordion: FC<{ children: ReactNode }> = ({ children }) => {
  const [expandedItem, setExpandedItem] = useState<string | null>(null);

  return (
    <AccordionContext.Provider value={{ expandedItem, setExpandedItem }}>
      <div>{children}</div>
    </AccordionContext.Provider>
  );
};

const AccordionItem: FC<{ id: string; title: string; children: ReactNode }> = ({
  id,
  title,
  children
}) => {
  const context = useContext(AccordionContext);
  if (!context) throw new Error('AccordionItem must be inside Accordion');

  const isExpanded = context.expandedItem === id;

  return (
    <div>
      <button onClick={() => context.setExpandedItem(id)}>
        {title}
      </button>
      {isExpanded && <div>{children}</div>}
    </div>
  );
};

// Usage
<Accordion>
  <AccordionItem id="1" title="Section 1">Content 1</AccordionItem>
  <AccordionItem id="2" title="Section 2">Content 2</AccordionItem>
</Accordion>
```

### 3. Render Props

```typescript
// ✅ Share state/logic via render function prop
interface MouseTrackerProps {
  children: (position: { x: number; y: number }) => ReactNode;
}

const MouseTracker: FC<MouseTrackerProps> = ({ children }) => {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  return (
    <div
      onMouseMove={(e) =>
        setPosition({ x: e.clientX, y: e.clientY })
      }
    >
      {children(position)}
    </div>
  );
};

// Usage
<MouseTracker>
  {({ x, y }) => <p>Mouse at {x}, {y}</p>}
</MouseTracker>
```

---

## Prop Patterns

### 1. Spreading Props

```typescript
// ✅ Good: Forward native HTML attributes
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary';
}

const Button: FC<ButtonProps> = ({ variant = 'primary', ...rest }) => (
  <button className={`btn btn-${variant}`} {...rest} />
);

// User can pass any button attribute
<Button onClick={handleClick} disabled type="submit">
  Submit
</Button>
```

### 2. Slot Components (Named Slots)

```typescript
// ✅ Good: Named slots for complex layouts
interface ModalProps {
  header?: ReactNode;
  body: ReactNode;
  footer?: ReactNode;
}

const Modal: FC<ModalProps> = ({ header, body, footer }) => (
  <div className="modal">
    {header && <div className="modal-header">{header}</div>}
    <div className="modal-body">{body}</div>
    {footer && <div className="modal-footer">{footer}</div>}
  </div>
);

// Usage
<Modal
  header={<h2>Confirm</h2>}
  body={<p>Are you sure?</p>}
  footer={<button>OK</button>}
/>
```

---

## Performance Patterns

### 1. Memoization

```typescript
// ✅ Prevent unnecessary re-renders
const UserCard = memo<UserCardProps>(({ user }) => (
  <div>{user.name}</div>
));

// With comparison function (use rarely)
const UserCard = memo(
  ({ user }: UserCardProps) => <div>{user.name}</div>,
  (prevProps, nextProps) => prevProps.user.id === nextProps.user.id
);
```

### 2. Lazy Loading

```typescript
// ✅ Code split by route/feature
const UserDashboard = lazy(() => import('./UserDashboard'));

function App() {
  return (
    <Suspense fallback={<Spinner />}>
      <UserDashboard />
    </Suspense>
  );
}
```

---

## Best Practices

1. **Single Responsibility** — Each component does one thing
2. **Presentational by Default** — No logic, just render
3. **Prop Drilling Solution** — Extract container or use Context
4. **Memoize Wisely** — Only when you have proven performance issues
5. **Name Components Clearly** — Container suffix, presentational suffix if needed
6. **Type All Props** — Use TypeScript interfaces
7. **Organize by Feature** — Components live with their module
8. **Extract Custom Hooks** — For complex logic, not components
