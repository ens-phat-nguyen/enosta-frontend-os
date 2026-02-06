# Code Standards

General coding conventions and best practices for frontend development.

See [Tech Stack Standards](./tech-stack.md) for technology-specific guidelines.

---

## File Organization

> **Architecture Foundation**: This project follows the **F4ST architecture** (Foundation, Application, Shared, Types).
> See [standards/01-architecture/](../01-architecture/) for detailed layer documentation.

### Project Structure

We use a **three-layer architecture** with strict dependency flow:

```text
src/
├── shared/                    # Pure utilities (no dependencies)
│   ├── utils/
│   │   ├── format-currency.ts
│   │   ├── format-date.ts
│   │   └── index.ts
│   ├── hooks/
│   │   ├── use-debounce.ts
│   │   ├── use-local-storage.ts
│   │   └── index.ts
│   ├── types/
│   │   ├── api-response.type.ts
│   │   └── index.ts
│   └── validators/
│       ├── is-email.ts
│       └── index.ts
│
├── core/                      # Foundation & configuration
│   ├── api/
│   │   └── client.ts          # API client setup
│   ├── router/
│   │   └── router.tsx         # Router configuration
│   ├── store/
│   │   └── provider.tsx       # State management setup
│   └── ui/
│       └── provider.tsx       # UI library provider
│
└── modules/                   # Business features
    ├── auth/
    │   ├── components/
    │   │   ├── login-form.tsx
    │   │   └── user-avatar.tsx
    │   ├── hooks/
    │   │   └── use-auth.ts
    │   ├── api/
    │   │   └── auth-api.ts
    │   ├── types/
    │   │   └── user.type.ts
    │   └── index.ts           # Public API
    │
    ├── dashboard/
    │   ├── components/
    │   ├── hooks/
    │   └── index.ts
    │
    └── [feature-name]/
        ├── components/        # Feature-specific components
        ├── hooks/            # Feature-specific hooks
        ├── api/              # Feature API calls
        ├── types/            # Feature types
        ├── utils/            # Feature utilities
        └── index.ts          # Barrel export
```

**Dependency Flow Rules:**

- `modules/` → can import from `core/` and `shared/`
- `core/` → can import from `shared/` only
- `shared/` → imports nothing (completely portable)

**Quick Decision Guide:**

- Pure utility with no dependencies? → `shared/`
- Project setup or external service config? → `core/`
- Business logic or feature code? → `modules/`

### File Naming

Follow these conventions consistently:

```text
✅ Components: PascalCase
   UserProfile.tsx
   Button.tsx
   LoginForm.tsx

✅ Hooks: camelCase with 'use' prefix
   useUser.ts
   useAuth.ts
   useDebounce.ts

✅ Utils: camelCase or kebab-case
   formatDate.ts (or format-date.ts)
   validation.ts
   api-helpers.ts

✅ Types: PascalCase or lowercase with .type suffix
   User.ts
   user.type.ts
   api-response.type.ts

✅ API Files: kebab-case with -api suffix
   auth-api.ts
   user-api.ts

✅ Tests: Match source file with .test or .spec
   UserProfile.test.tsx
   formatDate.spec.ts
   use-auth.test.ts
```

**See also:** [Code Organization Standards](./16-code-organization/) for detailed naming patterns.

---

## Component Standards

### Component Structure

```typescript
// ✅ Good component structure
import { useState, useEffect } from 'react';
import type { User } from '@/types/User';

interface UserProfileProps {
  userId: string;
  onUpdate?: (user: User) => void;
}

export const UserProfile = ({ userId, onUpdate }: UserProfileProps) => {
  // 1. Hooks first
  const [user, setUser] = useState<User | null>(null);
  const [isEditing, setIsEditing] = useState(false);

  // 2. Effects
  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  // 3. Handlers
  const handleSave = async () => {
    if (!user) return;
    await updateUser(user);
    onUpdate?.(user);
    setIsEditing(false);
  };

  // 4. Early returns
  if (!user) return <Loading />;

  // 5. Main render
  return (
    <div className="user-profile">
      {isEditing ? (
        <EditForm user={user} onSave={handleSave} />
      ) : (
        <DisplayView user={user} onEdit={() => setIsEditing(true)} />
      )}
    </div>
  );
};
```

### Component Composition

```typescript
// ✅ Break down complex components
const UserProfile = ({ user }: { user: User }) => (
  <div>
    <UserHeader user={user} />
    <UserStats user={user} />
    <UserActivity user={user} />
  </div>
);

// ✅ Use children prop for flexible layouts
const Card = ({ children, title }: { children: React.ReactNode; title: string }) => (
  <div className="card">
    <h3>{title}</h3>
    <div className="card-content">{children}</div>
  </div>
);

// ❌ Don't create monolithic components
const MassiveComponent = () => {
  // 500 lines of JSX...
};
```

### Props

```typescript
// ✅ Use interfaces for props
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: "primary" | "secondary";
  disabled?: boolean;
}

// ✅ Provide defaults
const Button = ({
  label,
  onClick,
  variant = "primary",
  disabled = false,
}: ButtonProps) => {
  // ...
};

// ✅ Use children when appropriate
interface ContainerProps {
  children: React.ReactNode;
  className?: string;
}

// ❌ Don't pass too many props (>5-7 is a smell)
// Consider breaking down the component or using a config object
```

---

## TypeScript Standards

### Type Definitions

```typescript
// ✅ Define types explicitly
interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  createdAt: Date;
}

type UserRole = "admin" | "user" | "guest";

// ✅ Use enums for fixed sets of values
enum Status {
  Active = "ACTIVE",
  Inactive = "INACTIVE",
  Pending = "PENDING",
}

// ✅ Use utility types
type PartialUser = Partial<User>;
type UserWithoutId = Omit<User, "id">;
type UserRole = Pick<User, "role">;

// ✅ Use generics for reusable types
interface ApiResponse<T> {
  data: T;
  error?: string;
  loading: boolean;
}

// ❌ Don't use 'any' - use 'unknown' when type is truly unknown
const parseJSON = (str: string): unknown => {
  return JSON.parse(str);
};
```

### Function Types

```typescript
// ✅ Type function parameters and returns
const calculateTotal = (items: CartItem[]): number => {
  return items.reduce((sum, item) => sum + item.price, 0);
};

// ✅ Type async functions
const fetchUser = async (id: string): Promise<User> => {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
};

// ✅ Type event handlers
const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
  event.preventDefault();
  // ...
};

// ✅ Type callbacks
interface FormProps {
  onSubmit: (values: FormValues) => void | Promise<void>;
  onError?: (error: Error) => void;
}
```

---

## Naming Conventions

### Variables and Functions

```typescript
// ✅ Use descriptive names
const userProfileData = await fetchUserProfile(userId);
const isUserActive = user.status === "active";

// ✅ Boolean variables: is/has/can/should prefix
const isLoading = true;
const hasPermission = checkPermission(user);
const canEdit = user.role === "admin";
const shouldShowModal = errors.length > 0;

// ✅ Functions: verb + noun
const fetchUserData = () => {
  /* ... */
};
const validateEmail = (email: string) => {
  /* ... */
};
const handleSubmit = () => {
  /* ... */
};

// ❌ Don't use abbreviations unless universally known
const usr = {}; // Bad
const user = {}; // Good

const btn = ""; // Bad
const button = ""; // Good

const API = ""; // Good (universally known)
const req = {}; // Bad (use 'request')
```

### Constants

```typescript
// ✅ Use UPPER_SNAKE_CASE for true constants
const MAX_RETRY_ATTEMPTS = 3;
const API_BASE_URL = "https://api.example.com";
const DEFAULT_PAGE_SIZE = 20;

// ✅ Group related constants
const BREAKPOINTS = {
  MOBILE: 640,
  TABLET: 768,
  DESKTOP: 1024,
  WIDE: 1280,
} as const;
```

---

## Code Style

### Functions

```typescript
// ✅ Keep functions small and focused
const calculateTotal = (items: CartItem[]): number => {
  return items.reduce((sum, item) => sum + item.price, 0);
};

const applyDiscount = (total: number, discount: number): number => {
  return total * (1 - discount);
};

// ✅ Use early returns to reduce nesting
const processUser = (user: User | null): ProcessedUser => {
  if (!user) return DEFAULT_USER;
  if (!user.isActive) return INACTIVE_USER;

  return {
    ...user,
    processedAt: new Date(),
  };
};

// ❌ Don't nest deeply
const badExample = () => {
  if (condition1) {
    if (condition2) {
      if (condition3) {
        // deeply nested
      }
    }
  }
};
```

### Arrow Functions vs Regular Functions

```typescript
// ✅ Use arrow functions for simple expressions
const double = (x: number) => x * 2;

// ✅ Use regular functions for methods that need 'this'
class UserService {
  getUserName() {
    return this.user.name;
  }
}

// ✅ Use arrow functions in React components
const Button = ({ onClick }: Props) => {
  return <button onClick={onClick}>Click</button>;
};
```

### Destructuring

```typescript
// ✅ Use destructuring to extract values
const { name, email, role } = user;

// ✅ Use default values
const { theme = "light", locale = "en" } = settings;

// ✅ Rename when needed
const { name: userName, id: userId } = user;

// ✅ Destructure function parameters
const UserCard = ({ name, email, avatar }: User) => {
  // ...
};

// ❌ Don't over-destructure (hurts readability)
const {
  user: {
    profile: {
      settings: {
        notifications: { email: emailNotifications },
      },
    },
  },
} = data; // Too deep
```

### Template Literals

```typescript
// ✅ Use template literals for string interpolation
const greeting = `Hello, ${user.name}!`;
const url = `/api/users/${userId}/posts`;

// ✅ Use for multi-line strings
const message = `
  Welcome to our platform!
  We're glad to have you here.
`;

// ❌ Don't concatenate strings with +
const url = "/api/users/" + userId + "/posts"; // Bad
```

---

## Async/Await

```typescript
// ✅ Use async/await over promise chains
const fetchUserPosts = async (userId: string): Promise<Post[]> => {
  const user = await fetchUser(userId);
  const posts = await fetchPosts(user.id);
  return posts;
};

// ✅ Handle errors properly
const fetchUserSafe = async (userId: string): Promise<User | null> => {
  try {
    return await fetchUser(userId);
  } catch (error) {
    console.error("Failed to fetch user:", error);
    return null;
  }
};

// ✅ Run parallel requests when possible
const fetchDashboardData = async () => {
  const [user, posts, stats] = await Promise.all([
    fetchUser(),
    fetchPosts(),
    fetchStats(),
  ]);

  return { user, posts, stats };
};

// ❌ Don't use .then() chains (use async/await instead)
// ❌ Don't forget error handling
```

---

## Error Handling

```typescript
// ✅ Use try/catch for async operations
const saveUser = async (user: User): Promise<void> => {
  try {
    await api.saveUser(user);
    showSuccessMessage("User saved!");
  } catch (error) {
    if (error instanceof ValidationError) {
      showError(error.message);
    } else {
      showError("Failed to save user");
      logError(error);
    }
  }
};

// ✅ Create custom error types
class ValidationError extends Error {
  constructor(
    message: string,
    public field: string,
  ) {
    super(message);
    this.name = "ValidationError";
  }
}

// ✅ Type errors when catching
try {
  // ...
} catch (error) {
  if (error instanceof Error) {
    console.error(error.message);
  }
}
```

---

## Comments

```typescript
// ✅ Explain WHY, not WHAT
// Using setTimeout to defer execution until after DOM update
setTimeout(() => {
  measureHeight();
}, 0);

// ✅ Document complex logic
/**
 * Calculates the discount based on user tier and purchase amount.
 * Premium users get 20% off, regular users get 10% off.
 * Orders over $100 get an additional 5% off.
 */
const calculateDiscount = (user: User, amount: number): number => {
  // ...
};

// ✅ Mark TODOs and FIXMEs
// TODO: Add pagination support
// FIXME: This breaks on Safari < 14

// ❌ Don't state the obvious
// Set the user name
const name = user.name; // Bad comment

// ❌ Don't leave commented-out code
// const oldImplementation = () => {
//   // old code...
// };
```

---

## Imports

```typescript
// ✅ Group imports logically
// 1. External dependencies
import { useState, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";

// 2. Internal utilities/hooks
import { useAuth } from "@/hooks/useAuth";
import { formatDate } from "@/utils/date";

// 3. Types
import type { User } from "@/types/User";

// 4. Components
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";

// 5. Styles (if any)
import "./styles.css";

// ✅ Use path aliases
import { Button } from "@/components/ui/Button";
// Instead of: import { Button } from '../../../components/ui/Button';

// ❌ Don't use wildcard imports
import * as Utils from "./utils"; // Bad
import { formatDate, parseDate } from "./utils"; // Good
```

---

## Magic Numbers

```typescript
// ❌ Don't use magic numbers
setTimeout(callback, 3600000);
if (user.age > 18) {
  /* ... */
}

// ✅ Extract to named constants
const ONE_HOUR_MS = 60 * 60 * 1000;
setTimeout(callback, ONE_HOUR_MS);

const LEGAL_AGE = 18;
if (user.age > LEGAL_AGE) {
  /* ... */
}
```

---

## Testing Standards

```typescript
// ✅ Describe what you're testing
describe('UserProfile', () => {
  it('displays user name', () => {
    // ...
  });

  it('shows edit button for admin users', () => {
    // ...
  });

  it('handles missing data gracefully', () => {
    // ...
  });
});

// ✅ Use Arrange-Act-Assert pattern
it('submits form successfully', async () => {
  // Arrange
  const handleSubmit = vi.fn();
  render(<Form onSubmit={handleSubmit} />);

  // Act
  await userEvent.type(screen.getByLabelText('Email'), 'test@example.com');
  await userEvent.click(screen.getByRole('button', { name: 'Submit' }));

  // Assert
  expect(handleSubmit).toHaveBeenCalledWith({ email: 'test@example.com' });
});

// ✅ Test behavior, not implementation
// Good: Test what the user sees/does
expect(screen.getByText('Welcome')).toBeInTheDocument();

// Bad: Test implementation details
expect(component.state.isLoggedIn).toBe(true);
```

---

## Performance

```typescript
// ✅ Memoize expensive computations
const expensiveValue = useMemo(() => {
  return complexCalculation(data);
}, [data]);

// ✅ Memoize callbacks passed to children
const handleClick = useCallback(() => {
  doSomething(value);
}, [value]);

// ✅ Use React.memo for expensive renders
export const ExpensiveComponent = React.memo(({ data }: Props) => {
  // ...
});

// ✅ Lazy load heavy components
const HeavyChart = lazy(() => import("./HeavyChart"));

// ❌ Don't premature optimize
// Only memoize if you've identified a performance issue
```

---

## Accessibility

```typescript
// ✅ Use semantic HTML
<button onClick={handleClick}>Click me</button>
<nav><ul><li><a href="/">Home</a></li></ul></nav>

// ✅ Add ARIA labels when needed
<button aria-label="Close dialog" onClick={onClose}>
  <X />
</button>

// ✅ Support keyboard navigation
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => e.key === 'Enter' && handleClick()}
>
  Click me
</div>

// ✅ Provide alt text for images
<img src={avatar} alt={`${user.name}'s profile picture`} />

// ❌ Don't use div for buttons
<div onClick={handleClick}>Click</div> // Bad
```

---

## Security

```typescript
// ✅ Sanitize user input
import DOMPurify from 'dompurify';

const SafeHTML = ({ html }: { html: string }) => (
  <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(html) }} />
);

// ✅ Validate on both client and server
const validateEmail = (email: string): boolean => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
};

// ❌ Don't trust client-side validation alone
// ❌ Don't expose sensitive data in client code
// ❌ Don't store tokens in localStorage (use httpOnly cookies)
```

---

## Git Commits

```bash
# ✅ Use conventional commits
feat: add user profile page
fix: resolve navigation bug on mobile
refactor: extract user validation logic
docs: update API documentation
test: add tests for auth flow
chore: update dependencies
perf: optimize image loading

# ✅ Write descriptive commit messages
git commit -m "feat: add password reset flow

- Add reset password form
- Implement email verification
- Add success/error states
- Update tests"

# ❌ Don't commit without context
git commit -m "fix stuff"
git commit -m "wip"
```

---

## Code Review Checklist

Before submitting a PR, verify:

- [ ] Code follows these standards
- [ ] TypeScript types are correct
- [ ] No console.log statements (use proper logging)
- [ ] Tests are written and passing
- [ ] No unused imports or variables
- [ ] Accessibility requirements met
- [ ] Performance considered
- [ ] Error handling implemented
- [ ] Documentation updated
- [ ] No TODO comments without issue links

---

## Tools & Automation

### ESLint

Enforce standards automatically:

```json
{
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended"
  ],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "react/react-in-jsx-scope": "off"
  }
}
```

### Prettier

Format code consistently:

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
```

### Husky

Run checks before commit:

```json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "pre-push": "npm test"
    }
  }
}
```

---

## Questions?

- See [tech stack](./tech-stack.md) for technology-specific standards
- Check [architecture](../architecture/) for design patterns
- Review [workflows](../workflows/) for process guidance

---

**Remember**: Standards exist to improve code quality and team collaboration. Follow them consistently, but propose changes when they don't serve the team well.
