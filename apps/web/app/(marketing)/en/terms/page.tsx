import type { Metadata } from 'next';

import { languageAlternates } from '@/lib/i18n';
import { messages } from '@/lib/messages';

import { LegalPlaceholder } from '../../_components/legal-placeholder';
import { MarketingShell } from '../../_components/marketing-shell';

export const metadata: Metadata = {
  title: { absolute: messages.en.meta.termsTitle },
  alternates: { canonical: '/en/terms', languages: languageAlternates('terms') },
};

// Task 15.5 ★ — see LegalPlaceholder.
export default function TermsPageEn() {
  return (
    <MarketingShell locale="en" page="terms">
      <LegalPlaceholder locale="en" kind="terms" />
    </MarketingShell>
  );
}
