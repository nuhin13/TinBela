import Link from 'next/link';

import { admin } from '@/lib/api';
import { ErrorNote, Panel, when } from '@/lib/ui';

// Tenant search + paginated list (task 16.3). Search is a plain GET form, so a
// query is a shareable URL an operator can paste into a ticket.
export const dynamic = 'force-dynamic';

const PAGE_SIZE = 20;

export default async function TenantsPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; page?: string }>;
}) {
  const params = await searchParams;
  const query = (params.q ?? '').trim();
  const page = Math.max(0, Number.parseInt(params.page ?? '0', 10) || 0);

  try {
    const { tenants, total } = await admin.listTenants(query, page, PAGE_SIZE);
    const pages = Math.max(1, Math.ceil(total / PAGE_SIZE));

    return (
      <Panel title="Tenants">
        <form className="flex gap-md" action="/tenants" method="get">
          <input
            type="search"
            name="q"
            defaultValue={query}
            placeholder="Search by mess name…"
            className="min-h-touch flex-1 rounded-button border border-divider bg-card px-md text-ink"
          />
          <button
            type="submit"
            className="min-h-touch rounded-button bg-primary px-lg font-semibold text-card"
          >
            Search
          </button>
        </form>

        <p className="text-sm text-inkMuted">
          {total} {total === 1 ? 'mess' : 'messes'}
          {query ? ` matching “${query}”` : ''}
        </p>

        <div className="overflow-x-auto rounded-card border border-divider bg-card">
          <table className="w-full min-w-[560px] text-sm">
            <thead>
              <tr className="border-b border-divider text-left text-inkMuted">
                <th className="px-lg py-md font-medium">Mess</th>
                <th className="px-lg py-md font-medium">Members</th>
                <th className="px-lg py-md font-medium">Created</th>
                <th className="px-lg py-md font-medium">Last activity</th>
              </tr>
            </thead>
            <tbody>
              {tenants.map((t) => (
                <tr key={t.id} className="border-b border-divider last:border-0">
                  <td className="px-lg py-md">
                    <Link href={`/tenants/${t.id}`} className="text-primary hover:underline">
                      {t.name}
                    </Link>
                  </td>
                  <td className="tnum px-lg py-md">{t.memberCount}</td>
                  <td className="px-lg py-md text-inkMuted">{when(t.createdAt)}</td>
                  <td className="px-lg py-md text-inkMuted">{when(t.lastActivityAt)}</td>
                </tr>
              ))}
              {tenants.length === 0 && (
                <tr>
                  <td colSpan={4} className="px-lg py-lg text-center text-inkMuted">
                    No messes found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {pages > 1 && (
          <div className="flex items-center gap-md text-sm">
            <PageLink q={query} page={page - 1} disabled={page <= 0} label="← Prev" />
            <span className="text-inkMuted">
              Page {page + 1} of {pages}
            </span>
            <PageLink q={query} page={page + 1} disabled={page + 1 >= pages} label="Next →" />
          </div>
        )}
      </Panel>
    );
  } catch (error) {
    return <ErrorNote error={error} />;
  }
}

function PageLink({
  q,
  page,
  disabled,
  label,
}: {
  q: string;
  page: number;
  disabled: boolean;
  label: string;
}) {
  if (disabled) {
    return <span className="rounded-chip px-md py-xs text-inkMuted opacity-50">{label}</span>;
  }
  const href = `/tenants?${new URLSearchParams({ q, page: String(page) }).toString()}`;
  return (
    <Link href={href} className="rounded-chip bg-tint px-md py-xs text-primary hover:underline">
      {label}
    </Link>
  );
}
