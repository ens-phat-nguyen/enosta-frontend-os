# DRY (Don't Repeat Yourself)

> TL;DR: Each piece of knowledge should exist in ONE place only. But DRY is about knowledge, not code.

---

## Checklist

Before extracting duplicate code, verify:

- [ ] **Same knowledge** — Do both pieces represent the exact same concept?
- [ ] **Change together** — If one changes, must the other change too?
- [ ] **Three times** — Has this pattern appeared at least 3 times?
- [ ] **Clear name** — Can you name the abstraction clearly? (not `doStuff`)
- [ ] **Still simple** — Will the abstraction be simple, without many conditionals?

---

## Red Flags: Under-DRY

- Same business rule (tax rate, discount logic) hardcoded in multiple files
- Constants like magic numbers repeated across the codebase
- Same validation logic copy-pasted between services
- Bug fix needed in multiple places

## Red Flags: Over-DRY

- Function needs 5+ parameters to handle all cases
- Complex if/else chains to handle different contexts
- Changing one case breaks other cases
- Generic names like `processData`, `handleItem`
- Unrelated features forced to share code

---

## Key Distinction: Same Knowledge vs Same Code

```typescript
// SAME KNOWLEDGE (apply DRY) — both represent "10% tax calculation"
// order-service.ts
const tax = subtotal * 0.1;
// invoice-service.ts
const tax = subtotal * 0.1;
// → Extract: calculateTax(subtotal)

// SAME CODE but DIFFERENT KNOWLEDGE (keep separate)
// These look similar but represent different concepts
function formatUserName(user: User): string {
  return `${user.firstName} ${user.lastName}`;
}
function formatProductDisplay(product: Product): string {
  return `${product.name} - $${product.price}`;
}
// → Keep separate. They will evolve differently.
```

---

## Examples

### Business Rule — Extract Immediately

```typescript
// Bad: tax knowledge scattered across files
function calculateOrderTotal(items: OrderItem[]) {
  const subtotal = items.reduce((sum, i) => sum + i.price * i.quantity, 0);
  const tax = subtotal * 0.1; // duplicated!
  return subtotal + tax;
}

function generateInvoice(items: OrderItem[]) {
  const subtotal = items.reduce((sum, i) => sum + i.price * i.quantity, 0);
  const tax = subtotal * 0.1; // duplicated!
  return { subtotal, tax, total: subtotal + tax };
}

// Good: single source of truth
const TAX_RATE = 0.1;

function calculateTax(amount: number): number {
  return amount * TAX_RATE;
}

function calculateSubtotal(items: OrderItem[]): number {
  return items.reduce((sum, i) => sum + i.price * i.quantity, 0);
}
```

### Over-DRY — Wrong Merge

```typescript
// Bad: merging different knowledge just because code looks similar
function validateEntity(entity: any, type: "user" | "product") {
  if (type === "user") {
    if (!entity.email) errors.push("Email required");
    // ...user-specific rules
  } else if (type === "product") {
    if (!entity.name) errors.push("Name required");
    // ...product-specific rules
  }
}

// Good: separate functions for separate knowledge
function validateUser(user: User): ValidationError[] {
  /* ... */
}
function validateProduct(product: Product): ValidationError[] {
  /* ... */
}
```

---

## References

- Sandi Metz — [The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction)
- "The Pragmatic Programmer" — Hunt & Thomas (origin of DRY)
- "99 Bottles of OOP" — Sandi Metz
