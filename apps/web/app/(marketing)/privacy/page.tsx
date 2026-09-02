import type { Metadata } from 'next';

import { languageAlternates } from '@/lib/i18n';
import { messages } from '@/lib/messages';

import { LegalPlaceholder } from '../_components/legal-placeholder';
import { MarketingShell } from '../_components/marketing-shell';

export const metadata: Metadata = {
  title: messages.bn.meta.privacyTitle,
  alternates: { canonical: '/privacy', languages: languageAlternates('privacy') },
};

// Task 15.4 is ★. Epic 15's GATE is "the privacy page and the Play data
// safety declaration say the same thing" -- which means this page cannot be
// drafted before the form it must match, and cannot be drafted by an agent
// at all, in any language. See LegalPlaceholder.
export default function PrivacyPage() {
  return (
    <MarketingShell locale="bn" page="privacy">
      <LegalPlaceholder locale="bn" kind="privacy" />
    </MarketingShell>
  );
}
