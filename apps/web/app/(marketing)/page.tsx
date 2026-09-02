import { HomeContent } from './_components/home-content';
import { MarketingShell } from './_components/marketing-shell';

// The bn landing page, canonical at the root. Its title/description come from
// the root layout's default metadata (app/layout.tsx); the en mirror at
// /en/page.tsx sets its own.
export default function HomePage() {
  return (
    <MarketingShell locale="bn" page="">
      <HomeContent locale="bn" />
    </MarketingShell>
  );
}
