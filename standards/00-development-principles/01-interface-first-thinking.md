# Interface-First Thinking

> "Spend 30% of your time designing the interface, and implementation will be 50% easier."

---

## 1. Overview

**Interface-First Thinking** (also known as **Design by Contract**) is a programming mindset where you **design interfaces (contracts) BEFORE writing implementation**. This concept was introduced by Bertrand Meyer in the 1980s and remains one of the most important best practices today.

**Key Idea:** Define the inputs, outputs, and boundaries of your code before writing any logic.

---

## 2. Why It Matters

### The Problem

When developers write code without thinking about interfaces first:

- Code becomes hard to read and understand - unclear purpose
- Refactoring causes breaking changes across the codebase
- Testing is difficult without clear input/output definitions
- Team members cannot work in parallel on related code
- Technical debt accumulates rapidly

### The Solution

Following Interface-First Thinking provides:

- **Self-documenting code** - interfaces describe what code does
- **Stable contracts** - implementation can change without breaking callers
- **Easy testing** - tests are written against clear interfaces
- **Parallel development** - teams can work on caller and callee simultaneously
- **Long-term maintainability** - changes are isolated and predictable

---

## 3. Core Concepts

### Contract

Each interface is a **contract** between two parties:

```plaintext
┌─────────────────────────────────────────────────────────┐
│                      CONTRACT                           │
│                                                         │
│   CALLER                            CALLEE              │
│   "I will provide the correct  ←→  "I will return the   │
│    input as agreed"                 correct output as   │
│                                     promised"           │
└─────────────────────────────────────────────────────────┘
```

### Interface = Boundaries

```plaintext
┌─────────────────────────────────────────────────────────┐
│                    INTERFACE                            │
│  ┌──────────────┐              ┌──────────────────┐     │
│  │    INPUT     │  ──────────► │     OUTPUT       │     │
│  │  (Props,     │   Black Box  │  (Return value,  │     │
│  │   Arguments) │              │   Side effects)  │     │
│  └──────────────┘              └──────────────────┘     │
│                                                         │
│  ✅ Define this FIRST                                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                  IMPLEMENTATION                         │
│                                                         │
│     if (x) { ... } else { ... }                         │
│     for (let i...) { ... }                              │
│     await fetch(...)                                    │
│                                                         │
│  ⏳ Write this LATER                                    │
└─────────────────────────────────────────────────────────┘
```

### Key Terms

| Term | Definition |
| --- | --- |
| Interface | The public API surface - inputs, outputs, and expected behavior |
| Contract | An agreement between caller and callee about what each side provides |
| Caller | The code that uses/calls a function or component |
| Callee | The function or component being called |
| Boundary | The line between what is public (exposed) and private (internal) |

---

## 4. Workflow & Checklist

### Recommended Workflow

```plaintext
1. UNDERSTAND    →   2. DESIGN      →   3. REVIEW     →   4. IMPLEMENT
   Requirement       Interface           Interface         Logic

   "What needs       "What are the       "Team reviews     "Write the
    to be done?"      inputs/outputs?"    the interface"    actual code"
```

### Checklist

Before writing implementation, verify:

- [ ] **INPUT:** Have all inputs been clearly defined? (Required vs Optional, Types, Defaults)
- [ ] **OUTPUT:** Do you know exactly what will be returned? (Success case, Error cases, Side effects)
- [ ] **NAMING:** Are names self-documenting? (Function name, Prop names)
- [ ] **CONSTRAINTS:** Have constraints been identified? (Validation rules, Pre/Post-conditions)
- [ ] **EXAMPLES:** Can you write a usage example? (If not → interface is not clear enough)

---

## 5. Examples

### Example 1: Function Interface

❌ **Bad:**

```typescript
// Write logic first, then figure out input/output
function processData(data) {
  // ... 100 lines of code ...
  return something // No idea what this returns
}
```

✅ **Good:**

```typescript
// Step 1: Define the CONTRACT first
type ProcessDataInput = {
  users: User[]
  filters: {
    status: 'active' | 'inactive' | 'all'
    minAge?: number
  }
}

type ProcessDataOutput = {
  filteredUsers: User[]
  totalCount: number
  appliedFilters: string[]
}

// Step 2: Write function signature
function processUserData(input: ProcessDataInput): ProcessDataOutput {
  // Step 3: NOW implement the logic
}
```

### Example 2: React Component Props

❌ **Bad:**

```tsx
// Props added incrementally without a plan
function UserCard({ user, showAvatar, size, onClick, isAdmin, theme, ... }) {
  // Messy implementation
}
```

✅ **Good:**

```tsx
// Step 1: Define clear prop categories
type UserCardProps = {
  // Required data
  user: {
    id: string
    name: string
    email: string
    avatarUrl?: string
  }

  // Display options (with sensible defaults)
  variant?: 'compact' | 'detailed' | 'minimal'
  showAvatar?: boolean // default: true

  // Interaction handlers
  onSelect?: (userId: string) => void
  onEdit?: (userId: string) => void

  // Styling escape hatch
  className?: string
}

// Step 2: Document the contract
/**
 * Displays a user card with configurable appearance.
 *
 * @example
 * <UserCard
 *   user={currentUser}
 *   variant="detailed"
 *   onSelect={handleUserSelect}
 * />
 */
function UserCard({
  user,
  variant = 'compact',
  showAvatar = true,
  onSelect,
  onEdit,
  className,
}: UserCardProps) {
  // Step 3: Implement
}
```

### Example 3: API Endpoint

❌ **Bad:**

```typescript
// No clear contract - just start coding
app.post('/api/orders', (req, res) => {
  // What does req.body contain? What should we return?
})
```

✅ **Good:**

```typescript
// Step 1: Define Request/Response contracts
type CreateOrderRequest = {
  customerId: string
  items: Array<{
    productId: string
    quantity: number
  }>
  shippingAddress: Address
  paymentMethod: 'credit_card' | 'bank_transfer'
}

type CreateOrderResponse =
  | {
      success: true
      orderId: string
      estimatedDelivery: string
      totalAmount: number
    }
  | {
      success: false
      errorCode: 'INVALID_PRODUCT' | 'OUT_OF_STOCK' | 'PAYMENT_FAILED'
      message: string
    }

// Step 2: Define the endpoint contract
// POST /api/orders
// Request: CreateOrderRequest
// Response: CreateOrderResponse

// Step 3: Implement handler
```

### Example 4: Custom Hook

❌ **Bad:**

```typescript
// No clear interface - figure it out as we go
function useSearch(data, fields) {
  // What does this return? What options are available?
}
```

✅ **Good:**

```typescript
// Step 1: Define the hook interface
type UseSearchOptions<T> = {
  data: T[]
  searchFields: (keyof T)[]
  debounceMs?: number // default: 300
}

type UseSearchReturn<T> = {
  query: string
  setQuery: (query: string) => void
  results: T[]
  isSearching: boolean
  clearSearch: () => void
}

// Step 2: Write hook signature
function useSearch<T>(options: UseSearchOptions<T>): UseSearchReturn<T> {
  // Step 3: Implement
}

// Usage is clear from the interface:
const { query, setQuery, results, isSearching } = useSearch({
  data: users,
  searchFields: ['name', 'email'],
  debounceMs: 500,
})
```

---

## 6. References

### Philosophy & Methodology

- Bertrand Meyer - ["Design by Contract"](https://en.wikipedia.org/wiki/Design_by_contract) (1986) - The origin of this philosophy
- Martin Fowler - ["Published Interface"](https://martinfowler.com/bliki/PublishedInterface.html) - On the importance of stable interfaces
- ["API-First Design"](https://swagger.io/resources/articles/adopting-an-api-first-approach/) - Applying Interface-First to API development
- ["Contract-First API Design"](https://blog.stoplight.io/api-design-first-vs-code-first) - Design-First vs Code-First comparison

### Books

- "Object-Oriented Software Construction" - Bertrand Meyer (1988)
- "Clean Architecture" - Robert C. Martin (Chapter on Boundaries & Interfaces)
