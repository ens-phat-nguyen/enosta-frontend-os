---
name: component-design
description: >
  Guide for designing frontend components in a SaaS or large-scale product. Use this skill
  whenever a developer asks about component structure, where to put a component, how to
  reduce coupling between modules, how to handle component variants or composition patterns,
  when to split a component, how to share UI across features, or how to organize growing
  modules. Also trigger for questions like "how do I design this component", "should I use
  props or composition", "my component is getting too big", "where does this component
  belong", "how do I share this between modules", "how do I handle permissions/feature flags
  in components", or any question about component reusability, abstraction timing, or
  state placement. When in doubt about a frontend architecture question, use this skill.
---

# Component Design Skill

A practical guide for designing components in a SaaS or large-scale frontend codebase.
Covers where components live, how they should be structured, and which composition
patterns to use — with decision trees for fast decisions.

---

## The core principle

> **Be deliberate about who owns each decision.**

Every component design problem is really a question of misplaced ownership.
When a component feels hard to work with, it's almost always owning a decision
that belongs somewhere else.

| Decision                                    | Owner                             |
| ------------------------------------------- | --------------------------------- |
| Which parts appear on screen                | Caller / composition root         |
| Shared state between parts                  | Compound component context        |
| Behavior (sort, select, drag)               | Hook — injected by caller         |
| Cross-cutting concerns (permissions, flags) | Provider — ambient context        |
| Core structure and data fetching            | The component itself              |
| What's public vs private                    | `index.ts` — deliberately curated |

---

## Quick reference — the rules

**Always**

- Separate logic (hooks) from rendering (JSX) for anything beyond simple components
- Colocate files that change together inside a component folder
- Keep `index.ts` as the hard public API — only export what other modules genuinely need
- Use slots (ReactNode props) when one module needs to embed another module's component
- Wait for **three usages** before extracting a shared component

**Never**

- Import from inside another module's internals — always go through `index.ts`
- Make a presentational component fetch its own data
- Reach for a global store when lifting state would solve it
- Add a fifth boolean prop — reach for composition instead
- Abstract a pattern on the second usage — wait for the third

**Switch from props to composition when**

- 4+ boolean variant props exist on one component
- The same component is needed by multiple user roles with different parts
- Feature flags control which sections appear
- You're adding a new prop just to handle one new caller's case

---

## The four layers (where components live)

```
routes/      Pages and layouts. Composes modules together. Knows everything.
modules/     Business features. Self-contained with explicit public API.
core/        Project infrastructure: API client, theme, providers, base UI.
shared/      Pure utilities. Zero project dependencies.
```

Dependencies only flow **downward**. `modules/` imports from `core/` and `shared/`.
`shared/` imports from nothing.

| Layer                | Component knows about                          |
| -------------------- | ---------------------------------------------- |
| `core/ui/`           | Design system only. No business domain.        |
| `modules/common/`    | Business domain, but no single feature owns it |
| `modules/<feature>/` | One specific feature                           |
| `routes/`            | How features compose together on a page        |

---

## Decision trees

Use these for fast answers. Full explanations are in the reference files.

### Where does this component live?

```
Is the component domain-agnostic?
(button, input, modal, chart wrapper — no business knowledge)
  └─ YES → core/ui/

Is it business-aware but no single feature owns it?
(UserAvatar, MemberPicker, RoleBadge — used by tasks, notifications, dashboard)
  └─ YES → modules/common/

Does one feature clearly own it, and only that feature uses it?
  └─ YES → modules/<feature>/ internal (not exported from index.ts)

Does one feature own it, but other modules need to use it?
  └─ Do they need the COMPONENT or just its DATA?
      ├─ Just data → export a hook from index.ts
      └─ The component itself
            ├─ They EMBED it in their own page?
            │   └─ Use slots — route injects it, modules don't import each other
            └─ They show a small reference/preview?
                └─ Export from index.ts (TaskMiniPreview, NotificationsBell)
```

### Which composition pattern?

```
Component has variation. Which pattern fits?
                        │
        ┌───────────────┴───────────────┐
   Variation in STRUCTURE?         Variation in BEHAVIOR?
   (different parts appear)        (selection, sorting, drag)
        │                                   │
   Do parts share                      Pattern 3: Hook
   implicit state?                     Extract behavior,
        │                              inject as prop.
   ┌────┴────┐
  YES       NO                    Variation is CROSS-CUTTING?
   │         │                    (permissions, flags, plan tier)
Pattern 1:  Pattern 2:                      │
Compound.   Slots.                    Pattern 4: Provider
Context +   ReactNode                 Wrap the subtree.
dot         as prop.
notation.                         Just DATA / STYLE variation?
                                  (color, label, size)
                                        │
                                   Simple prop. Fine here.
```

### Component feels hard to work with?

```
Too many props (5+ booleans)?
  └─ Switch to composition. Compound or slots.

Hard to reuse?
  └─ Does it fetch its own data?
      ├─ YES → Make it presentational. Caller provides data.
      └─ NO  → Is it doing too many things?
                ├─ YES → Split into compound sub-components.
                └─ NO  → Is logic tangled with rendering?
                          ├─ YES → Extract to a hook file.
                          └─ NO  → It's just big. Colocate into a folder.
```

---

## Reference files

Read these when you need full detail on a topic:

| File                      | Contents                                                       | Read when...                                                  |
| ------------------------- | -------------------------------------------------------------- | ------------------------------------------------------------- |
| `references/patterns.md`  | All four composition patterns with full code examples          | Implementing compound, slots, hook injection, or providers    |
| `references/structure.md` | File/folder conventions, colocation rules, index.ts discipline | Setting up a new component or module                          |
| `references/state.md`     | State placement rules, when to lift vs store vs cache          | Deciding where state lives                                    |
| `references/modules.md`   | Module bloat signals, split strategies, -core pattern          | A module is getting too large                                 |
| `references/examples.md`  | Full real-world example: B2B SaaS placement decisions          | Seeing how all rules apply to a realistic component inventory |
