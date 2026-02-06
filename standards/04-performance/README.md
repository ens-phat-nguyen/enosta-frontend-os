# Performance

> "Make it work. Make it right. Make it fast. In that order. Most developers skip the last step."

---

## Foundational Principles

Before optimizing, understand these principles:

### 1. **Interface-First Thinking**

Understand user expectations before optimizing. What does "fast" mean for your users?

### 2. **KISS (Keep It Simple, Stupid)**

Simple code is often faster than clever code. Profile before optimizing.

### 3. **YAGNI (You Aren't Gonna Need It)**

Don't optimize features no one uses. Focus on critical user journeys.

**Must Read:** [Development Principles](../00-development-principles/README.md)

---

## Overview

**Performance** is about ensuring your application feels fast and responsive to users. Poor performance frustrates users, increases bounce rates, and damages brand perception. Performance optimization is not optional—it's a core responsibility.

Frontend performance encompasses:

- **Load time** - How quickly the page becomes interactive
- **Runtime performance** - How smoothly interactions respond
- **Bundle size** - How much JavaScript users download
- **Rendering efficiency** - How well React manages re-renders

**Key Insight:** Performance priorities differ based on project type:

- **React SPA (Dashboards)** → Focus on runtime performance and interactivity
- **Next.js/Astro (Marketing)** → Focus on initial load and SEO metrics

---

## Goals

1. **Fast Initial Load** - Lighthouse score ≥ 90
2. **Smooth Interactions** - 60 FPS during animations and scrolling
3. **Small Bundle** - Keep JavaScript under control
4. **Memory Efficient** - Avoid memory leaks and bloat

---

## Table of Contents

- [Foundational Principles](#foundational-principles)
- [Project Type Performance Priorities](#project-type-performance-priorities)
- [Key Metrics](#key-metrics)
- [Loading Performance](#loading-performance)
- [Runtime Performance](#runtime-performance)
- [Bundle Optimization](#bundle-optimization)
- [Tools & Monitoring](#tools--monitoring)
- [Best Practices](#best-practices)

---

## Project Type Performance Priorities

### React SPA (Internal Dashboards, Admin Tools, Real-time Apps)

**Performance Focus: Runtime & Interactivity**

```
Priority 1: Smooth interactions (no jank)
Priority 2: Bundle size (users stay in app)
Priority 3: Initial load time (one-time cost)
```

**Target Metrics:**

- ✅ First Paint: < 2s (cached, less critical)
- ✅ Time to Interactive: < 3s (once loaded, users stay)
- ✅ Interaction Response: < 100ms (critical)
- ✅ JavaScript Bundle: < 300 KB
- ✅ Lighthouse: ≥ 80

**Why Different:**

- Users load once, then stay in the app for hours
- Interactions must be instant (buttons, filters, real-time updates)
- Initial load is amortized over long sessions
- Bundle size matters because users rarely refresh

**Optimization Strategy:**

1. Code splitting by routes (users only load what they need)
2. Memoization for expensive re-renders
3. Virtual scrolling for large lists
4. WebWorkers for heavy computation
5. Service workers for offline support

---

### Next.js / Astro (Marketing Sites, Public Content)

**Performance Focus: Initial Load & SEO**

```
Priority 1: Initial load time (first impression)
Priority 2: SEO metrics (search rankings)
Priority 3: Runtime performance (less critical)
```

**Target Metrics:**

- ✅ First Contentful Paint (FCP): < 1.5s
- ✅ Largest Contentful Paint (LCP): < 2.5s
- ✅ Cumulative Layout Shift (CLS): < 0.1
- ✅ First Input Delay (FID): < 100ms
- ✅ Lighthouse: ≥ 90 (Core Web Vitals)
- ✅ JavaScript Bundle: < 150 KB (minimal JS)

**Why Different:**

- Users visit once, judge quickly, then leave (or convert)
- First impression is everything
- SEO directly impacts business
- Low interactivity (mostly content)
- New visitors every day (no cache benefit)

**Optimization Strategy (Astro Priority):**

1. **Zero JavaScript by default** - Only add JS for interactive components
2. **Static generation** - Pre-render pages at build time
3. **Image optimization** - Critical for visual appeal
4. **Streaming HTML** - Show content as it renders
5. **Edge caching** - Serve from CDN globally

**Optimization Strategy (Next.js Priority):**

1. **Static generation for public pages** - ISR for updates
2. **Image optimization** - Next.js Image component
3. **Font optimization** - Self-hosted, preloaded
4. **API route optimization** - Keep responses fast
5. **Selective hydration** - Only hydrate interactive parts

---

## Key Metrics

### Core Web Vitals (All Projects)

Modern browsers track three key metrics:

| Metric                             | Target  | What It Measures                            |
| ---------------------------------- | ------- | ------------------------------------------- |
| **LCP** (Largest Contentful Paint) | < 2.5s  | When largest content element appears        |
| **FID** (First Input Delay)        | < 100ms | How long until page responds to interaction |
| **CLS** (Cumulative Layout Shift)  | < 0.1   | Visual stability during load                |

### Performance Budget

**React SPA:**

```
✅ JavaScript Bundle: < 300 KB (gzipped)
✅ Initial Load: < 3 seconds
✅ Time to Interactive: < 4 seconds
✅ Lighthouse Score: ≥ 80
✅ Runtime Jank: < 16ms per frame
```

**Next.js/Astro:**

```
✅ JavaScript Bundle: < 150 KB (gzipped)
✅ Initial Load: < 2 seconds
✅ FCP: < 1.5 seconds
✅ LCP: < 2.5 seconds
✅ Lighthouse Score: ≥ 90
✅ CLS: < 0.1
```

Adjust based on your specific project type and network conditions.

---

## Loading Performance

### 1. Code Splitting

**What:** Break JavaScript into chunks loaded only when needed.

```typescript
// Bad: Everything in one bundle
import { HeavyComponent } from './heavy';

export default function App() {
  return <HeavyComponent />;
}

// Good: Lazy load non-critical components
const HeavyComponent = lazy(() => import('./heavy'));

export default function App() {
  return (
    <Suspense fallback={<Spinner />}>
      <HeavyComponent />
    </Suspense>
  );
}
```

**Best Practices:**

- Route-based splitting (each route is a chunk)
- Feature-based splitting (modals, drawers)
- Vendor splitting (separate bundle for node_modules)

### 2. Image Optimization

**Web-friendly formats:**

```typescript
// Bad: Large unoptimized image
<img src="photo.jpg" alt="Photo" />

// Good: Multiple formats with Next.js Image
import Image from 'next/image';

<Image
  src="/photo.jpg"
  alt="Photo"
  width={800}
  height={600}
  placeholder="blur" // Low-quality placeholder
/>
```

**Guidelines:**

- Use WebP format (Next.js/Astro handle conversion)
- Provide multiple sizes for responsive images
- Lazy load images below the fold
- Compress images (TinyPNG, Squoosh)
- Use `placeholder="blur"` for better UX

### 3. Font Optimization

```typescript
// next.config.js - Self-host fonts
import { fetchFont } from 'next/font/google';

const inter = fetchFont({
  family: 'Inter',
  weight: ['400', '700'],
  display: 'swap', // Show fallback immediately
  preload: true, // Preload in head
});

// _app.tsx
<style jsx global>{`
  body {
    font-family: ${inter.style.fontFamily};
  }
`}</style>
```

**Guidelines:**

- Self-host fonts (avoid external requests)
- Use `font-display: swap` to show content immediately
- Load only needed weights and styles
- Limit number of font families (max 2-3)

### 4. Bundle Size Monitoring

```typescript
// next.config.js
const withBundleAnalyzer = require("@next/bundle-analyzer")({
  enabled: process.env.ANALYZE === "true",
});

module.exports = withBundleAnalyzer({
  // config
});
```

```bash
# Analyze bundle
ANALYZE=true npm run build

# Check what's taking space
npm list --depth=0
```

**Action Triggers:**

- Bundle grows > 10% → Investigate
- Large unused dependency → Remove or replace
- Duplicate dependency → Use single version

---

## Runtime Performance

### 1. Prevent Unnecessary Re-renders

**Problem:** React re-renders component whenever state changes, even if props don't change.

```typescript
// Bad: Re-renders on every parent update
function UserCard({ user }) {
  return <div>{user.name}</div>;
}

// Good: Memoize to skip re-render if props unchanged
const UserCard = memo(function UserCard({ user }) {
  return <div>{user.name}</div>;
}, (prev, next) => prev.user.id === next.user.id);
```

**When to use memo:**

- Component is expensive to render
- Props rarely change
- Parent re-renders frequently

### 2. Optimize Context

**Problem:** Context causes all consumers to re-render.

```typescript
// Bad: All components re-render when user changes
const UserContext = createContext();

function App() {
  const [user, setUser] = useState(null);
  return (
    <UserContext.Provider value={{ user, setUser }}>
      <Header /> {/* Re-renders unnecessarily */}
      <Sidebar /> {/* Re-renders unnecessarily */}
    </UserContext.Provider>
  );
}

// Good: Split into separate contexts
const UserContext = createContext();
const UserSetContext = createContext();

function App() {
  const [user, setUser] = useState(null);
  return (
    <UserContext.Provider value={user}>
      <UserSetContext.Provider value={setUser}>
        <Header /> {/* Only re-renders if user changes */}
        <Sidebar />
      </UserSetContext.Provider>
    </UserContext.Provider>
  );
}
```

### 3. Use useCallback and useMemo

```typescript
// Bad: Function recreated on every render
function SearchBox({ onSearch }) {
  return (
    <input
      onChange={(e) => onSearch(e.target.value)}
      placeholder="Search..."
    />
  );
}

// Good: Stable function reference
function SearchBox({ onSearch }) {
  const handleChange = useCallback(
    (e) => onSearch(e.target.value),
    [onSearch]
  );

  return (
    <input
      onChange={handleChange}
      placeholder="Search..."
    />
  );
}

// Memoize expensive computations
const expensiveValue = useMemo(
  () => computeExpensiveValue(a, b),
  [a, b] // Only recalculate when a or b changes
);
```

**When to use:**

- Function passed to memoized child
- Expensive computation from props/state
- Dependency list has many items

### 4. Virtualization for Long Lists

```typescript
// Bad: Render 10,000 items → 10,000 DOM nodes
function UserList({ users }) {
  return (
    <div>
      {users.map(user => (
        <UserRow key={user.id} user={user} />
      ))}
    </div>
  );
}

// Good: Only render visible items (30-50)
import { FixedSizeList } from 'react-window';

function UserList({ users }) {
  const Row = ({ index, style }) => (
    <div style={style}>
      <UserRow user={users[index]} />
    </div>
  );

  return (
    <FixedSizeList
      height={600}
      itemCount={users.length}
      itemSize={50}
    >
      {Row}
    </FixedSizeList>
  );
}
```

**When to use:**

- Lists > 100 items
- Each item is complex
- Performance profiler shows rendering as bottleneck

### 5. Debounce and Throttle

```typescript
// Bad: Update store on every keystroke
const [search, setSearch] = useState("");

const handleSearch = (e) => {
  setSearch(e.target.value); // Network request on every keystroke
};

// Good: Debounce user input
import { useCallback } from "react";

const [search, setSearch] = useState("");

const handleSearch = useCallback(
  debounce((value) => {
    setSearch(value); // Network request after user stops typing
  }, 300),
  [],
);

// Shared utility
export function debounce(fn, delay) {
  let timeout;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => fn(...args), delay);
  };
}
```

---

## Bundle Optimization

### 1. Tree Shaking

```typescript
// Bad: Import entire utility library
import _ from "lodash";

const sorted = _.sortBy(array, "name");

// Good: Import specific function
import { sortBy } from "lodash-es";

const sorted = sortBy(array, "name");
```

### 2. Dynamic Imports

```typescript
// Bad: Load admin UI for all users
import AdminPanel from './AdminPanel';

// Good: Only load if user is admin
const AdminPanel = lazy(() => import('./AdminPanel'));

export function Dashboard() {
  const { isAdmin } = useAuthStore();

  return (
    <>
      <MainContent />
      {isAdmin && (
        <Suspense fallback={<div>Loading...</div>}>
          <AdminPanel />
        </Suspense>
      )}
    </>
  );
}
```

### 3. External Dependencies Review

```typescript
// Check bundle impact before adding library
// npm install --save-bundle
// npm bundle-report

// Bad: 50 KB library for one function
import moment from "moment";

// Good: 2 KB alternative or native
import { format } from "date-fns";
// or use native Intl API
new Intl.DateTimeFormat("en-US").format(date);
```

---

## Best Practices

### ✅ DO

- **Measure first** - Use Lighthouse, DevTools, or Sentry
- **Set performance budgets** - Make trade-offs visible
- **Profile with DevTools** - Identify real bottlenecks
- **Monitor in production** - Real user metrics matter most
- **Optimize images aggressively** - Often the biggest impact
- **Code split by route** - Every route is a separate chunk
- **Lazy load below-the-fold content** - Images, components, styles
- **Cache aggressively** - Leverage browser and CDN caching

### ❌ DON'T

- **Optimize prematurely** - Measure first
- **Use `useCallback` everywhere** - Only for expensive children
- **Keep large libraries for one feature** - Find alternatives
- **Ignore bundle size growth** - Monitor in CI/CD
- **Load all data upfront** - Paginate or virtualize
- **Trust feelings over metrics** - Use DevTools
- **Forget about mobile** - Test on real devices

---

## Tools & Monitoring

### Measurement Tools

| Tool                | Purpose                                 |
| ------------------- | --------------------------------------- |
| **Lighthouse**      | Comprehensive performance audit         |
| **Chrome DevTools** | Performance profiling, network analysis |
| **WebPageTest**     | Detailed waterfall analysis             |
| **SpeedCurve**      | Continuous performance monitoring       |
| **Bundle Analyzer** | Identify large packages in bundle       |

### Production Monitoring

**Sentry (already in tech stack)**

```typescript
// src/core/sentry.ts
import * as Sentry from "@sentry/react";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1,
  integrations: [
    new Sentry.Replay({
      maskAllText: true,
      blockAllMedia: true,
    }),
  ],
});

// Capture performance metrics
Sentry.captureMessage(`Page load: ${timing.duration}ms`, "info");
```

### Observability Checklist

- [ ] Lighthouse score ≥ 90 on first load
- [ ] Time to Interactive < 4 seconds
- [ ] Bundle size tracked in CI/CD
- [ ] Core Web Vitals monitored in production
- [ ] Sentry capturing performance data
- [ ] Real user metrics collected (RUM)
- [ ] Slow transaction alerts configured

---

## Workflow & Checklist

When optimizing performance:

- [ ] Profile with DevTools Performance tab
- [ ] Identify the actual bottleneck
- [ ] Set measurable target (e.g., reduce load by 20%)
- [ ] Implement optimization
- [ ] Verify with measurement tools
- [ ] Monitor impact in production
- [ ] Document what improved and why

---

## References

- [Web.dev Performance Guidance](https://web.dev/performance/)
- [Chrome DevTools Performance](https://developer.chrome.com/docs/devtools/performance/)
- [Next.js Image Optimization](https://nextjs.org/docs/basic-features/image-optimization)
- [React Profiler API](https://react.dev/reference/react/Profiler)
- [Bundle Analyzer](https://github.com/vercel/next.js/tree/canary/packages/next-bundle-analyzer)
