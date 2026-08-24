import type { MetadataRoute } from 'next';

import { color } from '@/lib/tokens';

// The member PWA is installed from the browser, never from a store: the
// link is the whole distribution channel (ADR-0009). A2HS is offered on the
// second visit, not the first (task 14.6) -- this manifest only makes the
// install possible, it does not prompt.
export default function manifest(): MetadataRoute.Manifest {
  return {
    name: 'টিনবেলা',
    short_name: 'টিনবেলা',
    description: 'মেসের খাবার আর হিসাব',
    lang: 'bn',
    start_url: '/',
    display: 'standalone',
    background_color: color.surface,
    theme_color: color.primary,
    icons: [
      // TODO(19.4): real icons. Declared so the manifest is valid and the
      // install path can be tested before the art exists.
    ],
  };
}
