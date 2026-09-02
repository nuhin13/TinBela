// Marketing-site localisation (task 15.7).
//
// Bangla is the product's mother tongue and stays canonical at the root
// (`/`); English is the translation, served under `/en`. This mirrors
// apps/web/AGENTS.md: "bn default with Bangla numerals ... en is the
// translation, not the other way round." Only the marketing surface is
// localised here — the member PWA carries its own numerals toggle (task
// 14.7), and the Play-required legal pages are still founder-owned
// placeholders (15.4-15.6 ★) in every language.

export const locales = ['bn', 'en'] as const;
export type Locale = (typeof locales)[number];
export const defaultLocale: Locale = 'bn';

// The BCP-47 tags search engines and OpenGraph consumers expect, keyed by our
// short locale. Used for the lang attribute, hreflang alternates, and
// og:locale.
export const bcp47: Record<Locale, string> = { bn: 'bn-BD', en: 'en-US' };

// The locale-independent tail of every marketing route. '' is the home page.
export type Page = '' | 'privacy' | 'terms' | 'delete-account';

/**
 * The path a marketing route lives at in a given locale. bn is canonical at
 * the root; en is prefixed with `/en`. So `('bn','privacy') -> '/privacy'`
 * and `('en','privacy') -> '/en/privacy'`; the home page is `/` and `/en`.
 */
export function localePath(locale: Locale, page: Page = ''): string {
  const tail = page ? `/${page}` : '';
  if (locale === 'en') return `/en${tail}`;
  return tail || '/';
}

/**
 * The hreflang alternates for one page, in the shape Next's Metadata
 * `alternates.languages` wants. `x-default` points at bn — it is the default
 * a crawler falls back to when it has no locale preference.
 */
export function languageAlternates(page: Page = ''): Record<string, string> {
  return {
    'bn-BD': localePath('bn', page),
    'en-US': localePath('en', page),
    'x-default': localePath('bn', page),
  };
}
