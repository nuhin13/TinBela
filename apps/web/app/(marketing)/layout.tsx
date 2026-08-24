import Link from 'next/link';

// The marketing shell. Four pages: home, and the three Play requirements.
// Kept deliberately plain -- this route group must not import anything the
// member PWA would then pay for in its own bundle (UX law 3).
export default function MarketingLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <div className="flex min-h-screen flex-col">
      <header className="border-b border-divider">
        <nav className="mx-auto flex max-w-3xl items-center justify-between px-lg py-md">
          <Link href="/" className="text-lg font-semibold text-primary">
            টিনবেলা
          </Link>
        </nav>
      </header>

      <main className="mx-auto w-full max-w-3xl flex-1 px-lg py-xl">
        {children}
      </main>

      <footer className="border-t border-divider">
        <div className="mx-auto flex max-w-3xl flex-wrap gap-lg px-lg py-lg text-sm text-inkMuted">
          <Link href="/privacy" className="hover:text-ink">
            গোপনীয়তা
          </Link>
          <Link href="/terms" className="hover:text-ink">
            শর্তাবলী
          </Link>
          <Link href="/delete-account" className="hover:text-ink">
            অ্যাকাউন্ট মুছুন
          </Link>
        </div>
      </footer>
    </div>
  );
}
