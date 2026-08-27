import Link from 'next/link';

// The tenant inspector (task 16.4) is founder-owned (★): the READ-ONLY view of
// one mess's members, ledger, exceptions and statements, which the gate ("what
// did mess X do last Tuesday") depends on. The route, the staff gate and the
// read-only tinbela_admin pool (ADR-0016) are all in place for it to drop into;
// the data assembly is not an agent's to write.
export default async function TenantInspectorPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  return (
    <div className="flex flex-col gap-lg">
      <Link href="/tenants" className="text-sm text-primary hover:underline">
        ← Tenants
      </Link>

      <div className="rounded-card border border-divider bg-card p-lg">
        <p className="font-semibold text-ink">Tenant inspector — task 16.4 ★</p>
        <p className="mt-sm text-sm text-inkMuted">
          The read-only inspector (members · ledger · exceptions · statements) is
          founder-owned. Backend <code className="text-ink">GetTenant</code> is
          intentionally unimplemented until it lands.
        </p>
        <p className="mt-md text-xs text-inkMuted">
          Tenant id: <code className="text-ink">{id}</code>
        </p>
      </div>
    </div>
  );
}
