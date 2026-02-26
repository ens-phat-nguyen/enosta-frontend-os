# KISS (Keep It Simple, Stupid)

> TL;DR: Always choose the simplest solution that solves the problem correctly. Simple ≠ Easy.

---

## Checklist

Before writing or reviewing code, verify:

- [ ] **Explain** — Can I explain this solution in one sentence?
- [ ] **Necessary** — Is every part of this code actually needed?
- [ ] **Readable** — Can a junior developer understand this in 5 minutes?
- [ ] **Direct** — Am I solving the problem directly, without extra layers?
- [ ] **Testable** — Can I easily write tests for this?

---

## Red Flags

- More than 2 levels of abstraction for a simple task
- Class/interface hierarchy when a function would do
- "Clever" one-liners that need comments to explain
- Custom query builders wrapping an already-good ORM
- Config objects with 10+ options when 2-3 suffice
- Design patterns applied where they add no value

---

## Simple vs Easy

- **Simple** — Few moving parts, clear responsibilities, minimal dependencies. Opposite: complex.
- **Easy** — Familiar, quick to start, low learning curve. Opposite: hard.

KISS is about **simple**, not necessarily easy. Sometimes simple solutions require effort to design.

---

## Examples

### Over-Abstracted Code

```typescript
// Bad: 5 classes for getting a full name
interface DataProcessor<T, R> { process(data: T): R }
interface DataValidator<T> { validate(data: T): boolean }
interface DataTransformer<T, R> { transform(data: T): R }

class UserNameProcessor implements DataProcessor<User, string> {
  constructor(
    private validator: DataValidator<User>,
    private transformer: DataTransformer<User, string>
  ) {}
  process(user: User): string {
    if (!this.validator.validate(user)) throw new Error('Invalid user')
    return this.transformer.transform(user)
  }
}
// + UserValidator class + UserNameTransformer class...

// Good: one function
function getFullName(user: User): string {
  if (!user.firstName || !user.lastName) {
    throw new Error('Invalid user: name is required')
  }
  return `${user.firstName} ${user.lastName}`
}
```

### Clever vs Clear

```typescript
// Bad: clever one-liner
const result = data.reduce((a, x) => (x.active && x.score > 50 ? [...a, { ...x, rank: a.length + 1 }] : a), [])

// Good: clear steps
const activeHighScorers = data.filter(item => item.active && item.score > 50)
const rankedResults = activeHighScorers.map((item, index) => ({
  ...item,
  rank: index + 1,
}))
```

### Config Over-Engineering

```tsx
// Bad: configurable everything
const buttonConfig = {
  styling: { variant: 'primary', size: 'medium', rounded: 'md', shadow: 'sm', animation: 'none' },
  behavior: { debounce: 300, preventDoubleClick: true, loadingIndicator: 'spinner' },
  accessibility: { ariaLabel: 'Submit', tabIndex: 0, focusRing: 'default' },
  analytics: { trackClicks: true, eventName: 'button_click' },
}

// Good: sensible defaults
<Button type="submit" variant="primary" loading={isSubmitting}>
  Submit
</Button>
```

---

## Common Anti-Patterns

| Anti-Pattern | Solution |
|-------------|----------|
| Premature Abstraction | Wait for the third occurrence |
| Framework Fever | Use vanilla solutions when possible |
| Config Overload | Use sensible defaults |
| Inheritance Abuse | Prefer composition |
| Design Pattern Obsession | Use patterns only when they simplify |

---

## References

- Rich Hickey — [Simple Made Easy](https://www.infoq.com/presentations/Simple-Made-Easy/)
- "A Philosophy of Software Design" — John Ousterhout
- "Clean Code" — Robert C. Martin
