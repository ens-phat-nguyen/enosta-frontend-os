# Tech Stack Standards

This document defines our frontend tech stack and how we use each technology.

---

## Overview

Our frontend stack is optimized for:

- Type safety and developer experience
- Performance and scalability
- Component reusability
- Modern best practices

---

## Core Technologies

### TypeScript

**Version**: Latest stable (5.x+)

**Why**: Type safety, better IDE support, fewer runtime errors

**Standards**:

```typescript
// ✅ Always use strict mode
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true
  }
}

// ✅ Explicit types for function parameters and returns
const fetchUser = async (id: string): Promise<User> => {
  // implementation
};

// ✅ Use type inference for variables when obvious
const userName = "John"; // string is inferred

// ✅ Use interfaces for objects, types for unions/primitives
interface User {
  id: string;
  name: string;
  email: string;
}

type Status = "active" | "inactive" | "pending";

// ❌ Don't use 'any' - use 'unknown' if type is truly unknown
// ❌ Don't disable strict checks without documentation
```

**Resources**:

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)

---

## Frameworks

### React

**Version**: 18.x+

**Why**: Component-based, large ecosystem, team expertise

**Standards**:

```typescript
// ✅ Use functional components with hooks
const UserProfile = ({ userId }: { userId: string }) => {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  return <div>{user?.name}</div>;
};

// ✅ Extract custom hooks for reusable logic
const useUser = (userId: string) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    fetchUser(userId)
      .then(setUser)
      .finally(() => setLoading(false));
  }, [userId]);

  return { user, loading };
};

// ✅ Use React.memo() for expensive components
const ExpensiveComponent = React.memo(({ data }: Props) => {
  // expensive rendering logic
});

// ❌ Don't use class components for new code
// ❌ Don't create new functions inside render
// ❌ Don't mutate state directly
```

**Component Patterns**:

- Container/Presentational pattern for complex components
- Compound components for related UI elements
- Render props or hooks for logic sharing

---

### Astro

**Version**: 4.x+

**Why**: Static site generation, island architecture, performance

**When to Use**:

- Marketing/content sites
- Documentation
- Blogs
- Landing pages

**Standards**:

```astro
---
// ✅ Use Astro components for static content
import Layout from '../layouts/Layout.astro';
import Card from '../components/Card.astro';

const posts = await getCollection('blog');
---

<Layout title="Blog">
  {posts.map(post => (
    <Card title={post.title} />
  ))}
</Layout>

// ✅ Use React islands for interactive elements
<ReactCounter client:load />

// ✅ Choose the right loading strategy
client:load      // Load immediately
client:idle      // Load when browser is idle
client:visible   // Load when in viewport
```

---

### Next.js

**Version**: 14.x+ (App Router)

**Why**: SSR, API routes, optimizations, full-stack capabilities

**When to Use**:

- Full web applications
- SEO-critical pages
- Server-side data fetching needed

**Standards**:

```typescript
// ✅ Use App Router (not Pages Router)
// app/users/[id]/page.tsx
export default async function UserPage({ params }: { params: { id: string } }) {
  const user = await fetchUser(params.id);
  return <UserProfile user={user} />;
}

// ✅ Use Server Components by default
// app/dashboard/page.tsx
async function Dashboard() {
  const data = await fetchDashboardData();
  return <DashboardView data={data} />;
}

// ✅ Mark Client Components explicitly
"use client";
import { useState } from 'react';

// ✅ Use Server Actions for mutations
async function updateUser(formData: FormData) {
  "use server";
  // server-side logic
}

// ❌ Don't fetch data in Client Components when Server Components can do it
// ❌ Don't use "use client" unless you need client-side interactivity
```

---

## Styling

### TailwindCSS

**Version**: 3.x+

**Why**: Utility-first, consistent spacing, fast development

**Standards**:

```tsx
// ✅ Use Tailwind utilities
<div className="flex items-center gap-4 p-6 bg-white rounded-lg shadow-md">
  <img src={avatar} alt="Avatar" className="w-12 h-12 rounded-full" />
  <div className="flex-1">
    <h3 className="text-lg font-semibold">{name}</h3>
    <p className="text-sm text-gray-600">{email}</p>
  </div>
</div>

// ✅ Extract repeated patterns to components, not CSS classes
const Card = ({ children }: { children: React.ReactNode }) => (
  <div className="p-6 bg-white rounded-lg shadow-md">
    {children}
  </div>
);

// ✅ Use @apply sparingly for truly repeated patterns
// styles.css
.btn-primary {
  @apply px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700;
}

// ✅ Configure Tailwind for design system values
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#your-brand-color',
      },
      spacing: {
        '72': '18rem',
      }
    }
  }
};

// ❌ Don't write custom CSS when Tailwind has the utility
// ❌ Don't use inline styles (use Tailwind classes)
```

**Responsive Design**:

```tsx
<div className="text-sm md:text-base lg:text-lg">Responsive text</div>

// Breakpoints: sm (640px), md (768px), lg (1024px), xl (1280px), 2xl (1536px)
```

---

## Component Libraries

### Ant Design (AntD)

**Version**: 5.x+

**When to Use**: Internal tools, admin dashboards, data-heavy UIs

**Standards**:

```typescript
import { Button, Form, Input, Table } from 'antd';

// ✅ Use AntD for complex data interactions
<Table
  dataSource={users}
  columns={columns}
  pagination={{ pageSize: 10 }}
/>

// ✅ Customize theme tokens
// theme.ts
export const theme = {
  token: {
    colorPrimary: '#your-color',
    borderRadius: 8,
  }
};

// ✅ Use Form for complex forms
<Form onFinish={handleSubmit}>
  <Form.Item name="email" rules={[{ required: true, type: 'email' }]}>
    <Input />
  </Form.Item>
</Form>

// ❌ Don't mix AntD with ShadcnUI in the same project
```

---

### ShadcnUI

**Version**: Latest

**When to Use**: Customer-facing products, modern UIs, full design control

**Why**: Copy-paste components, full customization, no package dependency

**Standards**:

```typescript
// ✅ Copy components into your project
// components/ui/button.tsx
import { Button } from "@/components/ui/button"

<Button variant="default" size="lg">
  Click me
</Button>

// ✅ Customize copied components as needed
// You own the code, modify freely

// ✅ Use with Tailwind for styling
<Button className="bg-gradient-to-r from-blue-500 to-purple-600">
  Gradient Button
</Button>

// ❌ Don't mix ShadcnUI with AntD in the same project
```

**Choice Guideline**:

- **AntD**: Internal tools, admin panels, enterprise apps
- **ShadcnUI**: Customer-facing products, marketing sites, modern UIs

---

## Data Fetching

### Apollo Client (GraphQL)

**Version**: 3.x+

**When to Use**: GraphQL APIs

**Standards**:

```typescript
import { useQuery, useMutation, gql } from "@apollo/client";

// ✅ Define typed queries
const GET_USER = gql`
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
    }
  }
`;

const useUser = (id: string) => {
  const { data, loading, error } = useQuery(GET_USER, {
    variables: { id },
  });

  return { user: data?.user, loading, error };
};

// ✅ Use mutations with optimistic updates
const [updateUser] = useMutation(UPDATE_USER, {
  optimisticResponse: {
    updateUser: {
      __typename: "User",
      id,
      name: newName,
    },
  },
});

// ✅ Use fragments for reusable fields
const USER_FRAGMENT = gql`
  fragment UserFields on User {
    id
    name
    email
    avatar
  }
`;

// ❌ Don't fetch all fields if you only need a few
// ❌ Don't skip error handling
```

---

### TanStack Query (REST)

**Version**: 5.x+

**When to Use**: REST APIs, any async data

**Standards**:

```typescript
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

// ✅ Use query keys consistently
const useUser = (id: string) => {
  return useQuery({
    queryKey: ["user", id],
    queryFn: () => fetchUser(id),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};

// ✅ Invalidate queries after mutations
const queryClient = useQueryClient();

const useUpdateUser = () => {
  return useMutation({
    mutationFn: updateUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["user"] });
    },
  });
};

// ✅ Use suspense for simpler loading states
const { data } = useQuery({
  queryKey: ["user", id],
  queryFn: () => fetchUser(id),
  suspense: true,
});

// ❌ Don't manage loading/error states manually when React Query can
// ❌ Don't forget to set appropriate staleTime
```

---

## Routing

### TanStack Router

**Version**: Latest

**When to Use**: New projects, need type-safe routing

**Why**: Full TypeScript support, best-in-class type safety

**Standards**:

```typescript
import { createRoute, createRouter } from "@tanstack/react-router";

// ✅ Define type-safe routes
const userRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/users/$userId",
  loader: ({ params }) => fetchUser(params.userId),
  component: UserPage,
});

// ✅ Navigate with type safety
navigate({ to: "/users/$userId", params: { userId: "123" } });

// ✅ Access typed params
const { userId } = useParams({ from: userRoute.id });
```

---

### React Router v6

**Version**: 6.x

**When to Use**: Existing projects, familiar API

**Standards**:

```typescript
import { createBrowserRouter, RouterProvider } from 'react-router-dom';

// ✅ Use data router
const router = createBrowserRouter([
  {
    path: '/users/:userId',
    element: <UserPage />,
    loader: ({ params }) => fetchUser(params.userId)
  }
]);

// ✅ Use hooks
const { userId } = useParams();
const navigate = useNavigate();

// ✅ Type your params
const { userId } = useParams<{ userId: string }>();
```

**Choice Guideline**:

- **TanStack Router**: New projects, want full type safety
- **React Router v6**: Existing projects, team familiarity

---

## Build Tools

### Vite

**Version**: 5.x+

**Why**: Fast, modern, great DX

**All projects use Vite** unless Next.js (which has its own build system)

---

## Testing

### Vitest

**Why**: Fast, Vite-compatible, Jest-like API

```typescript
import { describe, it, expect } from "vitest";

describe("User utilities", () => {
  it("formats user name correctly", () => {
    expect(formatUserName({ firstName: "John", lastName: "Doe" })).toBe(
      "John Doe",
    );
  });
});
```

### React Testing Library

**Why**: Test behavior, not implementation

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

it('submits form', async () => {
  render(<LoginForm />);

  await userEvent.type(screen.getByLabelText('Email'), 'test@example.com');
  await userEvent.click(screen.getByRole('button', { name: 'Submit' }));

  expect(screen.getByText('Success')).toBeInTheDocument();
});
```

### Playwright

**Why**: E2E testing, multiple browsers

```typescript
import { test, expect } from "@playwright/test";

test("user can login", async ({ page }) => {
  await page.goto("/login");
  await page.fill('[name="email"]', "test@example.com");
  await page.click('button[type="submit"]');

  await expect(page).toHaveURL("/dashboard");
});
```

---

## Package Management

**Use**: pnpm (preferred) or npm

**Why pnpm**: Faster, disk-efficient, strict

```bash
# Install dependencies
pnpm install

# Add dependency
pnpm add package-name

# Add dev dependency
pnpm add -D package-name
```

---

## Version Control

**Commit Convention**: Conventional Commits

```bash
feat: add user profile page
fix: resolve navigation bug
refactor: optimize dashboard queries
docs: update API documentation
test: add tests for auth flow
chore: update dependencies
```

---

## Decision Framework

### Choosing React vs Astro vs Next.js

```text
Need SSR/SEO + Full App? → Next.js
Mostly Static Content? → Astro
SPA/Client-side Heavy? → React (Vite)
```

### Choosing AntD vs ShadcnUI

```text
Internal Tool/Admin? → AntD
Customer-facing? → ShadcnUI
Need data tables/complex forms? → AntD
Need full design control? → ShadcnUI
```

### Choosing Apollo vs TanStack Query

```text
GraphQL API? → Apollo Client
REST API? → TanStack Query
Any other async state? → TanStack Query
```

### Choosing TanStack Router vs React Router

```text
New project + want type safety? → TanStack Router
Existing project? → React Router v6
Team familiarity matters? → React Router v6
```

---

## Staying Updated

- Review release notes for major versions
- Test upgrades in feature branches
- Update this document when standards change
- Discuss major changes as a team

---

## Questions?

- Check [code standards](./code-standards.md) for conventions
- See [architecture](../architecture/) for patterns
- Ask in team channels

---

**Remember**: These tools are chosen for team productivity and consistency. Follow standards unless you have a documented reason to deviate.
