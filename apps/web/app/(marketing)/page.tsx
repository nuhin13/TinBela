import { PlaceholderNotice } from '@/lib/placeholder-notice';

// Task 15.1 is ★ -- the founder writes this page.
//
// The brief is a constraint, not a suggestion: ONE idea, one screenshot, one
// button. "স্বাভাবিক দিনে কিছুই করতে হবে না।" Not a feature list. The
// structure below is the frame that copy goes into; the words are not an
// agent's to choose.
export default function HomePage() {
  return (
    <div className="flex flex-col gap-xl">
      <section className="flex flex-col gap-lg">
        <h1 className="text-3xl font-semibold leading-snug">
          স্বাভাবিক দিনে কিছুই করতে হবে না।
        </h1>
        <p className="text-lg text-inkMuted">
          মেসের খাবার আর হিসাব — একটাই অ্যাপে।
        </p>

        {/* TODO(15.3): Play badge CTA + one screenshot. */}
        {/* TODO(15.2): the khata-vs-apps-vs-TinBela tap comparison graphic.
            That graphic IS the differentiator; it is not decoration. */}
      </section>

      <PlaceholderNotice
        task="15.1"
        owner="founder"
        what="The home page copy — one idea, one screenshot, one button."
      />
    </div>
  );
}
