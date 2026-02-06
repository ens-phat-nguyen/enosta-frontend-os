---
name: Initialize Project Architecture
description: AI prompt for initializing a new project with F4ST architecture
category: Project Setup
created: 2026-02-06
---

# Initialize Project Architecture

Use this prompt with GitHub Copilot or AI assistants to generate a new project following the F4ST architecture.

---

## When to Use

- Starting a new frontend project from scratch
- Migrating an existing project to F4ST architecture
- Creating a new module/feature in an existing project

---

## Prompt Template

```
I need to set up a new frontend project with the F4ST architecture (Foundation, Application, Shared, Types).

Project details:
- Name: {{PROJECT_NAME}}
- Tech stack: {{TECH_STACK}} (e.g., "React 18, TypeScript, Vite, TailwindCSS")
- State management: {{STATE_LIBRARY}} (e.g., "Zustand", "Jotai", "None")
- UI library: {{UI_LIBRARY}} (e.g., "AntD", "ShadcnUI", "None")
- Router: {{ROUTER}} (e.g., "TanStack Router", "React Router v6")
- Data fetching: {{DATA_LIBRARY}} (e.g., "TanStack Query", "Apollo Client")

Please create the following structure:

1. **shared/** layer:
   - Pure utilities (format-currency, format-date)
   - Generic hooks (use-debounce, use-local-storage)
   - Shared types (api-response, pagination)
   - Validators (is-email)
   - Constants (http-status)

2. **core/** layer:
   - API client setup
   - Router configuration
   - State management provider
   - UI library provider
   - Global styles

3. **modules/** layer:
   - auth module with:
     - components/ (login-form, user-avatar)
     - hooks/ (use-auth)
     - api/ (auth-api)
     - types/ (user.type)
     - index.ts (public API barrel export)

Include:
- TypeScript configuration with strict mode
- Path aliases (@/, @/shared, @/core, @/modules)
- Vite configuration
- ESLint setup
- Basic package.json
- .gitignore
- README with architecture overview

Follow these rules:
- shared/ imports nothing (completely portable)
- core/ can only import from shared/
- modules/ can import from core/ and shared/
- Each module exports public API via index.ts
- Use barrel exports for clean imports
- Type everything with TypeScript

Generate the complete file structure with working code examples.
```

---

## Example Usage

### For a React + TanStack Project

```
I need to set up a new frontend project with the F4ST architecture.

Project details:
- Name: my-dashboard-app
- Tech stack: React 18, TypeScript 5, Vite 5, TailwindCSS 3
- State management: Jotai
- UI library: ShadcnUI
- Router: TanStack Router
- Data fetching: TanStack Query

[... rest of prompt ...]
```

### For a Next.js Project

```
I need to set up a new Next.js 14+ project with the F4ST architecture.

Project details:
- Name: my-nextjs-app
- Tech stack: Next.js 14, TypeScript 5, App Router, TailwindCSS 3
- State management: Zustand
- UI library: AntD 5
- Data fetching: TanStack Query

Note: Adapt the structure for Next.js App Router conventions.

[... rest of prompt ...]
```

---

## Automated Alternative

For faster initialization, use the bash script:

```bash
cd playbooks/project-setup
./init-project.sh my-project-name
```

The script generates the same structure automatically.

---

## Validation Checklist

After initialization, verify:

- [ ] Directory structure follows F4ST layers
- [ ] Path aliases are configured (@/, @/shared, @/core, @/modules)
- [ ] TypeScript strict mode is enabled
- [ ] Each module has an index.ts barrel export
- [ ] Dependency flow is correct (modules → core → shared)
- [ ] No circular dependencies
- [ ] All imports use path aliases (no relative paths crossing layers)
- [ ] README documents the architecture

---

## Next Steps

After initialization:

1. **Install dependencies**: `npm install`
2. **Start dev server**: `npm run dev`
3. **Review architecture**: Read [standards/01-architecture/](../../standards/01-architecture/)
4. **Add features**: Create new modules in `modules/`
5. **Follow standards**: Reference [standards/code-standards.md](../../standards/code-standards.md)

---

## Related

- [Project Setup Playbook](../../playbooks/project-setup/)
- [Architecture Standards](../../standards/01-architecture/)
- [Code Standards](../../standards/code-standards.md)
- [Development Workflow](../../workflows/development-workflow.md)
