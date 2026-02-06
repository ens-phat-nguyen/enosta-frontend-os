# Security

> "Security is not optional. It's a feature."

---

## Foundational Principles

Security must be built in from the start:

### 1. **Interface-First Thinking**

Design security requirements before code. What data is sensitive? Who should access it?

### 2. **KISS (Keep It Simple, Stupid)**

Use well-established libraries (Apollo Client, React's auto-escaping). Don't invent security.

### 3. **DRY (Don't Repeat Yourself)**

Extract security helpers (validation, sanitization, CSP headers).

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Frontend Security** includes:

1. **XSS Prevention** — Stop malicious scripts
2. **CSRF Protection** — Stop unauthorized requests
3. **Secrets Management** — Never expose API keys
4. **Authentication** — Secure login flow
5. **Data Protection** — Encrypt sensitive data in transit

Frontend can't prevent everything (SQL injection, data breaches happen on backend), but you can prevent common attacks.

---

## Goals

1. **Prevent XSS** — No injected scripts
2. **CSRF Protection** — Tokens for state-changing requests
3. **Secure Auth** — HttpOnly cookies, no localStorage tokens
4. **Environment Secrets** — Never commit API keys
5. **HTTPS Everywhere** — Encrypted transport
6. **CSP Headers** — Control which scripts run

---

## Table of Contents

- [Foundational Principles](#foundational-principles)
- [XSS Prevention](#xss-prevention)
- [CSRF Protection](#csrf-protection)
- [Secrets Management](#secrets-management)
- [Authentication](#authentication)
- [Security Headers](#security-headers)
- [Best Practices](#best-practices)

---

## XSS Prevention

### React Auto-Escaping (Most Common Protection)

```typescript
// ✅ React automatically escapes by default
const Comment = ({ text }: { text: string }) => {
  // Even if text = '<script>alert("xss")</script>'
  // React renders it as plain text, NOT as script
  return <div>{text}</div>;
};
```

### Dangerous Methods (Avoid!)

```typescript
// ❌ NEVER use dangerouslySetInnerHTML without sanitization
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// ❌ NEVER use eval()
const result = eval(userCode);

// ❌ NEVER set innerHTML
element.innerHTML = userContent;
```

### When You Need HTML Content (DOMPurify)

```typescript
import DOMPurify from 'dompurify';

const RichContent = ({ html }: { html: string }) => {
  const sanitized = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'a'],
    ALLOWED_ATTR: ['href']
  });

  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
};
```

### URL Injection

```typescript
// ❌ DANGEROUS: javascript: URLs
<a href={userProvidedUrl}>Click</a>

// ✅ SAFE: React prevents javascript: URLs
const isValidUrl = (url: string) => {
  try {
    const parsed = new URL(url);
    return ['http:', 'https:'].includes(parsed.protocol);
  } catch {
    return false;
  }
};

<a href={isValidUrl(url) ? url : '#'}>Click</a>
```

---

## CSRF Protection

### Apollo Client + CSRF Tokens

```typescript
// Backend sets CSRF token in secure, HttpOnly cookie
// Frontend reads token from response header or hidden input

import { ApolloClient, createHttpLink } from "@apollo/client";

const httpLink = createHttpLink({
  uri: "/graphql",
  credentials: "include", // ✅ Send cookies with requests
  headers: {
    "X-CSRF-Token": getCsrfToken(), // ✅ Include CSRF token
  },
});

const client = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache(),
});

// Get token from meta tag
const getCsrfToken = () => {
  return (
    document
      .querySelector('meta[name="csrf-token"]')
      ?.getAttribute("content") || ""
  );
};
```

### SameSite Cookies

```typescript
// ✅ Backend: Set SameSite cookie
Set-Cookie: sessionId=abc123; SameSite=Strict; HttpOnly; Secure

// Strict = only same-site requests
// Lax = same-site + top-level navigation
// None = all requests (requires Secure + HTTPS)

// Frontend: Don't need to do anything, browser handles it
```

### Token-Based CSRF

```typescript
// ✅ POST request with CSRF token
const submitForm = async (data: FormData) => {
  const response = await fetch("/api/form", {
    method: "POST",
    headers: {
      "X-CSRF-Token": getCsrfToken(),
    },
    body: JSON.stringify(data),
  });
};
```

---

## Secrets Management

### Environment Variables

```bash
# .env.local (NEVER commit this)
NEXT_PUBLIC_API_URL=https://api.example.com
NEXT_SECRET_API_KEY=sk-1234567890

# public: visible to browser
# secret: backend only
```

### Private Environment Variables

```typescript
// ✅ Backend only (Node.js)
const apiKey = process.env.NEXT_SECRET_API_KEY;

// ❌ NEVER expose in frontend
const apiKey = import.meta.env.VITE_SECRET_KEY; // DANGEROUS!
```

### Public vs Private

```typescript
// ✅ Safe: Public configuration
export const config = {
  apiUrl: process.env.REACT_APP_API_URL,
  analyticsId: process.env.REACT_APP_ANALYTICS_ID,
};

// ❌ Dangerous: Private keys in frontend code
const graphqlKey = "sk-secret-key"; // VISIBLE IN BROWSER!
```

### API Keys in Requests

```typescript
// ❌ NEVER send API keys from frontend
const response = await fetch("https://api.external.com/data", {
  headers: {
    Authorization: "Bearer sk-secret-key", // ❌ Exposed!
  },
});

// ✅ CORRECT: Call your backend, backend calls external API
const response = await fetch("/api/external-data");
// Backend has the API key, sends secure request
```

---

## Authentication

### Secure Login Flow

```typescript
// ✅ Best practice flow
const login = async (email: string, password: string) => {
  // 1. Send credentials over HTTPS (only in POST body, not URL)
  const response = await fetch("/api/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
    credentials: "include", // Include cookies
  });

  // 2. Backend sets HttpOnly, Secure, SameSite cookie
  // 3. No token stored in localStorage (vulnerable to XSS)
  // 4. Subsequent requests automatically include cookie
};

// Logout
const logout = async () => {
  await fetch("/api/logout", {
    method: "POST",
    credentials: "include",
  });
  // Backend clears session cookie
};
```

### Check Auth Status

```typescript
// ✅ Query user from session
const ME_QUERY = gql`
  query Me {
    user {
      id
      email
      role
    }
  }
`;

const useAuth = () => {
  const { data } = useQuery(ME_QUERY);
  return data?.user || null;
};
```

### Protected Routes

```typescript
// ✅ Simple route guard
const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const user = useAuth();

  if (!user) {
    return <Navigate to="/login" />;
  }

  return <>{children}</>;
};
```

---

## Security Headers

### Content Security Policy (CSP)

```
# .next/server configuration or Apache/Nginx
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'wasm-unsafe-eval';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  connect-src 'self' api.example.com

# Prevents loading scripts from unauthorized origins
```

### CORS Headers

```typescript
// Backend: Only allow requests from trusted origins
cors({
  origin: ["https://example.com", "https://app.example.com"],
  credentials: true, // Allow cookies
});
```

### X-Frame-Options (Clickjacking)

```
X-Frame-Options: DENY
# Prevents site from being embedded in iframe
```

---

## Best Practices

1. **Always HTTPS** — Never trust HTTP in production
2. **React Auto-Escaping** — Trust it, don't work around it
3. **HttpOnly Cookies** — Not localStorage for auth tokens
4. **Secure by Default** — Assume user input is malicious
5. **Never Expose Secrets** — Check .gitignore includes .env
6. **CSRF Tokens** — For state-changing requests
7. **Content Security Policy** — Restrict script sources
8. **Regular Security Audits** — npm audit, OWASP Top 10
9. **Sanitize User Input** — Use DOMPurify when needed
10. **Keep Dependencies Updated** — Patch vulnerabilities immediately

---

## Security Checklist

- [ ] HTTPS enabled in production
- [ ] API keys not in frontend code
- [ ] .env files in .gitignore
- [ ] CSRF tokens on forms
- [ ] CSP headers configured
- [ ] XSS prevention (no dangerouslySetInnerHTML without DOMPurify)
- [ ] HttpOnly cookies for auth
- [ ] SameSite cookies set
- [ ] Regular npm audit runs
- [ ] Third-party libraries audited
