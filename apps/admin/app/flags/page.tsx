import { admin } from '@/lib/api';
import { ErrorNote, Panel } from '@/lib/ui';

import { toggleFlag } from './actions';

// Feature flags + kill switch (task 16.6). A curated catalogue so an operator
// sees the switches that matter even before any has been set, plus whatever
// else exists in the table.
export const dynamic = 'force-dynamic';

const CATALOG: { key: string; label: string; help: string }[] = [
  { key: 'kill_switch', label: 'Kill switch', help: 'Freeze writes fleet-wide in an incident.' },
  { key: 'demo_mess_enabled', label: 'Demo mess', help: 'Offer the one-tap demo on onboarding.' },
  { key: 'ads_enabled', label: 'Ads (P5)', help: 'Reserved; ships nothing in v1.0.' },
];

export default async function FlagsPage() {
  let flags: Record<string, boolean>;
  try {
    flags = await admin.getFlags();
  } catch (error) {
    return <ErrorNote error={error} />;
  }

  const known = new Set(CATALOG.map((f) => f.key));
  const extras = Object.keys(flags)
    .filter((k) => !known.has(k))
    .map((key) => ({ key, label: key, help: '' }));

  return (
    <Panel title="Feature flags">
      <div className="flex flex-col gap-md">
        {[...CATALOG, ...extras].map((f) => (
          <FlagRow key={f.key} label={f.label} help={f.help} flagKey={f.key} on={flags[f.key] ?? false} />
        ))}
      </div>
    </Panel>
  );
}

function FlagRow({
  flagKey,
  label,
  help,
  on,
}: {
  flagKey: string;
  label: string;
  help: string;
  on: boolean;
}) {
  return (
    <div className="flex items-center justify-between gap-lg rounded-card border border-divider bg-card p-lg">
      <div className="flex flex-col gap-xs">
        <span className="font-medium text-ink">
          {label}{' '}
          <span
            className={
              on
                ? 'ml-sm rounded-chip bg-tint px-md py-xs text-xs font-semibold text-primary'
                : 'ml-sm rounded-chip bg-surface px-md py-xs text-xs font-semibold text-inkMuted'
            }
          >
            {on ? 'ON' : 'OFF'}
          </span>
        </span>
        {help && <span className="text-sm text-inkMuted">{help}</span>}
      </div>
      <form action={toggleFlag}>
        <input type="hidden" name="key" value={flagKey} />
        <input type="hidden" name="value" value={on ? 'false' : 'true'} />
        <button
          type="submit"
          className={
            on
              ? 'min-h-touch rounded-button border border-divider bg-card px-lg text-sm font-semibold text-ink'
              : 'min-h-touch rounded-button bg-primary px-lg text-sm font-semibold text-card'
          }
        >
          {on ? 'Disable' : 'Enable'}
        </button>
      </form>
    </div>
  );
}
