import { formatCount, toBanglaDigits } from '@/lib/bn';

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

const ROWS: readonly Row[] = [
  { name: 'কাগজের খাতা', cost: 'প্রতিদিন হাতে লেখা, প্রতি বেলায়', actions: 3 },
  { name: 'অন্য অ্যাপ', cost: 'প্রতিদিন প্রত্যেকের জন্য ট্যাপ', actions: 3 },
  { name: 'টিনবেলা', cost: 'ডিফল্ট প্যাটার্ন নিজেই হিসাব রাখে', actions: 0, hero: true },
];

// A normal day has three meals; three marks is "every meal, by hand".
const MARKS_PER_DAY = 3;

export function TapComparison() {
  return (
    <section aria-labelledby="tap-comparison-heading" className="flex flex-col gap-lg">
      <h2 id="tap-comparison-heading" className="text-2xl font-semibold">
        স্বাভাবিক দিনে কয়টা কাজ?
      </h2>

      <ul className="flex flex-col gap-md">
        {ROWS.map((row) => (
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
              <Marks actions={row.actions} hero={row.hero} />
              <Count actions={row.actions} hero={row.hero} />
            </div>
          </li>
        ))}
      </ul>

      <p className="text-sm text-inkMuted">
        ব্যতিক্রম — কারো অফ বা গেস্ট — হলে মাত্র ১ ট্যাপ। বাকি সব দিন শূন্য।
      </p>
    </section>
  );
}

// The marks a day costs. Filled dots for hand-work; an empty strip with a
// check for the day TinBela leaves you nothing to do.
function Marks({ actions, hero }: { actions: number; hero?: boolean }) {
  if (actions === 0) {
    return (
      <span
        className="flex items-center gap-xs text-primary"
        aria-label="কিছু করার নেই"
      >
        <svg viewBox="0 0 20 20" className="h-5 w-5" fill="none" aria-hidden="true">
          <path
            d="M5 10.5l3.5 3.5L15 6.5"
            stroke="currentColor"
            strokeWidth="2.2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
        <span className="text-sm font-medium">কিছু করার নেই</span>
      </span>
    );
  }

  return (
    <span
      className="flex gap-xs"
      aria-label={`প্রতিদিন ${toBanglaDigits(String(actions))}টি কাজ`}
    >
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
function Count({ actions, hero }: { actions: number; hero?: boolean }) {
  return (
    <span className="flex items-baseline gap-xs">
      <span
        className={
          hero ? 'text-3xl font-semibold text-primary' : 'text-3xl font-semibold text-ink'
        }
      >
        {formatCount(actions)}
      </span>
      <span className="text-sm text-inkMuted">/দিন</span>
    </span>
  );
}
