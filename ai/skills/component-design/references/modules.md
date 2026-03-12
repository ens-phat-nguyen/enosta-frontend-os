# Module Structure & Splitting

---

## When a module is too large

Size alone isn't the problem — **incoherence** is.
A module with 30 cohesive components is fine.
A module with 10 components that never relate to each other needs work.

### Warning signals

| Signal                                                      | What it means                                         |
| ----------------------------------------------------------- | ----------------------------------------------------- |
| Components that never import each other                     | Likely separate sub-features hiding inside one module |
| A `utils/` folder with 20 unrelated functions               | Dumping ground, needs sorting                         |
| Different teammates always working in different sub-folders | Ownership boundary = module boundary                  |
| Sub-folders already emerging naturally                      | Module is telling you how to split                    |
| `index.ts` exporting 20+ things                             | Too broad a public API — module doing too much        |
| Types used by only 1–2 components                           | Probably belongs closer to those files                |

**Before splitting**, ask: is this module large because it's doing too many different things,
or because one thing is genuinely complex? Only the first case needs a split.

---

## Strategy 1: Vertical slice by sub-feature

`tasks/` is rarely just "tasks." It's multiple implicit sub-features:

```
modules/
├── task-board/        # Kanban view, drag-drop, column management
├── task-detail/       # Detail modal/page, full editing experience
├── task-list/         # Table/list view, sorting, filtering, bulk actions
├── task-creation/     # Creation flow, templates, quick-add
└── tasks-core/        # Shared types, API, hooks — NO UI (see below)
```

Each sub-feature has its own `index.ts`. What they share moves to `tasks-core/`.

---

## Strategy 2: Extract a -core module for shared logic

When multiple sub-features (or multiple modules) share types, API calls, and hooks
but not UI, extract a `-core` module:

```
modules/
├── tasks-core/
│   ├── index.ts
│   ├── types/
│   │   └── task.types.ts       # Task, TaskStatus, TaskPriority
│   ├── api/
│   │   └── tasks.api.ts        # fetchTask, updateTask, deleteTask
│   └── hooks/
│       └── use-task.ts         # useTask(id), useTaskList()
│
├── task-board/
│   ├── index.ts
│   └── ...                     # imports from tasks-core, owns its UI
│
└── task-detail/
    ├── index.ts
    └── ...                     # imports from tasks-core, owns its UI
```

**`tasks-core` has no UI at all.** Pure logic, types, API.
This is the cleanest way to share domain knowledge without sharing components.

---

## Strategy 3: Component folder before module split

Sometimes the module isn't conceptually large — its components are just complex.
Before splitting the module, split the _components_:

```
modules/tasks/
└── components/
    └── task-card/
        ├── index.ts                  # exports TaskCard only
        ├── task-card.tsx             # layout and composition only
        ├── task-card-header.tsx      # internal
        ├── task-card-footer.tsx      # internal
        └── task-card.hooks.ts        # local hooks, not exported
```

This often eliminates the _feeling_ of bloat without any structural change.
The module's public API stays small. Complexity is contained.

---

## Strategy 4: Enforce index.ts as a gatekeeper

When you can't split yet (deadlines, risk), at minimum make `index.ts` explicit:

```ts
// modules/tasks/index.ts — be deliberate

// Only what other modules genuinely need
export { TaskCard } from "./components/task-card";
export { TaskMiniPreview } from "./components/task-mini-preview";
export { useTask } from "./hooks/use-task";
export type { Task, TaskStatus } from "./types/task.types";

// Everything NOT listed here is private by omission
// TaskStatusSelect, TaskForm, DueDatePicker — not your problem
```

This doesn't fix internal mess but stops it from spreading.
When you eventually split, `index.ts` is already your roadmap.

---

## The evolution over time

Don't start at Phase 3. Earn it by feeling Phase 2 pain in the right places.

```
Phase 1 — early         Phase 2 — growing          Phase 3 — mature
─────────────────       ─────────────────────────   ─────────────────────────
modules/                modules/                    modules/
└── tasks/              └── tasks/                  ├── tasks-core/
    ├── index.ts             ├── index.ts            │   ├── types/
    ├── components/          ├── components/         │   ├── api/
    ├── hooks/               │   ├── board/          │   └── hooks/
    ├── api/                 │   ├── detail/         ├── task-board/
    └── types/               │   └── list/           ├── task-detail/
                             ├── hooks/              ├── task-list/
                             ├── api/                └── task-creation/
                             └── types/
```

---

## Decision: should I split this module?

```
Is the module large?
  └─ NO → Don't split. You're fine.
  └─ YES → Do components inside it naturally cluster into sub-topics?
            (board vs detail vs list vs creation)
              └─ NO → Is it one complex component causing the size?
                        └─ YES → Use component folder strategy (Strategy 3)
                        └─ NO  → Are there shared types/hooks used by 2+ areas?
                                   └─ YES → Extract -core module (Strategy 2)
                                   └─ NO  → Enforce index.ts. Move on.
              └─ YES → Split into sub-feature modules (Strategy 1)
                        Do sub-features share types/hooks/API?
                          └─ YES → Also extract -core (Strategy 2)
                          └─ NO  → Each sub-feature is self-contained. Done.
```
