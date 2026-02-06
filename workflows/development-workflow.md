# Frontend Development Workflow

This document defines the standard workflow for frontend developers from receiving a task to merging a PR.

---

## Overview

```text
Task → Analysis → Design Review → Implementation → Testing → Documentation → PR → Merge
```

**Key Principles:**

- Understand before building
- Test as you build
- Document as you go
- Review before merging

---

## Phase 1: Task Analysis

**Goal**: Fully understand requirements before writing code

### Steps

1. **Read the task/ticket thoroughly**
   - Identify acceptance criteria
   - Note unclear requirements
   - List technical constraints

2. **Ask clarifying questions**
   - What's the user problem we're solving?
   - Are there edge cases to consider?
   - What's the expected behavior?
   - Are there performance requirements?

3. **Break down the work**
   - Split into smaller, testable units
   - Identify dependencies
   - Estimate complexity

4. **Document your understanding**
   - Write a brief implementation plan
   - List files/components to modify
   - Note potential risks

**AI Agent**: [Task Analyzer Agent](../ai/agents/task-analyzer.agent.md)

**Output**: Clear understanding + implementation plan

---

## Phase 2: Design Review

**Goal**: Validate design specs and ensure technical feasibility

### Steps

1. **Review design files** (Figma, etc.)
   - Check all states (default, hover, active, disabled, error)
   - Verify responsive breakpoints
   - Note animations and interactions
   - Check accessibility considerations

2. **Map design to components**
   - Identify reusable components
   - Check if components exist in design system
   - Plan new components if needed

3. **Validate technical feasibility**
   - Can we build this with our tech stack?
   - Are there performance concerns?
   - Do we need new dependencies?

4. **Flag design issues early**
   - Missing states or breakpoints
   - Accessibility concerns
   - Unclear interactions

**AI Agent**: [Design Reviewer Agent](../ai/agents/design-reviewer.agent.md)

**Output**: Component structure + design validation

---

## Phase 3: Implementation

**Goal**: Write clean, tested, maintainable code

### Steps

1. **Create feature branch**

   ```bash
   git checkout -b feature/task-name
   ```

2. **Set up structure**
   - Create necessary files
   - Import dependencies
   - Set up types

3. **Implement iteratively**
   - Start with the core logic
   - Add UI layer
   - Handle edge cases
   - Add error handling

4. **Follow standards** (see [/standards](../standards/))
   - TypeScript strict mode
   - Component composition patterns
   - Naming conventions
   - File organization

5. **Test as you go**
   - Unit tests for logic
   - Component tests for UI
   - Integration tests for flows

**AI Agent**: [Implementation Agent](../ai/agents/implementation.agent.md)

**Tech Stack Reference**: [Tech Stack Standards](../standards/tech-stack.md)

**Output**: Working, tested code

---

## Phase 4: Testing

**Goal**: Ensure code works correctly and handles edge cases

### Testing Checklist

#### Unit Tests

- [ ] Core logic functions tested
- [ ] Edge cases covered
- [ ] Error handling tested

#### Component Tests

- [ ] Components render correctly
- [ ] User interactions work
- [ ] Props are validated

#### Integration Tests

- [ ] Data flows work end-to-end
- [ ] API calls succeed/fail appropriately
- [ ] Navigation works

#### Manual Testing

- [ ] Test in multiple browsers
- [ ] Test responsive breakpoints
- [ ] Test keyboard navigation
- [ ] Test screen reader compatibility
- [ ] Test error states
- [ ] Test loading states

**AI Agent**: [Testing Agent](../ai/agents/testing.agent.md)

**Output**: Comprehensive test coverage

---

## Phase 5: Documentation

**Goal**: Make your code understandable for others (and future you)

### What to Document

1. **Code Comments**
   - Why, not what (code should be self-explanatory)
   - Complex logic explanations
   - Workarounds and their reasons

2. **Component Documentation**
   - Props and their types
   - Usage examples
   - Common patterns

3. **Update Related Docs**
   - README if setup changed
   - Architecture docs if patterns changed
   - API docs if endpoints changed

4. **Add Storybook stories** (if applicable)
   - All component variants
   - Interactive examples

**AI Agent**: [Documentation Agent](../ai/agents/documentation.agent.md)

**Output**: Well-documented code

---

## Phase 6: Pull Request

**Goal**: Get code reviewed and merged safely

### Before Opening PR

- [ ] All tests pass locally
- [ ] Code follows standards
- [ ] No console errors/warnings
- [ ] Branch is up to date with main
- [ ] Commits are clean and descriptive

### Creating the PR

1. **Write a clear title**

   ```
   feat: add user profile settings page
   fix: resolve navigation bug on mobile
   refactor: optimize dashboard queries
   ```

2. **Fill out PR template** (see [.github/PULL_REQUEST_TEMPLATE.md](../.github/PULL_REQUEST_TEMPLATE.md))
   - Describe what changed
   - Explain why it changed
   - List how to test it
   - Add screenshots/videos

3. **Request reviewers**
   - Tag relevant team members
   - Ask for specific feedback if needed

### During Review

- Respond to feedback promptly
- Be open to suggestions
- Explain your decisions when needed
- Make requested changes

### After Approval

- Squash commits if needed
- Merge to main
- Delete feature branch
- Close related tickets

**AI Agent**: [PR Reviewer Agent](../ai/agents/pr-reviewer.agent.md)

**Output**: Reviewed and merged code

---

## Best Practices

### Do

✅ Understand requirements fully before coding
✅ Write tests as you build
✅ Commit frequently with clear messages
✅ Keep PRs focused and small
✅ Document complex logic
✅ Ask for help when stuck

### Don't

❌ Start coding without understanding the task
❌ Skip writing tests
❌ Wait until the end to test
❌ Create massive PRs
❌ Leave commented-out code
❌ Merge without review

---

## Common Pitfalls

### "I'll test it later"

**Problem**: Tests never get written, bugs slip through

**Solution**: Write tests as you implement features

### "It works on my machine"

**Problem**: Environment-specific issues

**Solution**: Test in multiple environments, use consistent tooling

### "I'll document it after"

**Problem**: Documentation never happens

**Solution**: Document as you build, while context is fresh

### "Small fix, no need for review"

**Problem**: Small changes can have big impacts

**Solution**: All code goes through review, no exceptions

---

## Time Guidelines

These are rough estimates, adjust based on complexity:

| Phase          | Simple Task | Medium Task | Complex Task |
| -------------- | ----------- | ----------- | ------------ |
| Analysis       | 15-30 min   | 30-60 min   | 1-2 hours    |
| Design Review  | 15-30 min   | 30-60 min   | 1-2 hours    |
| Implementation | 2-4 hours   | 1-2 days    | 3-5 days     |
| Testing        | 1-2 hours   | 2-4 hours   | 1 day        |
| Documentation  | 30 min      | 1 hour      | 2 hours      |
| PR Review      | 30 min      | 1 hour      | 2 hours      |

**If a task takes longer**: Break it down further or ask for help

---

## Tools & Resources

- **Task Management**: [Link to your tool]
- **Design Files**: [Link to Figma/design tool]
- **Code Review**: GitHub PRs
- **Testing**: Vitest, React Testing Library, Playwright
- **Documentation**: Storybook, TSDoc
- **AI Agents**: [Agent Manifest](../ai/agents/manifest.md)

---

## Questions?

- Check [playbooks](../playbooks/) for specific scenarios
- Review [standards](../standards/) for technical guidance
- Ask in team channels
- Consult with tech leads

---

**Remember**: This workflow exists to help you ship quality code confidently. Adapt it to your needs, but don't skip critical steps.
