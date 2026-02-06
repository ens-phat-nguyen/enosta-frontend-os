# AI Usage Guidelines

## Philosophy

AI is a **multiplier**, not a replacement for engineering judgment.

This document defines how our frontend team uses AI tools responsibly and effectively.

---

## Core Principles

### 1. Understand what you ship

- **Never** blindly copy-paste AI-generated code
- Read, understand, and verify all suggestions
- You own the code, not the AI

### 2. AI assists, engineers decide

- Use AI for exploration, refactoring, and review
- Final architectural decisions are human-driven
- Question AI outputs that seem off

### 3. Treat AI tools like any other tool

- Prompts and agents are reusable, shareable assets
- Document effective patterns in `/ai/prompts` and `/ai/agents`
- Iterate on prompts for better results

---

## When to use AI

✅ **Good use cases:**

- Generating boilerplate code
- Refactoring repetitive patterns
- Explaining unfamiliar code
- Writing tests for existing logic
- Reviewing PRs for common issues
- Translating designs to code structure

❌ **Avoid AI for:**

- Making critical architectural decisions alone
- Security-sensitive code without review
- Complex business logic without validation
- Anything you don't understand

---

## Best Practices

### Ask better questions

- Provide context: language, framework, constraints
- Be specific about what you want
- Iterate on prompts if the output isn't quite right

### Review AI output critically

- Does it match our standards? (`/standards`)
- Is it accessible? Performant? Maintainable?
- Does it introduce security risks?

### Share what works

- Add reusable prompts to `/ai/prompts`
- Document agent workflows in `/ai/agents`
- Help the team learn from your patterns

---

## AI Tools We Use

_(Add team-specific tools here, e.g., GitHub Copilot, ChatGPT, Cursor, etc.)_

---

## Red Flags

Watch out for:

- Over-complicated solutions
- Outdated patterns or deprecated APIs
- Code that "just works" but you can't explain
- Suggestions that bypass standards

---

## Learning & Growth

Using AI well is a **skill**.

- Beginners: Use AI to learn patterns, not skip learning
- Experienced: Use AI to move faster, not think less
- Everyone: Stay curious and critical

---

**Remember:** AI makes you faster, but judgment makes you better.
