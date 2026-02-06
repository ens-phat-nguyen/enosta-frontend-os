# Copilot Instructions Quick Start

This directory contains templates and guidelines for using GitHub Copilot with our Frontend OS agent system.

---

## Files

- **[copilot-instructions-template.md](./copilot-instructions-template.md)** - Complete template for project `.github/copilot-instructions.md`
- **[guidelines.md](./guidelines.md)** - General AI usage guidelines
- **[agents/](./agents/)** - Individual agent definitions
- **[prompts/](./prompts/)** - Reusable prompt templates

---

## Quick Setup

### 1. Copy Template to Your Project

```bash
# In your project repository
mkdir -p .github
cp path/to/frontend-os/ai/copilot-instructions-template.md .github/copilot-instructions.md
```

### 2. Customize Template

Edit `.github/copilot-instructions.md` and update:

- `[CUSTOMIZE]` sections with your project details
- Tech stack specifics
- Project-specific patterns and conventions
- Team workflows

### 3. Use in Development

Tell Copilot which mode to use based on your task:

```
Mode: Full Feature Implementation
Task: [your task description]
Start as task-analyzer agent.
```

---

## Common Workflows

### Building a Feature (Full Flow)

```
Mode: Full Feature Implementation
Task: Add user notification preferences page
Requirements: [paste requirements]

Start as task-analyzer agent.
```

Copilot will guide you through: Analysis → Design → Implementation → Testing → Docs → Review

### Fixing a Bug

```
Mode: Bug Fix
Issue: Login button not working on mobile Safari
Steps to reproduce: [list steps]

Act as task-analyzer to diagnose, then implementation to fix.
```

### Adding Tests

```
Mode: Testing Improvement
Component: UserProfile component in src/components/UserProfile.tsx
Current coverage: 45%

Act as testing agent to improve coverage.
```

### Code Review

```
Mode: Code Review
Review my changes in this PR.
Focus on: accessibility, performance, security

Act as pr-reviewer agent.
```

### Refactoring

```
Mode: Refactoring
Target: src/hooks/useUserData.ts (70 lines, multiple responsibilities)
Goal: Split into focused hooks

Act as implementation agent focused on refactoring.
```

---

## Agent Reference

| Agent               | Use When                                | Output                                     |
| ------------------- | --------------------------------------- | ------------------------------------------ |
| **task-analyzer**   | Starting new work, unclear requirements | Implementation plan, file structure, risks |
| **design-reviewer** | Have designs to implement               | Component structure, states, accessibility |
| **implementation**  | Writing code                            | Production-ready TypeScript/React code     |
| **testing**         | Adding tests                            | Comprehensive test suites                  |
| **documentation**   | Documenting code                        | TSDoc, usage examples, READMEs             |
| **pr-reviewer**     | Reviewing code                          | Quality feedback, issues, suggestions      |

---

## Tips for Effective Use

### 1. Be Specific About Mode

✅ Good:

```
Mode: Bug Fix
Act as task-analyzer to understand, then implementation to fix.
```

❌ Vague:

```
Help me fix this bug.
```

### 2. Provide Context

✅ Good:

```
Mode: Full Feature Implementation
Framework: Next.js 14 (App Router)
UI: ShadcnUI
Data: TanStack Query
Design: [Figma link]
```

❌ Missing context:

```
Build a user profile page.
```

### 3. Switch Agents Explicitly

```
Now switch to testing agent.
Create comprehensive tests for the UserProfile component.
```

### 4. Reference Standards

```
Follow /standards/code-standards.md for TypeScript conventions.
Use patterns from /standards/tech-stack.md for data fetching.
```

---

## Example Session

```
// Starting
Mode: Full Feature Implementation
Task: Add password reset flow
Requirements:
- User enters email
- System sends reset link
- User clicks link, sets new password
- Success confirmation

Start as task-analyzer agent.

// After analysis
Now switch to design-reviewer agent.
Design: [Figma link to reset password screens]

// After design review
Now switch to implementation agent.
Implement the password reset flow based on the plan and design review.

// After implementation
Now switch to testing agent.
Create tests for the password reset flow.

// After tests
Now switch to documentation agent.
Document the password reset flow and API endpoints.

// Before PR
Now switch to pr-reviewer agent.
Review all my changes for this feature.
```

---

## Project-Specific Setup

When setting up for your project:

1. **Copy the template** to your repo's `.github/copilot-instructions.md`
2. **Customize tech stack** sections
3. **Add project patterns** (auth, state management, API conventions)
4. **Document team conventions** (naming, file structure, git workflow)
5. **Add common pitfalls** specific to your codebase
6. **Commit and push** so the whole team benefits

---

## Resources

- [Frontend OS Repository](https://github.com/YOUR_ORG/enosta-frontend-os)
- [Development Workflow](../workflows/development-workflow.md)
- [Code Standards](../standards/code-standards.md)
- [Tech Stack Standards](../standards/tech-stack.md)
- [Agent Manifest](./agents/manifest.md)

---

**Remember**: The agent system is a framework for focused, high-quality development. Use it to maintain consistency and reduce cognitive load across your projects.
