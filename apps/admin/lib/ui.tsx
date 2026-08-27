// Small shared pieces for the admin screens. Plain, token-styled, no chart
// libraries — these are metric cards and tables in the existing design system.

import { AdminApiError } from './api';

export function Stat({ label, value }: { label: string; value: number | string }) {
  return (
    <div className="rounded-card border border-divider bg-card p-lg">
      <p className="text-sm text-inkMuted">{label}</p>
      <p className="tnum mt-xs text-3xl font-semibold text-ink">{value}</p>
    </div>
  );
}

export function Panel({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section className="flex flex-col gap-md">
      <h2 className="text-lg font-semibold">{title}</h2>
      {children}
    </section>
  );
}

// A friendly, non-technical failure. 403 is the common one — a portal without a
// staff token — and it must read as "you are not staff", not a stack trace.
export function ErrorNote({ error }: { error: unknown }) {
  const is403 =
    error instanceof AdminApiError && (error.status === 403 || error.status === 401);
  const message =
    error instanceof AdminApiError
      ? error.message
      : 'Something went wrong reaching the API.';
  return (
    <div className="rounded-card border border-alert/40 bg-card p-lg">
      <p className="font-semibold text-alert">
        {is403 ? 'Staff access only' : 'Could not load'}
      </p>
      <p className="mt-xs text-sm text-inkMuted">{message}</p>
    </div>
  );
}

/** A wire timestamp (RFC3339) as a short, stable UTC day-and-time. */
export function when(iso: string): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';
  return d.toISOString().slice(0, 16).replace('T', ' ') + ' UTC';
}
