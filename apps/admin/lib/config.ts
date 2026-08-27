// Server-only configuration. Imported exclusively by server components and
// server actions, so the staff token never reaches the browser.
//
// The admin surface's real gate is the API (staff uid + IP allow-list,
// ADR-0016 / task 16.1). This portal simply holds a staff credential and
// forwards it; portal-level SSO is a later hardening step.

export const adminConfig = {
  // The API origin. Server-side fetch, so this is not a NEXT_PUBLIC value.
  apiBaseUrl: process.env.ADMIN_API_URL ?? 'http://localhost:8080',

  // The bearer sent to the admin API. In dev, the seeded staff uid as a
  // `dev:<uid>` token; in prod, a staff Firebase ID token. Never exposed to
  // the client.
  staffToken: process.env.ADMIN_API_STAFF_TOKEN ?? 'dev:dev-staff',
} as const;
