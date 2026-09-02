import type { Locale } from '@/lib/i18n';

// Every visible string on the marketing surface, in both locales (task 15.7).
//
// The bn column is the source of truth and is copied VERBATIM from the
// original single-locale components — in particular the hero line and tagline
// are task 15.1 ★ (the founder's words) and must not be reworded here.
//
// The en column is a faithful translation of that bn, not a fresh marketing
// angle. The hero copy (`home.*`) is an agent-drafted rendering of ★ words and
// is flagged in PROGRESS.md as awaiting the founder's sign-off; the strings the
// `web` agent owns (chrome, the two graphics) need no such caveat.

type RowCopy = { readonly name: string; readonly cost: string };

export type Messages = {
  readonly nav: {
    /** The other locale's name, in its own script — the toggle's label. */
    readonly switchTo: string;
    readonly privacy: string;
    readonly terms: string;
    readonly deleteAccount: string;
  };
  readonly home: { readonly title: string; readonly tagline: string };
  readonly showcase: { readonly blurb: string; readonly playCta: string };
  readonly comparison: {
    readonly heading: string;
    readonly khata: RowCopy;
    readonly otherApps: RowCopy;
    readonly tinbela: RowCopy;
    readonly nothingToDo: string;
    readonly perDay: string;
    /** aria label for a row that costs `n` taps a day (n already localised). */
    readonly tapsPerDay: (n: string) => string;
    readonly footnote: string;
  };
  readonly legal: {
    readonly privacy: string;
    readonly terms: string;
    readonly deleteAccount: string;
  };
  readonly meta: {
    readonly homeTitle: string;
    readonly homeDescription: string;
    readonly privacyTitle: string;
    readonly termsTitle: string;
    readonly deleteTitle: string;
  };
};

const bn: Messages = {
  nav: {
    switchTo: 'English',
    privacy: 'গোপনীয়তা',
    terms: 'শর্তাবলী',
    deleteAccount: 'অ্যাকাউন্ট মুছুন',
  },
  // ★ 15.1 — the founder's verbatim words. Do not reword.
  home: {
    title: 'স্বাভাবিক দিনে কিছুই করতে হবে না।',
    tagline: 'মেসের খাবার আর হিসাব — একটাই অ্যাপে।',
  },
  showcase: {
    blurb: 'খুলেই দেখবেন — আজকের হিসাব শেষ।',
    playCta: 'Google Play-তে পাওয়া যাচ্ছে',
  },
  comparison: {
    heading: 'স্বাভাবিক দিনে কয়টা কাজ?',
    khata: { name: 'কাগজের খাতা', cost: 'প্রতিদিন হাতে লেখা, প্রতি বেলায়' },
    otherApps: { name: 'অন্য অ্যাপ', cost: 'প্রতিদিন প্রত্যেকের জন্য ট্যাপ' },
    tinbela: { name: 'টিনবেলা', cost: 'ডিফল্ট প্যাটার্ন নিজেই হিসাব রাখে' },
    nothingToDo: 'কিছু করার নেই',
    perDay: '/দিন',
    tapsPerDay: (n) => `প্রতিদিন ${n}টি কাজ`,
    footnote: 'ব্যতিক্রম — কারো অফ বা গেস্ট — হলে মাত্র ১ ট্যাপ। বাকি সব দিন শূন্য।',
  },
  legal: {
    privacy: 'গোপনীয়তা নীতি',
    terms: 'শর্তাবলী',
    deleteAccount: 'অ্যাকাউন্ট মুছে ফেলার অনুরোধ',
  },
  meta: {
    homeTitle: 'টিনবেলা — স্বাভাবিক দিনে কিছুই করতে হবে না।',
    homeDescription: 'মেসের খাবার আর হিসাব — একটাই অ্যাপে। স্বাভাবিক দিনে কিছুই করতে হবে না।',
    privacyTitle: 'গোপনীয়তা · টিনবেলা',
    termsTitle: 'শর্তাবলী · টিনবেলা',
    deleteTitle: 'অ্যাকাউন্ট মুছুন · টিনবেলা',
  },
};

const en: Messages = {
  nav: {
    switchTo: 'বাংলা',
    privacy: 'Privacy',
    terms: 'Terms',
    deleteAccount: 'Delete account',
  },
  // A faithful rendering of the ★ bn hero — pending founder sign-off (PROGRESS).
  home: {
    title: 'On a normal day, there is nothing to do.',
    tagline: 'Your mess’s meals and money — in one app.',
  },
  showcase: {
    blurb: 'Open it and today is already settled.',
    playCta: 'Get it on Google Play',
  },
  comparison: {
    heading: 'How many taps on a normal day?',
    khata: { name: 'Paper khata', cost: 'Written by hand every day, every meal' },
    otherApps: { name: 'Other apps', cost: 'A tap for every person, every day' },
    tinbela: { name: 'TinBela', cost: 'The default pattern keeps the count for you' },
    nothingToDo: 'Nothing to do',
    perDay: '/day',
    tapsPerDay: (n) => `${n} taps per day`,
    footnote: 'An exception — someone off, or a guest — is a single tap. Every other day is zero.',
  },
  legal: {
    privacy: 'Privacy Policy',
    terms: 'Terms of Service',
    deleteAccount: 'Delete account request',
  },
  meta: {
    homeTitle: 'TinBela — On a normal day, there is nothing to do.',
    homeDescription: 'Your mess’s meals and money — in one app. On a normal day, there is nothing to do.',
    privacyTitle: 'Privacy Policy · TinBela',
    termsTitle: 'Terms of Service · TinBela',
    deleteTitle: 'Delete account · TinBela',
  },
};

export const messages: Record<Locale, Messages> = { bn, en };
