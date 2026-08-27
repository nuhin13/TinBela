import { AppShowcase } from './_components/app-showcase';
import { TapComparison } from './_components/tap-comparison';

// The hero copy (h1 + tagline) is task 15.1 ★ — the founder's words, kept
// verbatim. The screenshot + Play CTA (15.3) and the tap-comparison graphic
// (15.2) are the `web` deliverables that fill the frame the brief left.
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
      </section>

      {/* 15.3 — one screenshot, one button. */}
      <AppShowcase />

      {/* 15.2 — the differentiating visual: the daily action count. */}
      <TapComparison />
    </div>
  );
}
