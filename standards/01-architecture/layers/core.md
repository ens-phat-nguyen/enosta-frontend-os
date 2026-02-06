# Core Layer

The foundation layer containing all essential setup and configuration required to run the application.

---

## Characteristics

- **Stability** - Code here changes rarely. Modifications potentially affect the entire application.
- **Singleton nature** - Many components are single instances (one router, one API client, one theme).
- **Framework integration** - This is where framework-specific configuration lives.
- **No business logic** - Pure infrastructure, no domain rules.

---

## What Belongs Here

Categories ordered by how commonly they appear in web applications:

| Category | Examples |
| -------- | -------- |
| Routing | Router configuration, route definitions, navigation utilities |
| API Layer | HTTP client, interceptors, generated queries/mutations/types/hooks |
| UI | Component library setup, theme, extended components |
| Styling | Theme tokens, global styles, CSS framework setup |
| State Management | Store setup, state persistence, hydration logic |
| Environment | Environment variables, feature flags, runtime config |
| Error Handling | Global error boundaries, error reporting (Sentry, etc.) |
| i18n | Internationalization setup, locale configuration |
| Analytics | Google Analytics, Mixpanel, Segment setup |
| Real-time | WebSocket client, connection management, reconnection logic |
| Performance | Web Vitals, monitoring setup |
| Logging | Logger instance, log level configuration |

> **Note:** Not all applications need every category. Start with what you need (often just Routing + API + UI).

---

## Example Structure

```plaintext
core/
├── api/
│   ├── client.ts           # API client instance
│   └── index.ts
├── router/
│   ├── provider.tsx        # Router configuration
│   ├── routes.ts           # Route definitions
│   └── index.ts
├── store/
│   ├── provider.ts         # Store setup
│   └── index.ts
├── styles/
│   ├── prose.css           # Typography styles
│   ├── colors.css          # Color variables
│   └── main.css            # Global CSS
└── index.ts                # Re-exports all core modules
```

---

## Guidelines

### Do

- Keep components loosely coupled from each other
- Provide clear initialization order if components have dependencies
- Document global side effects (e.g., axios interceptors)
- Export configuration through barrel files

### Don't

- Import from `modules/` - this breaks the dependency rule
- Put business logic here - that belongs in modules
- Create feature-specific code - keep it generic

---

## Dependency Rule

```plaintext
core/ → can import from shared/ only
core/ → CANNOT import from modules/
```

This allows core to use pure utilities from shared (e.g., custom cache strategies using shared utils).

---

## Checklist: Does This Belong in Core?

```plaintext
[ ] Is it required for the app to run at all?
[ ] Is it configured once and used everywhere?
[ ] Is it independent of specific business features?
[ ] Would removing it break the entire application?

All YES → core/
Any NO  → Consider shared/ or modules/
```

---

## Common Mistakes

| Mistake | Why It's Wrong | Correct Approach |
| ------- | -------------- | ---------------- |
| API endpoints in core | Endpoints are feature-specific | Keep base client in core, endpoints in modules |
| Feature flags logic in core | Business rules about features | Config in core, logic in modules |
| Business components in core/ui | UI primitives should be generic | Keep `Button`, `Modal` in core; `OrderCard` in modules |

---

## Related

- [Shared Layer](./shared.md) - For reusable utilities
- [Modules Layer](./modules.md) - For business features
