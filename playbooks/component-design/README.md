# Component Design

> This content has moved.

The component design guide has been merged into the standards reference:

**[standards/09-component-patterns/README.md](../../standards/09-component-patterns/README.md)**

That document covers everything that was here — the four layers, the five key concerns, file structure, composition patterns, decision trees, and where components belong — plus the full composition pattern catalog from the standards.

---

## Playbooks in this folder

- [Build a Feature Component](./build-feature-component.md) — folder setup → hook → component → tests → wiring
- [Refactor a Growing Component](./refactor-growing-component.md) — diagnose → extract hook → split sub-components → reduce props
- [Extract a Shared Component](./extract-shared-component.md) — validate readiness → design API → move to `modules/common/` → update callers
