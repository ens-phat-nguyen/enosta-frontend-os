# DRY (Don't Repeat Yourself)

> "Every piece of knowledge must have a single, unambiguous, authoritative representation within a system." — Andy Hunt & Dave Thomas, The Pragmatic Programmer

---

## 1. Overview

**DRY** is a fundamental principle that aims to reduce duplication of knowledge in a codebase. When the same logic, data, or concept exists in multiple places, changes become difficult and error-prone.

**Key Idea:** Each piece of knowledge should exist in **one place only**, so you only need to change it once.

---

## 2. Why It Matters

### The Problem

When the same knowledge is duplicated across multiple locations:

- **Inconsistent updates** - Change one place, forget another, introduce bugs
- **Higher maintenance cost** - More code to read, understand, and maintain
- **Hidden bugs** - Same bug appears in multiple places
- **Unclear source of truth** - Which version is correct?
- **Wasted effort** - Fixing the same issue multiple times

### The Solution

Following DRY gives you:

- **Single source of truth** - One place to understand and modify
- **Easier maintenance** - Change once, apply everywhere
- **Fewer bugs** - Fix once, fixed everywhere
- **Better consistency** - Behavior is uniform across the system
- **Cleaner codebase** - Less code to read and understand

---

## 3. Core Concepts

### What is "Knowledge"?

DRY is about **knowledge**, not just code. Knowledge includes:

```plaintext
┌─────────────────────────────────────────────────────────────┐
│                    TYPES OF KNOWLEDGE                       │
│                                                             │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│   │ Business     │  │ Technical    │  │ Domain       │      │
│   │ Logic        │  │ Logic        │  │ Rules        │      │
│   │              │  │              │  │              │      │
│   │ Tax calc     │  │ Validation   │  │ "Active user │      │
│   │ Pricing      │  │ Formatting   │  │  = logged in │      │
│   │ Discounts    │  │ Parsing      │  │  last 30d"   │      │
│   └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                             │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│   │ Config       │  │ Schema       │  │ Constants    │      │
│   │              │  │ Definitions  │  │              │      │
│   │ API URLs     │  │ DB models    │  │ TAX_RATE     │      │
│   │ Timeouts     │  │ Type defs    │  │ MAX_RETRIES  │      │
│   └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### DRY vs. Code Duplication

**Important:** DRY is NOT just about removing duplicate code.

```plaintext
┌─────────────────────────────────────────────────────────────┐
│              DRY vs. CODE DUPLICATION                       │
│                                                             │
│   ┌─────────────────────────┐  ┌─────────────────────────┐  │
│   │  SAME KNOWLEDGE         │  │  SAME CODE              │  │
│   │  (Apply DRY)            │  │  (May NOT need DRY)     │  │
│   │                         │  │                         │  │
│   │  - Same business rule   │  │  - Coincidentally       │  │
│   │  - Same calculation     │  │    similar code         │  │
│   │  - Same validation      │  │  - Different contexts   │  │
│   │  - Same domain concept  │  │  - Different purposes   │  │
│   │                         │  │  - May evolve           │  │
│   │  → Extract & Reuse      │  │    differently          │  │
│   │                         │  │                         │  │
│   │                         │  │  → Keep separate        │  │
│   └─────────────────────────┘  └─────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Key Terms

| Term | Definition |
| --- | --- |
| Knowledge | Any fact, rule, or concept that the system represents |
| Single Source of Truth | One authoritative location for each piece of knowledge |
| Abstraction | A way to capture shared knowledge in one place |
| Coupling | When components depend on each other |
| Coincidental Duplication | Code that looks similar but represents different knowledge |

---

## 4. The Danger of Over-DRY

### What is Over-DRY?

Over-DRY happens when developers remove duplication **too aggressively**, merging code that only **looks similar** but represents **different knowledge**.

```plaintext
┌─────────────────────────────────────────────────────────────┐
│                    OVER-DRY SPECTRUM                        │
│                                                             │
│   Under-DRY          Sweet Spot           Over-DRY          │
│       │                  │                    │             │
│       ▼                  ▼                    ▼             │
│   ┌───────┐          ┌───────┐          ┌───────┐           │
│   │ Copy  │          │ Right │          │ Wrong │           │
│   │ Paste │          │ Level │          │ Merge │           │
│   │ Hell  │          │       │          │       │           │
│   └───────┘          └───────┘          └───────┘           │
│                                                             │
│   Problems:          Benefits:          Problems:           │
│   - Inconsistency    - Easy to change   - Tight coupling    │
│   - Bugs everywhere  - Clear intent     - Hard to change    │
│   - Hard to update   - Flexible         - Wrong abstraction │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Signs of Over-DRY

| Sign | Description |
| --- | --- |
| **Too many parameters** | Function needs 5+ params to handle all cases |
| **Complex conditionals** | if/else chains to handle different contexts |
| **Fragile changes** | Changing one case breaks other cases |
| **Unclear naming** | Generic names like `processData`, `handleItem` |
| **Forced coupling** | Unrelated features share code unnecessarily |

### Over-DRY Example

❌ **Over-DRY (Wrong Merge):**

```typescript
// Merging user validation and product validation
// They look similar but are DIFFERENT knowledge
function validateEntity(entity: any, type: 'user' | 'product') {
  const errors = []

  if (type === 'user') {
    if (!entity.email) errors.push('Email required')
    if (!entity.password || entity.password.length < 8) {
      errors.push('Password must be 8+ characters')
    }
  } else if (type === 'product') {
    if (!entity.name) errors.push('Name required')
    if (!entity.price || entity.price < 0) {
      errors.push('Price must be positive')
    }
  }

  // More conditionals as requirements change...
  return errors
}
```

✅ **Right Level of DRY:**

```typescript
// Separate functions - they represent DIFFERENT knowledge
function validateUser(user: User): ValidationError[] {
  const errors = []
  if (!user.email) errors.push('Email required')
  if (!user.password || user.password.length < 8) {
    errors.push('Password must be 8+ characters')
  }
  return errors
}

function validateProduct(product: Product): ValidationError[] {
  const errors = []
  if (!product.name) errors.push('Name required')
  if (!product.price || product.price < 0) {
    errors.push('Price must be positive')
  }
  return errors
}

// If you see a REAL pattern later, extract it then
```

---

## 5. Workflow & Checklist

### Recommended Workflow

```plaintext
1. WRITE          →   2. NOTICE        →   3. EVALUATE      →   4. EXTRACT
   First Time          Duplication          Same Knowledge?      If Pattern

   "Just code          "Hmm, this          "Is this the        "Create
    the solution"       looks familiar"     SAME concept?"       abstraction"

   Don't worry         Note it, but        Ask: would they     Name it well,
   about DRY yet       don't rush          change together?    document why
```

### Checklist

Before extracting duplicate code, verify:

- [ ] **SAME KNOWLEDGE:** Do both pieces represent the exact same concept?
- [ ] **CHANGE TOGETHER:** If one changes, must the other change too?
- [ ] **THREE TIMES:** Has this pattern appeared at least 3 times?
- [ ] **CLEAR ABSTRACTION:** Can you name it clearly? (not `doStuff`)
- [ ] **NOT OVER-DRY:** Will this abstraction be simple without many conditionals?

---

## 6. Examples

### Example 1: Business Rule (Apply DRY)

❌ **Bad (Duplicated Knowledge):**

```typescript
// Order service
function calculateOrderTotal(items: OrderItem[]) {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  const tax = subtotal * 0.1  // 10% tax - knowledge duplicated!
  return subtotal + tax
}

// Invoice service
function generateInvoice(items: OrderItem[]) {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  const tax = subtotal * 0.1  // 10% tax - same knowledge!
  return { subtotal, tax, total: subtotal + tax }
}

// Report service
function calculateRevenue(orders: Order[]) {
  return orders.reduce((sum, order) => {
    const subtotal = order.items.reduce((s, i) => s + i.price * i.quantity, 0)
    return sum + subtotal * 1.1  // 10% tax - duplicated again!
  }, 0)
}
```

✅ **Good (Single Source of Truth):**

```typescript
// Tax knowledge in ONE place
const TAX_CONFIG = {
  rate: 0.1,  // 10% tax
} as const

function calculateTax(amount: number): number {
  return amount * TAX_CONFIG.rate
}

function calculateSubtotal(items: OrderItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0)
}

// All services use the same source
function calculateOrderTotal(items: OrderItem[]) {
  const subtotal = calculateSubtotal(items)
  return subtotal + calculateTax(subtotal)
}

function generateInvoice(items: OrderItem[]) {
  const subtotal = calculateSubtotal(items)
  const tax = calculateTax(subtotal)
  return { subtotal, tax, total: subtotal + tax }
}
```

### Example 2: Coincidental Duplication (Keep Separate)

❌ **Over-DRY (Wrong):**

```typescript
// Merging two different concepts because code looks similar
function formatEntity(entity: User | Product, type: 'user' | 'product'): string {
  if (type === 'user') {
    return `${entity.firstName} ${entity.lastName}`
  } else {
    return `${entity.name} - $${entity.price}`
  }
}
```

✅ **Good (Separate Concerns):**

```typescript
// These are DIFFERENT knowledge - keep them separate
function formatUserName(user: User): string {
  return `${user.firstName} ${user.lastName}`
}

function formatProductDisplay(product: Product): string {
  return `${product.name} - $${product.price}`
}

// They may look similar now, but will evolve differently:
// - User: might add title, middle name, suffix
// - Product: might add currency, discount, availability
```

### Example 3: Waiting for Pattern (YAGNI + DRY)

❌ **Premature Abstraction:**

```typescript
// First API endpoint - immediately creating abstraction
const createApiHandler = <T>(
  validator: (data: unknown) => T,
  handler: (data: T) => Promise<Response>,
  errorHandler: (error: Error) => Response,
  middleware: Middleware[],
) => { /* complex generic code */ }
```

✅ **Wait for Pattern:**

```typescript
// First endpoint - just write it
app.post('/users', async (req, res) => {
  const user = validateUser(req.body)
  const created = await userService.create(user)
  res.json(created)
})

// Second endpoint - similar, but wait
app.post('/products', async (req, res) => {
  const product = validateProduct(req.body)
  const created = await productService.create(product)
  res.json(created)
})

// Third endpoint - now we see the pattern!
// NOW extract if the pattern is clear and stable
```

---

## 7. References

### Articles

- [The Pragmatic Programmer - DRY](https://pragprog.com/tips/) - Original source of DRY
- [Martin Fowler - Refactoring](https://refactoring.com/) - Patterns for removing duplication
- [Sandi Metz - The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction) - When DRY goes wrong

### Books

- "The Pragmatic Programmer" - Hunt & Thomas (Chapter on DRY)
- "Clean Code" - Robert C. Martin (Duplication and Abstraction)
- "99 Bottles of OOP" - Sandi Metz (Finding the right abstraction)

### Related Principles

| Principle | Relationship to DRY |
| --- | --- |
| **[YAGNI](./02-yagni.md)** | Balance - don't create abstractions too early |
| **[KISS](./04-kiss.md)** | Both aim for simplicity |
| **Single Responsibility** | Each abstraction should have one reason to change |

> 📖 **See also:** [Balancing Principles Guide](./guides/balancing-principles.md) - How to navigate conflicts between DRY, YAGNI, and KISS
