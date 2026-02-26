# Development Principles — Cheatsheet

> Principles are tools to help you think, not rules to follow blindly.

---

## Quick Reference

| # | Principle | One-liner | Ask before coding |
|---|-----------|-----------|-------------------|
| 01 | [Interface-First](./01-interface-first.md) | Design contracts before implementation | "What are the inputs/outputs?" |
| 02 | [YAGNI](./02-yagni.md) | Only build what's needed RIGHT NOW | "Is there a requirement for this?" |
| 03 | [DRY](./03-dry.md) | Each knowledge exists in one place only | "Is this the same knowledge or just similar code?" |
| 04 | [KISS](./04-kiss.md) | Choose the simplest correct solution | "Can a junior dev understand this in 5 minutes?" |

---

## When Principles Conflict

### DRY vs KISS

> Prefer simple duplication over complex abstraction.

If your abstraction needs many parameters or conditionals to handle all cases, the duplication was better.

### DRY vs YAGNI — Rule of Three

> 1st time → Just write it. 2nd time → Note it, keep separate. 3rd time → Extract.

Two occurrences might be coincidence. Three confirm a pattern.

### Priority Order

When in doubt, follow this order:

1. **Correctness** — Does it work?
2. **Clarity** — Can others understand it? (KISS)
3. **Simplicity** — Is it as simple as possible? (KISS + YAGNI)
4. **No duplication** — Is knowledge consolidated? (DRY, only after 1-3 are satisfied)

### Quick Decision Guide

| Situation | Do this |
|-----------|---------|
| Same logic, 2 places, simple to extract | Wait (YAGNI) |
| Same logic, 3+ places | Extract (DRY) |
| Same code, different concepts | Keep separate (avoid Over-DRY) |
| Extraction adds complexity | Keep duplication (KISS > DRY) |
| "Might need this later" | Don't build it (YAGNI) |
| Business rule repeated anywhere | Extract immediately (DRY) |

### Context Matters

| Context | Priority | Reason |
|---------|----------|--------|
| Startup / MVP | YAGNI > KISS > DRY | Speed matters, requirements will change |
| Established product | KISS > DRY > YAGNI | Maintainability matters |
| Public API / Library | DRY > KISS > YAGNI | Consistency is critical |
| Team with junior devs | KISS > YAGNI > DRY | Readability is essential |

---

## Roadmap

Upcoming principles to be documented:

- [ ] Single Responsibility
- [ ] Separation of Concerns
- [ ] Fail Fast
- [ ] Explicit over Implicit
- [ ] Composition over Inheritance
