# Architecture

This document describes the architectural foundation for our web applications.

**Goals:** Fast onboarding. Long-term maintainability.

---

## Layers

The application is organized into **four layers** with a strict downward dependency flow:

```
┌─────────────────────────────────────────┐
│              routes/                    │  Routing (file-based or code-based)
├─────────────────────────────────────────┤
│             modules/                    │  Business features
├─────────────────────────────────────────┤
│               core/                     │  Project infrastructure
├─────────────────────────────────────────┤
│              shared/                    │  Portable utilities
└─────────────────────────────────────────┘

          ↓ Dependencies flow downward ↓
```

| Layer      | Purpose                         | Changes                    |
| ---------- | ------------------------------- | -------------------------- |
| `routes/`  | Page routing and layouts        | When adding/changing pages |
| `modules/` | Business logic and features     | Frequently                 |
| `core/`    | Project-specific infrastructure | Rarely                     |
| `shared/`  | Pure, portable utilities        | Occasionally               |

---

## Documentation

| Document                                            | Use when                               |
| --------------------------------------------------- | -------------------------------------- |
| **Reference**                                       |                                        |
| [Layers](./reference/layers.md)                     | Looking up layer specs and rules       |
| [Module Structure](./reference/module-structure.md) | Structuring a module or its public API |
| [Dependency Rules](./reference/dependency-rules.md) | Checking what can import what          |
| **Guides**                                          |                                        |
| [Placing Code](./guides/placing-code.md)            | Deciding where new code belongs        |
| [Splitting Modules](./guides/splitting-modules.md)  | A module is getting too large          |
| **Examples**                                        |                                        |
| [React + Vite](./examples/react.md)                 | Seeing the architecture in practice    |
