// The member PWA's bottom navigation.
//
// TWO tabs in v1.0 (docs/design/SCREENS.md M6: গ্রুপ is P2). Thumb-zone
// bottom nav, 48dp minimum touch target, and every icon carries a Bangla
// label -- English literacy varies across the user base, so an icon on its
// own is not a label (UX law 4).
//
// Not interactive yet: there is nothing behind either tab until Epic 05 and
// 06 can answer for them.
const TABS = [
  { id: 'today', label: 'আজ' },
  { id: 'accounts', label: 'আমার হিসাব' },
] as const;

export function MemberTabs() {
  return (
    <nav
      aria-label="প্রধান মেনু"
      className="sticky bottom-0 border-t border-divider bg-card"
    >
      <ul className="mx-auto flex max-w-md">
        {TABS.map((tab, i) => (
          <li key={tab.id} className="flex-1">
            <span
              aria-current={i === 0 ? 'page' : undefined}
              className={`flex min-h-touch items-center justify-center px-md py-md text-sm ${
                i === 0 ? 'font-semibold text-primary' : 'text-inkMuted'
              }`}
            >
              {tab.label}
            </span>
          </li>
        ))}
      </ul>
    </nav>
  );
}
