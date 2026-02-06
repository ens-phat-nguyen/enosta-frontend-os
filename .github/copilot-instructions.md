# GitHub Copilot Instructions for Frontend OS

This repository defines the **operating system** for our frontend team's engineering practices.

When assisting with code or documentation in this repository, follow these guidelines:

---

## Repository Context

**Purpose**: Single source of truth for frontend engineering standards, architecture, workflows, and AI-assisted practices.

**Structure**:

- `/principles/` – Core engineering principles
- `/architecture/` – Architecture patterns and decisions
- `/standards/` – Code standards and conventions
- `/workflows/` – Development workflows
- `/ai/` – AI usage guidelines, prompts, and agents
- `/skills/` – Skills matrix and growth expectations
- `/onboarding/` – Onboarding materials
- `/playbooks/` – Step-by-step guides
- `/decision-records/` – Architecture Decision Records (ADRs)

---

## Writing Style

When generating or editing documentation:

- **Be pragmatic**: Focus on actionable guidance over theory
- **Be concise**: Clarity beats completeness
- **Be specific**: Include examples and context
- **Avoid jargon**: Unless it's widely understood by the team
- **Use active voice**: "Use X" instead of "X should be used"
- **Structure clearly**: Use headings, lists, and code blocks effectively

---

## Documentation Standards

### Markdown Formatting

- Use `#` for main titles, `##` for sections, `###` for subsections
- Use code blocks with language tags: ``javascript`, ``typescript`, etc.
- Use **bold** for emphasis, _italics_ sparingly
- Keep line length reasonable (80-100 chars where possible)
- Add horizontal rules (`---`) to separate major sections

### File Structure

- Start with a clear title and purpose
- Include a table of contents for longer docs (>200 lines)
- End with "Next Steps" or "Related Resources" when applicable
- Use relative links for internal references: `[principles](../principles/)`

### Examples

Always include examples when explaining concepts:

```markdown
✅ **Good:**
Use semantic HTML elements for better accessibility.

<nav>
  <ul>
    <li><a href="/">Home</a></li>
  </ul>
</nav>

❌ **Avoid:**
Using div elements for navigation.

<div class="nav">
  <div class="nav-item">...</div>
</div>
```

---

## Code Standards (When Adding Code Examples)

- **Follow modern JavaScript/TypeScript practices**
- Use functional patterns over class-based where appropriate
- Prefer `const` over `let`, never `var`
- Use async/await over promise chains
- Include TypeScript types when relevant
- Write self-documenting code with clear variable names
- Add comments only when the "why" isn't obvious

### Example Code Format

```typescript
// ✅ Good: Clear, typed, self-documenting
const fetchUserProfile = async (userId: string): Promise<UserProfile> => {
  const response = await fetch(`/api/users/${userId}`);
  if (!response.ok) {
    throw new Error(`Failed to fetch user: ${response.statusText}`);
  }
  return response.json();
};

// ❌ Avoid: Unclear naming, no types, poor error handling
const getData = async (id) => {
  return fetch("/api/users/" + id).then((r) => r.json());
};
```

---

## Architecture Decision Records (ADRs)

When suggesting or writing ADRs in `/decision-records/`:

**Required Structure:**

1. **Title**: ADR-XXX: [Clear, descriptive title]
2. **Status**: Proposed | Accepted | Deprecated | Superseded
3. **Context**: Problem statement and constraints
4. **Decision**: What we decided and why
5. **Consequences**: Trade-offs, benefits, risks
6. **Alternatives Considered**: Other options evaluated

**Tone**: Objective, fact-based, future-oriented

---

## AI-Related Content

When working on content in `/ai/`:

- Focus on **responsible AI usage**
- Emphasize understanding over speed
- Treat AI as an assistant, not a replacement
- Include practical examples and patterns
- Address common pitfalls and red flags
- Align with the philosophy: "AI is a multiplier, not a replacement"

### Prompts (`/ai/prompts/`)

Format prompts as reusable templates:

```markdown
# [Prompt Name]

## Purpose

[What this prompt does]

## When to Use

[Specific scenarios]

## Prompt Template

[The actual prompt text with {{placeholders}}]

## Example Usage

[Concrete example]

## Tips

- [Optimization suggestions]
```

### Agents (`/ai/agents/`)

Document agent workflows with:

- Clear purpose and scope
- Input requirements
- Expected outputs
- Limitations and warnings
- Example usage

---

## Playbooks

When creating playbooks in `/playbooks/`:

1. **Start with the goal**: What will the reader accomplish?
2. **List prerequisites**: What do they need first?
3. **Provide step-by-step instructions**: Be explicit
4. **Include checkpoints**: How to verify each step
5. **Troubleshoot common issues**: What can go wrong?
6. **Link to related resources**

Use numbered lists for sequential steps:

````markdown
## Steps

1. **Install dependencies**
   ```bash
   npm install
   ```
````

✓ Checkpoint: `node_modules/` folder should exist

2. **Configure environment**
   ```bash
   cp .env.example .env
   ```
   ✓ Checkpoint: `.env` file should contain valid values

````

---

## Principles and Standards

When suggesting code or documentation:

- **Align with repository principles** (check `/principles/`)
- **Follow established standards** (check `/standards/`)
- **Reference existing patterns** (check `/architecture/`)
- **Maintain consistency** with the rest of the repository

If you're unsure about a standard, suggest checking the relevant directory.

---

## Language and Tone

- **Supportive**: Help developers learn and grow
- **Direct**: Don't hedge unnecessarily
- **Inclusive**: Use "we" and "our", avoid "you should"
- **Constructive**: When critiquing, explain the better approach
- **Practical**: Focus on real-world application

---

## Common Patterns

### When Adding a New Guideline

```markdown
# [Guideline Name]

## Why This Matters
[Brief explanation of the problem this solves]

## The Standard
[Clear, actionable rule]

## Examples

✅ **Do:**
[Good example with explanation]

❌ **Don't:**
[Bad example with explanation]

## Exceptions
[When this rule doesn't apply, if any]

## Related
- [Link to related guidelines]
````

### When Creating a Skills Matrix

```markdown
# [Skill Category]

## Junior Level

- [ ] Criterion 1
- [ ] Criterion 2

## Mid Level

- [ ] Criterion 1
- [ ] Criterion 2

## Senior Level

- [ ] Criterion 1
- [ ] Criterion 2

## Staff Level

- [ ] Criterion 1
- [ ] Criterion 2
```

---

## Red Flags to Avoid

When generating content, **don't**:

- ❌ Add unnecessary complexity
- ❌ Use outdated patterns or APIs
- ❌ Include unverified "best practices"
- ❌ Copy patterns without understanding context
- ❌ Suggest tools/libraries without justification
- ❌ Create rigid rules without explaining trade-offs

---

## Questions to Ask Yourself

Before suggesting code or documentation:

1. **Is it aligned with the repository's philosophy?**
2. **Is it actionable and practical?**
3. **Is it clear and well-explained?**
4. **Does it include examples?**
5. **Is it consistent with existing content?**
6. **Will it help developers make better decisions?**

---

## Remember

This repository is a **living system**. The goal is to:

- Help engineers do their best work
- Reduce cognitive load
- Create consistency without rigidity
- Enable growth and learning
- Make AI a responsible force multiplier

**Clarity beats completeness. Pragmatism beats perfection.**
