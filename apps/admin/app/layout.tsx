import type { Metadata, Viewport } from 'next';
import { Hind_Siliguri } from 'next/font/google';
import Link from 'next/link';

import { color } from '@/lib/tokens';

import './globals.css';

// Mess names are Bangla, so the operator chrome still needs a Bangla-capable
// face even though its own labels are English.
const hindSiliguri = Hind_Siliguri({
  subsets: ['bengali', 'latin'],
  weight: ['400', '500', '600'],
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'TinBela Admin',
  // An internal operations surface must never be indexed.
  robots: { index: false, follow: false },
};

export const viewport: Viewport = {
  themeColor: color.primary,
  width: 'device-width',
  initialScale: 1,
};

const NAV = [
  { href: '/', label: 'Dashboard' },
  { href: '/tenants', label: 'Tenants' },
  { href: '/users', label: 'Users' },
  { href: '/flags', label: 'Flags' },
];

export default function AdminLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={hindSiliguri.className}>
      <body className="min-h-screen bg-surface text-ink">
        <header className="border-b border-divider bg-card">
          <div className="mx-auto flex max-w-5xl flex-wrap items-center gap-lg px-lg py-md">
            <Link href="/" className="text-lg font-semibold text-primary">
              টিনবেলা <span className="text-inkMuted">admin</span>
            </Link>
            <nav className="flex flex-wrap gap-md text-sm">
              {NAV.map((n) => (
                <Link
                  key={n.href}
                  href={n.href}
                  className="rounded-chip px-md py-xs text-ink hover:bg-tint"
                >
                  {n.label}
                </Link>
              ))}
            </nav>
            <span className="ml-auto rounded-chip bg-tint px-md py-xs text-xs font-semibold text-primary">
              READ-ONLY
            </span>
          </div>
        </header>

        <main className="mx-auto w-full max-w-5xl px-lg py-xl">{children}</main>
      </body>
    </html>
  );
}
