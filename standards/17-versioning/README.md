# Versioning & Changelog

> "Every version tells a story. Make it clear."

---

## Foundational Principles

Versioning communicates to other teams.

### 1. **Interface-First Thinking**

Decide versioning strategy before first release. How will users upgrade?

### 2. **DRY (Don't Repeat Yourself)**

Automated versioning and changelog generation saves time.

### 3. **KISS (Keep It Simple, Stupid)**

Semantic Versioning is proven. Don't invent alternatives.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Versioning & Changelog** includes:

1. **Semantic Versioning** — MAJOR.MINOR.PATCH format
2. **Changelog** — What changed and why
3. **Commit Messages** — Conventional Commits
4. **Deprecation** — How to retire old APIs
5. **Release Process** — Automated or manual

Clear versioning = happy users who know what breaks.

---

## Goals

1. **Clear API Contracts** — Users know what changed
2. **Automated Changelog** — Generated from commits
3. **Deprecation Path** — Users know what's ending
4. **Easy Upgrades** — Users understand breaking changes
5. **Release Confidence** — Automated version bumping

---

## Table of Contents

- [Foundational Principles](#foundational-principles)
- [Semantic Versioning](#semantic-versioning)
- [Changelog Format](#changelog-format)
- [Conventional Commits](#conventional-commits)
- [Deprecation Strategy](#deprecation-strategy)
- [Release Process](#release-process)
- [Best Practices](#best-practices)

---

## Semantic Versioning

### MAJOR.MINOR.PATCH Format

```
Version: 2.5.3
        │ │ │
        │ │ └─ PATCH: Bug fixes (2.5.0 → 2.5.3)
        │ └─── MINOR: New features, backwards compatible (2.0.0 → 2.5.0)
        └───── MAJOR: Breaking changes (1.0.0 → 2.0.0)
```

### When to Bump

```typescript
// PATCH: Bug fixes
// 1.0.0 → 1.0.1
// - Fix: Memory leak in useEffect cleanup
// - Fix: Incorrect date formatting for RTL languages

// MINOR: New features (backwards compatible)
// 1.0.0 → 1.1.0
// - Add: useFormValidation hook
// - Add: Dark mode theme support
// - Deprecate: Old AuthContext (use useAuth hook instead)

// MAJOR: Breaking changes
// 1.0.0 → 2.0.0
// - Remove: AuthContext (use useAuth hook)
// - Change: API endpoint from /api/v1 to /api/v2
// - Remove: Legacy Modal component
```

### Pre-release Versions

```
1.0.0-alpha.1     (Early development)
1.0.0-beta.1      (Feature complete, may have bugs)
1.0.0-rc.1        (Release candidate, almost ready)
```

---

## Changelog Format

### Keep a Changelog Format

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [2.1.0] - 2024-01-15

### Added

- New `useFormValidation` hook for advanced form validation
- Support for RTL languages in form components
- Dark mode theme with system preference detection

### Fixed

- Memory leak in Apollo cache cleanup
- Date formatting bug for non-US locales
- Incorrect z-index stacking in Modal component

### Changed

- Improved error messages in form validation
- Updated dependencies to latest versions

### Deprecated

- `useAuth()` hook (use `useSession()` instead, will be removed in v3.0.0)

### Removed

- Legacy AuthContext (use `useSession()` hook)

### Security

- Updated axios to fix XSS vulnerability

## [2.0.0] - 2024-01-01

### Breaking Changes

- Changed API endpoint from `/api/v1` to `/api/v2`
- Removed `Modal` component (use `Dialog` instead)
- Changed default button size from `large` to `medium`
```

### Types of Changes

```
Added       - New feature
Changed     - Existing functionality change
Deprecated  - Will be removed in next major
Removed     - Previous deprecated features
Fixed       - Bug fix
Security    - Security fix
```

---

## Conventional Commits

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

```
feat:      New feature
fix:       Bug fix
docs:      Documentation
style:     Code style (formatting, semicolons, etc.)
refactor:  Code refactoring (no new feature, no bug fix)
perf:      Performance improvement
test:      Adding tests
chore:     Build, dependencies, tooling
ci:        CI/CD configuration
```

### Examples

```bash
# Feature
git commit -m "feat(auth): add two-factor authentication"

# Fix
git commit -m "fix(modal): correct z-index stacking issue"

# Breaking change
git commit -m "feat(api)!: change endpoint from /v1 to /v2

BREAKING CHANGE: API endpoint changed from /api/v1 to /api/v2"

# Deprecation
git commit -m "deprecate(auth): useAuth hook deprecated in favor of useSession

Migrate: const user = useSession() instead of useAuth()
Timeline: Will be removed in v3.0.0"
```

### Tools

```bash
# Install commitizen for guided commits
npm install -D commitizen cz-conventional-changelog

# Then commit with:
npx cz commit
```

---

## Deprecation Strategy

### Deprecation Warning Pattern

```typescript
// ✅ Add deprecation warning
const useAuth = () => {
  console.warn(
    "⚠️ useAuth() is deprecated since v2.0.0. " +
      "Use useSession() instead. " +
      "This will be removed in v3.0.0.",
  );

  return useSession();
};

// In development, this appears in console
// In production, only appears if user has DevTools open
```

### Deprecation Timeline

```markdown
# Deprecation Policy

## Phase 1: Deprecation (Release v2.0.0)

- Feature marked as deprecated in code and docs
- Warnings logged to console
- Migration guide provided

## Phase 2: Warning Period (v2.0.0 - v2.x.x)

- Deprecated feature still works
- Users have 2-3 minor versions to migrate
- Release notes clearly state timeline

## Phase 3: Removal (v3.0.0)

- Deprecated feature completely removed
- Release notes include migration guide
```

### Examples

```typescript
// Version 2.0.0: Deprecate
const useAuth = () => {
  console.warn("useAuth() deprecated, use useSession() instead");
  return useSession();
};

// Version 2.5.0: Still deprecated
// Version 2.9.0: Last release with deprecated API
// Version 3.0.0: Remove completely

export const useSession = () => {
  /* ... */
};
```

---

## Release Process

### Manual Release Steps

```bash
# 1. Bump version in package.json
npm version minor
# or
npm version major
# or
npm version patch

# 2. Create CHANGELOG entry
# Edit CHANGELOG.md

# 3. Commit changes
git add -A
git commit -m "chore(release): bump version to 2.1.0"
git tag v2.1.0

# 4. Push
git push --tags

# 5. Publish
npm publish
```

### Automated Release with semantic-release

```json
{
  "name": "my-package",
  "version": "2.0.0",
  "scripts": {
    "release": "semantic-release"
  },
  "devDependencies": {
    "semantic-release": "^19.0.0"
  }
}
```

```bash
# Automatically:
# 1. Analyzes commits
# 2. Bumps version (major/minor/patch)
# 3. Generates changelog
# 4. Creates git tag
# 5. Publishes to npm
npm run release
```

### GitHub Release Notes

```markdown
# v2.1.0 - Form Validation Improvements

## What's New

### Features

- ✨ New `useFormValidation` hook for advanced form validation (#456)
- ✨ Dark mode support with system preference detection (#457)
- ✨ RTL language support in forms (#458)

### Fixes

- 🐛 Fixed memory leak in Apollo cache cleanup (#459)
- 🐛 Fixed date formatting for non-US locales (#460)

### Migration Guide

No breaking changes. All updates are backwards compatible.

### Contributors

@alice, @bob, @charlie
```

---

## Best Practices

1. **Semantic Versioning** — Always use MAJOR.MINOR.PATCH
2. **Conventional Commits** — Automate changelog generation
3. **One Version per Release** — No multi-version releases
4. **Deprecation Warning** — Always warn before removal
5. **Changelog First** — Write changelog as you code
6. **Clear Migration Paths** — Show how to upgrade
7. **Release Notes** — Include summary and breaking changes
8. **Version Documentation** — Keep old docs accessible
9. **Breaking Changes in MAJOR** — Only change API with major bumps
10. **Release Early, Often** — Smaller releases = easier reviews

---

## Versioning Checklist

- [ ] Semantic Versioning used (MAJOR.MINOR.PATCH)
- [ ] Changelog updated before release
- [ ] Commit messages follow Conventional Commits
- [ ] Breaking changes in CHANGELOG marked clearly
- [ ] Deprecation warnings in code
- [ ] Migration guide provided
- [ ] Release notes generated
- [ ] Git tags applied
- [ ] Automated versioning configured (semantic-release)
- [ ] Old versions documented

---

## Version Examples Timeline

```
v1.0.0 (initial release)
│
├─ v1.0.1 (patch: fix bug)
├─ v1.1.0 (minor: add feature)
├─ v1.2.0 (minor: add feature)
├─ v1.2.1 (patch: fix bug)
│
├─ v2.0.0 (major: breaking changes)
├─ v2.0.1 (patch: fix bug in v2)
├─ v2.1.0 (minor: add feature)
├─ v2.1.1 (patch: fix bug)
├─ v2.2.0 (minor: deprecate old API)
│
└─ v3.0.0 (major: remove deprecated API)
```
