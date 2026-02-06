# YAGNI (You Aren't Gonna Need It)

> "Always implement things when you actually need them, never when you just foresee that you need them." — Ron Jeffries

---

## 1. Overview

**YAGNI** is a principle from Extreme Programming (XP). It says: **don't add features until you actually need them**. This helps keep code simple, saves time, and avoids wasting effort on things that may never be used.

**Key Idea:** Only write code for what you need **right now**, not for what you **think** you might need later.

---

## 2. Why It Matters

### The Problem

When developers write code "just in case" for the future:

- **Wasted effort** - 80% of pre-built code is never used
- **More complexity** - Codebase becomes harder to understand and maintain
- **Slower development** - Time spent on things nobody asked for
- **Harder to change** - Complex code is difficult to refactor
- **Over-engineering** - Too many abstractions make code confusing

### The Solution

Following YAGNI gives you:

- **Simpler codebase** - Easy to read and maintain
- **Faster delivery** - Ship features quickly
- **Easier refactoring** - Small codebase is easy to change
- **Lower mental load** - Less code = less to remember
- **Fewer bugs** - Less code = fewer hidden bugs

---

## 3. Core Concepts

### The Cost of "Just In Case" Code

```plaintext
┌─────────────────────────────────────────────────────────────┐
│              "JUST IN CASE" CODE                            │
│                                                             │
│   ┌─────────────────┐     ┌─────────────────┐               │
│   │  Writing Cost   │  +  │ Maintenance Cost│  =  WASTE     │
│   │  (Time to code) │     │ (Forever burden)│               │
│   └─────────────────┘     └─────────────────┘               │
│                                                             │
│   📊 Facts:                                                 │
│   - 64% of features are rarely or never used                │
│   - Only 20% of features are used regularly                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### YAGNI Decision Flow

```plaintext
┌──────────────────────────────────────────────────────────────┐
│                    YAGNI DECISION FLOW                       │
│                                                              │
│   "Should I add this feature/abstraction?"                   │
│                         │                                    │
│                         ▼                                    │
│            ┌─────────────────────┐                           │
│            │ Is it needed RIGHT  │                           │
│            │ NOW for current     │                           │
│            │ requirements?       │                           │
│            └─────────────────────┘                           │
│                    │         │                               │
│                   YES        NO                              │
│                    │         │                               │
│                    ▼         ▼                               │
│              ┌─────────┐  ┌─────────────────────────┐        │
│              │ BUILD IT│  │ DON'T BUILD IT          │        │
│              └─────────┘  │ → Write it down         │        │
│                           │ → Build when needed     │        │
│                           └─────────────────────────┘        │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Key Terms

| Term | What It Means |
| --- | --- |
| Over-engineering | Making code more complex than it needs to be |
| Premature abstraction | Creating abstractions before you see a real pattern |
| Gold plating | Adding "nice to have" features nobody asked for |
| Speculative generality | Code for "future expansion" without a real use case |
| Incremental design | Build step by step, refactor when needed |

---

## 4. Workflow & Checklist

### Recommended Workflow

```plaintext
1. IMPLEMENT     →   2. VALIDATE    →   3. REFACTOR    →   4. EXTEND
   Minimum           Real Usage         When Needed        When Required

   "Build the        "Does it           "Improve code      "Add features
    simplest          solve the          when patterns      only when
    solution"         problem?"          emerge"            actually needed"
```

### Checklist

Before adding code or features, ask yourself:

- [ ] **NEED:** Is there a requirement asking for this RIGHT NOW?
- [ ] **USER:** Is there a real user who needs this?
- [ ] **SIMPLE:** Is this the simplest solution for the current problem?
- [ ] **COST:** Will it really cost more to add this later?
- [ ] **PROOF:** Is there data or feedback showing this will be used?

---

## 5. Examples

### Example 1: Premature Abstraction

❌ **Bad:**

```typescript
// Building complex interface "just in case"
interface PaymentProcessor {
  processPayment(payment: Payment): Promise<PaymentResult>
  refundPayment(paymentId: string): Promise<RefundResult>     // not needed yet
  partialRefund(paymentId: string, amount: number): Promise<RefundResult>  // not needed yet
  schedulePayment(payment: Payment, date: Date): Promise<void>  // not needed yet
  getPaymentHistory(userId: string): Promise<Payment[]>        // not needed yet
  exportToCSV(): Promise<string>                               // not needed yet
}

// Building multiple implementations upfront
class StripeProcessor implements PaymentProcessor { /* ... */ }
class PayPalProcessor implements PaymentProcessor { /* ... */ }  // not needed yet
class VNPayProcessor implements PaymentProcessor { /* ... */ }   // not needed yet
```

✅ **Good:**

```typescript
// Only build what you need now
interface PaymentProcessor {
  processPayment(payment: Payment): Promise<PaymentResult>
}

class StripeProcessor implements PaymentProcessor {
  async processPayment(payment: Payment): Promise<PaymentResult> {
    // Stripe implementation - the only thing needed now
  }
}

// When you ACTUALLY need PayPal → refactor and add it
// When you ACTUALLY need refund → add refundPayment() method
```

### Example 2: Over-engineered Configuration

❌ **Bad:**

```typescript
// Complex config system "for future flexibility"
const config = {
  features: {
    darkMode: {
      enabled: true,
      variants: ['dark', 'dim', 'midnight'],  // not needed yet
      scheduleEnabled: true,                   // not needed yet
      autoDetect: true,                        // not needed yet
    },
    notifications: {
      email: { enabled: true, frequency: 'daily' },     // not needed yet
      push: { enabled: false, sound: 'default' },       // not needed yet
      sms: { enabled: false, provider: 'twilio' },      // not needed yet
    },
  },
  plugins: [],           // not needed yet
  customThemes: [],      // not needed yet
  analytics: { ... },    // not needed yet
}
```

✅ **Good:**

```typescript
// Simple config for what you need now
const config = {
  darkMode: true,
}

// When you need more options → expand config
// When you need notifications → add them then
```

### Example 3: Speculative API Design

❌ **Bad:**

```typescript
// API endpoint with too many options "just in case"
// GET /api/users?
//   fields=name,email,avatar
//   &include=posts,comments,followers
//   &filter[status]=active
//   &filter[role]=admin
//   &sort=-createdAt,name
//   &page[size]=20
//   &page[number]=1
//   &cache=true
//   &format=json

app.get('/api/users', (req, res) => {
  // 200 lines of code to handle all options
})
```

✅ **Good:**

```typescript
// Simple API for actual use case
// GET /api/users

app.get('/api/users', async (req, res) => {
  const users = await db.users.findAll({
    where: { status: 'active' },
    limit: 20,
  })
  res.json(users)
})

// When you ACTUALLY need pagination → add ?page=
// When you ACTUALLY need filter → add ?status=
// When you ACTUALLY need sort → add ?sort=
```

### Example 4: Component Props

❌ **Bad:**

```tsx
// Button with too many props "for flexibility"
type ButtonProps = {
  variant: 'primary' | 'secondary' | 'tertiary' | 'ghost' | 'link' | 'danger' | 'success' | 'warning'
  size: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl'
  rounded: 'none' | 'sm' | 'md' | 'lg' | 'full'
  shadow: 'none' | 'sm' | 'md' | 'lg'
  animation: 'none' | 'pulse' | 'bounce' | 'shake'
  iconPosition: 'left' | 'right' | 'top' | 'bottom'
  loading: boolean
  loadingText: string
  loadingPosition: 'left' | 'right' | 'center'
  // ... 20 more props
}
```

✅ **Good:**

```tsx
// Button with props that are actually used
type ButtonProps = {
  variant?: 'primary' | 'secondary'  // 2 variants are enough
  size?: 'sm' | 'md' | 'lg'          // 3 common sizes
  disabled?: boolean
  loading?: boolean
  onClick?: () => void
  children: React.ReactNode
}

// When design system needs more variants → add them
// When you actually need icons → add icon prop
```

---

## 6. When NOT to Apply YAGNI

YAGNI is not always right. Some things need upfront design:

| Case | Why |
| --- | --- |
| **Security** | Adding security later is expensive and risky |
| **Core Architecture** | Database schema, API contracts are hard to change later |
| **Public APIs** | Breaking changes hurt external users |
| **Performance Critical** | Some decisions affect basic performance |
| **Compliance/Legal** | GDPR, HIPAA... must be designed from the start |

---

## 7. Related Principles

| Principle | How It Relates |
| --- | --- |
| **[KISS](./04-kiss.md)** | Both aim for simplicity |
| **[DRY](./03-dry.md)** | Balance - don't abstract too early just for DRY |
| **SOLID** | Apply when needed, not "just in case" |
| **[Interface-First](./01-interface-first-thinking.md)** | Design simple interfaces, enough for current needs |

> 📖 **See also:** [Balancing Principles Guide](./guides/balancing-principles.md) - How to navigate conflicts between DRY, YAGNI, and KISS

---

## 8. References

### Articles

- Ron Jeffries - [YAGNI](https://ronjeffries.com/xprog/articles/practices/pracnotneed/) - Origin of the principle
- Martin Fowler - [YAGNI](https://martinfowler.com/bliki/Yagni.html) - Detailed analysis
- C2 Wiki - [You Arent Gonna Need It](https://wiki.c2.com/?YouArentGonnaNeedIt) - Community discussion

### Books

- "Extreme Programming Explained" - Kent Beck (Chapter on Simplicity)
- "Clean Code" - Robert C. Martin (Chapter on Simple Design)
- "The Pragmatic Programmer" - Hunt & Thomas (Tips on avoiding speculation)
