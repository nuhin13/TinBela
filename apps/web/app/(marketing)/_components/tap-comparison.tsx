import { formatCount, toBanglaDigits } from '@/lib/bn';
import type { Locale } from '@/lib/i18n';
import { messages } from '@/lib/messages';

// Task 15.2 — the khata-vs-apps-vs-TinBela comparison. This is THE
// differentiating visual, not decoration (EPICS 15.2): the whole product is
// "স্বাভাবিক দিনে কিছুই করতে হবে না", and the fastest way to feel that is to
// see the daily action count next to the two things a manager already tries.
//
// The number that matters is TinBela's zero. Everything else on the page is in
// service of making that zero legible.

type Row = {
  /** Who is doing the tracking. */
  readonly name: string;
  /** The one-line cost of a normal day. */
  readonly cost: string;
  /** Daily actions to draw as marks. TinBela is 0 — and that is the point. */
  readonly actions: number;
  /** The finished-day row is the product; it gets the emphasis. */
  readonly hero?: boolean;
};

// A normal day has three meals; three marks is "every meal, by hand".
const MARKS_PER_DAY = 3;

export function TapComparison({ locale }: { locale: Locale }) {
  const t = messages[locale].comparison;
  const rows: readonly Row[] = [
    { name: t.khata.name, cost: t.khata.cost, actions: 3 },
    { name: t.otherApps.name, cost: t.otherApps.cost, actions: 3 },
    { name: t.tinbela.name, cost: t.tinbela.cost, actions: 0, hero: true },
  ];

  return (
    <section aria-labelledby="tap-comparison-heading" className="flex flex-col gap-lg">
      <h2 id="tap-comparison-heading" className="text-2xl font-semibold">
        {t.heading}
      </h2>

      <ul className="flex flex-col gap-md">
        {rows.map((row) => (
          <li
            key={row.name}
            className={
              row.hero
                ? 'flex flex-col gap-md rounded-card border border-primary bg-tint p-lg sm:flex-row sm:items-center sm:justify-between'
                : 'flex flex-col gap-md rounded-card border border-divider bg-card p-lg sm:flex-row sm:items-center sm:justify-between'
            }
          >
            <div className="flex flex-col gap-xs">
              <span
                className={
                  row.hero ? 'text-lg font-semibold text-primary' : 'text-lg font-semibold text-ink'
                }
              >
                {row.name}
              </span>
              <span className="text-sm text-inkMuted">{row.cost}</span>
            </div>

            <div className="flex items-center gap-md">
              <Marks actions={row.actions} locale={locale} />
              <Count actions={row.actions} locale={locale} hero={row.hero} />
            </div>
          </li>
        ))}
      </ul>

      <p className="text-sm text-inkMuted">{t.footnote}</p>
    </section>
  );
}

// The marks a day costs. Filled dots for hand-work; an empty strip with a
// check for the day TinBela leaves you nothing to do.
function Marks({ actions, locale }: { actions: number; locale: Locale }) {
  const t = messages[locale].comparison;

  if (actions === 0) {
    return (
      <span className="flex items-center gap-xs text-primary" aria-label={t.nothingToDo}>
        <svg viewBox="0 0 20 20" className="h-5 w-5" fill="none" aria-hidden="true">
          <path
            d="M5 10.5l3.5 3.5L15 6.5"
            stroke="currentColor"
            strokeWidth="2.2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
        <span className="text-sm font-medium">{t.nothingToDo}</span>
      </span>
    );
  }

  const count = locale === 'bn' ? toBanglaDigits(String(actions)) : String(actions);
  return (
    <span className="flex gap-xs" aria-label={t.tapsPerDay(count)}>
      {Array.from({ length: MARKS_PER_DAY }).map((_, i) => (
        <span
          key={i}
          aria-hidden="true"
          className={
            i < actions
              ? 'h-3 w-3 rounded-full bg-alert'
              : 'h-3 w-3 rounded-full border border-divider'
          }
        />
      ))}
    </span>
  );
}

// The count a normal day costs, per day. Zero is the headline.
function Count({ actions, locale, hero }: { actions: number; locale: Locale; hero?: boolean }) {
  return (
    <span className="flex items-baseline gap-xs">
      <span
        className={
          hero ? 'text-3xl font-semibold text-primary' : 'text-3xl font-semibold text-ink'
        }
      >
        {formatCount(actions, locale)}
      </span>
      <span className="text-sm text-inkMuted">{messages[locale].comparison.perDay}</span>
    </span>
  );
}
