# Component Structure & File Conventions

---

## The component folder pattern

When a component grows beyond a single file, promote it to a folder.
Everything inside the folder is private — only `index.ts` is public.

```
modules/tasks/
└── components/
    └── task-card/
        ├── index.ts              # Public API — exports TaskCard only
        ├── task-card.tsx         # Composition root, layout only
        ├── task-card-header.tsx  # Internal subcomponent
        ├── task-card-footer.tsx  # Internal subcomponent
        ├── task-card.hooks.ts    # Local hooks — NOT exported
        ├── task-card.utils.ts    # Local helpers — NOT exported
        └── task-card.test.tsx    # Tests live here, not in __tests__/
```

**The rule:** consumers import from the folder, never from internal files.

```ts
// ✅ Correct — through the public API
import { TaskCard } from "modules/tasks/components/task-card";

// ❌ Wrong — reaches into internals
import { TaskCardHeader } from "modules/tasks/components/task-card/task-card-header";
```

Enforce this with `eslint-plugin-boundaries` or `no-restricted-imports`.

---

## Separate logic from rendering

Logic and rendering change for different reasons. Keep them in separate files.

```tsx
// task-card.hooks.ts — no JSX, fully testable without a browser
export function useTaskCard(taskId: string) {
  const task = useTask(taskId);
  const { mutate: updateStatus } = useUpdateTaskStatus();
  const isOverdue = task.dueDate < new Date() && task.status !== "done";
  const canEdit = usePermission("task:edit", task.projectId);

  return { task, isOverdue, canEdit, updateStatus };
}

// task-card.tsx — no business logic, only rendering decisions
export function TaskCard({ taskId }: { taskId: string }) {
  const { task, isOverdue, canEdit, updateStatus } = useTaskCard(taskId);

  return (
    <Card highlight={isOverdue ? "red" : undefined}>
      <TaskCardHeader task={task} />
      {canEdit && <TaskCardFooter onStatusChange={updateStatus} />}
    </Card>
  );
}
```

The hook is unit-testable. The component is visually testable. Neither does the other's job.

**When to create a hooks file:**

- Component has any derived state (computed from raw data)
- Component has any side effects
- Component has more than one `useState`
- Logic would be worth testing independently

---

## The module index.ts contract

`index.ts` is your module's public API. Be deliberate about it.
Everything not exported is private and can change freely.

```ts
// modules/tasks/index.ts

// UI — only what other modules genuinely need
export { TaskCard } from "./components/task-card";
export { TaskMiniPreview } from "./components/task-mini-preview";

// Logic — hooks and types other modules depend on
export { useTask } from "./hooks/use-task";
export type { Task, TaskStatus } from "./types/task.types";

// NOT exported (private — free to change):
// TaskStatusSelect, TaskForm, DueDatePicker, useTaskDragDrop
// TaskCardHeader, TaskCardFooter, task-card internals
```

Ask before exporting: "Does another module actually need this, or am I exporting
it just in case?" Exporting is a commitment. Unexported code can be freely changed.

---

## Colocate what changes together

The colocating rule: if two files always change when the same thing changes,
they should be in the same folder.

```
✅ Colocate these:
- A component and its local hooks
- A component and its direct subcomponents
- A component and its tests
- A feature and its API calls
- A feature and its types

❌ Don't colocate these:
- Shared utilities that multiple components use (→ shared/)
- Types used across modules (→ module types/, not component folder)
- Global state (→ module store/ or core/store/)
```

---

## When to split a file into a folder

Use this to decide when a single file component needs to become a folder:

```
Single file component is fine when:
- Under ~100 lines
- One clear responsibility
- Logic is simple enough to be inline

Promote to folder when:
- Logic is complex enough to extract to a hooks file
- Has internal subcomponents that exist only for this component
- Has local utilities or helpers
- You want to test logic separately from rendering
```

---

## Data fetching placement

| Pattern          | Location                   | Example                                      |
| ---------------- | -------------------------- | -------------------------------------------- |
| Smart/Container  | Module boundary, exported  | `NotificationsFeed` — self-contained widget  |
| Presentational   | Anywhere, usually internal | `NotificationItem` — receives data as props  |
| Shared data hook | Exported from `index.ts`   | `useTask(id)` — other modules read task data |

**The mistake to avoid:** a presentational component that fetches internally.
It looks reusable but secretly couples every caller to your API shape.

```tsx
// ❌ Looks reusable, actually coupled
function UserAvatar({ userId }: { userId: string }) {
  const user = useQuery(["user", userId], fetchUser); // internal fetch
  return <img src={user.avatarUrl} />;
}

// ✅ Truly reusable — caller decides where data comes from
function UserAvatar({ avatarUrl, name }: { avatarUrl: string; name: string }) {
  return <img src={avatarUrl} alt={name} />;
}
```
