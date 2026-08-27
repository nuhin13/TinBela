import Link from 'next/link';

import { admin } from '@/lib/api';
import { ErrorNote, Panel, Stat, when } from '@/lib/ui';

// The one-screen dashboard (tasks 16.2 + 16.7): the fleet at a glance, plus
// the most recently active messes as a jumping-off point.
export const dynamic = 'force-dynamic';

export default async function DashboardPage() {
  try {
    const [metrics, recent] = await Promise.all([
      admin.getMetrics(),
      admin.listTenants('', 0, 5),
    ]);

    return (
      <div className="flex flex-col gap-xl">
        <Panel title="Today">
          <div className="grid grid-cols-2 gap-md sm:grid-cols-4">
            <Stat label="Active messes" value={metrics.activeMesses} />
            <Stat label="Exceptions today" value={metrics.exceptionsToday} />
            <Stat label="Closes this month" value={metrics.closesThisMonth} />
            <Stat label="Member links opened" value={metrics.memberLinksOpened} />
          </div>
        </Panel>

        <Panel title="Recently active messes">
          <div className="overflow-x-auto rounded-card border border-divider bg-card">
            <table className="w-full min-w-[520px] text-sm">
              <thead>
                <tr className="border-b border-divider text-left text-inkMuted">
                  <th className="px-lg py-md font-medium">Mess</th>
                  <th className="px-lg py-md font-medium">Members</th>
                  <th className="px-lg py-md font-medium">Last activity</th>
                </tr>
              </thead>
              <tbody>
                {recent.tenants.map((t) => (
                  <tr key={t.id} className="border-b border-divider last:border-0">
                    <td className="px-lg py-md">
                      <Link href={`/tenants/${t.id}`} className="text-primary hover:underline">
                        {t.name}
                      </Link>
                    </td>
                    <td className="tnum px-lg py-md">{t.memberCount}</td>
                    <td className="px-lg py-md text-inkMuted">{when(t.lastActivityAt)}</td>
                  </tr>
                ))}
                {recent.tenants.length === 0 && (
                  <tr>
                    <td colSpan={3} className="px-lg py-lg text-center text-inkMuted">
                      No messes yet.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
          <Link href="/tenants" className="text-sm text-primary hover:underline">
            All tenants →
          </Link>
        </Panel>
      </div>
    );
  } catch (error) {
    return <ErrorNote error={error} />;
  }
}
