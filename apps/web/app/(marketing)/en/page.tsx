import type { Metadata } from 'next';

import { languageAlternates } from '@/lib/i18n';
import { messages } from '@/lib/messages';

import { HomeContent } from '../_components/home-content';
import { MarketingShell } from '../_components/marketing-shell';

// The English mirror of the landing page. bn stays canonical at the root; this
// page carries its own English title/description and points its canonical at
// itself, with hreflang alternates back to bn (task 15.7).
export const metadata: Metadata = {
  // `absolute` bypasses the "%s · টিনবেলা" template so the en title is not
  // suffixed with the Bangla brand form.
  title: { absolute: messages.en.meta.homeTitle },
  description: messages.en.meta.homeDescription,
  alternates: { canonical: '/en', languages: languageAlternates('') },
  openGraph: {
    locale: 'en_US',
    url: '/en',
    title: messages.en.meta.homeTitle,
    description: messages.en.meta.homeDescription,
  },
};

export default function HomePageEn() {
  return (
    <MarketingShell locale="en" page="">
      <HomeContent locale="en" />
    </MarketingShell>
  );
}
