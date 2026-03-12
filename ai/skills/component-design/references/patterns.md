# Composition Patterns

Four patterns for handling component variation in a SaaS product.
Use them together — a real page typically uses all four.

---

## Why composition over props

In a SaaS product, components face:

- Multiple user roles (admin, member, guest)
- Feature flags and plan tiers (free, pro, enterprise)
- Dense, data-rich UIs
- Rapid iteration — variants multiply faster than you refactor

A prop-based approach collapses under this:

```tsx
// ❌ This is where prop-based design ends up
<TaskCard
  role={currentUser.role}
  plan={workspace.plan}
  variant="compact"
  showActions={featureFlags.taskActions}
  isReadOnly={!hasPermission}
  headerMode="minimal"
  footerMode="full"
/>
```

The component becomes a decision engine. Every new requirement adds a prop,
every prop adds a branch, every branch makes testing harder.

**The mental shift:**

- ❌ "What props does this component need to handle every case?"
- ✅ "What decisions does this component own, and what does it delegate outward?"

---

## Pattern 1: Compound Components

**Use when:** a component has multiple cooperating parts that share implicit state,
and callers want to control which parts appear and in what order.

```tsx
// TaskCard owns: data fetching, shared context, base layout
function TaskCard({ children, taskId }: TaskCardProps) {
  const task = useTask(taskId);

  return (
    <TaskCardContext.Provider value={{ task }}>
      <div className="task-card">{children}</div>
    </TaskCardContext.Provider>
  );
}

// Sub-components read shared state from context — no prop drilling
TaskCard.Header = function TaskCardHeader() {
  const { task } = useTaskCardContext();
  return <div className="task-card__header">{task.title}</div>;
};

TaskCard.Assignee = function TaskCardAssignee() {
  const { task } = useTaskCardContext();
  return <UserAvatar userId={task.assigneeId} />;
};

TaskCard.DueDate = function TaskCardDueDate() {
  const { task } = useTaskCardContext();
  return <DueDatePicker taskId={task.id} />;
};

TaskCard.Actions = function TaskCardActions({
  children,
}: {
  children: ReactNode;
}) {
  return <div className="task-card__actions">{children}</div>;
};
```

Different roles compose differently — zero variant props needed:

```tsx
// Guest: read-only, minimal
<TaskCard taskId={id}>
  <TaskCard.Header />
</TaskCard>

// Member: standard view
<TaskCard taskId={id}>
  <TaskCard.Header />
  <TaskCard.Assignee />
  <TaskCard.DueDate />
</TaskCard>

// Admin: full actions
<TaskCard taskId={id}>
  <TaskCard.Header />
  <TaskCard.Assignee />
  <TaskCard.DueDate />
  <TaskCard.Actions>
    <DeleteTaskButton taskId={id} />
    <MoveTaskButton taskId={id} />
  </TaskCard.Actions>
</TaskCard>
```

**What TaskCard owns:** fetching, context, base layout.
**What the caller owns:** which parts appear and in what order.

---

## Pattern 2: Slot Pattern

**Use when:** whole sections of a component vary by context — not just sub-components,
but entirely different UI blocks (toolbars, empty states, footers).

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
    <div className="data-table">
      {toolbar && <div className="data-table__toolbar">{toolbar}</div>}
      <table>
        {data.length === 0 && (emptyState ?? <DefaultEmptyState />)}
        {data.map((row) => (
          <>
            <TableRow row={row} columns={columns} />
            {rowExpanded && <ExpandedRow>{rowExpanded(row)}</ExpandedRow>}
          </>
        ))}
      </table>
      {pagination && <div className="data-table__footer">{pagination}</div>}
    </div>
  );
}
```

Same component, two completely different contexts:

```tsx
// Task list
<DataTable
  data={tasks}
  columns={taskColumns}
  toolbar={<><TaskFilters /><BulkActionBar /></>}
  emptyState={<CreateFirstTaskPrompt />}
  rowExpanded={task => <TaskMiniDetail taskId={task.id} />}
  pagination={<CursorPagination cursor={cursor} />}
/>

// Billing invoices — same DataTable, totally different context
<DataTable
  data={invoices}
  columns={invoiceColumns}
  toolbar={<DateRangeFilter />}
  emptyState={<NoInvoicesYet />}
  pagination={<PageNumberPagination total={total} />}
/>
```

**Slots vs compound:** use slots when the variable part is a whole independent block.
Use compound when the parts share state with each other.

---

## Pattern 3: Hook Composition (Behavior Injection)

**Use when:** the variation is behavioral, not visual — sorting, selection,
drag-drop, inline editing.

```tsx
// The hook defines the behavior contract
function useTableSelection(ids: string[]) {
  const [selected, setSelected] = useState<Set<string>>(new Set());

  return {
    selected,
    toggleOne: (id: string) =>
      setSelected((prev) => {
        const next = new Set(prev);
        next.has(id) ? next.delete(id) : next.add(id);
        return next;
      }),
    toggleAll: () => setSelected(new Set(ids)),
    clearAll: () => setSelected(new Set()),
    isAllSelected: selected.size === ids.length,
  };
}

// Component accepts behavior as a prop — doesn't own it
interface DataTableProps<T> {
  data: T[];
  columns: ColumnDef<T>[];
  selection?: ReturnType<typeof useTableSelection>; // optional
}
```

Callers opt into behaviors:

```tsx
// Table with selection — caller owns the behavior
const selection = useTableSelection(tasks.map(t => t.id))

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
/>

// Table without selection — same component, zero config
<DataTable
  data={invoices}
  columns={invoiceColumns}
/>
```

Each behavior is independently testable, independently optional.
Build a library: `useTableSelection`, `useTableSorting`, `useTableFiltering`,
`useInlineEdit`, `useRowDragDrop` — all composable, none required.

---

## Pattern 4: Provider Composition

**Use when:** a concern affects a whole subtree — permissions, feature flags,
theme, plan tier. These should not travel through props.

```tsx
// Set context once at the feature boundary
function TaskBoardFeature({ projectId }: { projectId: string }) {
  return (
    <ProjectPermissionsProvider projectId={projectId}>
      <FeatureFlagsProvider flags={PROJECT_FLAGS}>
        <TaskBoardDragProvider>
          <TaskBoard projectId={projectId} />
        </TaskBoardDragProvider>
      </FeatureFlagsProvider>
    </ProjectPermissionsProvider>
  );
}

// Deep inside the tree — components just consume, no prop drilling
function TaskCard({ taskId }: { taskId: string }) {
  const canEdit = usePermission("task:edit"); // from ProjectPermissionsProvider
  const hasDueDates = useFeatureFlag("due-dates"); // from FeatureFlagsProvider

  return (
    <TaskCard.Root taskId={taskId}>
      <TaskCard.Header />
      {hasDueDates && <TaskCard.DueDate />}
      {canEdit && <TaskCard.Actions />}
    </TaskCard.Root>
  );
}
```

---

## How the patterns combine in a real page

The route is the composition root. It's the only place that knows about everything:

```tsx
// routes/projects/[id]/board/page.tsx
export default function BoardPage() {
  const { projectId } = useParams();
  const selection = useTableSelection([]); // Pattern 3: behavior

  return (
    // Pattern 4: ambient context
    <ProjectPermissionsProvider projectId={projectId}>
      <PlanGateProvider feature="kanban">
        {/* Pattern 2: slot-based layout */}
        <BoardLayout
          toolbar={
            <>
              <TaskFilters />
              {selection.selected.size > 0 && (
                <BulkActionsBar selection={selection} />
              )}
            </>
          }
          upgradePrompt={<UpgradePrompt feature="kanban" />}
        >
          {/* Pattern 1: compound component owns the board structure */}
          <KanbanBoard projectId={projectId}>
            <KanbanBoard.Columns>
              {tasks.map((task) => (
                <TaskCard key={task.id} taskId={task.id}>
                  <TaskCard.Header />
                  <TaskCard.Assignee />
                  <TaskCard.SelectToggle
                    onToggle={() => selection.toggleOne(task.id)}
                    selected={selection.selected.has(task.id)}
                  />
                </TaskCard>
              ))}
            </KanbanBoard.Columns>
          </KanbanBoard>
        </BoardLayout>
      </PlanGateProvider>
    </ProjectPermissionsProvider>
  );
}
```

Each layer owns exactly one kind of decision:

| Layer                | Owns                                       |
| -------------------- | ------------------------------------------ |
| Route (page.tsx)     | Composition — what goes where              |
| Providers            | Ambient context — permissions, flags, plan |
| Layout components    | Structure — zones and slots                |
| Feature components   | Domain logic — data, business rules        |
| Primitive components | Rendering — pure UI, no logic              |
| Hooks                | Behavior — state machines, side effects    |
