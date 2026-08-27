// The admin API client, server-side only.
//
// Connect's unary JSON protocol (ADR-0002/0003): a POST of proto3 JSON to
// /{package}.{Service}/{Method}, with the staff bearer. proto3 JSON OMITS
// default values, so every field is normalised with a default on the way out
// — a mess with zero members simply has no `memberCount` key on the wire.
//
// NOTE: this hand-written client should migrate to the generated
// @tinbela/api-clients once the monorepo wires that package into the app
// workspaces; until then a thin typed fetch keeps the admin app self-contained.

import { adminConfig } from './config';

export class AdminApiError extends Error {
  constructor(
    readonly status: number,
    message: string,
  ) {
    super(message);
    this.name = 'AdminApiError';
  }
}

async function adminCall<T>(method: string, body: unknown): Promise<T> {
  let res: Response;
  try {
    res = await fetch(
      `${adminConfig.apiBaseUrl}/tinbela.admin.v1.AdminService/${method}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminConfig.staffToken}`,
        },
        body: JSON.stringify(body ?? {}),
        cache: 'no-store',
      },
    );
  } catch {
    throw new AdminApiError(0, 'Could not reach the API.');
  }

  if (!res.ok) {
    let message = res.statusText;
    try {
      const parsed = (await res.json()) as { message?: string };
      if (parsed.message) message = parsed.message;
    } catch {
      // non-JSON error body (a proxy, say); the status text stands.
    }
    throw new AdminApiError(res.status, message);
  }
  return (await res.json()) as T;
}

export interface TenantSummary {
  id: string;
  name: string;
  kind: string;
  memberCount: number;
  createdAt: string;
  lastActivityAt: string;
}

export interface Metrics {
  activeMesses: number;
  exceptionsToday: number;
  closesThisMonth: number;
  memberLinksOpened: number;
}

type WireTenant = Partial<TenantSummary>;

function tenant(t: WireTenant): TenantSummary {
  return {
    id: t.id ?? '',
    name: t.name ?? '',
    kind: t.kind ?? '',
    memberCount: t.memberCount ?? 0,
    createdAt: t.createdAt ?? '',
    lastActivityAt: t.lastActivityAt ?? '',
  };
}

export const admin = {
  listTenants: async (query: string, page: number, pageSize: number) => {
    const r = await adminCall<{ tenants?: WireTenant[]; total?: number }>(
      'ListTenants',
      { query, page, pageSize },
    );
    return {
      tenants: (r.tenants ?? []).map(tenant),
      total: r.total ?? 0,
    };
  },

  getMetrics: async (): Promise<Metrics> => {
    const r = await adminCall<Partial<Metrics>>('GetMetrics', {});
    return {
      activeMesses: r.activeMesses ?? 0,
      exceptionsToday: r.exceptionsToday ?? 0,
      closesThisMonth: r.closesThisMonth ?? 0,
      memberLinksOpened: r.memberLinksOpened ?? 0,
    };
  },

  findUser: async (opts: { phoneE164?: string; firebaseUid?: string }) => {
    const r = await adminCall<{ userJson?: string }>('FindUser', opts);
    return r.userJson ?? '';
  },

  getFlags: async (): Promise<Record<string, boolean>> => {
    const r = await adminCall<{ flags?: Record<string, boolean> }>('GetFlags', {});
    return r.flags ?? {};
  },

  setFlag: async (key: string, value: boolean) => {
    await adminCall<Record<string, never>>('SetFlag', { key, value });
  },
};
