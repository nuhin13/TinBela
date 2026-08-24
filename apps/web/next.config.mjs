/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,

  // The member link is the credential (ADR-0009), so it must never leak to a
  // third party through a Referer header on an outbound click.
  async headers() {
    return [
      {
        source: '/m/:token*',
        headers: [{ key: 'Referrer-Policy', value: 'no-referrer' }],
      },
    ];
  },
};

export default nextConfig;
