'use server';

import { revalidatePath } from 'next/cache';

import { admin } from '@/lib/api';

// The one write in the whole portal (task 16.6). SetFlag persists to
// feature_flags; the next read reflects it, no deploy. Any failure (a
// non-staff token, say) surfaces on the re-rendered page.
export async function toggleFlag(formData: FormData) {
  const key = String(formData.get('key') ?? '').trim();
  if (!key) return;
  const value = String(formData.get('value') ?? '') === 'true';
  await admin.setFlag(key, value);
  revalidatePath('/flags');
}
