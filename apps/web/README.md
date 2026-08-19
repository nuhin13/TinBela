# TinBela Web — landing page + member PWA

**Scaffolded in Epics 14 and 15.**

One Next.js app serves both surfaces, because they share a domain, a deploy,
and design tokens:

```
app/(marketing)/          /              landing page
                          /privacy       Play requirement
                          /terms
                          /delete-account  Play requirement
app/m/[token]/            the member PWA — no install, no password
```

## Initialise

```bash
cd apps
pnpm create next-app@latest web --typescript --tailwind --app --no-src-dir
```

Point `tailwind.config.ts` at `packages/design-tokens/tailwind.tokens.js`.

## Hard budget — enforced by Lighthouse CI

**<500KB shell, <3s first paint on throttled 3G.**

This is a marketing surface as much as a feature. A member who waits eight
seconds never opens it again, and the growth loop dies with them.

## Rules

- No `localStorage` / `sessionStorage` — anywhere
- Token auth from the URL. No session, no password, ever
- Use the generated TypeScript client from `packages/api-clients`
- bn default with Bangla numerals, visually identical to the Flutter app
