// The design tokens, read from the same tokens.json that generates the
// Flutter theme and the Tailwind config (ADR-0014).
//
// Tailwind covers everything expressible as a class. This exists for the
// handful of places that need a raw value in TypeScript -- a theme-color
// meta tag, a web manifest -- where a hex literal would otherwise creep in
// and quietly drift from the app (apps/web/AGENTS.md: never a hex literal).

import tokens from '../../../packages/design-tokens/tokens.json';

export const color = {
  primary: tokens.color.primary.value,
  accent: tokens.color.accent.value,
  alert: tokens.color.alert.value,
  surface: tokens.color.surface.value,
  card: tokens.color.card.value,
  ink: tokens.color.ink.value,
  inkMuted: tokens.color.inkMuted.value,
  tint: tokens.color.tint.value,
  divider: tokens.color.divider.value,
} as const;
