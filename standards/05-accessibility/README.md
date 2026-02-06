# Accessibility (A11y)

> "Accessibility is not a feature. It's a fundamental right. Building without it is building for only some of your users."

---

## Foundational Principles

Before implementing accessibility features, understand these principles:

### 1. **Interface-First Thinking**

Design with accessibility in mind from the start. Don't add it later as an afterthought.

### 2. **KISS (Keep It Simple, Stupid)**

Simple, semantic HTML is inherently more accessible. Avoid complex custom components.

### 3. **DRY (Don't Repeat Yourself)**

Create reusable accessible components. Don't duplicate accessibility logic.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Accessibility (A11y)** means creating applications that work for everyone, including people with disabilities. This includes visual impairments, hearing impairments, motor disabilities, cognitive disabilities, and temporary disabilities (like a broken arm).

Accessibility benefits everyone:

- **Visual impairments** - Screen readers, high contrast modes
- **Motor disabilities** - Keyboard navigation, voice control
- **Hearing impairments** - Captions, transcripts
- **Cognitive disabilities** - Clear language, predictable patterns
- **Temporary disabilities** - Working with one hand, slow internet

---

## Goals

1. **WCAG 2.1 AA Compliance** - Industry standard for accessibility
2. **Keyboard Navigation** - All features accessible without mouse
3. **Screen Reader Support** - Content understandable with screen readers
4. **Visual Clarity** - High contrast, readable text
5. **Predictability** - Consistent, understandable interactions

---

## Table of Contents

- [WCAG Standards](#wcag-standards)
- [Semantic HTML](#semantic-html)
- [Keyboard Navigation](#keyboard-navigation)
- [Screen Readers](#screen-readers)
- [Visual Design](#visual-design)
- [Form Accessibility](#form-accessibility)
- [Testing Tools](#testing-tools)
- [Best Practices](#best-practices)

---

## WCAG Standards

### WCAG 2.1 Levels

| Level   | Difficulty | Requirements                            |
| ------- | ---------- | --------------------------------------- |
| **A**   | Basic      | Minimum compliance, easy to implement   |
| **AA**  | Standard   | ✅ **Target for most applications**     |
| **AAA** | Enhanced   | Maximum compliance, harder to implement |

**Default Target: WCAG 2.1 AA**

### Four Core Principles

```
P  Perceivable  → Users can perceive all content
↓
O  Operable      → Users can navigate and operate interface
↓
U  Understandable → Content and operation are clear
↓
R  Robust        → Works with assistive technologies

POUR principles = WCAG compliance
```

---

## Semantic HTML

### Use Semantic Elements

**Good semantic HTML is the foundation of accessibility.**

```html
<!-- Bad: Meaningless divs -->
<div class="header">
  <div class="nav">
    <div class="link">Home</div>
  </div>
</div>

<!-- Good: Semantic elements -->
<header>
  <nav>
    <a href="/">Home</a>
  </nav>
</header>
```

### Common Semantic Elements

| Element      | Purpose                | Use When                |
| ------------ | ---------------------- | ----------------------- |
| `<button>`   | Clickable action       | User performs an action |
| `<a>`        | Link                   | Navigating to URL       |
| `<form>`     | Form container         | Collecting user input   |
| `<label>`    | Form label             | Labeling form inputs    |
| `<fieldset>` | Related form fields    | Grouping related inputs |
| `<nav>`      | Navigation section     | Main navigation         |
| `<main>`     | Main content           | Primary page content    |
| `<header>`   | Page header            | Page/section header     |
| `<footer>`   | Page footer            | Page/section footer     |
| `<article>`  | Self-contained content | Blog post, news article |
| `<section>`  | Themed content group   | Related content section |

### Never Do This

```html
<!-- ❌ DON'T: Use div for button -->
<div class="button" onclick="handleClick()">Click me</div>

<!-- ✅ DO: Use button element -->
<button onClick="{handleClick}">Click me</button>

<!-- ❌ DON'T: Use span for link -->
<span onclick="navigate('/')">Home</span>

<!-- ✅ DO: Use anchor -->
<a href="/">Home</a>

<!-- ❌ DON'T: Generic text for headings -->
<p style="font-size: 24px; font-weight: bold">Section Title</p>

<!-- ✅ DO: Use heading element -->
<h2>Section Title</h2>
```

---

## Keyboard Navigation

### Keyboard Support Checklist

Every interactive element must be usable with keyboard:

- [ ] **Tab** - Move focus forward
- [ ] **Shift+Tab** - Move focus backward
- [ ] **Enter** - Activate button/link
- [ ] **Space** - Toggle checkbox/button
- [ ] **Arrow Keys** - Navigate menus, tabs, sliders
- [ ] **Escape** - Close modals, menus

### Focus Management

```typescript
// Bad: Focus visible by default but no visible indicator
button {
  outline: none; /* ❌ Removes focus indicator */
}

// Good: Clear focus indicator
button:focus-visible {
  outline: 2px solid #0066cc; /* ✅ Visible on keyboard focus */
  outline-offset: 2px;
}

// Good: Use focus-visible to only show for keyboard
button:focus-visible {
  outline: 2px solid blue;
}
button:focus:not(:focus-visible) {
  outline: none; /* Hide for mouse focus */
}
```

### Tab Order

```html
<!-- Tab order follows DOM order by default - use semantic HTML -->
<button>First</button>
<button>Second</button>
<button>Third</button>

<!-- Only use tabindex in special cases -->
<!-- ❌ Avoid positive tabindex -->
<button tabindex="3">Should be third</button>

<!-- ✅ Only use tabindex="-1" to remove from tab order -->
<button tabindex="-1">Hidden from tab order</button>

<!-- ✅ Use tabindex="0" to make div focusable (but use button instead) -->
<div tabindex="0" role="button">Custom button</div>
```

### Skip Links

```html
<!-- Allow users to skip to main content -->
<header>
  <a href="#main" class="skip-link">Skip to main content</a>
  <nav>...</nav>
</header>

<main id="main">
  <!-- Main content here -->
</main>

<style>
  .skip-link {
    position: absolute;
    left: -9999px;
  }

  .skip-link:focus {
    left: 0; /* Show on focus */
  }
</style>
```

---

## Screen Readers

### Using ARIA (Accessible Rich Internet Applications)

ARIA provides additional semantic information to screen readers.

```typescript
// Bad: No indication what this button does
<button>+</button>

// Good: aria-label provides context
<button aria-label="Add to cart">+</button>

// Bad: Screen reader doesn't know status changed
<div id="status">Ready</div>

// Good: ARIA live region announces changes
<div id="status" aria-live="polite" aria-atomic="true">Ready</div>

// Bad: Image without description
<img src="dashboard.png" />

// Good: alt text describes image
<img src="dashboard.png" alt="Sales dashboard showing 42% increase" />
```

### Common ARIA Attributes

| Attribute          | Purpose                                      | Example                     |
| ------------------ | -------------------------------------------- | --------------------------- |
| `aria-label`       | Label for element without visible text       | Button with icon            |
| `aria-labelledby`  | Element ID that labels this element          | Label associated with field |
| `aria-describedby` | Element ID with description                  | Help text for field         |
| `aria-live`        | Announce dynamic content changes             | Toast notifications         |
| `aria-hidden`      | Hide decorative elements from screen readers | Icon that's only visual     |
| `aria-expanded`    | Indicate expanded/collapsed state            | Accordion, menu             |
| `aria-selected`    | Indicate selected state                      | Tab, menu item              |
| `aria-disabled`    | Indicate disabled state                      | Disabled button             |
| `role`             | Override semantic meaning                    | `<div role="button">`       |

### When to Use ARIA

```typescript
// ✅ DO: Announce dynamic changes
<div aria-live="polite">
  {itemCount} items in cart
</div>

// ✅ DO: Label icon-only buttons
<button aria-label="Close dialog">
  <Icon name="close" />
</button>

// ✅ DO: Describe form field errors
<input
  aria-describedby="error"
  aria-invalid={hasError}
/>
<span id="error">Email format invalid</span>

// ❌ DON'T: Use role when semantic HTML exists
<div role="button">Click me</div> {/* Use <button> */}

// ❌ DON'T: Hide keyboard-accessible elements
<div aria-hidden="true" tabindex="0">
  {/* Screen readers won't announce, but keyboard can focus */}
</div>

// ❌ DON'T: Use aria-label on already labeled elements
<button aria-label="Submit">
  <Icon name="send" /> Submit {/* Screen reader announces twice */}
</button>
```

---

## Visual Design

### Color Contrast

**WCAG AA requires 4.5:1 contrast ratio for normal text.**

```css
/* Bad: Insufficient contrast (2.5:1) */
p {
  color: #999; /* Gray on white */
  background: white;
}

/* Good: Sufficient contrast (7:1) */
p {
  color: #333; /* Dark gray on white */
  background: white;
}

/* Test with: https://webaim.org/resources/contrastchecker/ */
```

### Don't Rely on Color Alone

```html
<!-- Bad: Status only indicated by color -->
<div style="color: red;">Error</div>

<!-- Good: Color + text + icon -->
<div><Icon name="error" /> Error</div>

<!-- Good: Color + pattern -->
<div style="border: 2px solid red; border-radius: 2px;">Error</div>
```

### Readable Text

```css
/* Font size */
body {
  font-size: 16px; /* Minimum - 14px is too small */
}

/* Line height (spacing) */
p {
  line-height: 1.5; /* Helps with dyslexia */
}

/* Letter spacing */
p {
  letter-spacing: 0.12em; /* Can help readability */
}

/* Font family */
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  /* Avoid decorative/script fonts for body text */
}

/* Text alignment */
p {
  text-align: left; /* Justified text is harder to read */
}
```

---

## Form Accessibility

### Accessible Form Inputs

```typescript
// Bad: No association between label and input
<label>Email:</label>
<input type="email" />

// Good: Proper label association
<label htmlFor="email">Email:</label>
<input id="email" type="email" />

// Bad: Placeholder instead of label
<input placeholder="Email address" />

// Good: Label + placeholder
<label htmlFor="email">Email address:</label>
<input id="email" placeholder="you@example.com" type="email" />

// Bad: Error with no context
{hasError && <span>Invalid</span>}

// Good: Error with aria attributes
<label htmlFor="email">Email address:</label>
<input
  id="email"
  type="email"
  aria-invalid={hasError}
  aria-describedby={hasError ? "email-error" : undefined}
/>
{hasError && (
  <span id="email-error" role="alert">
    Please enter a valid email address
  </span>
)}

// Bad: Unlabeled required field
<input type="email" required />

// Good: Clear required indication
<label htmlFor="email">
  Email address
  <span aria-label="required">*</span>
</label>
<input id="email" type="email" required />
```

### Form Error Handling

```typescript
function LoginForm() {
  const [errors, setErrors] = useState({});
  const [touched, setTouched] = useState({});

  const handleBlur = (field) => {
    setTouched({ ...touched, [field]: true });
  };

  return (
    <form>
      <fieldset>
        <legend>Login</legend>

        <label htmlFor="email">Email address:</label>
        <input
          id="email"
          type="email"
          aria-invalid={touched.email && !!errors.email}
          aria-describedby={errors.email ? "email-error" : undefined}
          onBlur={() => handleBlur('email')}
        />
        {errors.email && (
          <span id="email-error" role="alert">
            {errors.email}
          </span>
        )}

        <label htmlFor="password">Password:</label>
        <input
          id="password"
          type="password"
          aria-invalid={touched.password && !!errors.password}
          aria-describedby={errors.password ? "password-error" : undefined}
          onBlur={() => handleBlur('password')}
        />
        {errors.password && (
          <span id="password-error" role="alert">
            {errors.password}
          </span>
        )}

        <button type="submit">Login</button>
      </fieldset>
    </form>
  );
}
```

---

## Testing Tools

### Automated Testing

| Tool             | Purpose           | Notes                       |
| ---------------- | ----------------- | --------------------------- |
| **axe DevTools** | Browser extension | Quick audit of current page |
| **WAVE**         | Browser extension | Visual feedback on issues   |
| **Lighthouse**   | Built into Chrome | Accessibility score         |
| **jest-axe**     | Automated testing | Unit test accessibility     |
| **Pa11y**        | CLI tool          | Command-line auditing       |

### Manual Testing

**Keyboard Navigation Test:**

1. Unplug mouse
2. Navigate entire page with Tab, Enter, Space, Arrow keys
3. Can you reach all interactive elements?

**Screen Reader Test:**

- Use built-in screen readers:
  - macOS: VoiceOver (Cmd+F5)
  - Windows: NVDA (free, download)
  - Chrome: ChromeVox extension

**Color Contrast Test:**

- WebAIM Contrast Checker: https://webaim.org/resources/contrastchecker/
- Ensure ≥ 4.5:1 for normal text

### Adding Jest Accessibility Testing

```typescript
// src/__tests__/Button.test.tsx
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

describe('Button', () => {
  it('should not have accessibility violations', async () => {
    const { container } = render(<button>Click me</button>);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```

---

## Best Practices

### ✅ DO

- **Use semantic HTML** - `<button>`, `<a>`, `<label>`, etc.
- **Test with keyboard** - Mouse is optional
- **Include alt text** - Describe images
- **Provide captions** - Videos should have captions
- **Use sufficient contrast** - 4.5:1 minimum
- **Write clear link text** - Avoid "click here"
- **Use form labels** - Associate with inputs
- **Test with screen readers** - NVDA, VoiceOver, JAWS
- **Follow focus indicators** - Show where keyboard focus is
- **Use ARIA sparingly** - Only when semantic HTML won't work

### ❌ DON'T

- **Rely on color alone** - Use text, icons, patterns too
- **Use placeholder as label** - Placeholders disappear
- **Hide focus indicators** - Users need to know where they are
- **Use role when HTML exists** - `<button>` instead of `<div role="button">`
- **Autoplay audio/video** - Let users control
- **Use overly complex language** - Write clearly
- **Skip alt text** - Images need descriptions
- **Create keyboard traps** - Users must be able to escape
- **Use decorative images with alt text** - Use `alt=""` for decorative images
- **Forget about mobile/touch** - Consider all interactions

---

## Architecture Integration

### Where Accessibility Lives in Code

```
MODULES
├── forms/
│   └── LoginForm.tsx (form accessibility)
├── components/
│   ├── Button.tsx (aria-label, focus)
│   └── Modal.tsx (focus trap, semantics)
└── layouts/
    └── MainLayout.tsx (skip links, landmarks)

CORE
├── components/
│   ├── Input.tsx (label association)
│   ├── Button.tsx (reusable with a11y)
│   └── FormFieldWrapper.tsx (error handling)
└── hooks/
    └── useFocusTrap.ts

SHARED
├── hooks/
│   ├── useAriaLive.ts
│   ├── useFocusVisible.ts
│   └── useKeyboardNavigation.ts
└── utils/
    └── contrastChecker.ts
```

---

## Workflow & Checklist

Before shipping features:

- [ ] All text ≥ 16px or 14px with 1.5 line height
- [ ] Color contrast ≥ 4.5:1 verified
- [ ] All interactive elements keyboard accessible
- [ ] Form fields properly labeled
- [ ] Images have alt text
- [ ] Links have descriptive text (not "click here")
- [ ] Focus indicators visible
- [ ] Tested with keyboard only
- [ ] Tested with screen reader (NVDA or VoiceOver)
- [ ] Axe DevTools run with no violations

---

## References

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)
- [Web.dev Accessibility](https://web.dev/accessibility/)
- [ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [axe DevTools](https://www.deque.com/axe/devtools/)
- [jest-axe](https://github.com/nickcolley/jest-axe)
