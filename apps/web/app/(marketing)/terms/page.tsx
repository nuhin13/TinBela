import type { Metadata } from 'next';

import { PlaceholderNotice } from '@/lib/placeholder-notice';

export const metadata: Metadata = { title: 'শর্তাবলী · টিনবেলা' };

// Task 15.5 is ★.
export default function TermsPage() {
  return (
    <article className="flex flex-col gap-lg">
      <h1 className="text-2xl font-semibold">শর্তাবলী</h1>
      <PlaceholderNotice task="15.5" owner="founder" what="Terms of service." />
    </article>
  );
}
