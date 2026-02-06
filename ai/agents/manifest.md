# AI Agent Manifest

This manifest defines all AI agents available for the frontend development workflow.

Each agent is specialized for a specific phase of development, with clearly defined skills and responsibilities.

---

## Agent Overview

| Agent                                     | Phase         | Purpose                                       | File                                                   |
| ----------------------------------------- | ------------- | --------------------------------------------- | ------------------------------------------------------ |
| [Task Analyzer](#task-analyzer-agent)     | Analysis      | Break down requirements into actionable tasks | [task-analyzer.agent.md](./task-analyzer.agent.md)     |
| [Design Reviewer](#design-reviewer-agent) | Design Review | Validate designs and map to components        | [design-reviewer.agent.md](./design-reviewer.agent.md) |
| [Implementation](#implementation-agent)   | Development   | Generate and refactor code                    | [implementation.agent.md](./implementation.agent.md)   |
| [Testing](#testing-agent)                 | Testing       | Generate tests and identify gaps              | [testing.agent.md](./testing.agent.md)                 |
| [Documentation](#documentation-agent)     | Documentation | Generate and improve documentation            | [documentation.agent.md](./documentation.agent.md)     |
| [PR Reviewer](#pr-reviewer-agent)         | Code Review   | Review code quality and standards             | [pr-reviewer.agent.md](./pr-reviewer.agent.md)         |

---

## Task Analyzer Agent

**File**: [task-analyzer.agent.md](./task-analyzer.agent.md)

**Purpose**: Help developers understand requirements and create implementation plans

**When to Use**:

- Starting a new task
- Requirements are unclear
- Need to break down complex work
- Estimating effort

**Skills**:

- Requirement analysis
- Technical constraint identification
- Work breakdown
- Risk assessment
- Effort estimation

**Inputs**:

- Task description/ticket
- Design files (if available)
- Technical constraints

**Outputs**:

- Clear requirement summary
- Implementation plan
- List of files to modify
- Potential risks
- Estimated complexity

**Tech Stack Knowledge**:

- TypeScript
- React/Astro/Next.js architecture
- Team standards

---

## Design Reviewer Agent

**File**: [design-reviewer.agent.md](./design-reviewer.agent.md)

**Purpose**: Validate designs and provide implementation guidance

**When to Use**:

- Reviewing Figma designs
- Mapping designs to components
- Checking accessibility
- Identifying missing states

**Skills**:

- Design system expertise
- Component architecture
- Accessibility (WCAG 2.1)
- Responsive design
- State management patterns

**Inputs**:

- Design files (Figma, etc.)
- Component library (AntD/ShadcnUI)
- Responsive requirements

**Outputs**:

- Component structure
- State requirements
- Accessibility checklist
- Missing design states
- Implementation suggestions

**Tech Stack Knowledge**:

- React component patterns
- TailwindCSS
- AntD/ShadcnUI
- Accessibility standards

---

## Implementation Agent

**File**: [implementation.agent.md](./implementation.agent.md)

**Purpose**: Generate code following team standards

**When to Use**:

- Implementing new features
- Refactoring existing code
- Creating boilerplate
- Converting designs to code

**Skills**:

- TypeScript development
- React/Astro/Next.js patterns
- TailwindCSS styling
- Component library usage (AntD/ShadcnUI)
- Data fetching (Apollo/TanStack Query)
- Routing (TanStack Router/React Router v6)
- State management
- Error handling
- Performance optimization

**Inputs**:

- Requirements/design
- Existing code context
- Component structure

**Outputs**:

- Implementation code
- Type definitions
- Component files
- Utility functions
- Styled components

**Tech Stack Knowledge**:

- **Core**: TypeScript (strict mode)
- **Frameworks**: React 18+, Astro 4+, Next.js 14+
- **Styling**: TailwindCSS 3+
- **UI Libraries**: AntD 5+ or ShadcnUI
- **Data**: Apollo Client 3+ (GraphQL) or TanStack Query 5+ (REST)
- **Routing**: TanStack Router or React Router v6
- **Build**: Vite 5+
- **Standards**: Code standards, tech stack standards

---

## Testing Agent

**File**: [testing.agent.md](./testing.agent.md)

**Purpose**: Generate comprehensive tests and identify coverage gaps

**When to Use**:

- Writing tests for new code
- Improving test coverage
- Debugging test failures
- Creating test strategies

**Skills**:

- Unit testing (Vitest)
- Component testing (React Testing Library)
- E2E testing (Playwright)
- Test strategy
- Mock data generation
- Coverage analysis

**Inputs**:

- Source code
- Requirements
- Edge cases

**Outputs**:

- Unit tests
- Component tests
- Integration tests
- E2E test scenarios
- Mock data
- Coverage report analysis

**Tech Stack Knowledge**:

- Vitest
- React Testing Library
- Playwright
- Testing best practices
- Accessibility testing

---

## Documentation Agent

**File**: [documentation.agent.md](./documentation.agent.md)

**Purpose**: Create clear, helpful documentation

**When to Use**:

- Documenting new features
- Writing component docs
- Creating usage examples
- Updating READMEs

**Skills**:

- Technical writing
- Code documentation (TSDoc)
- Component documentation
- API documentation
- Usage examples
- Markdown formatting

**Inputs**:

- Source code
- Component interfaces
- Feature requirements

**Outputs**:

- TSDoc comments
- Component documentation
- Usage examples
- README updates
- API documentation

**Tech Stack Knowledge**:

- TypeScript/JSDoc syntax
- Markdown
- Storybook (if used)
- Documentation standards

---

## PR Reviewer Agent

**File**: [pr-reviewer.agent.md](./pr-reviewer.agent.md)

**Purpose**: Review code for quality, standards, and potential issues

**When to Use**:

- Before submitting a PR
- Reviewing others' PRs
- Identifying code smells
- Enforcing standards

**Skills**:

- Code review best practices
- Standards enforcement
- Performance analysis
- Security review
- Accessibility audit
- Best practice identification

**Inputs**:

- Pull request diff
- Changed files
- PR description

**Outputs**:

- Code quality feedback
- Standards violations
- Performance concerns
- Security issues
- Accessibility issues
- Suggested improvements

**Tech Stack Knowledge**:

- All team tech stack
- Code standards
- Security best practices
- Performance patterns
- Accessibility standards

---

## How to Use Agents

### 1. Choose the Right Agent

Match the agent to your current workflow phase:

```text
Starting a task? → Task Analyzer
Reviewing designs? → Design Reviewer
Writing code? → Implementation
Adding tests? → Testing
Writing docs? → Documentation
Reviewing PR? → PR Reviewer
```

### 2. Provide Context

Give agents relevant context:

```markdown
**Task**: Add user profile settings page

**Context**:

- Using Next.js App Router
- ShadcnUI for components
- TanStack Query for data fetching
- Need mobile responsive

**Design**: [link to Figma]

**Constraints**:

- Must support keyboard navigation
- Performance budget: < 100KB bundle size
```

### 3. Iterate on Outputs

- Review agent outputs critically
- Ask follow-up questions
- Refine based on feedback
- Validate against standards

### 4. Verify Results

- Test generated code
- Run linters and tests
- Check against standards
- Ensure accessibility

---

## Agent Workflow Example

**Scenario**: Implement a new dashboard feature

```text
1. Task Analyzer
   Input: Feature ticket + requirements
   Output: Implementation plan + file structure

2. Design Reviewer
   Input: Figma design
   Output: Component breakdown + accessibility checklist

3. Implementation Agent
   Input: Plan + design validation
   Output: Component code + types

4. Testing Agent
   Input: Implementation code
   Output: Test suites

5. Documentation Agent
   Input: Components + tests
   Output: Documentation

6. PR Reviewer
   Input: All changes
   Output: Review feedback
```

---

## Agent Capabilities Matrix

| Capability     | Task Analyzer | Design Reviewer | Implementation | Testing | Documentation | PR Reviewer |
| -------------- | ------------- | --------------- | -------------- | ------- | ------------- | ----------- |
| TypeScript     | ✓             | ✓               | ✓✓✓            | ✓✓      | ✓✓            | ✓✓✓         |
| React          | ✓             | ✓✓              | ✓✓✓            | ✓✓      | ✓✓            | ✓✓✓         |
| Astro          | ✓             | ✓               | ✓✓✓            | ✓✓      | ✓✓            | ✓✓✓         |
| Next.js        | ✓             | ✓               | ✓✓✓            | ✓✓      | ✓✓            | ✓✓✓         |
| TailwindCSS    | -             | ✓✓              | ✓✓✓            | -       | ✓             | ✓✓          |
| AntD           | -             | ✓✓              | ✓✓✓            | ✓       | ✓✓            | ✓✓          |
| ShadcnUI       | -             | ✓✓              | ✓✓✓            | ✓       | ✓✓            | ✓✓          |
| Apollo Client  | -             | -               | ✓✓✓            | ✓✓      | ✓             | ✓✓          |
| TanStack Query | -             | -               | ✓✓✓            | ✓✓      | ✓             | ✓✓          |
| Testing        | -             | -               | ✓              | ✓✓✓     | ✓             | ✓✓          |
| Accessibility  | ✓             | ✓✓✓             | ✓✓             | ✓✓      | ✓             | ✓✓✓         |
| Performance    | ✓             | ✓               | ✓✓             | ✓       | -             | ✓✓✓         |
| Security       | ✓             | -               | ✓✓             | ✓       | -             | ✓✓✓         |

Legend: ✓ = Basic, ✓✓ = Intermediate, ✓✓✓ = Expert

---

## Standards Compliance

**All agents must follow**:

- [Code Standards](../../standards/code-standards.md)
- [Tech Stack Standards](../../standards/tech-stack.md)
- [AI Usage Guidelines](../guidelines.md)

**All agent outputs should**:

- Be type-safe (TypeScript strict mode)
- Follow naming conventions
- Include error handling
- Be accessible (WCAG 2.1)
- Be performant
- Be tested

---

## Updating Agents

When updating agent definitions:

1. Update this manifest
2. Update individual agent file
3. Test agent with real examples
4. Document changes in PR
5. Share with team

---

## Creating New Agents

To add a new agent:

1. Identify the need (what workflow gap exists?)
2. Define scope and skills
3. Create agent file in `/ai/agents/`
4. Add to this manifest
5. Test with team
6. Gather feedback and iterate

---

## Questions?

- Read [AI Guidelines](../guidelines.md)
- Check [Development Workflow](../../workflows/development-workflow.md)
- Review individual agent files
- Ask in team channels

---

**Remember**: Agents are tools to enhance your workflow. They assist with thinking and execution but don't replace engineering judgment.
