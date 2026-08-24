import type { Metadata } from 'next';

import { PlaceholderNotice } from '@/lib/placeholder-notice';

import { InvalidLink } from './invalid-link';
import { MemberTabs } from './tabs';

export const metadata: Metadata = {
  // Neutral on purpose. Metadata is resolved before we know whether the
  // token is any good, so titling this "আজ" would caption a dead link with
  // the screen it failed to reach.
  title: 'টিনবেলা',
  // The link is the credential. Keeping it out of search results is the
  // cheapest half of protecting it; the other half is the no-referrer header
  // in next.config.mjs.
  robots: { index: false, follow: false },
};

// M1-M5, the member surface (docs/design/SCREENS.md).
//
// TWO tabs in v1.0, not three. The prototype's গ্রুপ tab is M6 and is P2:
// it is the single largest thing that could be added to a 500KB budget, and
// the first thing to add once the budget shows headroom -- but not now.
//
// WHAT IS NOT HERE, AND WHY
//
// No data. Rendering আজ needs GetDay and আমার হিসাব needs GetStatement;
// both are Epic 05/06 handlers that currently return unimplemented, and both
// are blocked behind the Epic 02 engine. Beyond that there is no member auth
// path on the server at all yet: authInterceptor verifies a Firebase ID
// token, and a member never has one -- the invite token IS the credential
// (ADR-0009), which needs its own verifier and tasks 04.5/04.6.
//
// So this renders the shell and says so, rather than mocking numbers. A
// member PWA that shows invented meal counts is worse than one that shows
// none: the entire product is a claim about arithmetic being trustworthy.
export default async function MemberPage({
  params,
}: {
  params: Promise<{ token: string }>;
}) {
  const { token } = await params;

  // A shape check only. It rejects a link mangled in a Messenger paste
  // without pretending to be authentication -- whether the token names a
  // real membership is a question only the server can answer, and it cannot
  // answer it yet.
  if (!looksLikeToken(token)) {
    return <InvalidLink />;
  }

  return (
    <div className="flex min-h-screen flex-col">
      <main className="mx-auto w-full max-w-md flex-1 px-lg py-xl">
        <PlaceholderNotice
          task="14.2–14.4"
          owner="web"
          what="আজ and আমার হিসাব need GetDay and GetStatement, which are blocked behind Epic 02. No member token verifier exists on the server yet either (tasks 04.5, 04.6)."
        />
      </main>

      <MemberTabs />
    </div>
  );
}

// Invite tokens are base64url of at least 16 random bytes (invites.MinBytes),
// so 22 characters is the shortest legitimate one.
function looksLikeToken(token: string): boolean {
  return /^[A-Za-z0-9_-]{22,}$/.test(token);
}
