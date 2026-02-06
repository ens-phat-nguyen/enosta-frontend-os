# Playbooks

Step-by-step guides for common frontend development tasks.

---

## What are Playbooks?

Playbooks are **actionable guides** that walk you through specific tasks step-by-step. Unlike reference documentation, playbooks focus on **how to do something** from start to finish.

Each playbook includes:

- Clear prerequisites
- Step-by-step instructions
- Validation checkpoints
- Troubleshooting tips
- Example commands

---

## Available Playbooks

### 🚀 [Project Setup](./project-setup/)

Initialize a new frontend project with F4ST architecture.

**When to use:**

- Starting a new project from scratch
- Setting up a consistent project structure
- Learning the F4ST architecture

**What you'll get:**

- Complete project structure (`shared/`, `core/`, `modules/`)
- Working code examples
- TypeScript configuration
- Build setup (Vite)
- Development scripts

**Quick start:**

```bash
cd playbooks/project-setup
./init-project.sh my-project-name
```

**Read more:** [Project Setup Guide](./project-setup/README.md)

---

## Coming Soon

More playbooks in development:

- **Feature Development** - Build a complete feature from requirements to PR
- **Migration Guide** - Migrate existing project to F4ST architecture
- **Testing Setup** - Configure testing (Vitest, React Testing Library, Playwright)
- **Deployment** - Deploy to production (Vercel, Netlify, AWS)
- **Performance Audit** - Optimize application performance
- **Accessibility Audit** - Ensure WCAG compliance
- **Refactoring** - Safely refactor legacy code
- **Debugging** - Debug common issues systematically

---

## How to Use Playbooks

### 1. Choose the Right Playbook

Browse available playbooks and select the one that matches your task.

### 2. Check Prerequisites

Each playbook lists required tools, knowledge, or setup. Ensure you have everything before starting.

### 3. Follow Step-by-Step

Work through the playbook sequentially. Don't skip steps unless you're experienced.

### 4. Validate at Checkpoints

Playbooks include validation steps. Verify each checkpoint before proceeding.

### 5. Troubleshoot Issues

If you encounter problems, check the troubleshooting section in the playbook.

---

## Playbook Structure

Standard playbook format:

```markdown
# Playbook Title

Brief description of what this playbook does.

## Overview

- What you'll accomplish
- Estimated time
- Difficulty level

## Prerequisites

- Required tools
- Required knowledge
- Required setup

## Steps

### Step 1: [Action]

Instructions...
✓ Checkpoint: How to verify

### Step 2: [Action]

Instructions...
✓ Checkpoint: How to verify

## Validation

Final verification checklist

## Troubleshooting

Common issues and solutions

## Next Steps

What to do after completing this playbook
```

---

## Contributing New Playbooks

Want to create a new playbook? Follow these guidelines:

### 1. Identify the Need

Ask:

- Is this a common task?
- Would a step-by-step guide help?
- Can this be broken into clear steps?

### 2. Structure Your Playbook

Use the standard template above. Include:

- Clear prerequisites
- Numbered steps
- Validation checkpoints
- Troubleshooting section
- Example commands

### 3. Test It

Have someone else follow your playbook. Can they complete the task successfully?

### 4. Submit for Review

Create a PR with your playbook. Include:

- The playbook markdown file
- Any supporting scripts/files
- Updates to this README

---

## Playbook vs. Other Docs

| Document Type    | Purpose                     | Example                    |
| ---------------- | --------------------------- | -------------------------- |
| **Playbook**     | How to do a specific task   | "Initialize New Project"   |
| **Standard**     | What to follow consistently | "Code Standards"           |
| **Principle**    | Why we make decisions       | "Interface-First Thinking" |
| **Architecture** | How to structure code       | "F4ST Layers"              |
| **Workflow**     | Process for development     | "Feature Development Flow" |

Use playbooks for **actionable tasks with clear start and end points**.

---

## Resources

- [Standards](../standards/) - Code and architecture standards
- [Workflows](../workflows/) - Development processes
- [AI Prompts](../ai/prompts/) - Reusable AI prompts
- [Skills](../skills/) - Skill expectations and growth

---

## Questions?

- Check the specific playbook's troubleshooting section
- Review related standards and documentation
- Ask in team chat
- Create an issue if something's unclear

---

**Start with [Project Setup](./project-setup/) to initialize your first project!**
