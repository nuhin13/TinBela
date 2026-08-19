# AGENTS.md — Web (landing page + member PWA)

One Next.js app, two surfaces:

```
app/(marketing)/   /                landing page
                   /privacy         Play requirement
                   /terms
                   /delete-account  Play requirement
app/m/[token]/     the member PWA — no install, no password
```

## The budget is the feature

**<500KB shell, <3s first paint on throttled 3G.** Lighthouse CI enforces it.

This is a marketing surface as much as a feature. Every member who opens the
link is a free acquisition impression — and a member who waits eight seconds
never opens it again, which kills the growth loop. Treat a budget regression
as a broken build, not a nice-to-have.

## Rules

- **No `localStorage`, no `sessionStorage`, no browser storage of any kind.**
- Token auth from the URL. No session, no password, ever. The link *is* the
  credential.
- Use the generated TypeScript client from `packages/api-clients`. Never
  hand-write a fetch against the API.
- Colours and spacing come from `packages/design-tokens/tailwind.tokens.js`
  (run `make tokens`). Never a hex literal.
- bn default with Bangla numerals, visually identical to the Flutter app.
- Invalid or revoked token gets a friendly screen, never a stack trace.
- A2HS prompt on the **second** visit, not the first.

## Admin portal

`apps/admin/` is a separate Next.js app with its own `AGENTS.md` rule:
**READ-ONLY on customer data.** No mutation path may exist in the code.
Feature flags and the kill switch are the only writes in the whole app.
