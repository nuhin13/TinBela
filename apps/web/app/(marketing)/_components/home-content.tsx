import type { Locale } from '@/lib/i18n';
import { messages } from '@/lib/messages';

import { AppShowcase } from './app-showcase';
import { TapComparison } from './tap-comparison';

// The landing page body, shared by the bn root (`/`) and the en mirror
// (`/en`) so the copy lives in exactly one place (lib/messages.ts).
//
// The hero copy (h1 + tagline) is task 15.1 ★ — the founder's words. The
// screenshot + Play CTA (15.3) and the tap-comparison graphic (15.2) are the
// `web` deliverables that fill the frame the brief left.
export function HomeContent({ locale }: { locale: Locale }) {
  const t = messages[locale].home;
  return (
    <div className="flex flex-col gap-xl">
      <section className="flex flex-col gap-lg">
        <h1 className="text-3xl font-semibold leading-snug">{t.title}</h1>
        <p className="text-lg text-inkMuted">{t.tagline}</p>
      </section>

      {/* 15.3 — one screenshot, one button. */}
      <AppShowcase locale={locale} />

      {/* 15.2 — the differentiating visual: the daily action count. */}
      <TapComparison locale={locale} />
    </div>
  );
}
