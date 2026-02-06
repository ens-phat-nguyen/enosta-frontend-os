# Form Handling

> "Forms are the most complex part of web applications. Get this right."

---

## Foundational Principles

Before building forms, understand these principles:

### 1. **Interface-First Thinking**

Design form state and validation rules before implementation. What data do you need? What are the rules?

### 2. **KISS (Keep It Simple, Stupid)**

Use proven libraries (React Hook Form). Don't build custom form state.

### 3. **DRY (Don't Repeat Yourself)**

Extract validation rules, error components, and field wrappers.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Form Handling** encompasses:

1. **State Management** — Track input values
2. **Validation** — Rules and error messages
3. **Submission** — Async operations, error handling
4. **UX** — Disable buttons, show errors, provide feedback

Bad form handling = Data loss, frustration, support tickets.

---

## Goals

1. **Minimize Re-renders** — Form state changes shouldn't re-render everything
2. **Easy Validation** — Declarative rules, reusable validators
3. **Good UX** — Error messaging, loading states, recovery
4. **Type Safety** — Form data is strongly typed
5. **Testing** — Easy to test form behavior

---

## Table of Contents

- [Foundational Principles](#foundational-principles)
- [Form Architecture](#form-architecture)
- [React Hook Form](#react-hook-form)
- [Validation Patterns](#validation-patterns)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)

---

## Form Architecture

### Single Form (Local State)

```typescript
// ✅ Use React Hook Form for single forms
interface LoginFormData {
  email: string;
  password: string;
}

const LoginForm: FC = () => {
  const { register, handleSubmit, formState: { errors } } = useForm<LoginFormData>({
    mode: 'onBlur' // Validate on blur, not on every keystroke
  });

  const onSubmit = async (data: LoginFormData) => {
    try {
      await loginUser(data);
    } catch (error) {
      // Handle error
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email', { required: 'Email required' })} />
      {errors.email && <span>{errors.email.message}</span>}

      <input {...register('password', { required: 'Password required' })} />
      {errors.password && <span>{errors.password.message}</span>}

      <button type="submit">Login</button>
    </form>
  );
};
```

### Multi-Step Form (Zustand + React Hook Form)

```typescript
// ✅ Multi-step: Use Zustand to persist state across steps
interface CheckoutState {
  step1: { email: string };
  step2: { address: string };
  step3: { paymentMethod: string };
  updateStep: (step: keyof CheckoutState, data: unknown) => void;
}

const useCheckoutStore = create<CheckoutState>((set) => ({
  step1: { email: '' },
  step2: { address: '' },
  step3: { paymentMethod: '' },
  updateStep: (step, data) => set({ [step]: data } as CheckoutState)
}));

function CheckoutStep1() {
  const { step1, updateStep } = useCheckoutStore();
  const { register, handleSubmit } = useForm({
    defaultValues: step1
  });

  return (
    <form onSubmit={handleSubmit((data) => updateStep('step1', data))}>
      {/* form */}
    </form>
  );
}
```

---

## React Hook Form

### Basic Setup

```typescript
import { useForm } from 'react-hook-form';

function MyForm() {
  const {
    register,           // Register input
    handleSubmit,       // Wrap form submission
    formState: { errors, isSubmitting },
    watch,             // Watch field changes
    setValue           // Set field value programmatically
  } = useForm();

  return (
    <form onSubmit={handleSubmit(async (data) => {
      // This only runs if validation passes
      await submitForm(data);
    })}>
      {/* form content */}
    </form>
  );
}
```

### Custom Components

```typescript
// ✅ Reusable text input
interface TextInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

const TextInput = forwardRef<HTMLInputElement, TextInputProps>(
  ({ label, error, ...rest }, ref) => (
    <div>
      {label && <label>{label}</label>}
      <input ref={ref} {...rest} />
      {error && <span className="error">{error}</span>}
    </div>
  )
);

// Usage with React Hook Form
const { register, formState: { errors } } = useForm();

<TextInput
  label="Email"
  {...register('email', { required: 'Required' })}
  error={errors.email?.message}
/>
```

---

## Validation Patterns

### Built-in Validation

```typescript
const { register } = useForm();

<input
  {...register('email', {
    required: 'Email is required',
    pattern: {
      value: /^[^@]+@[^@]+\.[^@]+$/,
      message: 'Invalid email'
    },
    minLength: { value: 5, message: 'Too short' }
  })}
/>
```

### Custom Validators

```typescript
// ✅ Reusable validation rules
const validators = {
  email: (value: string) => {
    if (!value.includes('@')) return 'Invalid email';
    return true;
  },
  password: (value: string) => {
    if (value.length < 8) return 'Min 8 characters';
    if (!/[A-Z]/.test(value)) return 'Need uppercase';
    return true;
  }
};

<input {...register('email', { validate: validators.email })} />
```

### Schema Validation (Zod)

```typescript
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";

const schema = z
  .object({
    email: z.string().email("Invalid email"),
    password: z.string().min(8, "Min 8 characters"),
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Passwords must match",
    path: ["confirmPassword"],
  });

const {
  register,
  formState: { errors },
} = useForm({
  resolver: zodResolver(schema),
});
```

---

## Error Handling

### Async Validation

```typescript
// ✅ Validate against server (check if email exists)
const checkEmailExists = async (email: string) => {
  const exists = await fetch(`/api/users/${email}`).then(r => r.ok);
  return !exists || 'Email already registered';
};

<input
  {...register('email', {
    required: 'Required',
    validate: {
      async checkEmail(value) {
        return await checkEmailExists(value);
      }
    }
  })}
/>
```

### Server Errors

```typescript
const {
  register,
  setError,
  formState: { errors },
} = useForm<LoginData>();

const onSubmit = async (data: LoginData) => {
  try {
    await loginUser(data);
  } catch (error) {
    if (error instanceof FieldError) {
      // Set error for specific field
      setError("email", {
        type: "manual",
        message: error.message,
      });
    } else {
      // Set root error
      setError("root", {
        type: "manual",
        message: "Login failed",
      });
    }
  }
};
```

---

## Best Practices

1. **Use React Hook Form** — Industry standard, minimal re-renders
2. **Validate on Blur** — Not on every keystroke (mode: 'onBlur')
3. **Schema Validation** — Use Zod for complex forms
4. **Reusable Fields** — Create field wrapper components
5. **Show Errors Clearly** — Inline validation messages
6. **Disable Submit During Load** — Prevent double submissions
7. **Server Validation** — Never trust client validation alone
8. **Preserve Data** — Don't lose form data on errors
9. **Extract Validators** — Reuse validation rules across forms
10. **Test Form Behavior** — Submit, validation, error states
