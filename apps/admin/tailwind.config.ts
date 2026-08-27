import type { Config } from 'tailwindcss';

import tokens from '../../packages/design-tokens/tailwind.tokens.js';

// Colours, spacing and radii come from packages/design-tokens (run
// `make tokens`). Never write a hex literal in this app; if a value is
// missing, add it to tokens.json and regenerate so all three clients move
// together.
const config: Config = {
  content: ['./app/**/*.{ts,tsx}', './lib/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: tokens.colors,
      borderRadius: tokens.borderRadius,
      spacing: tokens.spacing,
      boxShadow: {
        // One elevation only (UI_SPEC section 5).
        card: '0 1px 4px rgba(0,0,0,.08)',
      },
      // Minimum touch target. Field condition: one-handed, in sunlight.
      minHeight: { touch: '48px' },
      minWidth: { touch: '48px' },
    },
  },
  plugins: [],
};

export default config;
