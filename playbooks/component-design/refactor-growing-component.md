# Refactor a Growing Component

Diagnose what's wrong with a hard-to-work-with component and fix it step by step — without breaking anything.

---

## Overview

This playbook covers the workflow for cleaning up a component that has grown painful to work with. By the end you'll have:

- A clear diagnosis of what's actually wrong
- Logic extracted into a hook
- Rendering split into the right sub-components
- Props reduced through composition where needed
- All existing behaviour preserved

**Time:** 30–90 min depending on component size

---

## Prerequisites

- Familiar with the [Component Patterns standard](../../standards/09-component-patterns/README.md)
- Have a component that feels hard to change, test, or reuse
- Existing tests (even partial) are helpful — you'll use them as a safety net

---

## Steps

### Step 1 — Diagnose the problem

Don't refactor blindly. Run the component through this checklist first.

| Symptom                           | Likely cause                                           |
| --------------------------------- | ------------------------------------------------------ |
| Hard to test                      | Logic is tangled with rendering                        |
| Hard to reuse                     | It fetches its own data (presentational + smart mixed) |
| Too many props, half are booleans | Absorbing decisions that belong to callers             |
| Difficult to add a new variant    | Missing composition — use slots or compound pattern    |
| File is 300+ lines and growing    | Sub-components need to be extracted                    |
| Changing one thing breaks another | Too many responsibilities in one place                 |

Pick the **one biggest problem** and fix only that. Resist fixing everything at once.

✓ **Checkpoint:** You can name the problem in one sentence (e.g. "the hook logic is inside the component body" or "there are 8 boolean props").

---

### Step 2 — Add a safety net before touching anything

If there are no tests, write a minimal smoke test now. It doesn't need to be thorough — just enough to know you haven't broken the main behaviour.

```tsx
// task-form.test.tsx (minimal, before refactor)
it("renders without crashing", () => {
  render(<TaskForm taskId="task-1" />);
  expect(screen.getByRole("form")).toBeInTheDocument();
});

it("submits the form", async () => {
  render(<TaskForm taskId="task-1" />);
  await userEvent.click(screen.getByRole("button", { name: /save/i }));
  expect(mockOnSave).toHaveBeenCalled();
});
```

✓ **Checkpoint:** At least one test exists and passes before you change anything.

---

### Step 3 — Extract logic into a hook

If business logic, data fetching, or derived state lives inside the component body, move it to `<component-name>.hooks.ts`.

**Before:**

```tsx
// task-form.tsx — logic and rendering mixed
export function TaskForm({ taskId }: { taskId: string }) {
  const { data: task } = useQuery({
    queryKey: ["task", taskId],
    queryFn: () => fetchTask(taskId),
  });
  const { mutate: updateTask } = useMutation({ mutationFn: saveTask });
  const [isDirty, setIsDirty] = useState(false);
  const isOverdue = task?.dueDate < new Date() && task?.status !== "done";
  const canEdit = usePermission("task:edit", task?.projectId);

  const handleSubmit = (values: TaskFormValues) => {
    updateTask(values, { onSuccess: () => setIsDirty(false) });
  };

  return (
    <form onSubmit={handleSubmit}>
      {isOverdue && <OverdueBanner />}
      {/* ... */}
    </form>
  );
}
```

**After — hook takes the logic:**

```tsx
// task-form.hooks.ts
export function useTaskForm(taskId: string) {
  const { data: task } = useQuery({
    queryKey: ["task", taskId],
    queryFn: () => fetchTask(taskId),
  });
  const { mutate: updateTask } = useMutation({ mutationFn: saveTask });
  const [isDirty, setIsDirty] = useState(false);
  const isOverdue =
    (task?.dueDate ?? new Date()) < new Date() && task?.status !== "done";
  const canEdit = usePermission("task:edit", task?.projectId);

  const handleSubmit = (values: TaskFormValues) => {
    updateTask(values, { onSuccess: () => setIsDirty(false) });
  };

  return { task, isOverdue, canEdit, isDirty, handleSubmit };
}

// task-form.tsx — only rendering
export function TaskForm({ taskId }: { taskId: string }) {
  const { task, isOverdue, canEdit, handleSubmit } = useTaskForm(taskId);

  return (
    <form onSubmit={handleSubmit}>
      {isOverdue && <OverdueBanner />}
      {/* ... */}
    </form>
  );
}
```

✓ **Checkpoint:** Component file contains no `useQuery`, `useMutation`, or business logic. Tests still pass.

---

### Step 4 — Extract sub-components for large render blocks

If the JSX is long and contains clearly separate sections, extract each section into its own file in the same folder.

**Rule:** extract when a section:

- Is 30+ lines of JSX and stands alone conceptually
- Has its own local state
- Would benefit from being tested independently

```tsx
// Before: one large render
export function TaskDetail({ taskId }: { taskId: string }) {
  const { task, comments, activity } = useTaskDetail(taskId);

  return (
    <div>
      <div className="header">          {/* 40 lines */}
        <h1>{task.title}</h1>
        {/* ... */}
      </div>
      <div className="comments">       {/* 60 lines */}
        {comments.map(c => /* ... */)}
      </div>
      <div className="activity">       {/* 50 lines */}
        {activity.map(a => /* ... */)}
      </div>
    </div>
  );
}

// After: sections extracted to internal files
// task-detail-header.tsx, task-detail-comments.tsx, task-detail-activity.tsx
export function TaskDetail({ taskId }: { taskId: string }) {
  const { task, comments, activity } = useTaskDetail(taskId);

  return (
    <div>
      <TaskDetailHeader task={task} />
      <TaskDetailComments comments={comments} />
      <TaskDetailActivity activity={activity} />
    </div>
  );
}
```

Sub-components live in the same folder. They are **not exported** from `index.ts`.

✓ **Checkpoint:** Component file is readable in one screen. Sub-components are in sibling files.

---

### Step 5 — Replace boolean props with composition

If the component accumulates boolean props to handle variants, switch to a composition pattern.

**Warning signs:**

```tsx
// Too many booleans — the component is absorbing caller decisions
<TaskCard
  showAssignee={isAdminView}
  showDueDate={!isCompact}
  showActions={canEdit}
  isSelected={selectedIds.has(task.id)}
  variant="compact"
/>
```

**Fix with compound components** when parts share state:

```tsx
// Callers compose only what they need
// Guest
<TaskCard taskId={id}>
  <TaskCard.Header />
</TaskCard>

// Admin
<TaskCard taskId={id}>
  <TaskCard.Header />
  <TaskCard.Assignee />
  <TaskCard.Actions>
    <DeleteTaskButton taskId={id} />
  </TaskCard.Actions>
</TaskCard>
```

**Fix with slots** when whole sections vary:

```tsx
<TaskCard
  taskId={id}
  footer={canEdit ? <TaskCardActions taskId={id} /> : null}
/>
```

Choose the pattern using the [decision tree in the Component Patterns standard](../../standards/09-component-patterns/README.md#decision-trees).

✓ **Checkpoint:** No more than 5–7 props. No boolean props that control which sub-sections appear.

---

### Step 6 — Verify and clean up

Run the full test suite. Then do a final review of the component:

- [ ] Component file has no business logic or data fetching
- [ ] Hook file has no JSX
- [ ] `index.ts` only exports the public API
- [ ] Sub-components are not exported from `index.ts`
- [ ] No cross-module direct imports (always go through `index.ts`)
- [ ] All tests pass

✓ **Checkpoint:** The checklist above is fully green.

---

## Troubleshooting

**"I started refactoring and now everything is broken."**
Stop and revert. Refactor one thing at a time: extract the hook first and verify tests pass, then extract sub-components, then address props. Don't do all three in one step.

**"I'm not sure what counts as business logic vs rendering."**
Business logic: anything that could be true even without a UI — calculations, permission checks, API calls, derived state. Rendering: anything that only makes sense in a React component — JSX, className, event handler wiring.

**"The hook is still too big after extraction."**
A hook that does six things at once has the same problem as the component did. Split it by concern: `useTaskFormData`, `useTaskFormPermissions`, `useTaskFormSubmit`, then compose in the main hook.

**"Switching to compound components is a big API change and will break callers."**
Yes — do it in two steps. First add the compound API as an alternative (both work). Then update all callers in a follow-up PR. Then remove the old API.

---

## Related Resources

- [Component Patterns Standard](../../standards/09-component-patterns/README.md) — patterns, decision trees, rules
- [Build a Feature Component](./build-feature-component.md) — the right structure from the start
- [Extract a Shared Component](./extract-shared-component.md) — when the component needs to move to `modules/common/`
