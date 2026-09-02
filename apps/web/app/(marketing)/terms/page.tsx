import type { Metadata } from 'next';

import { languageAlternates } from '@/lib/i18n';
import { messages } from '@/lib/messages';

import { LegalPlaceholder } from '../_components/legal-placeholder';
import { MarketingShell } from '../_components/marketing-shell';

export const metadata: Metadata = {
  title: messages.bn.meta.termsTitle,
  alternates: { canonical: '/terms', languages: languageAlternates('terms') },
};

// Task 15.5 is ★.
export default function TermsPage() {
  return (
    <MarketingShell locale="bn" page="terms">
      <LegalPlaceholder locale="bn" kind="terms" />
    </MarketingShell>
  );
}
