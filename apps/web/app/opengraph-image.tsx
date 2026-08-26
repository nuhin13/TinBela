import { readFile } from 'node:fs/promises';
import { join } from 'node:path';

import { ImageResponse } from 'next/og';

import { color } from '@/lib/tokens';

// Task 15.7 — the Messenger link-preview image. Every invite is shared as a
// link into a mess group chat, so this is the growth loop's first impression.
//
// It is generated, not a committed PNG, so the brand and tagline stay in step
// with the tokens and copy instead of drifting from a stale export. Next renders
// it at build time (static), which is why reading the font from node_modules is
// safe here: it happens during `next build`, and the output is a baked PNG.

export const alt = 'টিনবেলা — স্বাভাবিক দিনে কিছুই করতে হবে না।';
export const size = { width: 1200, height: 630 };
export const contentType = 'image/png';

const FONT_DIR = join(process.cwd(), 'node_modules/@fontsource/hind-siliguri/files');

export default async function OpengraphImage() {
  const [regular, semibold] = await Promise.all([
    readFile(join(FONT_DIR, 'hind-siliguri-bengali-400-normal.woff')),
    readFile(join(FONT_DIR, 'hind-siliguri-bengali-600-normal.woff')),
  ]);

  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          gap: 40,
          padding: 96,
          background: color.surface,
          fontFamily: 'Hind Siliguri',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: 28 }}>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              width: 96,
              height: 96,
              borderRadius: 24,
              background: color.primary,
              color: color.card,
              fontSize: 60,
              fontWeight: 600,
            }}
          >
            ত
          </div>
          <div style={{ fontSize: 56, fontWeight: 600, color: color.primary }}>টিনবেলা</div>
        </div>

        <div style={{ display: 'flex', fontSize: 76, fontWeight: 600, color: color.ink, lineHeight: 1.2 }}>
          স্বাভাবিক দিনে কিছুই করতে হবে না।
        </div>

        <div style={{ display: 'flex', fontSize: 40, color: color.inkMuted }}>
          মেসের খাবার আর হিসাব — একটাই অ্যাপে।
        </div>
      </div>
    ),
    {
      ...size,
      fonts: [
        { name: 'Hind Siliguri', data: regular, weight: 400, style: 'normal' },
        { name: 'Hind Siliguri', data: semibold, weight: 600, style: 'normal' },
      ],
    },
  );
}
