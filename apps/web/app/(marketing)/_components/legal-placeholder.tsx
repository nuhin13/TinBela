import type { Locale } from '@/lib/i18n';
import { messages } from '@/lib/messages';
import { PlaceholderNotice } from '@/lib/placeholder-notice';

// The three Play-requirement pages (privacy 15.4, terms 15.5, delete-account
// 15.6) are all ★ founder-owned and deliberately unwritten in EVERY language:
// a plausible-looking privacy policy or ToS is worse than a missing one, in bn
// or en alike. So the en mirror does not translate policy text — there is none
// to translate. Only the heading is localised; the body stays the same
// developer-facing PlaceholderNotice on both locales.

type Kind = 'privacy' | 'terms' | 'deleteAccount';

const NOTICE: Record<Kind, { task: string; owner: 'founder'; what: string }> = {
  privacy: {
    task: '15.4',
    owner: 'founder',
    what: "Must match the Play data safety form line by line. Epic 15's gate is exactly this agreement.",
  },
  terms: { task: '15.5', owner: 'founder', what: 'Terms of service.' },
  deleteAccount: {
    task: '15.6',
    owner: 'founder',
    what: "Play requires web-based account deletion. Blocked on task 04.9 — the retention policy deciding what survives for other members' statements.",
  },
};

export function LegalPlaceholder({ locale, kind }: { locale: Locale; kind: Kind }) {
  const heading = messages[locale].legal[kind];
  const notice = NOTICE[kind];
  return (
    <article className="flex flex-col gap-lg">
      <h1 className="text-2xl font-semibold">{heading}</h1>
      <PlaceholderNotice task={notice.task} owner={notice.owner} what={notice.what} />
    </article>
  );
}
