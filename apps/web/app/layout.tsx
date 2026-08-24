import type { Metadata, Viewport } from 'next';
import { Hind_Siliguri } from 'next/font/google';

import { color } from '@/lib/tokens';

import './globals.css';

// next/font self-hosts the file at build time, so there is no request to
// fonts.googleapis.com at runtime. On a throttled 3G connection that round
// trip alone is a meaningful slice of the 3s budget (UX law 3).
const hindSiliguri = Hind_Siliguri({
  subsets: ['bengali', 'latin'],
  weight: ['400', '500', '600'],
  display: 'swap',
  variable: '--font-hind-siliguri',
});

export const metadata: Metadata = {
  // TODO(15.7): real title, description and OG images. The Messenger link
  // preview is the growth loop's first impression, so this is not cosmetic.
  title: 'টিনবেলা',
  description: 'মেসের খাবার আর হিসাব — স্বাভাবিক দিনে কিছুই করতে হবে না।',
  manifest: '/manifest.webmanifest',
};

export const viewport: Viewport = {
  themeColor: color.primary,
  width: 'device-width',
  initialScale: 1,
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  // lang="bn" is load-bearing, not decoration: it selects Bangla line
  // breaking and tells a screen reader which language it is reading.
  return (
    <html lang="bn" className={hindSiliguri.variable}>
      <body className={hindSiliguri.className}>{children}</body>
    </html>
  );
}
