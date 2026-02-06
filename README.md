# Frontend OS

**Frontend OS** is the operating system for how our frontend team **designs, builds, reviews, and scales** frontend applications.

This repository is the **single source of truth** for frontend engineering at our team — covering principles, architecture decisions, development workflows, skill expectations, and AI-assisted practices.

It’s not just documentation.  
It’s _how we work_.

---

## Why Frontend OS exists

As teams grow, frontend complexity doesn’t come from code alone — it comes from:

- inconsistent patterns
- unclear standards
- undocumented decisions
- ad-hoc AI usage
- uneven skill expectations

Frontend OS exists to:

- align the team on **how and why we build things**
- reduce cognitive load for developers
- make onboarding faster and safer
- enable consistent, high-quality output
- treat AI as a **first-class engineering tool**, not a shortcut

---

## What lives here

This repo defines **shared contracts** for frontend engineering.

```text
frontend-os/
├── principles/ # Core frontend engineering principles
├── architecture/ # Architecture patterns & trade-offs
├── standards/ # Code standards, conventions, linting rules
├── workflows/ # Dev flow, PRs, releases, QA
├── ai/
│ ├── agents/ # AI agent templates & instructions
│ ├── prompts/ # Reusable prompts (review, refactor, audit)
│ └── guidelines.md # Responsible & effective AI usage
├── skills/ # Skills matrix & growth expectations
├── onboarding/ # New joiner onboarding & setup
├── playbooks/ # Step-by-step guides for common scenarios
└── decision-records/ # Architecture Decision Records (ADRs)
```

---

## How to use this repo

### For all frontend engineers

- Treat this repo as **default guidance**
- Follow standards unless there’s a documented exception
- Reference it in PRs and technical discussions

### For reviewers & leads

- Use it to **justify decisions**, not personal preference
- Keep standards and playbooks up to date
- Capture important decisions as ADRs

### For onboarding

New members should start with:

1. `principles/`
2. `standards/`
3. `architecture/`
4. `ai/guidelines.md`

---

## AI usage philosophy

AI is a **multiplier**, not a replacement for engineering judgment.

In this team:

- AI assists with thinking, reviewing, refactoring, and learning
- Output from AI must be **understood and owned** by engineers
- Prompts and agents are treated like reusable tooling
- Blind copy-paste is discouraged

AI guidance, prompts, and agents live under `/ai`.

---

## What this repo is not

- A dumping ground for random notes
- Tool-specific documentation without principles
- A rigid rulebook that can’t evolve

If something changes how we work, it should be **documented here**.

---

## Contributing & updates

Frontend OS is a **living system**.

- Propose changes via PR
- Add ADRs for significant architectural decisions
- Improve docs when you notice confusion or repetition
- Keep content pragmatic and experience-driven

**Clarity beats completeness.**

---

## Ownership

This repository is maintained by the frontend team.  
Everyone is encouraged to contribute, improve, and challenge assumptions — constructively.
