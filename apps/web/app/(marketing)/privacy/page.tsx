import type { Metadata } from 'next';

import { PlaceholderNotice } from '@/lib/placeholder-notice';

export const metadata: Metadata = { title: 'গোপনীয়তা · টিনবেলা' };

// Task 15.4 is ★. Epic 15's GATE is "the privacy page and the Play data
// safety declaration say the same thing" -- which means this page cannot be
// drafted before the form it must match, and cannot be drafted by an agent
// at all. A plausible-looking privacy policy is worse than a missing one:
// it reads as a promise to users and as a compliance answer to Google.
export default function PrivacyPage() {
  return (
    <article className="flex flex-col gap-lg">
      <h1 className="text-2xl font-semibold">গোপনীয়তা নীতি</h1>
      <PlaceholderNotice
        task="15.4"
        owner="founder"
        what="Must match the Play data safety form line by line. Epic 15's gate is exactly this agreement."
      />
    </article>
  );
}
