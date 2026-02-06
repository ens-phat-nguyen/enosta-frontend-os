# Internationalization (i18n)

> "Build globally, think locally."

---

## Foundational Principles

i18n is more than translation strings.

### 1. **Interface-First Thinking**

Design i18n architecture before adding translations. How will content change? Where are translatable strings?

### 2. **DRY (Don't Repeat Yourself)**

Extract translation strings, reuse namespaces, don't duplicate keys.

### 3. **KISS (Keep It Simple, Stupid)**

Use i18next. It's proven, powerful, simple.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Internationalization (i18n)** includes:

1. **Translation Strings** — Text in multiple languages
2. **Namespaces** — Organize translations by feature
3. **Date/Time Formatting** — Different formats per locale
4. **Number Formatting** — Different separators per locale
5. **RTL Support** — Right-to-left languages (Arabic, Hebrew)
6. **Language Switching** — Let users choose language

Global audience = global responsibility.

---

## Goals

1. **Easy Translation** — Simple to extract and update strings
2. **Performance** — Don't load all languages
3. **Scalability** — Add languages without code changes
4. **Quality** — Translations are consistent
5. **RTL Support** — Right-to-left languages work
6. **Fallback Language** — Missing translations don't crash

---

## Table of Contents

- [Foundational Principles](#foundational-principles)
- [i18next Setup](#i18next-setup)
- [Translation Structure](#translation-structure)
- [React Integration](#react-integration)
- [Advanced Patterns](#advanced-patterns)
- [Best Practices](#best-practices)

---

## i18next Setup

### Installation

```bash
npm install i18next react-i18next i18next-browser-languagedetector
```

### Basic Configuration

```typescript
// i18n.ts
import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import LanguageDetector from "i18next-browser-languagedetector";

i18n
  .use(LanguageDetector) // Auto-detect language from browser
  .use(initReactI18next)
  .init({
    fallbackLng: "en", // Fallback if detection fails
    debug: true,
    resources: {
      en: {
        translation: {
          welcome: "Welcome",
          "button.submit": "Submit",
        },
      },
      es: {
        translation: {
          welcome: "Bienvenido",
          "button.submit": "Enviar",
        },
      },
    },
  });

export default i18n;
```

### App Setup

```typescript
// app.tsx
import './i18n';
import { useTranslation } from 'react-i18next';

export default function App() {
  const { i18n } = useTranslation();

  const changeLanguage = (lng: string) => {
    i18n.changeLanguage(lng);
  };

  return (
    <div>
      <button onClick={() => changeLanguage('en')}>English</button>
      <button onClick={() => changeLanguage('es')}>Español</button>
    </div>
  );
}
```

---

## Translation Structure

### Namespace Organization

```json
// public/locales/en/common.json
{
  "app": {
    "title": "My App",
    "description": "An amazing app"
  },
  "buttons": {
    "submit": "Submit",
    "cancel": "Cancel"
  }
}

// public/locales/en/user.json
{
  "profile": {
    "title": "User Profile",
    "editButton": "Edit Profile"
  },
  "settings": {
    "language": "Language",
    "theme": "Theme"
  }
}
```

### Load from Files

```typescript
import i18n from "i18next";
import HttpApi from "i18next-http-backend";

i18n.use(HttpApi).init({
  fallbackLng: "en",
  ns: ["common", "user"], // Namespaces
  defaultNS: "common",
  backend: {
    loadPath: "/locales/{{lng}}/{{ns}}.json",
  },
});
```

### Namespace Pattern

```
locales/
├── en/
│  ├── common.json    (shared: buttons, messages)
│  ├── user.json      (user pages)
│  └── errors.json    (error messages)
└── es/
   ├── common.json
   ├── user.json
   └── errors.json
```

---

## React Integration

### Basic Usage

```typescript
import { useTranslation } from 'react-i18next';

const UserProfile = () => {
  const { t } = useTranslation('user');

  return (
    <div>
      <h1>{t('profile.title')}</h1>
      <button>{t('profile.editButton')}</button>
    </div>
  );
};
```

### With Namespaces

```typescript
const Dashboard = () => {
  const { t: tCommon } = useTranslation('common');
  const { t: tDashboard } = useTranslation('dashboard');

  return (
    <div>
      <h1>{tDashboard('title')}</h1>
      <button>{tCommon('buttons.submit')}</button>
    </div>
  );
};
```

### Interpolation (Variables)

```json
{
  "greeting": "Hello, {{name}}!",
  "items": "You have {{count}} item",
  "items_plural": "You have {{count}} items"
}
```

```typescript
const { t } = useTranslation();

// Interpolation
<p>{t('greeting', { name: 'John' })}</p>

// Pluralization (automatic)
<p>{t('items', { count: 5 })}</p> // "You have 5 items"
<p>{t('items', { count: 1 })}</p> // "You have 1 item"
```

### Translate Components

```typescript
// ✅ For complex markup in translations
import { Trans } from 'react-i18next';

// locales/en/common.json
{
  "welcome": "Welcome <bold>{{name}}</bold>!"
}

<Trans i18nKey="welcome" values={{ name: 'John' }}>
  Welcome <strong>John</strong>!
</Trans>
```

---

## Advanced Patterns

### Detect Language from URL

```typescript
// i18n.ts
const getLangFromUrl = () => {
  const path = window.location.pathname;
  const segments = path.split("/");
  if (["en", "es", "fr"].includes(segments[1])) {
    return segments[1];
  }
  return "en";
};

i18n.init({
  lng: getLangFromUrl(),
  // ...
});
```

### Date and Number Formatting

```typescript
import { useTranslation } from 'react-i18next';

const DateDisplay = ({ date }: { date: Date }) => {
  const { i18n } = useTranslation();

  const formatted = new Intl.DateTimeFormat(i18n.language, {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  }).format(date);

  return <p>{formatted}</p>;
};

// Intl handles locale-specific formatting automatically
// EN: January 15, 2024
// ES: 15 de enero de 2024
// DE: 15. Januar 2024
```

### Number Formatting

```typescript
const PriceDisplay = ({ price }: { price: number }) => {
  const { i18n } = useTranslation();

  const formatted = new Intl.NumberFormat(i18n.language, {
    style: 'currency',
    currency: i18n.language === 'es' ? 'EUR' : 'USD'
  }).format(price);

  return <p>{formatted}</p>;
};

// EN: $1,234.56
// ES: 1.234,56 €
```

### RTL Support

```typescript
const useIsRTL = () => {
  const { i18n } = useTranslation();
  return ['ar', 'he'].includes(i18n.language);
};

const Layout = () => {
  const isRTL = useIsRTL();

  return (
    <div dir={isRTL ? 'rtl' : 'ltr'}>
      <style>
        {isRTL ? `
          body { direction: rtl; text-align: right; }
          button { margin-left: auto; }
        ` : `
          body { direction: ltr; text-align: left; }
          button { margin-right: auto; }
        `}
      </style>
    </div>
  );
};
```

### Extract Keys with Extraction Tools

```bash
# Use i18next-scanner to extract keys from code
npm install -D i18next-scanner

# Scans JSX/TSX files for t('key') calls
# Generates JSON files with keys
```

---

## Best Practices

1. **Namespace by Feature** — Not one giant translation file
2. **Use Keys, Not Content** — `t('form.submit')` not `t('Submit')`
3. **Extract Early** — Set up i18n from project start
4. **Pluralization Rules** — Use i18next's plural syntax
5. **Don't Translate Dates** — Use Intl API for locale formatting
6. **RTL Support** — Test with Arabic or Hebrew
7. **Fallback Language** — Always have English default
8. **Lazy Load Languages** — Don't load all languages upfront
9. **Version Translations** — Track changes to translation files
10. **Translation Management** — Use tools like Crowdin for teams

---

## Translation File Example

```json
// locales/en/user.json
{
  "profile": {
    "title": "User Profile",
    "email": "Email",
    "joinDate": "Joined {{date}}",
    "editButton": "Edit Profile"
  },
  "settings": {
    "language": {
      "label": "Language",
      "english": "English",
      "spanish": "Español",
      "french": "Français"
    },
    "theme": {
      "label": "Theme",
      "light": "Light",
      "dark": "Dark"
    }
  },
  "notifications": {
    "saved": "Profile saved successfully",
    "error": "Failed to save profile"
  }
}
```

## Complete Example

```typescript
// App.tsx
import { useTranslation } from 'react-i18next';
import { Suspense } from 'react';

const App = () => {
  const { i18n } = useTranslation();

  return (
    <div>
      <header>
        <select onChange={(e) => i18n.changeLanguage(e.target.value)}>
          <option value="en">English</option>
          <option value="es">Español</option>
        </select>
      </header>

      <Suspense fallback={<div>Loading...</div>}>
        <Dashboard />
      </Suspense>
    </div>
  );
};

const Dashboard = () => {
  const { t } = useTranslation(['common', 'dashboard']);

  return (
    <main>
      <h1>{t('dashboard:title')}</h1>
      <button>{t('common:buttons.submit')}</button>
    </main>
  );
};
```
