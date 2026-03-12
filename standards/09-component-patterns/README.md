# Component Patterns & Composition

> Be deliberate about who owns each decision.

---

## Table of Contents

- [Why This Matters](#why-this-matters)
- [The Core Question](#the-core-question)
- [Foundational Principles](#foundational-principles)
- [Quick Reference](#quick-reference)
- [The Four Layers](#the-four-layers)
- [Key Design Concerns](#key-design-concerns)
  - [1. Responsibility](#1-what-is-this-component-responsible-for)
  - [2. Data Fetching](#2-who-fetches-the-data)
  - [3. Props Count](#3-how-many-props-is-too-many)
  - [4. State Placement](#4-where-does-state-live)
  - [5. Abstraction Timing](#5-are-you-abstracting-too-early)
- [File Structure](#file-structure)
- [Separate Logic from Rendering](#separate-logic-from-rendering)
- [Composition Patterns](#composition-patterns)
  - [Pattern 1: Smart / Container vs Presentational](#pattern-1-smart--container-vs-presentational)
  - [Pattern 2: Compound Components](#pattern-2-compound-components)
  - [Pattern 3: Slot Pattern](#pattern-3-slot-pattern)
  - [Pattern 4: Hook Composition](#pattern-4-hook-composition-behavior-injection)
  - [Pattern 5: Provider](#pattern-5-provider-cross-cutting-concerns)
  - [Pattern 6: Render Props](#pattern-6-render-props)
- [Prop Patterns](#prop-patterns)
- [Performance Patterns](#performance-patterns)
- [Where Does a Component Belong?](#where-does-a-component-belong)
- [When a Module Gets Too Large](#when-a-module-gets-too-large)
- [Decision Trees](#decision-trees)
- [Related Resources](#related-resources)

---

## Why This Matters

As a product grows, the frontend gets harder to work with. New features slow down. Changing one thing breaks another. The same logic appears in five different places.

Most of the time, this isn't a logic problem — it's a **component design problem**.

Bad component design looks like this:

- You need to change a button label, but it's buried inside a 400-line component that also fetches data, manages 3 different layouts, and handles permissions
- You want to reuse a component, but it only works in one specific context because it fetches its own data in a very specific way
- A simple UI change requires touching 8 files because the same pattern was copied and pasted everywhere

Good component design prevents all of this. It's about being **clear about who owns what**.

---

## The Core Question

Before writing any component, ask:

> **"What decisions does this component own, and what decisions belong to whoever uses it?"**

A component that owns too many decisions becomes hard to reuse. A component that owns too few forces every caller to repeat the same logic.

| Decision                                    | Owner                             |
| ------------------------------------------- | --------------------------------- |
| Which parts appear on screen                | Caller / composition root         |
| Shared state between parts                  | Compound component context        |
| Behavior (sort, select, drag)               | Hook — injected by caller         |
| Cross-cutting concerns (permissions, flags) | Provider — ambient context        |
| Core structure and data fetching            | The component itself              |
| What's public vs private                    | `index.ts` — deliberately curated |

---

## Foundational Principles

**Must Read:** [Development Principles](../00-development-principles/README.md)

### Interface-First Thinking

Design component contracts (props, events) before implementation. Think about how it will be used, not how it will be built.

### KISS

Smaller, focused components are easier to test and reuse. If explaining a component requires a paragraph, it does too much.

### DRY

Extract common patterns into reusable components — but only once you've seen the pattern three times (see [Abstraction Timing](#5-are-you-abstracting-too-early)).

### YAGNI

Don't make components "flexible" for features you don't have yet. Build for the current requirements, not hypothetical ones.

---

## Quick Reference

### Always

- Separate logic (hooks) from rendering (JSX) for anything beyond trivial components
- Colocate files that change together inside a component folder
- Keep `index.ts` as the hard public API — only export what other modules genuinely need
- Use slots (`ReactNode` props) when one module needs to embed another module's component
- Wait for **three usages** before extracting a shared component

### Never

- Import from inside another module's internals — always go through `index.ts`
- Make a presentational component fetch its own data
- Reach for a global store when lifting state would solve it
- Add a fifth boolean prop — reach for composition instead
- Abstract a pattern after two usages — wait for the third

### Switch from props to composition when

- The component has 5+ props and half are booleans
- Different callers need to show/hide different sub-sections
- The variation is behavioral (selection, sorting, drag-drop)
- You find yourself adding `variant="X"` enums to handle new contexts

---

## The Four Layers

Components live in different layers depending on what they know about.

```text
routes/          Pages and layouts. Composes modules together.
modules/         Business features (tasks, billing, notifications...)
core/            Project infrastructure (API client, theme, providers...)
shared/          Pure utilities with no business knowledge
```

**The rule:** dependencies only flow downward. `modules/` can import from `core/` and `shared/`. `shared/` imports from nothing.

**Where a component lives tells you what it's allowed to know:**

| Layer                | Component knows about                          |
| -------------------- | ---------------------------------------------- |
| `core/ui/`           | Design system only. No business domain.        |
| `modules/common/`    | Business domain, but no single feature owns it |
| `modules/<feature>/` | One specific feature                           |
| `routes/`            | How features compose together on a page        |

---

## Key Design Concerns

Answer these five questions for every component you write.

### 1. What is this component responsible for?

A component should do one thing at the right level of abstraction.

```text
Too narrow                              Too broad
────────────────────────────────────────────────────────────────
<UserAvatarImageTag />                  <UserProfileWithEditModal
  just renders an <img>                   AndNotificationPrefs
  caller has to wire everything            AndBillingStatus />

Every caller duplicates the logic.      Impossible to reuse.
                                        Changing one thing risks breaking another.
```

**The test:** if you have to read the implementation to know how to use a component, the abstraction is wrong.

---

### 2. Who fetches the data?

This is where most coupling comes from. There are three valid patterns. Accidentally mixing them is the most common mistake.

| Pattern                   | Who fetches            | Who renders           | When to use                     |
| ------------------------- | ---------------------- | --------------------- | ------------------------------- |
| **Smart / Container**     | The component itself   | The component         | Self-contained feature widget   |
| **Presentational / Dumb** | The caller passes data | The component         | Reusable UI used in many places |
| **Composite**             | Parent coordinates     | Children render parts | Complex layouts                 |

**The mistake to avoid:** a presentational component that also fetches. It looks reusable but secretly couples every caller to your API.

```tsx
// ❌ Looks reusable, but secretly tied to your API
function UserAvatar({ userId }: { userId: string }) {
  const user = useQuery(["user", userId], fetchUser); // fetches internally
  return <img src={user.avatarUrl} />;
}

// ✅ Truly reusable — caller decides where the data comes from
function UserAvatar({ avatarUrl, name }: { avatarUrl: string; name: string }) {
  return <img src={avatarUrl} alt={name} />;
}
```

---

### 3. How many props is too many?

Props are your public API. Every prop you add is a commitment to maintain.

```tsx
// This is a warning sign
<TaskCard
  task={task}
  onEdit={handleEdit}
  onDelete={handleDelete}
  showAssignee={true}
  showDueDate={false}
  isSelected={false}
  isLoading={false}
  variant="compact"
  theme="dark"
/>
```

When you see this, the component is absorbing decisions that belong to its callers. The fix is composition — let callers assemble what they need instead of configuring everything through props.

**Rule of thumb:** if a component has more than 5–7 props and half of them are booleans, switch to a composition pattern.

---

### 4. Where does state live?

State should live as close to where it's used as possible.

| State type                      | Where it lives                   |
| ------------------------------- | -------------------------------- |
| UI only (dropdown open/closed)  | Component itself (`useState`)    |
| Shared between a few components | Lifted to common parent          |
| Shared across a whole feature   | Module-level store               |
| Shared across multiple modules  | Extracted hook in `-core` module |
| Server data                     | React Query / cache — not store  |

**The mistake:** reaching for a global store the moment two components need the same data. Try lifting state first. Globalize only when lifting becomes genuinely painful.

---

### 5. Are you abstracting too early?

Don't extract a shared component until you've seen the pattern in **three real, concrete places**.

```text
1st usage → write it inline
2nd usage → duplicate it (yes, really — you don't know its real shape yet)
3rd usage → now you see what varies and what's stable → extract it
```

Two usages might be a coincidence. Three reveal the real pattern. Abstracting after two creates components shaped for those two cases, which then get bent out of shape by every case that follows.

---

## File Structure

Colocate files that change together inside the same component folder.

```text
modules/tasks/
└── components/
    └── task-card/
        ├── index.ts              # exports TaskCard only — this is the public API
        ├── task-card.tsx         # composition root, layout only
        ├── task-card-header.tsx  # internal subcomponent
        ├── task-card-footer.tsx  # internal subcomponent
        ├── task-card.hooks.ts    # local hooks — not exported
        ├── task-card.utils.ts    # local helpers — not exported
        └── task-card.test.tsx    # tests live here, not in __tests__/
```

**Only `index.ts` is public.** Everything else is private. Consumers only ever import from the folder, never from internal files.

```ts
// ✅ correct
import { TaskCard } from "modules/tasks/components/task-card";

// ❌ wrong — reaches into internals
import { TaskCardHeader } from "modules/tasks/components/task-card/task-card-header";
```

### Barrel exports

```typescript
// index.ts — only export what other modules genuinely need
export { TaskCard } from "./task-card";
export { TaskList } from "./task-list";
export { useTaskById } from "./hooks/use-task-by-id";
export type { Task, TaskStatus } from "./types";
```

---

## Separate Logic from Rendering

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

The hook is unit-testable in isolation. The component is visually testable. Neither does the other's job.

---

## Composition Patterns

In a SaaS product, components face a particular combination of pressures: multiple user roles, feature flags and plan tiers, dense data-rich UIs, and rapid iteration where variants multiply faster than you refactor.

A prop-based approach collapses under this weight. Composition is what keeps it manageable. Use these patterns together.

---

### Pattern 1: Smart / Container vs Presentational

**Use when:** you need to separate data-fetching from rendering for testability and reuse.

```tsx
// ✅ Presentational: pure input → output, no side effects
interface UserCardProps {
  name: string;
  email: string;
  avatarUrl: string;
  onEdit?: () => void;
}

const UserCard: FC<UserCardProps> = ({ name, email, avatarUrl, onEdit }) => (
  <div>
    <img src={avatarUrl} alt={name} />
    <h2>{name}</h2>
    <p>{email}</p>
    {onEdit && <button onClick={onEdit}>Edit</button>}
  </div>
);

// ✅ Container: fetches data, manages state, passes to presentational
const UserListContainer: FC = () => {
  const { data: users, isLoading } = useQuery({
    queryKey: ["users"],
    queryFn: fetchUsers,
  });

  if (isLoading) return <Spinner />;

  return (
    <div>
      {users?.map((user) => (
        <UserCard
          key={user.id}
          name={user.name}
          email={user.email}
          avatarUrl={user.avatarUrl}
        />
      ))}
    </div>
  );
};
```

---

### Pattern 2: Compound Components

**Use when:** a component has multiple parts that share state, and callers want to control which parts appear.

```tsx
// TaskCard owns: fetching, shared state, base layout
function TaskCard({ children, taskId }: TaskCardProps) {
  const task = useTask(taskId);

  return (
    <TaskCardContext.Provider value={{ task }}>
      <div className="task-card">{children}</div>
    </TaskCardContext.Provider>
  );
}

// Sub-components read shared state from context
TaskCard.Header = function TaskCardHeader() {
  const { task } = useTaskCardContext();
  return <div>{task.title}</div>;
};

TaskCard.Assignee = function TaskCardAssignee() {
  const { task } = useTaskCardContext();
  return <UserAvatar userId={task.assigneeId} />;
};

TaskCard.Actions = function TaskCardActions({
  children,
}: {
  children: ReactNode;
}) {
  return <div className="task-card__actions">{children}</div>;
};
```

Different roles compose differently — with zero variant props:

```tsx
// Guest: read-only, minimal
<TaskCard taskId={id}>
  <TaskCard.Header />
</TaskCard>

// Admin: full control
<TaskCard taskId={id}>
  <TaskCard.Header />
  <TaskCard.Assignee />
  <TaskCard.Actions>
    <DeleteTaskButton taskId={id} />
    <MoveTaskButton taskId={id} />
  </TaskCard.Actions>
</TaskCard>
```

---

### Pattern 3: Slot Pattern

**Use when:** whole sections of a component vary by context — not just sub-components, but entirely different content.

```tsx
interface DataTableProps<T> {
  data: T[];
  columns: ColumnDef<T>[];
  // Slots — caller decides what goes here
  toolbar?: ReactNode;
  emptyState?: ReactNode;
  pagination?: ReactNode;
  rowExpanded?: (row: T) => ReactNode;
}

function DataTable<T>({
  data,
  columns,
  toolbar,
  emptyState,
  pagination,
  rowExpanded,
}: DataTableProps<T>) {
  return (
    <div>
      {toolbar && <div className="toolbar">{toolbar}</div>}
      <table>
        {data.length === 0 && (emptyState ?? <DefaultEmptyState />)}
        {data.map((row) => (
          <>
            <TableRow row={row} columns={columns} />
            {rowExpanded && <ExpandedRow>{rowExpanded(row)}</ExpandedRow>}
          </>
        ))}
      </table>
      {pagination && <div className="footer">{pagination}</div>}
    </div>
  );
}
```

The same `DataTable` in two completely different contexts:

```tsx
// Task list
<DataTable
  data={tasks}
  columns={taskColumns}
  toolbar={<><TaskFilters /><BulkActionBar /></>}
  emptyState={<CreateFirstTaskPrompt />}
  pagination={<CursorPagination />}
/>

// Billing invoices
<DataTable
  data={invoices}
  columns={invoiceColumns}
  toolbar={<DateRangeFilter />}
  emptyState={<NoInvoicesYet />}
  pagination={<PageNumberPagination total={total} />}
/>
```

---

### Pattern 4: Hook Composition (Behavior Injection)

**Use when:** the variation is behavioral — sorting, selection, drag-drop, inline editing — not visual.

```tsx
// The hook defines the behavior
function useTableSelection(ids: string[]) {
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const toggleOne = (id: string) =>
    setSelected((prev) => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  const toggleAll = () =>
    setSelected((prev) =>
      prev.size === ids.length ? new Set() : new Set(ids),
    );
  const clearAll = () => setSelected(new Set());
  const isAllSelected = selected.size === ids.length;

  return { selected, toggleOne, toggleAll, clearAll, isAllSelected };
}

// The component accepts behavior as a prop — doesn't own it
interface DataTableProps<T> {
  data: T[];
  columns: ColumnDef<T>[];
  selection?: ReturnType<typeof useTableSelection>;
}

// Caller opts into the behavior
const selection = useTableSelection(tasks.map((t) => t.id));

<DataTable
  data={tasks}
  columns={taskColumns}
  selection={selection}
  toolbar={
    <BulkActionBar
      selectedIds={[...selection.selected]}
      onClear={selection.clearAll}
    />
  }
/>;
```

The component renders selection state when provided; it works without it too. The caller owns the behavior.

---

### Pattern 5: Provider (Cross-Cutting Concerns)

**Use when:** the same concern — permissions, feature flags, plan tier — affects many components throughout a subtree, and prop-drilling would be painful.

```tsx
// Define the ambient context
interface ProjectPermissions {
  can: (action: string) => boolean;
}

const ProjectPermissionsContext = createContext<ProjectPermissions | null>(
  null,
);

export function ProjectPermissionsProvider({
  projectId,
  children,
}: {
  projectId: string;
  children: ReactNode;
}) {
  const permissions = useProjectPermissions(projectId); // fetches once at boundary
  return (
    <ProjectPermissionsContext.Provider value={permissions}>
      {children}
    </ProjectPermissionsContext.Provider>
  );
}

export function useProjectPermissions() {
  const ctx = useContext(ProjectPermissionsContext);
  if (!ctx)
    throw new Error(
      "useProjectPermissions must be used inside ProjectPermissionsProvider",
    );
  return ctx;
}

// Components deep in the tree consume it — no prop drilling
function DeleteTaskButton({ taskId }: { taskId: string }) {
  const { can } = useProjectPermissions();
  if (!can("task:delete")) return null;
  return <button onClick={() => deleteTask(taskId)}>Delete</button>;
}

// Wrap once at the route level
function ProjectPage({ projectId }: { projectId: string }) {
  return (
    <ProjectPermissionsProvider projectId={projectId}>
      <TaskBoard />
      <TaskList />
      <ProjectSettings />
    </ProjectPermissionsProvider>
  );
}
```

Each layer owns one kind of decision:

| Layer                | Owns                                 |
| -------------------- | ------------------------------------ |
| Route (`page.tsx`)   | Composition — what goes where        |
| Providers            | Ambient context — permissions, flags |
| Layout components    | Structure — zones and slots          |
| Feature components   | Domain logic — data, business rules  |
| Primitive components | Rendering — pure UI, no logic        |
| Hooks                | Behavior — state, side effects       |

---

### Pattern 6: Render Props

**Use when:** you need to share stateful logic between components and the consumer needs full control over rendering.

```tsx
// Share state/logic via render function prop
interface MouseTrackerProps {
  children: (position: { x: number; y: number }) => ReactNode;
}

const MouseTracker: FC<MouseTrackerProps> = ({ children }) => {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  return (
    <div onMouseMove={(e) => setPosition({ x: e.clientX, y: e.clientY })}>
      {children(position)}
    </div>
  );
};

// Usage
<MouseTracker>
  {({ x, y }) => (
    <p>
      Mouse at {x}, {y}
    </p>
  )}
</MouseTracker>;
```

> **Note:** Custom hooks solve most cases where render props were previously used. Prefer a custom hook unless you specifically need the consumer to control rendering.

---

## Prop Patterns

### Spreading native attributes

```typescript
// ✅ Forward native HTML attributes so callers aren't blocked
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary";
}

const Button: FC<ButtonProps> = ({ variant = "primary", ...rest }) => (
  <button className={`btn btn-${variant}`} {...rest} />
);

<Button onClick={handleClick} disabled type="submit">Submit</Button>
```

### Named slots via props

```typescript
// ✅ Named slots for complex layouts
interface ModalProps {
  header?: ReactNode;
  body: ReactNode;
  footer?: ReactNode;
}

const Modal: FC<ModalProps> = ({ header, body, footer }) => (
  <div className="modal">
    {header && <div className="modal-header">{header}</div>}
    <div className="modal-body">{body}</div>
    {footer && <div className="modal-footer">{footer}</div>}
  </div>
);
```

---

## Performance Patterns

### Memoization

Only memoize when you have a measured performance problem — not preemptively.

```typescript
// Prevent unnecessary re-renders when parent re-renders
const UserCard = memo<UserCardProps>(({ user }) => (
  <div>{user.name}</div>
));
```

### Lazy loading

```typescript
// Code-split by route or heavy feature
const UserDashboard = lazy(() => import("./UserDashboard"));

function App() {
  return (
    <Suspense fallback={<Spinner />}>
      <UserDashboard />
    </Suspense>
  );
}
```

---

## Where Does a Component Belong?

Use this when deciding where to put a new component.

```text
Is this component domain-agnostic?
(button, input, modal, chart wrapper with no business knowledge)
  └─ YES → core/ui/

Is it business-aware but no single feature owns it?
(UserAvatar, MemberPicker, RoleBadge — used by tasks, notifications, dashboard)
  └─ YES → modules/common/

Does one feature clearly own it, and only that feature uses it?
  └─ YES → modules/<feature>/ internal (not exported from index.ts)

Does one feature own it, but other modules need to render it?
  └─ Do they need the COMPONENT or just its DATA?
      ├─ Just data → export a hook from index.ts, not the component
      └─ The component itself
            ├─ Do they EMBED it in their own pages?
            │   └─ YES → use slots — route injects it, modules don't import each other
            └─ Do they show a small reference/preview?
                └─ YES → export from index.ts (e.g. TaskMiniPreview, NotificationsBell)
```

---

## When a Module Gets Too Large

A module is too large when components inside it don't naturally relate to each other. **Size alone isn't the problem — incoherence is.**

### Warning signs

| Signal                                                      | What it means                        |
| ----------------------------------------------------------- | ------------------------------------ |
| Components that never import each other                     | Likely separate sub-features         |
| A `utils/` folder with 20 unrelated functions               | Dumping ground                       |
| Different teammates always working in different sub-folders | Ownership boundary = module boundary |
| Sub-folders already emerging naturally                      | Module is telling you to split       |

### The fix: split by sub-feature

`tasks/` is rarely just "tasks". It's really:

```text
modules/
├── task-board/        # Kanban view, drag-drop, columns
├── task-detail/       # Detail view, full editing
├── task-list/         # Table view, filtering, bulk actions
├── task-creation/     # Create flow, templates, quick-add
└── tasks-core/        # Shared types, API, hooks — NO UI
    ├── types/
    ├── api/
    └── hooks/
```

`tasks-core` has no components. It's the shared foundation that the UI sub-features build on.

### The evolution over time

```text
Phase 1 — early         Phase 2 — growing          Phase 3 — mature
─────────────────       ─────────────────────────   ──────────────────────────
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

You don't start at Phase 3. You earn it by feeling the pain at Phase 2 in the right places.

---

## Decision Trees

### New component — which composition pattern?

```text
Component has variation. Which pattern fits?
                        │
        ┌───────────────┴───────────────────────┐
  Is variation in STRUCTURE?              Is variation BEHAVIORAL?
  (different parts in different contexts) (selection, sorting, drag-drop)
        │                                        │
   ┌────┴────┐                             ┌─────┴─────┐
  YES       NO                            YES          NO
   │                                       │
 Do the parts                         Pattern 4:      Is it CROSS-CUTTING?
 share implicit state?                Hook.           (permissions, flags, plan)
   │                                  Extract               │
  ┌┴────┐                             behavior,       ┌─────┴─────┐
 YES   NO                             inject          YES         NO
  │     │                             as prop.         │
 Pattern 2:  Pattern 3:                          Pattern 5:    Just use props.
 Compound.   Slots.                              Provider.     string, boolean,
 Context +   Pass ReactNode                      Wrap the      enum.
 dot         as prop.                            subtree.
 notation.
```

---

### New component — where does it live?

```text
Does the component know about this app's domain?
(users, tasks, billing, permissions — not just "a button")
                    │
         ┌──────────┴──────────┐
        NO                    YES
         │                     │
     core/ui/           Is there ONE module
   (pure design          that clearly owns it?
    system, no                 │
    domain knowledge)   ┌──────┴──────┐
                       NO            YES
                        │             │
                modules/common/       │
              (UserMention,     Do other modules
               MemberPicker,    need to USE it?
               RoleBadge)             │
                              ┌───────┴───────┐
                             NO              YES
                              │               │
                         module internal  Do they need
                         (not exported    the component
                          from index.ts)  or its DATA?
                                               │
                                    ┌──────────┴──────────┐
                                  DATA               COMPONENT
                                    │                     │
                              Export a hook         Do they EMBED it
                              from index.ts.        in their page?
                              (useCurrentUser,            │
                               useTaskById)       ┌───────┴───────┐
                                                 YES              NO
                                                  │               │
                                            Use slots.      Export from
                                            Route           index.ts.
                                            composes.       (TaskMiniPreview,
                                            Modules         NotificationsBell)
                                            don't import
                                            each other.
```

---

### Component feeling hard to work with?

```text
Something feels wrong. What is it?
                        │
         ┌──────────────┴──────────────┐
   Too many props?                Hard to reuse?
   (5+ booleans, variant flags)         │
         │                        ┌─────┴─────┐
   Switch to composition.   Does it fetch     │
   Compound or slots.       its own data?     │
                                  │      Is it too broad
                             ┌────┴────┐ (doing too many things)?
                            YES       NO          │
                             │         │     ┌────┴────┐
                       Make it      Is the  YES       NO
                       presentational. LOGIC        │
                       Caller        tangled  Split into  → OK.
                       provides      with     compound    Add a test
                       data.         rendering? sub-components.
                                         │
                                    ┌────┴────┐
                                   YES       NO
                                    │
                              Extract hook.
                              Move logic to
                              component.hooks.ts.
```

---

## Related Resources

- [Architecture Layers](../01-architecture/reference/layers.md) — how modules and layers are structured
- [Dependency Rules](../01-architecture/reference/dependency-rules.md) — what can import what
- [Placing Code](../01-architecture/guides/placing-code.md) — where to put new code
- [Development Principles](../00-development-principles/README.md) — YAGNI, KISS, DRY, interface-first
- [AI Component Design Skill](../../ai/skills/component-design/SKILL.md) — decision-tree prompt guide for Copilot
