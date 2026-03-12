# Real-World Example: B2B Project Management SaaS

A worked example applying all rules to a realistic component inventory.
Use this as a reference when making placement decisions for similar components.

---

## The app

Features: workspaces, projects, tasks, comments, notifications, billing, analytics, team members.

---

## Full component inventory with decisions

### Identity & People

| Component      | Decision          | Reason                                                                                |
| -------------- | ----------------- | ------------------------------------------------------------------------------------- |
| `UserAvatar`   | `core/ui/`        | No domain knowledge — renders image with fallback initials                            |
| `UserMention`  | `modules/common/` | Knows about "user" domain, links to profile, used by tasks + comments + notifications |
| `MemberPicker` | `modules/common/` | Searches workspace membership, used by tasks + projects + dashboard                   |
| `RoleBadge`    | `modules/common/` | "Admin/Member/Guest" — business-aware, used by team + settings + notifications        |

### Tasks

| Component          | Decision                                                              | Reason                                                                 |
| ------------------ | --------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `TaskCard`         | `modules/tasks/` exported                                             | Owned by tasks; dashboard gets it via slot                             |
| `TaskStatusSelect` | `modules/tasks/` internal                                             | Pure to task domain, only tasks use it                                 |
| `PriorityFlag`     | `modules/tasks/` internal                                             | "Priority" is task-domain; promote to `common/` only if others need it |
| `DueDatePicker`    | Split: base → `core/ui/`, overdue wrapper → `modules/tasks/` internal | Base picker is generic; overdue highlighting is task-domain            |
| `TaskMiniPreview`  | `modules/tasks/` exported                                             | Used by comments and notifications as a reference chip                 |

### Comments

| Component       | Decision                     | Reason                                          |
| --------------- | ---------------------------- | ----------------------------------------------- |
| `CommentThread` | `modules/comments/` exported | Used in project detail page via slot            |
| `CommentEditor` | `modules/comments/` internal | Uses `UserMention` from `modules/common/` ✅    |
| `CommentItem`   | `modules/comments/` internal | Single comment row, not needed outside comments |

### Notifications

| Component           | Decision                          | Reason                                          |
| ------------------- | --------------------------------- | ----------------------------------------------- |
| `NotificationsFeed` | `modules/notifications/` exported | Dashboard embeds it as a slot                   |
| `NotificationsBell` | `modules/notifications/` exported | Lives in global nav, `core/` layout imports it  |
| `NotificationItem`  | `modules/notifications/` internal | Uses `TaskMiniPreview` from `modules/tasks/` ✅ |

### Projects

| Component                  | Decision                     | Reason                                                 |
| -------------------------- | ---------------------------- | ------------------------------------------------------ |
| `ProjectCard`              | `modules/projects/` internal | Used only in workspace overview                        |
| `ProjectProgress`          | `modules/projects/` internal | Derived from task completion, only projects needs this |
| `ProjectMemberAvatarStack` | `modules/projects/` internal | Uses `UserAvatar` from `core/ui/` ✅                   |

### Billing

| Component             | Decision                                     | Reason                                                                              |
| --------------------- | -------------------------------------------- | ----------------------------------------------------------------------------------- |
| `BillingStatusBanner` | `modules/billing/` exported                  | App-wide banner, injected into `core/` layout as slot                               |
| `PlanBadge`           | `modules/billing/` exported                  | Used in settings, nav, and locked feature prompts                                   |
| `UpgradePrompt`       | `modules/billing/` exported, but prefer slot | `analytics/` shouldn't import from `billing/` directly — use slot injection instead |

### Analytics

| Component         | Decision                      | Reason                                                                        |
| ----------------- | ----------------------------- | ----------------------------------------------------------------------------- |
| `AnalyticsChart`  | `core/ui/`                    | Themed recharts wrapper — no business domain, used across all analytics views |
| `BurndownChart`   | `modules/analytics/` internal | Specific to analytics, used nowhere else                                      |
| `WorkloadHeatmap` | `modules/analytics/` internal | Specific to analytics, used nowhere else                                      |

---

## Final placement map

```
core/ui/
  UserAvatar
  DatePicker               (base, no overdue logic)
  AnalyticsChart           (themed recharts wrapper)

modules/common/
  UserMention
  MemberPicker
  RoleBadge

modules/tasks/
  TaskCard                 ← exported (used via slots in dashboard)
  TaskMiniPreview          ← exported (used by comments, notifications)
  TaskStatusSelect         ← internal
  PriorityFlag             ← internal
  DueDatePicker            ← internal (wraps core/ui DatePicker)

modules/comments/
  CommentThread            ← exported (injected as slot into projects)
  CommentEditor            ← internal
  CommentItem              ← internal

modules/notifications/
  NotificationsFeed        ← exported
  NotificationsBell        ← exported
  NotificationItem         ← internal

modules/projects/
  ProjectCard              ← internal
  ProjectProgress          ← internal
  ProjectMemberAvatarStack ← internal

modules/billing/
  BillingStatusBanner      ← exported
  PlanBadge                ← exported
  UpgradePrompt            ← exported (but prefer slot injection)

modules/analytics/
  BurndownChart            ← internal
  WorkloadHeatmap          ← internal
```

---

## How modules interact without importing each other

The key pattern: **routes are the composition root.**

```tsx
// routes/projects/[id]/page.tsx
// This is the ONLY place that knows about both projects and comments.

import { ProjectDetail } from "modules/projects";
import { CommentThread } from "modules/comments";
import { TaskCard } from "modules/tasks";

export default function ProjectPage() {
  const { projectId } = useParams();

  return (
    <ProjectDetail
      projectId={projectId}
      commentsSlot={<CommentThread entityId={projectId} entityType="project" />}
      taskSlot={(id) => <TaskCard taskId={id} />}
    />
  );
}
```

`modules/projects/` never imports from `modules/comments/` or `modules/tasks/`.
The route injects them as slots. Neither module knows the other exists.

---

## The three questions that resolve most placement debates

1. **"Does this know about our app's domain?"**
   No → `core/ui/`. Yes → continue.

2. **"Does one feature clearly own it?"**
   No → `modules/common/`. Yes → continue.

3. **"Do other modules need the component itself, or just its data?"**
   Data → export a hook. Component → use slots (route injects) or export from `index.ts`.
