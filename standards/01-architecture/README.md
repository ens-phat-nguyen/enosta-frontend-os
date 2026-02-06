# Architecture Overview

This document describes the architectural foundation for our web applications.

---

## Goals

1. **Fast onboarding** - New developers understand the codebase quickly
2. **Long-term maintainability** - Structure scales without accumulating debt

---

## Core Concept

The application is organized into **three layers** with a strict dependency flow:

```plaintext
┌─────────────────────────────────────────┐
│              modules/                   │  Feature code (business logic)
├─────────────────────────────────────────┤
│               core/                     │  Foundation & configuration
├─────────────────────────────────────────┤
│              shared/                    │  Pure utilities (no dependencies)
└─────────────────────────────────────────┘

        ↓ Dependencies flow downward only ↓
```

**The Rule:** Upper layers can import from lower layers. Lower layers cannot import from upper layers.

- `modules/` → can import from `core/` and `shared/`
- `core/` → can import from `shared/` only
- `shared/` → imports from nothing (completely portable)

---

## Layers at a Glance

| Layer | Purpose | Changes | Examples |
| --- | --- | --- | --- |
| **Modules** | Business features | Frequently | `auth`, `dashboard`, `checkout`, `notifications` |
| **Core** | Foundation setup, external integrations | Rarely | Router, API client, theme, UI components |
| **Shared** | Pure utilities, no dependencies | Occasionally | `formatDate()`, `useDebounce()`, `isEmail()` |

> **Detailed documentation:** See [layers/](./layers/) for in-depth explanation of each layer.

---

## Quick Decision Guide

```plaintext
Where does my code belong?

 ┌─ Is it pure utility with NO dependencies?
 │   └─ YES → shared/
 │
 ├─ Is it project setup or external service config?
 │   └─ YES → core/
 │
 └─ Is it tied to business logic or features?
     └─ YES → modules/
```

> **Need more guidance?** See [decisions/](./decisions/) for detailed decision frameworks.

---

## Documentation Map

| Topic | Document | When to read |
| --- | --- | --- |
| **Understanding Layers** | | |
| Core layer | [layers/core.md](./layers/core.md) | Setting up foundation code |
| Shared layer | [layers/shared.md](./layers/shared.md) | Creating reusable utilities |
| Modules layer | [layers/modules.md](./layers/modules.md) | Building features |
| **Patterns & How-tos** | | |
| Barrel exports | [patterns/barrel-exports.md](./patterns/barrel-exports.md) | Defining module public APIs |
| Cross-module dependencies | [patterns/cross-module-deps.md](./patterns/cross-module-deps.md) | When modules need each other |
| **Decision Making** | | |
| Decision framework | [decisions/](./decisions/) | Choosing where code belongs |
