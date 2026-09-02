import type { Metadata } from 'next';

import { languageAlternates } from '@/lib/i18n';
import { messages } from '@/lib/messages';

import { LegalPlaceholder } from '../_components/legal-placeholder';
import { MarketingShell } from '../_components/marketing-shell';

export const metadata: Metadata = {
  title: messages.bn.meta.deleteTitle,
  alternates: { canonical: '/delete-account', languages: languageAlternates('delete-account') },
};

// Task 15.6 is ★, and it is a Play requirement: an account created in the
// app must be deletable from the web, without installing anything. It also
// depends on task 04.9 (also ★). See LegalPlaceholder.
export default function DeleteAccountPage() {
  return (
    <MarketingShell locale="bn" page="delete-account">
      <LegalPlaceholder locale="bn" kind="deleteAccount" />
    </MarketingShell>
  );
}
