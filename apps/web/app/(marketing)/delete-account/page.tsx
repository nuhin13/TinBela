import type { Metadata } from 'next';

import { PlaceholderNotice } from '@/lib/placeholder-notice';

export const metadata: Metadata = { title: 'অ্যাকাউন্ট মুছুন · টিনবেলা' };

// Task 15.6 is ★, and it is a Play requirement: an account created in the
// app must be deletable from the web, without installing anything.
//
// It also depends on task 04.9 (also ★), which decides what survives a
// deletion -- a member's meals still have to count toward other members'
// statements for a closed month. Until that policy is written, a form here
// would be promising an outcome nobody has defined.
export default function DeleteAccountPage() {
  return (
    <article className="flex flex-col gap-lg">
      <h1 className="text-2xl font-semibold">অ্যাকাউন্ট মুছে ফেলার অনুরোধ</h1>
      <PlaceholderNotice
        task="15.6"
        owner="founder"
        what="Play requires web-based account deletion. Blocked on task 04.9 — the retention policy deciding what survives for other members' statements."
      />
    </article>
  );
}
