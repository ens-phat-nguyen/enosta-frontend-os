# Extract a Shared Component

Move a component from a single feature module into `modules/common/` so multiple features can use it — without breaking anything.

---

## Overview

This playbook covers the workflow for extracting a component that has earned its place as a shared piece of UI. By the end you'll have:

- The component in the correct shared location
- A clean public API that both (or all) callers depend on
- All original callers updated and working
- The duplicate copies removed

**Time:** 20–60 min depending on how many callers exist

---

## Prerequisites

- Familiar with the [Component Patterns standard](../../standards/09-component-patterns/README.md)
- The component exists in a feature module and is now genuinely needed in **three or more places**
- The component is already well-structured (if not, run the [Refactor a Growing Component](./refactor-growing-component.md) playbook first)

---

## Steps

### Step 1 — Validate it's actually ready to extract

Extracting too early creates abstractions shaped for your first two use cases that get bent out of shape by every case that follows. Apply these checks before moving anything.

**The rule of 3:**

```text
1st usage → write it inline
2nd usage → duplicate it (you don't know its real shape yet)
3rd usage → now you see what varies and what's stable → extract it
```

**Readiness checklist:**

- [ ] The component is used (or clearly needed) in 3+ distinct places
- [ ] You can see what varies across the usages and what stays the same
- [ ] The component is presentational — it does not fetch its own data (callers pass data in)
- [ ] It has no imports from the feature module that currently owns it

If the component still imports from its parent feature module (e.g., `modules/tasks/hooks/use-task`), it is not ready to be shared. Make it presentational first — move all data fetching to the caller.

✓ **Checkpoint:** All items on the checklist are met.

---

### Step 2 — Design the shared API

Look at all the call sites. What data does each one pass in? What varies? What's always the same?

Write the shared props interface from the call sites — not from the current implementation.

```tsx
// Call site 1 (tasks module)
<UserAvatar userId={task.assigneeId} size="sm" />

// Call site 2 (comments module)
<UserAvatar userId={comment.authorId} size="md" showName />

// Call site 3 (notifications module)
<UserAvatar userId={notification.actorId} size="sm" />
```

Derived shared interface:

```tsx
interface UserAvatarProps {
  userId: string;
  size?: "sm" | "md" | "lg";
  showName?: boolean;
}
```

Keep the interface to what the call sites actually need. Don't add props for hypothetical future callers.

✓ **Checkpoint:** Props interface is derived from real call sites, not guessed.

---

### Step 3 — Choose the right destination

```text
Does the component know about any business domain at all?
(users, tasks, projects — not just "a circle with an image")
    │
    ├── NO  → core/ui/          (pure design system primitive)
    └── YES → modules/common/   (business-aware shared UI)
```

Most components extracted from feature modules belong in `modules/common/` — they know about domain concepts like users, members, or roles, but no single feature owns them.

Create the folder:

```bash
mkdir -p modules/common/components/<component-name>
touch modules/common/components/<component-name>/index.ts
touch modules/common/components/<component-name>/<component-name>.tsx
touch modules/common/components/<component-name>/<component-name>.test.tsx
```

If the component has a hook, bring it too:

```bash
touch modules/common/components/<component-name>/<component-name>.hooks.ts
```

✓ **Checkpoint:** Destination folder exists with the standard file structure.

---

### Step 4 — Move and adapt the component

Copy the implementation to the new location. Then adapt it to the shared interface you designed in Step 2.

Key things to check during the move:

**Remove feature-specific imports.** The shared component must not import from any feature module.

```tsx
// ❌ Not allowed in modules/common/
import { useTask } from "modules/tasks/hooks/use-task";

// ✅ Data comes from the caller via props
interface UserAvatarProps {
  avatarUrl: string;
  name: string;
}
```

**Make it presentational.** If the component currently fetches data, strip that out. The caller will be responsible.

**Preserve the existing behaviour.** Don't add features or refactor beyond what's needed for sharing.

✓ **Checkpoint:** Component in new location compiles. No imports from feature modules.

---

### Step 5 — Export from `modules/common/index.ts`

Add the component to the `modules/common` public API.

```ts
// modules/common/index.ts
export { UserAvatar } from "./components/user-avatar";
export type { UserAvatarProps } from "./components/user-avatar";
```

Only export what callers genuinely need. Don't export internal sub-components.

✓ **Checkpoint:** `import { UserAvatar } from "modules/common"` resolves correctly.

---

### Step 6 — Update all callers

Find every import of the old component and update it to the new location.

```bash
# Find all existing imports
grep -r "from.*modules/tasks.*UserAvatar" src/
```

Update each one:

```tsx
// Before
import { UserAvatar } from "modules/tasks/components/user-avatar";

// After
import { UserAvatar } from "modules/common";
```

If you redesigned the props interface in Step 2, update the call sites to use the new props too.

✓ **Checkpoint:** No remaining imports from the old location. All call sites compile.

---

### Step 7 — Write or move the tests

If the component had tests in the original feature module, move them to the new location. Update the import path inside the test file.

Add test cases for the new shared prop variants if callers use them differently:

```tsx
describe("UserAvatar", () => {
  it("renders avatar image with alt text", () => {
    render(<UserAvatar avatarUrl="/img/user.png" name="Alex" />);
    expect(screen.getByRole("img", { name: "Alex" })).toBeInTheDocument();
  });

  it("shows name when showName is true", () => {
    render(<UserAvatar avatarUrl="/img/user.png" name="Alex" showName />);
    expect(screen.getByText("Alex")).toBeInTheDocument();
  });

  it("applies size class", () => {
    render(<UserAvatar avatarUrl="/img/user.png" name="Alex" size="lg" />);
    expect(screen.getByRole("img")).toHaveClass("avatar--lg");
  });
});
```

✓ **Checkpoint:** Tests are co-located with the new component. All tests pass.

---

### Step 8 — Delete the original

Remove the old component from the feature module. Don't leave it as a re-export — that creates a confusing indirection and callers won't know which import to use.

```bash
rm -rf modules/tasks/components/user-avatar/
```

If the original `index.ts` exported it, remove that export too.

✓ **Checkpoint:** The original location no longer exists. The codebase compiles. All tests pass.

---

## Troubleshooting

**"The component imports things from its feature module and I can't easily remove them."**
That means it's not ready to share. Make it presentational first: move all data fetching to the callers and pass data via props. Only then move it to `modules/common/`.

**"The call sites use it differently enough that the shared interface is awkward."**
That's the rule of 3 in action — you're looking at genuine variation, not a stable shared pattern. Either keep two slightly different components in their respective feature modules, or extract only the truly shared primitive to `core/ui/` and let the features build their domain-aware wrappers on top.

**"I moved the component and now one caller breaks because it needs feature-specific data."**
The caller needs to be updated to pass that data explicitly. The shared component should never reach back into a feature to get its own data.

**"I'm not sure if this belongs in `core/ui/` or `modules/common/`."**
Ask: does the component need to know about any domain concept (users, projects, tasks, billing)? If no — it's a pure UI primitive, it belongs in `core/ui/`. If yes — it's business-aware shared UI, it belongs in `modules/common/`.

---

## Related Resources

- [Component Patterns Standard](../../standards/09-component-patterns/README.md) — where components belong, dependency rules
- [Build a Feature Component](./build-feature-component.md) — original structure to extract from
- [Refactor a Growing Component](./refactor-growing-component.md) — clean up before extracting
