# YAGNI (You Aren't Gonna Need It)

> TL;DR: Only write code for what you need RIGHT NOW, not what you think you might need later.

---

## Checklist

Before adding code or features, ask:

- [ ] **Need** — Is there a requirement for this RIGHT NOW?
- [ ] **User** — Is there a real user who needs this?
- [ ] **Simple** — Is this the simplest solution for the current problem?
- [ ] **Cost** — Will it really cost more to add this later?
- [ ] **Proof** — Is there data or feedback showing this will be used?

---

## Red Flags

- Code has comments like `// not needed yet` or `// for future use`
- Interface has 5+ methods but only 1 is called
- Config object with many unused fields
- Multiple implementations of an interface when only one is used
- Generic type parameters solving problems you don't have

---

## Workflow

```
1. IMPLEMENT        2. VALIDATE       3. REFACTOR        4. EXTEND
   Minimum      →      Real usage  →     When needed  →     When required
   "Simplest            "Does it          "Improve when      "Add features
    solution"            work?"            patterns emerge"   when needed"
```

---

## Examples

### Premature Abstraction

```typescript
// Bad: building for futures that may never come
interface PaymentProcessor {
  processPayment(payment: Payment): Promise<PaymentResult>
  refundPayment(paymentId: string): Promise<RefundResult>      // not needed yet
  partialRefund(paymentId: string, amount: number): Promise<RefundResult>  // not needed yet
  schedulePayment(payment: Payment, date: Date): Promise<void>  // not needed yet
}

class StripeProcessor implements PaymentProcessor { /* ... */ }
class PayPalProcessor implements PaymentProcessor { /* ... */ }  // not needed yet

// Good: only what's needed now
interface PaymentProcessor {
  processPayment(payment: Payment): Promise<PaymentResult>
}

class StripeProcessor implements PaymentProcessor {
  async processPayment(payment: Payment): Promise<PaymentResult> {
    // the only thing needed now
  }
}
// When you ACTUALLY need PayPal → add it then
// When you ACTUALLY need refund → add the method then
```

### Over-engineered Config

```typescript
// Bad: complex config for features nobody uses
const config = {
  darkMode: {
    enabled: true,
    variants: ['dark', 'dim', 'midnight'],  // not needed yet
    scheduleEnabled: true,                   // not needed yet
  },
  notifications: { /* ... */ },              // not needed yet
  plugins: [],                               // not needed yet
}

// Good: what you need now
const config = {
  darkMode: true,
}
// Expand when you actually need more options
```

---

## When NOT to Apply YAGNI

| Case | Why |
|------|-----|
| **Security** | Adding security later is expensive and risky |
| **Core Architecture** | Database schema, API contracts are hard to change later |
| **Public APIs** | Breaking changes hurt external users |
| **Compliance/Legal** | GDPR, HIPAA must be designed from the start |

---

## References

- Ron Jeffries — [YAGNI](https://ronjeffries.com/xprog/articles/practices/pracnotneed/)
- Martin Fowler — [YAGNI](https://martinfowler.com/bliki/Yagni.html)
- "Extreme Programming Explained" — Kent Beck
