import Link from 'next/link';
import type { ReactNode } from 'react';

import { bcp47, defaultLocale, localePath, type Locale, type Page } from '@/lib/i18n';
import { messages } from '@/lib/messages';

// The marketing shell: header (brand + language toggle) and footer (the three
// Play-requirement links), rendered per locale. It replaces the old route-group
// layout, which could not localise itself because a layout at `(marketing)/`
// wraps both the bn root and the `/en` subtree and so never knows which it is.
//
// Kept deliberately plain and dependency-free -- this surface must not pull in
// anything the member PWA would then pay for in its own bundle (UX law 3).
export function MarketingShell({
  locale,
  page,
  children,
}: Readonly<{ locale: Locale; page: Page; children: ReactNode }>) {
  const t = messages[locale];
  const other: Locale = locale === 'bn' ? 'en' : 'bn';

  // The root <html> is lang="bn"; an en subtree overrides it here so screen
  // readers and line-breaking switch language for this content only. bn needs
  // no override (it matches the root), which also keeps the DOM identical to
  // the pre-i18n markup on the canonical path.
  const lang = locale === defaultLocale ? undefined : bcp47[locale];

  return (
    <div lang={lang} className="flex min-h-screen flex-col">
      <header className="border-b border-divider">
        <nav className="mx-auto flex max-w-3xl items-center justify-between px-lg py-md">
          <Link href={localePath(locale)} className="text-lg font-semibold text-primary">
            টিনবেলা
          </Link>
          {/* Plain link, not a client toggle: no JS on a 3G budget (UX law 3).
              The label is the other locale's name in its own script. */}
          <Link
            href={localePath(other, page)}
            hrefLang={bcp47[other]}
            className="text-sm text-inkMuted hover:text-ink"
          >
            {t.nav.switchTo}
          </Link>
        </nav>
      </header>

      <main className="mx-auto w-full max-w-3xl flex-1 px-lg py-xl">{children}</main>

      <footer className="border-t border-divider">
        <div className="mx-auto flex max-w-3xl flex-wrap gap-lg px-lg py-lg text-sm text-inkMuted">
          <Link href={localePath(locale, 'privacy')} className="hover:text-ink">
            {t.nav.privacy}
          </Link>
          <Link href={localePath(locale, 'terms')} className="hover:text-ink">
            {t.nav.terms}
          </Link>
          <Link href={localePath(locale, 'delete-account')} className="hover:text-ink">
            {t.nav.deleteAccount}
          </Link>
        </div>
      </footer>
    </div>
  );
}
