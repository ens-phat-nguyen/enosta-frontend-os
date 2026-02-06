# Project Setup Guide

Quick guide to initialize a new frontend project with F4ST architecture.

---

## Overview

This guide covers two methods to set up a new project:

1. **Automated Script** - Fast, consistent setup (recommended)
2. **AI-Assisted Setup** - Customizable, interactive

Both methods create the same F4ST architecture: `shared/`, `core/`, `modules/`

---

## Method 1: Automated Script (Recommended)

### Prerequisites

- Bash shell (macOS/Linux/WSL)
- Node.js 18+ installed

### Steps

**1. Run the initialization script:**

```bash
cd playbooks/project-setup
./init-project.sh my-project-name
```

**2. Install dependencies:**

```bash
cd my-project-name
npm install
```

**3. Start development:**

```bash
npm run dev
```

**4. Verify structure:**

```bash
tree src -L 2
```

Expected output:

```
src
├── shared/      # Pure utilities
├── core/        # Foundation
├── modules/     # Features
│   └── auth/
├── App.tsx
├── main.tsx
└── index.css
```

---

## Method 2: AI-Assisted Setup

### When to Use

- Need custom configuration
- Different tech stack combinations
- Learning the architecture
- Want to understand each file

### Steps

**1. Open AI assistant (GitHub Copilot Chat, Cursor, etc.)**

**2. Use the initialization prompt:**

See [ai/prompts/initialize-project.md](../../ai/prompts/initialize-project.md) for the full prompt template.

**3. Customize the prompt:**

```
I need to set up a new frontend project with the F4ST architecture.

Project details:
- Name: my-dashboard-app
- Tech stack: React 18, TypeScript 5, Vite 5, TailwindCSS 3
- State management: Jotai
- UI library: ShadcnUI
- Router: TanStack Router
- Data fetching: TanStack Query

[... continue with full prompt ...]
```

**4. Review and adjust generated code**

**5. Install dependencies and start:**

```bash
npm install
npm run dev
```

---

## What Gets Created

Both methods create this structure:

### Shared Layer (No Dependencies)

```
shared/
├── utils/
│   ├── format-currency.ts    # Currency formatting
│   ├── format-date.ts         # Date formatting
│   └── index.ts
├── hooks/
│   ├── use-debounce.ts        # Debounce values
│   ├── use-local-storage.ts   # localStorage hook
│   └── index.ts
├── types/
│   ├── api-response.type.ts   # API response types
│   └── index.ts
├── validators/
│   ├── is-email.ts            # Email validation
│   └── index.ts
└── constants/
    ├── http-status.ts         # HTTP status codes
    └── index.ts
```

### Core Layer (Foundation)

```
core/
├── api/
│   └── client.ts              # Fetch-based API client
├── router/
│   └── router.tsx             # Router configuration (placeholder)
├── store/
│   └── provider.tsx           # State provider (placeholder)
└── ui/
    └── provider.tsx           # UI provider (placeholder)
```

### Modules Layer (Features)

```
modules/
└── auth/
    ├── components/
    │   └── login-form.tsx     # Login form component
    ├── hooks/
    │   └── use-auth.ts        # Auth hook
    ├── api/
    │   └── auth-api.ts        # Auth API calls
    ├── types/
    │   └── user.type.ts       # User types
    └── index.ts               # Public API
```

### Configuration Files

- `tsconfig.json` - TypeScript config with path aliases
- `vite.config.ts` - Vite config with aliases
- `package.json` - Dependencies and scripts
- `index.html` - HTML entry point
- `.gitignore` - Git ignore rules
- `README.md` - Project documentation

---

## Post-Setup Configuration

### 1. Configure Router

Choose your router and update `core/router/router.tsx`:

**TanStack Router:**

```bash
npm install @tanstack/react-router
```

**React Router v6:**

```bash
npm install react-router-dom
```

### 2. Configure State Management

Choose your state library and update `core/store/provider.tsx`:

**Jotai:**

```bash
npm install jotai
```

**Zustand:**

```bash
npm install zustand
```

### 3. Configure UI Library

Choose your UI library and update `core/ui/provider.tsx`:

**AntD:**

```bash
npm install antd
```

**ShadcnUI:**

```bash
npx shadcn-ui@latest init
```

### 4. Configure Data Fetching

Choose your data fetching library:

**TanStack Query:**

```bash
npm install @tanstack/react-query
```

**Apollo Client:**

```bash
npm install @apollo/client graphql
```

---

## Validation Checklist

After setup, verify:

- [ ] `npm install` completes successfully
- [ ] `npm run dev` starts development server
- [ ] TypeScript has no errors (`npm run type-check`)
- [ ] Path aliases work (`@/`, `@/shared`, `@/core`, `@/modules`)
- [ ] Directory structure follows F4ST layers
- [ ] Each module has `index.ts` barrel export
- [ ] Dependency flow is correct:
  - `modules/` imports from `core/` and `shared/`
  - `core/` imports from `shared/` only
  - `shared/` imports nothing

---

## Common Issues

### Path Aliases Not Working

**Problem:** Imports like `@/shared/utils` fail

**Solution:**

1. Check `tsconfig.json` has `paths` configured
2. Check `vite.config.ts` has `alias` configured
3. Restart TypeScript server in VS Code (`Cmd+Shift+P` → "Restart TS Server")

### Module Not Found

**Problem:** `Cannot find module '@/modules/auth'`

**Solution:**

1. Check module has `index.ts` barrel export
2. Check exports in `index.ts` are correct
3. Restart dev server

### Circular Dependency

**Problem:** Build fails with circular dependency error

**Solution:**

1. Check dependency flow (modules → core → shared)
2. Never import from upper layers
3. Use barrel exports to control public API

---

## Next Steps

### 1. Add a New Feature Module

```bash
mkdir -p src/modules/dashboard/{components,hooks,api,types}
touch src/modules/dashboard/index.ts
```

See [workflows/development-workflow.md](../../workflows/development-workflow.md) for the full process.

### 2. Configure Development Tools

- **ESLint:** Add ESLint configuration
- **Prettier:** Add code formatting
- **Husky:** Add pre-commit hooks
- **Testing:** Set up Vitest + React Testing Library

### 3. Review Standards

- [Code Standards](../../standards/code-standards.md)
- [Architecture Standards](../../standards/01-architecture/)
- [Tech Stack Standards](../../standards/tech-stack.md)

### 4. Set Up AI Assistance

Copy the Copilot instructions template:

```bash
cp ai/copilot-instructions-template.md .github/copilot-instructions.md
```

Edit and customize for your project.

---

## Example Commands

### Create New Module

```bash
# Create module structure
mkdir -p src/modules/users/{components,hooks,api,types}

# Create files
touch src/modules/users/types/user.type.ts
touch src/modules/users/api/user-api.ts
touch src/modules/users/hooks/use-users.ts
touch src/modules/users/components/user-list.tsx
touch src/modules/users/index.ts

# Export public API in index.ts
echo "export * from './hooks';" > src/modules/users/index.ts
echo "export * from './components';" >> src/modules/users/index.ts
echo "export type * from './types';" >> src/modules/users/index.ts
```

### Add Shared Utility

```bash
# Create utility file
touch src/shared/utils/slug.ts

# Export from barrel
echo "export * from './slug';" >> src/shared/utils/index.ts
```

### Add Core Service

```bash
# Create service
mkdir -p src/core/analytics
touch src/core/analytics/tracker.ts
touch src/core/analytics/index.ts

# Export
echo "export * from './tracker';" > src/core/analytics/index.ts
echo "export * from './analytics';" >> src/core/index.ts
```

---

## Resources

- **Architecture:** [standards/01-architecture/](../../standards/01-architecture/)
- **Examples:** [standards/01-architecture/examples/](../../standards/01-architecture/examples/)
- **AI Prompts:** [ai/prompts/](../../ai/prompts/)
- **Workflow:** [workflows/development-workflow.md](../../workflows/development-workflow.md)
- **Standards:** [standards/](../../standards/)

---

## Support

For questions or issues:

1. Check [standards/01-architecture/decisions/](../../standards/01-architecture/decisions/) for guidance
2. Review [standards/code-standards.md](../../standards/code-standards.md)
3. Ask in team chat
4. Create an issue in the Frontend OS repo

---

**Ready to build!** 🚀
