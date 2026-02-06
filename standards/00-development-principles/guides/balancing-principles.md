# Balancing Development Principles

> "For every complex problem, there is an answer that is clear, simple, and wrong." — H.L. Mencken

---

## 1. Overview

Development principles like KISS, DRY, and YAGNI are guidelines, not absolute rules. Real-world software development requires balancing these principles based on context. This guide explains how to navigate situations where principles seem to conflict.

**Key Idea:** Principles are tools to help you think, not rules to follow blindly.

---

## 2. The Big Three: KISS, DRY, YAGNI

### Quick Reference

```plaintext
┌─────────────────────────────────────────────────────────────┐
│                    THE BIG THREE                            │
│                                                             │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│   │    KISS     │  │    DRY      │  │   YAGNI     │        │
│   │             │  │             │  │             │        │
│   │  Keep It    │  │  Don't      │  │  You Aren't │        │
│   │  Simple     │  │  Repeat     │  │  Gonna      │        │
│   │             │  │  Yourself   │  │  Need It    │        │
│   └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
│   Focus:           Focus:           Focus:                  │
│   Complexity       Duplication      Features                │
│                                                             │
│   Question:        Question:        Question:               │
│   "Is this the     "Is this the     "Do I need this        │
│    simplest         same             RIGHT NOW?"            │
│    solution?"       knowledge?"                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### How They Relate

```plaintext
┌─────────────────────────────────────────────────────────────┐
│              PRINCIPLE RELATIONSHIPS                        │
│                                                             │
│                      ┌───────┐                              │
│                      │ KISS  │                              │
│                      └───┬───┘                              │
│                          │                                  │
│           "Keep abstractions simple"                        │
│                          │                                  │
│              ┌───────────┴───────────┐                      │
│              │                       │                      │
│              ▼                       ▼                      │
│         ┌───────┐               ┌───────┐                   │
│         │  DRY  │◄─────────────►│ YAGNI │                   │
│         └───────┘               └───────┘                   │
│                                                             │
│              "Wait before abstracting"                      │
│                                                             │
│   All three principles share a common goal:                 │
│   → Reduce unnecessary complexity                           │
│   → Make code easier to change                              │
│   → Improve developer productivity                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Common Conflicts and Resolutions

### Conflict 1: DRY vs. KISS

**The Tension:** Removing duplication (DRY) can introduce complex abstractions that violate KISS.

```plaintext
┌─────────────────────────────────────────────────────────────┐
│                   DRY vs. KISS                              │
│                                                             │
│   DRY says:                    KISS says:                   │
│   "Extract this pattern!"      "Keep it simple!"            │
│                                                             │
│   ┌───────────────────┐        ┌───────────────────┐       │
│   │ Complex shared    │   vs   │ Simple duplicated │       │
│   │ abstraction       │        │ code              │       │
│   └───────────────────┘        └───────────────────┘       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Resolution:** Prefer simple duplication over complex abstraction.

❌ **Over-DRY (Violates KISS):**

```typescript
// Complex abstraction to avoid duplication
function processEntity<T extends { id: string }>(
  entity: T,
  type: "user" | "product" | "order",
  options: ProcessOptions,
): ProcessResult<T> {
  const validators = getValidators(type);
  const transformers = getTransformers(type);
  const handlers = getHandlers(type);
  // ... complex generic logic with many conditionals
}
```

✅ **Balanced (Simple but some duplication):**

```typescript
// Simple, focused functions - slight duplication is OK
function processUser(user: User): UserResult {
  validateUser(user);
  return transformUser(user);
}

function processProduct(product: Product): ProductResult {
  validateProduct(product);
  return transformProduct(product);
}
```

**Guideline:** If your abstraction needs many parameters or conditionals to handle all cases, the duplication was probably better.

---

### Conflict 2: DRY vs. YAGNI

**The Tension:** DRY encourages extraction, but YAGNI says wait until you need it.

```plaintext
┌──────────────────────────────────────────────────────────────┐
│                   DRY vs. YAGNI                              │
│                                                              │
│   DRY says:                    YAGNI says:                   │
│   "Extract the pattern!"       "Wait, you might not need it" │
│                                                              │
│   Resolution: THE RULE OF THREE                              │
│                                                              │
│   1st time → Just write it                                   │
│   2nd time → Note it, but keep separate                      │
│   3rd time → Now extract (pattern confirmed)                 │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

**Resolution:** Use the Rule of Three.

```typescript
// First occurrence - just write it
function calculateUserDiscount(user: User): number {
  return user.orders > 10 ? 0.1 : 0;
}

// Second occurrence - note similarity, but WAIT
function calculateMemberDiscount(member: Member): number {
  return member.purchases > 10 ? 0.1 : 0;
}

// Third occurrence - NOW we see the pattern, extract it
function calculateLoyaltyDiscount(purchaseCount: number): number {
  return purchaseCount > 10 ? 0.1 : 0;
}
```

**Guideline:** Two occurrences might be coincidence. Three occurrences confirm a pattern.

---

### Conflict 3: KISS vs. YAGNI

**The Tension:** Rarely conflict directly, but can when "simple now" creates problems later.

```plaintext
┌─────────────────────────────────────────────────────────────┐
│                   KISS vs. YAGNI                            │
│                                                             │
│   KISS says:                   YAGNI says:                  │
│   "Simplest solution"          "Only what's needed now"     │
│                                                             │
│   Usually aligned! Both favor minimal solutions.            │
│                                                             │
│   Rare conflict:                                            │
│   When the "simplest now" creates tech debt                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Resolution:** Consider known requirements, not speculative ones.

❌ **Too YAGNI (Creates obvious problems):**

```typescript
// Hardcoding values that WILL need to change
const TAX_RATE = 0.1; // "We only have one tax rate now"
// But you KNOW different regions have different rates
```

✅ **Balanced:**

```typescript
// Simple structure that handles known requirement
const TAX_RATES = {
  default: 0.1,
};

function getTaxRate(region = "default"): number {
  return TAX_RATES[region] ?? TAX_RATES.default;
}
```

**Guideline:** YAGNI applies to speculative features, not to handling known edge cases simply.

---

## 4. Decision Framework

### The Priority Order

When principles conflict, use this priority:

```plaintext
┌─────────────────────────────────────────────────────────────┐
│                 PRIORITY ORDER                              │
│                                                             │
│   1. CORRECTNESS    - Does it work?                         │
│          │                                                  │
│          ▼                                                  │
│   2. CLARITY        - Can others understand it?             │
│          │            (KISS)                                │
│          ▼                                                  │
│   3. SIMPLICITY     - Is it as simple as possible?          │
│          │            (KISS + YAGNI)                        │
│          ▼                                                  │
│   4. DRY            - Is knowledge consolidated?            │
│                       (Only after 1-3 are satisfied)        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Quick Decision Guide

| Situation                               | Recommendation                 |
| --------------------------------------- | ------------------------------ |
| Same logic, 2 places, simple to extract | Wait (YAGNI)                   |
| Same logic, 3+ places                   | Extract (DRY)                  |
| Same code, different concepts           | Keep separate (avoid Over-DRY) |
| Extraction adds complexity              | Keep duplication (KISS > DRY)  |
| "Might need this later"                 | Don't build it (YAGNI)         |
| Known requirement, simple solution      | Build it (KISS)                |
| Business rule repeated anywhere         | Extract immediately (DRY)      |
| Configuration/constants                 | DRY immediately                |

---

## 5. Context Matters

### When to Prioritize Each Principle

| Context                   | Priority           | Reason                                  |
| ------------------------- | ------------------ | --------------------------------------- |
| **Startup / MVP**         | YAGNI > KISS > DRY | Speed matters, requirements will change |
| **Established product**   | KISS > DRY > YAGNI | Maintainability matters                 |
| **Public API / Library**  | DRY > KISS > YAGNI | Consistency is critical                 |
| **Team with junior devs** | KISS > YAGNI > DRY | Readability is essential                |
| **Performance-critical**  | Correctness > all  | May need to violate DRY for speed       |

### Team Size Consideration

```plaintext
┌─────────────────────────────────────────────────────────────┐
│              TEAM SIZE IMPACT                               │
│                                                             │
│   Solo Developer:                                           │
│   - More flexibility                                        │
│   - Can handle more complexity (you wrote it)               │
│   - Still prefer KISS for "future you"                      │
│                                                             │
│   Small Team (2-5):                                         │
│   - Communication overhead                                  │
│   - Need clear patterns                                     │
│   - KISS becomes more important                             │
│                                                             │
│   Large Team (10+):                                         │
│   - Consistency is critical                                 │
│   - DRY for shared utilities                                │
│   - Clear boundaries between modules                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. Practical Checklist

Before making a decision, ask yourself:

### For Extraction (DRY)

- [ ] Have I seen this pattern 3+ times?
- [ ] Is it the SAME knowledge, not just similar code?
- [ ] Will the abstraction be simpler than the duplication?
- [ ] Can I name it clearly?

### For Building Features (YAGNI)

- [ ] Is there a real requirement for this?
- [ ] Is someone asking for this NOW?
- [ ] Will it definitely cost more to add later?

### For Simplification (KISS)

- [ ] Can I explain this in one sentence?
- [ ] Can a new team member understand this quickly?
- [ ] Is this the most direct solution?

---

## 7. Summary

```plaintext
┌─────────────────────────────────────────────────────────────┐
│                    KEY TAKEAWAYS                            │
│                                                             │
│   1. Principles are guidelines, not laws                    │
│                                                             │
│   2. Context determines which principle takes priority      │
│                                                             │
│   3. When in doubt:                                         │
│      - Prefer simple over clever (KISS)                     │
│      - Wait for patterns to emerge (Rule of Three)          │
│      - Build only what's needed (YAGNI)                     │
│                                                             │
│   4. The goal is maintainable, changeable code              │
│      - Principles are tools to achieve this                 │
│      - Not ends in themselves                               │
│                                                             │
│   5. "Duplication is far cheaper than the wrong             │
│       abstraction" — Sandi Metz                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 8. References

### Related Principle Files

- [YAGNI](../02-yagni.md) - You Aren't Gonna Need It
- [DRY](../03-dry.md) - Don't Repeat Yourself
- [KISS](../04-kiss.md) - Keep It Simple, Stupid

### External Resources

- [The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction) - Sandi Metz
- [Simple Made Easy](https://www.infoq.com/presentations/Simple-Made-Easy/) - Rich Hickey
- [AHA Programming](https://kentcdodds.com/blog/aha-programming) - Kent C. Dodds

### Books

- "A Philosophy of Software Design" - John Ousterhout
- "The Pragmatic Programmer" - Hunt & Thomas
- "Clean Code" - Robert C. Martin
