import { admin } from '@/lib/api';
import { ErrorNote, Panel } from '@/lib/ui';

// User lookup by phone or Firebase uid (task 16.5). A missing user is a normal,
// empty answer — not an error.
export const dynamic = 'force-dynamic';

interface UserView {
  id?: string;
  name?: string;
  phone_e164?: string;
  firebase_uid?: string;
  locale?: string;
  use_bangla_numerals?: boolean;
  created_at?: string;
}

export default async function UsersPage({
  searchParams,
}: {
  searchParams: Promise<{ phone?: string; uid?: string }>;
}) {
  const params = await searchParams;
  const phone = (params.phone ?? '').trim();
  const uid = (params.uid ?? '').trim();
  const searched = phone !== '' || uid !== '';

  let user: UserView | null = null;
  let error: unknown = null;
  if (searched) {
    try {
      const json = await admin.findUser({ phoneE164: phone, firebaseUid: uid });
      user = json ? (JSON.parse(json) as UserView) : null;
    } catch (e) {
      error = e;
    }
  }

  return (
    <Panel title="User lookup">
      <form className="flex flex-col gap-md sm:flex-row" action="/users" method="get">
        <input
          name="phone"
          defaultValue={phone}
          placeholder="Phone (+8801…)"
          className="min-h-touch flex-1 rounded-button border border-divider bg-card px-md text-ink"
        />
        <input
          name="uid"
          defaultValue={uid}
          placeholder="Firebase uid"
          className="min-h-touch flex-1 rounded-button border border-divider bg-card px-md text-ink"
        />
        <button
          type="submit"
          className="min-h-touch rounded-button bg-primary px-lg font-semibold text-card"
        >
          Find
        </button>
      </form>

      {error ? <ErrorNote error={error} /> : null}

      {searched && !error && !user && (
        <div className="rounded-card border border-divider bg-card p-lg text-inkMuted">
          No user matches that {phone ? 'phone' : 'uid'}.
        </div>
      )}

      {user && (
        <dl className="grid grid-cols-1 gap-px overflow-hidden rounded-card border border-divider bg-divider sm:grid-cols-2">
          <Field label="Name" value={user.name} />
          <Field label="Phone" value={user.phone_e164} />
          <Field label="Firebase uid" value={user.firebase_uid} mono />
          <Field label="User id" value={user.id} mono />
          <Field label="Locale" value={user.locale} />
          <Field label="Created" value={user.created_at} />
        </dl>
      )}
    </Panel>
  );
}

function Field({ label, value, mono }: { label: string; value?: string; mono?: boolean }) {
  return (
    <div className="bg-card p-lg">
      <dt className="text-xs text-inkMuted">{label}</dt>
      <dd className={`mt-xs text-ink ${mono ? 'font-mono text-sm' : ''}`}>{value || '—'}</dd>
    </div>
  );
}
