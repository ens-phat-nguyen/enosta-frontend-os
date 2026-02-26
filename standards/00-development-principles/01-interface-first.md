# Interface-First Thinking

> TL;DR: Define inputs, outputs, and boundaries BEFORE writing any logic.

---

## Checklist

Before writing implementation, verify:

- [ ] **Input** — All inputs clearly defined? (required vs optional, types, defaults)
- [ ] **Output** — Know exactly what will be returned? (success case, error cases, side effects)
- [ ] **Naming** — Are names self-documenting?
- [ ] **Constraints** — Validation rules and pre/post-conditions identified?
- [ ] **Usage example** — Can you write one? If not, the interface isn't clear enough.

---

## Red Flags

- Function has `any` type for input or output
- No clear return type — caller has to guess what comes back
- Props added incrementally without a plan
- Can't write a usage example without reading the implementation
- Team members can't work in parallel because contracts are undefined

---

## Workflow

```
1. UNDERSTAND       2. DESIGN         3. REVIEW          4. IMPLEMENT
   Requirement  →      Interface   →     With team    →     Logic
```

---

## Examples

### Function Interface

```typescript
// Bad: no contract, unclear input/output
function processData(data) {
  // ... 100 lines ...
  return something;
}

// Good: define contract first, implement later
type ProcessDataInput = {
  users: User[];
  filters: {
    status: "active" | "inactive" | "all";
    minAge?: number;
  };
};

type ProcessDataOutput = {
  filteredUsers: User[];
  totalCount: number;
  appliedFilters: string[];
};

function processUserData(input: ProcessDataInput): ProcessDataOutput {
  // NOW implement
}
```

### React Component Props

```tsx
// Bad: props added ad-hoc without plan
function UserCard({ user, showAvatar, size, onClick, isAdmin, theme, ... }) {}

// Good: clear prop categories with sensible defaults
type UserCardProps = {
  // Required data
  user: { id: string; name: string; email: string; avatarUrl?: string }

  // Display options
  variant?: 'compact' | 'detailed' | 'minimal'
  showAvatar?: boolean // default: true

  // Interaction
  onSelect?: (userId: string) => void
  onEdit?: (userId: string) => void

  // Styling escape hatch
  className?: string
}
```

### Custom Hook

```typescript
// Bad: unclear interface
function useSearch(data, fields) {
  // What does this return?
}

// Good: interface defined first
type UseSearchOptions<T> = {
  data: T[];
  searchFields: (keyof T)[];
  debounceMs?: number; // default: 300
};

type UseSearchReturn<T> = {
  query: string;
  setQuery: (query: string) => void;
  results: T[];
  isSearching: boolean;
  clearSearch: () => void;
};

function useSearch<T>(options: UseSearchOptions<T>): UseSearchReturn<T> {
  // implement
}
```

---

## References

- Bertrand Meyer — [Design by Contract](https://en.wikipedia.org/wiki/Design_by_contract) (1986)
- Martin Fowler — [Published Interface](https://martinfowler.com/bliki/PublishedInterface.html)
- "Clean Architecture" — Robert C. Martin (Chapter on Boundaries & Interfaces)
