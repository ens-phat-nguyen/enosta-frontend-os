# State Placement

State should live as close to where it's used as possible.
Only move it up or out when you have a concrete reason to.

---

## The placement ladder

```
1. Component itself (useState)
   └─ UI-only state: open/closed, hover, focus, local form input

2. Lifted to common parent
   └─ Two sibling components need the same value

3. Module-level store (Zustand slice, Context, etc.)
   └─ Multiple components across a feature share it
   └─ State persists across route changes within the feature

4. -core module hook
   └─ Multiple modules read the same data (e.g. current user, workspace)
   └─ Read-only from the consumer's perspective

5. Server cache (React Query, SWR)
   └─ Anything that comes from an API
   └─ Never put server data in a store — it has its own cache
```

---

## Decision: where does this state live?

```
Is it UI-only? (open, hover, selected tab, local input value)
  └─ useState inside the component. Don't lift it.

Do two or more sibling components need it?
  └─ Lift to their common parent. Pass down as props.

Does it need to persist across component unmounts within a feature?
  └─ Module-level store (Zustand slice, or module-scoped Context).

Do multiple modules need to read it?
  └─ Is it server data? → React Query / SWR cache. Not a store.
  └─ Is it client-only? → Exported hook from a -core module.
     (e.g. useCurrentUser, useWorkspace — read-only for consumers)

Is it configuration (feature flags, theme, permissions)?
  └─ Provider — ambient context for a subtree. Not store, not props.
```

---

## The most common mistake

Reaching for a global store the moment two components need the same state.

```tsx
// ❌ Unnecessary global store
// Two components in the same parent need the selected task ID
const useTaskStore = create((set) => ({
  selectedTaskId: null,
  setSelectedTaskId: (id) => set({ selectedTaskId: id }),
}));

// ✅ Just lift it — both components are rendered by the same parent
function TasksPage() {
  const [selectedTaskId, setSelectedTaskId] = useState<string | null>(null);

  return (
    <>
      <TaskList selectedTaskId={selectedTaskId} onSelect={setSelectedTaskId} />
      <TaskDetail taskId={selectedTaskId} />
    </>
  );
}
```

**Try lifting first. Globalize only when lifting becomes genuinely painful.**

Lifting becomes painful when:

- State needs to live above a route boundary
- More than 3–4 levels of prop drilling
- Unrelated components in different subtrees need it

---

## Server state is not application state

Anything from an API belongs in a server cache (React Query, SWR), not a store.

```tsx
// ❌ Don't sync server data into a store
const useTaskStore = create((set) => ({
  tasks: [],
  fetchTasks: async () => {
    const data = await api.getTasks();
    set({ tasks: data });
  },
}));

// ✅ Let React Query manage server state
function useTaskList() {
  return useQuery({
    queryKey: ["tasks"],
    queryFn: api.getTasks,
  });
}
```

Benefits: automatic caching, background refetching, deduplication, loading/error states.
A store can't do any of this without reimplementing it manually.

---

## Behavior state vs data state

| Type                     | Example                           | Where                                  |
| ------------------------ | --------------------------------- | -------------------------------------- |
| UI interaction state     | dropdown open, row hovered        | `useState` in component                |
| Selection / multi-select | which rows are checked            | `useTableSelection` hook, injected     |
| Form state               | field values, validation          | `useForm` (react-hook-form etc.) local |
| Optimistic updates       | temp state before server confirms | React Query `onMutate`                 |
| Feature-wide state       | active project, current view      | Module store                           |
| Cross-module identity    | current user, workspace           | `-core` hook                           |
| Server data              | task list, user profiles          | React Query / SWR                      |
| Config / permissions     | flags, roles, plan                | Provider context                       |
