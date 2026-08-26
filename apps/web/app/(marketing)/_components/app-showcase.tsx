// Task 15.3 — one screenshot and the Play badge CTA.
//
// The "screenshot" is a built mock of the Today screen's finished state, not a
// binary asset: real device captures are task 19.4, and a PNG placeholder in
// the repo would just be a heavier version of this. It is also on-message —
// the one screen we lead with is the one where a normal day is already done
// ("কিছু করার নেই"), which is the same promise the comparison graphic makes.
//
// The CTA points at the Play listing. The OFFICIAL Google Play badge is a
// brand-guidelines image that ships with the store listing (task 19.x); until
// then this is a plain, honest button, not a fake of Google's asset.

// TODO(19.x): confirm the final Play listing id when the listing is created.
const PLAY_URL = 'https://play.google.com/store/apps/details?id=com.droidbuilder.tinbela';

export function AppShowcase() {
  return (
    <section className="flex flex-col items-center gap-lg sm:flex-row sm:items-center sm:justify-between">
      <TodayScreenMock />

      <div className="flex flex-col items-center gap-md sm:items-start">
        <p className="text-center text-lg font-medium sm:text-left">
          খুলেই দেখবেন — আজকের হিসাব শেষ।
        </p>
        <PlayButton />
      </div>
    </section>
  );
}

// A drawn stand-in for the Today screen, not a real capture. Decorative to a
// screen reader: the sentence beside it carries the meaning.
function TodayScreenMock() {
  return (
    <div
      aria-hidden="true"
      className="w-[220px] shrink-0 rounded-card border border-divider bg-surface p-md shadow-card"
    >
      {/* cutoff card */}
      <div className="rounded-button bg-card p-md">
        <p className="text-xs text-inkMuted">আজকের কাটঅফ</p>
        <p className="text-lg font-semibold text-ink">দুপুর — ১০:৩০</p>
      </div>

      {/* the finished-day state (UX law 5: a zero-exception day looks DONE) */}
      <div className="mt-md flex flex-col items-center gap-xs rounded-button bg-tint p-lg text-center">
        <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary">
          <svg viewBox="0 0 20 20" className="h-5 w-5" fill="none">
            <path
              d="M5 10.5l3.5 3.5L15 6.5"
              stroke="#fff"
              strokeWidth="2.2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </span>
        <p className="text-base font-semibold text-primary">কিছু করার নেই</p>
        <p className="text-xs text-inkMuted">বাকি সবাই ডিফল্ট প্যাটার্নে ✓</p>
      </div>
    </div>
  );
}

function PlayButton() {
  return (
    <a
      href={PLAY_URL}
      className="inline-flex min-h-touch items-center gap-md rounded-button bg-primary px-lg py-md text-card"
    >
      {/* The Play triangle, drawn — not Google's coloured badge asset. */}
      <svg viewBox="0 0 24 24" className="h-6 w-6" fill="currentColor" aria-hidden="true">
        <path d="M4 3.5v17a1 1 0 001.5.87l14-8.5a1 1 0 000-1.74l-14-8.5A1 1 0 004 3.5z" />
      </svg>
      <span className="text-base font-semibold">Google Play-তে পাওয়া যাচ্ছে</span>
    </a>
  );
}
