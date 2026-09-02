import type { Metadata } from 'next';

import { languageAlternates } from '@/lib/i18n';
import { messages } from '@/lib/messages';

import { LegalPlaceholder } from '../../_components/legal-placeholder';
import { MarketingShell } from '../../_components/marketing-shell';

export const metadata: Metadata = {
  title: { absolute: messages.en.meta.privacyTitle },
  alternates: { canonical: '/en/privacy', languages: languageAlternates('privacy') },
};

// Task 15.4 ★ — see LegalPlaceholder. No policy text exists to translate.
export default function PrivacyPageEn() {
  return (
    <MarketingShell locale="en" page="privacy">
      <LegalPlaceholder locale="en" kind="privacy" />
    </MarketingShell>
  );
}
