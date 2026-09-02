import type { Metadata } from 'next';

import { languageAlternates } from '@/lib/i18n';
import { messages } from '@/lib/messages';

import { LegalPlaceholder } from '../../_components/legal-placeholder';
import { MarketingShell } from '../../_components/marketing-shell';

export const metadata: Metadata = {
  title: { absolute: messages.en.meta.deleteTitle },
  alternates: { canonical: '/en/delete-account', languages: languageAlternates('delete-account') },
};

// Task 15.6 ★ — see LegalPlaceholder. Blocked on 04.9.
export default function DeleteAccountPageEn() {
  return (
    <MarketingShell locale="en" page="delete-account">
      <LegalPlaceholder locale="en" kind="deleteAccount" />
    </MarketingShell>
  );
}
