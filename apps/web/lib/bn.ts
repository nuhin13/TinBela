// Bangla numerals, shared by every surface of the web app.
//
// The member PWA must look "visually identical to the Flutter app"
// (apps/web/AGENTS.md), and identical starts with the digits. Bangla is the
// default; en is the translation, not the other way round.

const BN_DIGITS = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'] as const;

export type Numerals = 'bn' | 'en';

/** Rewrites the ASCII digits in a string into Bangla ones. */
export function toBanglaDigits(input: string): string {
  return input.replace(/[0-9]/g, (d) => BN_DIGITS[Number(d)]);
}

/**
 * Formats an integer for display in the chosen numeral system.
 *
 * This is NOT a money formatter. Money is int64 paisa and is formatted by
 * MoneyText against the API's `math` object once Epic 06 supplies one
 * (Invariant 1: format only at the rendering edge, never compute here).
 */
export function formatCount(value: number, numerals: Numerals = 'bn'): string {
  const plain = String(Math.trunc(value));
  return numerals === 'bn' ? toBanglaDigits(plain) : plain;
}
