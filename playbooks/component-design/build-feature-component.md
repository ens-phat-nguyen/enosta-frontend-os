# Build a New Feature Component

Walk through building a well-structured feature component from scratch — from deciding where it lives to wiring it into a page.

---

## Overview

This playbook covers the full workflow for creating a new component in a feature module. By the end you'll have:

- A correctly placed component with the right file structure
- Logic separated into a hook
- A clean public API via `index.ts`
- A wired-up test file

**Time:** 20–40 min depending on complexity

---

## Prerequisites

- Familiar with the [Component Patterns standard](../../standards/09-component-patterns/README.md)
- Know which feature module you're working in (e.g., `modules/tasks/`)
- Have a ticket or requirement to work from

---

## Steps

### Step 1 — Decide where the component lives

Before creating any files, run the placement decision:

```text
Does the component know about this app's domain?
├── NO  → core/ui/          (pure design system, no business knowledge)
└── YES → Is there ONE module that clearly owns it?
           ├── NO  → modules/common/    (shared business UI, e.g. UserAvatar)
           └── YES → modules/<feature>/ (internal — not exported unless needed)
```

✓ **Checkpoint:** You can name the folder path before moving on.

---

### Step 2 — Create the component folder

Create one folder per component. All files for that component live inside it.

```bash
mkdir -p modules/<feature>/components/<component-name>
```

Create the four standard files:

```bash
touch modules/<feature>/components/<component-name>/index.ts
touch modules/<feature>/components/<component-name>/<component-name>.tsx
touch modules/<feature>/components/<component-name>/<component-name>.hooks.ts
touch modules/<feature>/components/<component-name>/<component-name>.test.tsx
```

**Example** for a `TaskCard` inside `modules/tasks`:

```text
modules/tasks/
└── components/
    └── task-card/
        ├── index.ts
        ├── task-card.tsx
        ├── task-card.hooks.ts
        └── task-card.test.tsx
```

Add sub-components only when a single file gets unwieldy (200+ lines of JSX). Name them `<component-name>-<part>.tsx`, e.g. `task-card-header.tsx`. They are never exported from `index.ts`.

✓ **Checkpoint:** Four files exist. No logic or JSX yet.

---

### Step 3 — Define the props interface

Start with the contract, not the implementation. Open `<component-name>.tsx` and write the interface first.

```tsx
// task-card.tsx

interface TaskCardProps {
  taskId: string;
}
```

Ask yourself:

- Is this component **presentational** (caller passes data) or **smart** (fetches its own data)?
- If presentational, what exact data does the caller need to provide?
- Are there more than 5–7 props? If yes, consider composition instead.

**Presentational example:**

```tsx
interface TaskCardProps {
  title: string;
  assigneeName: string;
  dueDate: Date;
  status: TaskStatus;
  onEdit: () => void;
}
```

**Smart example** (fetches its own data — good for self-contained feature widgets):

```tsx
interface TaskCardProps {
  taskId: string; // everything else comes from the hook
}
```

✓ **Checkpoint:** Props interface is written. No implementation yet.

---

### Step 4 — Implement the hook

Open `<component-name>.hooks.ts`. Write all data fetching, derived state, and event handlers here. No JSX.

```tsx
// task-card.hooks.ts
import { useTask } from "../hooks/use-task";
import { useUpdateTaskStatus } from "../hooks/use-update-task-status";
import { usePermission } from "modules/auth";

export function useTaskCard(taskId: string) {
  const task = useTask(taskId);
  const { mutate: updateStatus } = useUpdateTaskStatus();
  const isOverdue = task.dueDate < new Date() && task.status !== "done";
  const canEdit = usePermission("task:edit", task.projectId);

  return { task, isOverdue, canEdit, updateStatus };
}
```

Rules for the hook file:

- No JSX, no imports from React DOM
- Only returns what the component actually needs
- Should be fully unit-testable without rendering anything

✓ **Checkpoint:** Hook file is complete. Run it mentally: given a `taskId`, does it return everything the UI needs?

---

### Step 5 — Implement the component

Open `<component-name>.tsx`. Use the hook, render the result. No business logic here.

```tsx
// task-card.tsx
import { useTaskCard } from "./task-card.hooks";
import { Card } from "core/ui/card";
import { TaskCardHeader } from "./task-card-header";
import { TaskCardFooter } from "./task-card-footer";

export function TaskCard({ taskId }: TaskCardProps) {
  const { task, isOverdue, canEdit, updateStatus } = useTaskCard(taskId);

  return (
    <Card highlight={isOverdue ? "red" : undefined}>
      <TaskCardHeader task={task} />
      {canEdit && <TaskCardFooter onStatusChange={updateStatus} />}
    </Card>
  );
}
```

Rules for the component file:

- Calls the hook, spreads results into JSX
- Rendering decisions only — no API calls, no business logic
- If JSX goes beyond ~150 lines, extract sub-components into separate files in the same folder

✓ **Checkpoint:** Component renders. Does it contain any `useQuery`, `fetch`, or business logic? If yes, move it to the hook.

---

### Step 6 — Set the public API

Open `index.ts`. Export only what other parts of the codebase genuinely need.

```ts
// index.ts
export { TaskCard } from "./task-card";
// Do NOT export TaskCardHeader, TaskCardFooter, useTaskCard — these are internal
```

If other modules need a hook but not the component, export the hook too:

```ts
export { TaskCard } from "./task-card";
export { useTaskCard } from "./task-card.hooks"; // only if genuinely needed externally
```

✓ **Checkpoint:** `index.ts` exists and exports exactly one thing (or a deliberate few).

---

### Step 7 — Write the tests

Open `<component-name>.test.tsx`. Test the hook and the component separately.

**Test the hook in isolation:**

```tsx
// task-card.hooks.test.ts (or inside task-card.test.tsx)
import { renderHook } from "@testing-library/react";
import { useTaskCard } from "./task-card.hooks";

describe("useTaskCard", () => {
  it("marks task as overdue when dueDate is in the past and status is not done", () => {
    // mock useTask to return a past dueDate
    const { result } = renderHook(() => useTaskCard("task-1"));
    expect(result.current.isOverdue).toBe(true);
  });
});
```

**Test the component renders correctly:**

```tsx
import { render, screen } from "@testing-library/react";
import { TaskCard } from "./task-card";

describe("TaskCard", () => {
  it("renders the task title", () => {
    render(<TaskCard taskId="task-1" />);
    expect(screen.getByText("Fix login bug")).toBeInTheDocument();
  });

  it("hides edit controls when user cannot edit", () => {
    // mock usePermission to return false
    render(<TaskCard taskId="task-1" />);
    expect(
      screen.queryByRole("button", { name: /edit/i }),
    ).not.toBeInTheDocument();
  });
});
```

Aim for:

- One test per meaningful behaviour, not per line of code
- Mock at the hook level, not deep inside fetch calls
- No snapshot tests for logic verification

✓ **Checkpoint:** Tests cover the main behaviours. All tests pass.

---

### Step 8 — Wire it into the parent

Import from `index.ts`, never from internal files.

```tsx
// ✅ Correct — goes through the public API
import { TaskCard } from "modules/tasks/components/task-card";

// ❌ Wrong — reaches into internals
import { TaskCard } from "modules/tasks/components/task-card/task-card";
```

If the component needs to appear in a route that's composed of multiple modules, the route (`routes/`) does the composition — modules do not import each other.

```tsx
// routes/project/page.tsx
import { TaskBoard } from "modules/task-board";
import { ProjectHeader } from "modules/projects";

export function ProjectPage() {
  return (
    <>
      <ProjectHeader projectId={projectId} />
      <TaskBoard projectId={projectId} />
    </>
  );
}
```

✓ **Checkpoint:** The component renders in context. No cross-module imports between feature modules.

---

## Troubleshooting

**"I don't know if it should be smart or presentational."**
Start presentational. If the same data needs to come from three different API calls in three different contexts, make it smart. If callers always have the data already, keep it presentational.

**"My hook is getting huge."**
Split by concern. A `useTaskCard` should not also handle pagination, bulk selection, and drag-drop. Extract each behaviour into its own hook and compose in the component.

**"I'm not sure where the boundary of the component is."**
Apply the test: can you explain what it does in one sentence without using "and"? If not, it's doing too much.

**"I need to reuse this in another module now."**
Check the rule of 3 first — is it genuinely used in three places? If yes, move it to `modules/common/` and update the import in both call sites. See the [Extract a Shared Component playbook](./extract-shared-component.md) when it's ready.

---

## Related Resources

- [Component Patterns Standard](../../standards/09-component-patterns/README.md) — the full reference for all patterns and decision trees
- [Architecture Layers](../../standards/01-architecture/reference/layers.md) — what can import what
- [Placing Code](../../standards/01-architecture/guides/placing-code.md) — broader guide on where code belongs
