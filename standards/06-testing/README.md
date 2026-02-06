# Testing

> "If it's not tested, it's broken. If it's tested, you can refactor without fear."

---

## Foundational Principles

Before writing tests, understand these principles:

### 1. **Interface-First Thinking**

Test the contract, not the implementation. Test what users interact with, not internal details.

### 2. **DRY (Don't Repeat Yourself)**

Extract common test patterns into test utilities and helpers. Eliminate duplication.

### 3. **KISS (Keep It Simple, Stupid)**

Simple tests are easier to maintain. Don't over-test or test implementation details.

### 4. **YAGNI (You Aren't Gonna Need It)**

Write tests for actual bugs found, not theoretical scenarios. Don't test everything just to increase coverage.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Testing** is your safety net. Tests verify code works today and prevent regressions tomorrow. They enable refactoring, increase confidence, and document how code should behave.

Three levels of testing work together:

```
Integration Tests (10-15%)
    ↑↑↑↑↑
Unit Tests (60-70%)
  ↑↑↑↑↑↑↑↑
E2E Tests (10-15%)
```

The goal is **fast feedback with good coverage**, not 100% coverage.

---

## Goals

1. **Prevent Regressions** - Catch bugs before they reach production
2. **Enable Refactoring** - Change code with confidence
3. **Document Behavior** - Tests show how code should work
4. **Increase Velocity** - Spend less time debugging
5. **Reduce Bugs in Production** - Catch issues early

---

## Table of Contents

- [Testing Pyramid](#testing-pyramid)
- [Unit Testing](#unit-testing)
- [Integration Testing](#integration-testing)
- [E2E Testing](#e2e-testing)
- [Testing Strategy](#testing-strategy)
- [Best Practices](#best-practices)
- [Tools & Setup](#tools--setup)

---

## Testing Pyramid

### The Three Levels

```
        /\
       /E2E\        Fast to write, slow to run
      /─────\       10-15% of tests
     /Integr./      Reasonable cost
    /─────────\     50-60% of tests
   /   Unit   /     Slow to write, fast to run
  /───────────\     20-30% of tests
```

**Testing Distribution Target:**

- **Unit Tests: 60-70%** - Fast, isolated, precise feedback
- **Integration Tests: 15-25%** - Component interactions
- **E2E Tests: 5-15%** - Critical user journeys

---

## Unit Testing

### What to Test

**Unit tests test single functions/components in isolation.**

```typescript
// ✅ Good unit test targets
- Utility functions (formatDate, isEmail, etc.)
- Custom hooks (useDebounce, useLocalStorage)
- Business logic functions
- Reducer functions
- Component rendering with different props
- Error handling paths

// ❌ Avoid testing
- External APIs (mock them)
- Internal implementation details
- Complex integration scenarios
- Components with heavy dependencies
```

### Setup

```json
{
  "devDependencies": {
    "vitest": "^latest",
    "@testing-library/react": "^14",
    "@testing-library/jest-dom": "^6",
    "jsdom": "^latest"
  }
}
```

### Writing Unit Tests

#### Utility Function Test

```typescript
// src/utils/formatDate.test.ts
import { describe, it, expect } from "vitest";
import { formatDate } from "./formatDate";

describe("formatDate", () => {
  it("formats date to MM/DD/YYYY", () => {
    const date = new Date("2024-02-15");
    expect(formatDate(date)).toBe("02/15/2024");
  });

  it("handles invalid date", () => {
    expect(formatDate(null)).toBe("Invalid date");
  });

  it("handles edge cases", () => {
    const date = new Date("2024-01-01");
    expect(formatDate(date)).toBe("01/01/2024");
  });
});
```

#### Hook Test

```typescript
// src/hooks/useDebounce.test.ts
import { renderHook, act } from "@testing-library/react";
import { useDebounce } from "./useDebounce";

describe("useDebounce", () => {
  it("debounces value changes", async () => {
    let value = "initial";
    const { result, rerender } = renderHook(
      ({ val }) => useDebounce(val, 300),
      { initialProps: { val: value } },
    );

    // Initial value
    expect(result.current).toBe("initial");

    // Value changes but debounced value doesn't update immediately
    act(() => {
      value = "updated";
    });
    rerender({ val: value });
    expect(result.current).toBe("initial");

    // Wait for debounce
    await new Promise((resolve) => setTimeout(resolve, 350));
    rerender({ val: value });
    expect(result.current).toBe("updated");
  });
});
```

#### Component Test

```typescript
// src/components/Button.test.tsx
import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { Button } from './Button';

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);

    await screen.getByText('Click me').click();
    expect(handleClick).toHaveBeenCalledOnce();
  });

  it('respects disabled state', () => {
    const handleClick = vi.fn();
    render(
      <Button disabled onClick={handleClick}>
        Disabled Button
      </Button>
    );

    const button = screen.getByText('Disabled Button');
    expect(button).toBeDisabled();
  });

  it('renders loading state', () => {
    render(<Button loading>Loading...</Button>);
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });
});
```

### Unit Test Best Practices

```typescript
// ✅ DO: Test behavior, not implementation
describe("isEmail", () => {
  it("validates email format", () => {
    expect(isEmail("test@example.com")).toBe(true);
    expect(isEmail("invalid")).toBe(false);
  });
});

// ❌ DON'T: Test internal implementation
describe("isEmail", () => {
  it("calls regex.test()", () => {
    // Testing internal details
  });
});

// ✅ DO: Use descriptive test names
it("returns error when email is invalid", () => {});

// ❌ DON'T: Unclear test names
it("handles email", () => {});

// ✅ DO: Test one thing per test
it("validates valid email", () => {
  expect(isEmail("test@example.com")).toBe(true);
});

// ❌ DON'T: Test multiple things
it("validates email", () => {
  expect(isEmail("test@example.com")).toBe(true);
  expect(isEmail("invalid")).toBe(false);
  // Mix of valid and invalid testing
});

// ✅ DO: Test edge cases
describe("calculateDiscount", () => {
  it("returns 0 for null input", () => {});
  it("returns 0 for negative price", () => {});
  it("handles decimal values", () => {});
});

// ✅ DO: Mock external dependencies
it("fetches user data", async () => {
  const mockFetch = vi.fn().mockResolvedValue({
    json: () => ({ id: 1, name: "John" }),
  });
  global.fetch = mockFetch;

  const result = await getUser(1);
  expect(result.name).toBe("John");
});
```

---

## Integration Testing

### What to Test

**Integration tests test how components and functions work together.**

```typescript
// ✅ Good integration test targets
- Form submission with validation
- Component interaction (parent + child)
- Hooks working together
- Module exports working correctly
- Data flow between components

// ❌ Avoid testing
- External API calls (mock them)
- Full user journeys (use E2E tests)
- Individual functions (use unit tests)
```

### Writing Integration Tests

```typescript
// src/__tests__/LoginForm.integration.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { userEvent } from '@testing-library/user-event';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { LoginForm } from '@/modules/auth/LoginForm';
import { useAuthStore } from '@/stores/authStore';

// Mock the store
vi.mock('@/stores/authStore');

describe('LoginForm Integration', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('submits form with valid credentials', async () => {
    const mockLogin = vi.fn();
    vi.mocked(useAuthStore).mockReturnValue({
      login: mockLogin,
    } as any);

    render(<LoginForm />);

    const emailInput = screen.getByLabelText('Email');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByText('Login');

    await userEvent.type(emailInput, 'user@example.com');
    await userEvent.type(passwordInput, 'password123');
    await userEvent.click(submitButton);

    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith(
        'user@example.com',
        'password123'
      );
    });
  });

  it('shows validation error for invalid email', async () => {
    render(<LoginForm />);

    const emailInput = screen.getByLabelText('Email');
    const submitButton = screen.getByText('Login');

    await userEvent.type(emailInput, 'invalid-email');
    await userEvent.click(submitButton);

    expect(
      screen.getByText('Please enter a valid email')
    ).toBeInTheDocument();
  });

  it('disables submit button while loading', async () => {
    const mockLogin = vi.fn(
      () => new Promise(resolve => setTimeout(resolve, 1000))
    );
    vi.mocked(useAuthStore).mockReturnValue({
      login: mockLogin,
    } as any);

    render(<LoginForm />);

    const emailInput = screen.getByLabelText('Email');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByText('Login');

    await userEvent.type(emailInput, 'user@example.com');
    await userEvent.type(passwordInput, 'password123');
    await userEvent.click(submitButton);

    expect(submitButton).toBeDisabled();

    await waitFor(() => {
      expect(submitButton).not.toBeDisabled();
    });
  });
});
```

---

## E2E Testing

### What to Test

**E2E tests simulate real user behavior across the entire application.**

```typescript
// ✅ Good E2E test scenarios
- User completes signup flow
- User purchases product
- User creates post and deletes it
- User searches and filters results
- Critical user journeys

// ❌ Avoid testing
- Every button click (too granular)
- All error states (use unit/integration tests)
- Implementation details
- Things already tested in unit tests
```

### Setup

```bash
npm install --save-dev playwright
npx playwright install
```

### Writing E2E Tests

```typescript
// e2e/auth.spec.ts
import { test, expect } from "@playwright/test";

test.describe("User Authentication", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("http://localhost:3000");
  });

  test("user can sign up with valid credentials", async ({ page }) => {
    // Navigate to signup
    await page.click("text=Sign up");
    expect(page).toHaveURL("/signup");

    // Fill form
    await page.fill('[data-testid="email-input"]', "newuser@example.com");
    await page.fill('[data-testid="password-input"]', "SecurePass123");
    await page.fill('[data-testid="confirm-password-input"]', "SecurePass123");

    // Submit
    await page.click("text=Create Account");

    // Verify redirect
    await expect(page).toHaveURL("/dashboard", { timeout: 5000 });
    await expect(page.locator("text=Welcome, newuser")).toBeVisible();
  });

  test("user can log in and log out", async ({ page }) => {
    // Login
    await page.click("text=Log in");
    await page.fill('[data-testid="email-input"]', "user@example.com");
    await page.fill('[data-testid="password-input"]', "password123");
    await page.click("text=Login");

    await expect(page).toHaveURL("/dashboard");

    // Logout
    await page.click('[data-testid="user-menu"]');
    await page.click("text=Logout");

    await expect(page).toHaveURL("/login");
  });

  test("shows error for invalid credentials", async ({ page }) => {
    await page.click("text=Log in");
    await page.fill('[data-testid="email-input"]', "user@example.com");
    await page.fill('[data-testid="password-input"]', "wrongpassword");
    await page.click("text=Login");

    await expect(page.locator("text=Invalid email or password")).toBeVisible();
    expect(page).toHaveURL("/login");
  });
});
```

### E2E Testing Best Practices

```typescript
// ✅ DO: Wait for elements properly
await expect(page.locator("text=Loaded")).toBeVisible();

// ❌ DON'T: Use arbitrary waits
await page.waitForTimeout(5000);

// ✅ DO: Use test data attributes
await page.fill('[data-testid="email-input"]', "user@example.com");

// ❌ DON'T: Use fragile selectors
await page.fill("input.form-email", "user@example.com");

// ✅ DO: Test critical paths only
// Sign up → Create post → Share post

// ❌ DON'T: Test every single interaction
// Test every button, every error message
```

---

## Testing Strategy

### What Coverage Target?

```
✅ Aim for 70-80% coverage
- 100% coverage is rarely worth the time
- Focus on critical paths, not edge cases
- Some code doesn't need testing (getters, pure components)

High-value tests to prioritize:
- Business logic (calculations, validations)
- Error handling
- State management
- Critical user flows
```

### Test Organization

```
src/
├── __tests__/
│   ├── setupTests.ts          (test configuration)
│   └── mocks/                 (global mocks)
│       └── api.mock.ts
├── utils/
│   ├── formatDate.ts
│   └── formatDate.test.ts     (next to code)
├── hooks/
│   ├── useDebounce.ts
│   └── useDebounce.test.ts
└── modules/
    └── auth/
        ├── LoginForm.tsx
        ├── LoginForm.test.tsx
        └── __tests__/
            └── LoginForm.integration.test.tsx
```

### Mocking Strategy

```typescript
// Mock external dependencies
vi.mock("@/api/client", () => ({
  fetchUsers: vi.fn(),
}));

// Mock TanStack Query
vi.mock("@tanstack/react-query", () => ({
  useQuery: vi.fn(() => ({
    data: mockData,
    isLoading: false,
    error: null,
  })),
}));

// Mock API responses
global.fetch = vi.fn(() =>
  Promise.resolve({
    json: () => Promise.resolve({ id: 1, name: "John" }),
  }),
);
```

---

## Best Practices

### ✅ DO

- **Test behavior, not implementation** - Tests should not change when refactoring
- **Start with integration tests** - Test user behavior first
- **Mock external dependencies** - APIs, network calls, timers
- **Use descriptive test names** - "should show error when email invalid"
- **Keep tests simple** - One assertion per test is ideal
- **Use test data** - Create consistent test data
- **Test error paths** - Don't just test the happy path
- **Test accessibility** - Screen reader, keyboard support
- **Run tests in CI/CD** - Catch issues before production
- **Maintain tests** - Update tests when requirements change

### ❌ DON'T

- **Test implementation details** - Only test behavior
- **Create overly complex tests** - If test is hard to read, production code probably is too
- **Use arbitrary timeouts** - Use proper waitFor mechanisms
- **Mock everything** - Mock only external dependencies
- **Skip error cases** - Test what happens when things fail
- **Write tests after code** - Write tests first (TDD) or as you go
- **Ignore flaky tests** - Fix them immediately
- **Test trivial code** - Getters, constructors
- **Create tight coupling** - Tests should be independent

---

## Tools & Setup

### Recommended Setup

```json
{
  "devDependencies": {
    "vitest": "^1",
    "@testing-library/react": "^14",
    "@testing-library/jest-dom": "^6",
    "@testing-library/user-event": "^14",
    "@playwright/test": "^1",
    "jsdom": "^23",
    "happy-dom": "^12"
  }
}
```

### vitest.config.ts

```typescript
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: ["./src/__tests__/setupTests.ts"],
    coverage: {
      provider: "v8",
      reporter: ["text", "json", "html"],
      exclude: [
        "node_modules/",
        "src/__tests__/",
        "**/*.test.ts",
        "**/*.spec.ts",
      ],
      statements: 70,
      branches: 70,
      functions: 70,
      lines: 70,
    },
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
```

### setupTests.ts

```typescript
import "@testing-library/jest-dom";
import { expect, afterEach, vi } from "vitest";
import { cleanup } from "@testing-library/react";

// Cleanup after each test
afterEach(() => {
  cleanup();
});

// Mock IntersectionObserver
global.IntersectionObserver = class {
  constructor() {}
  disconnect() {}
  observe() {}
  unobserve() {}
  takeRecords() {
    return [];
  }
} as any;

// Mock window.matchMedia
Object.defineProperty(window, "matchMedia", {
  writable: true,
  value: vi.fn().mockImplementation((query) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
});
```

### npm scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:watch": "vitest --watch",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage",
    "e2e": "playwright test",
    "e2e:ui": "playwright test --ui",
    "e2e:debug": "playwright test --debug"
  }
}
```

---

## Workflow & Checklist

Before submitting code for review:

- [ ] New features have unit tests
- [ ] Business logic is tested
- [ ] Error paths are tested
- [ ] Integration tests added for user flows
- [ ] Coverage ≥ 70%
- [ ] All tests pass locally
- [ ] No console errors/warnings in tests
- [ ] Mocks are appropriate
- [ ] Accessibility tested (keyboard, screen reader)

---

## References

- [Vitest Documentation](https://vitest.dev/)
- [React Testing Library](https://testing-library.com/react)
- [Playwright Documentation](https://playwright.dev/)
- [Kent C. Dodds Testing Best Practices](https://testingjavascript.com/)
- [Testing Trophy](https://kentcdodds.com/blog/testing-trophy-and-testing-pyramid)
