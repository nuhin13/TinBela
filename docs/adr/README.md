# Architecture Decision Records

One file per decision. Never delete an ADR — supersede it and link both ways.
Create new ones with `/adr "<title>"`.

| # | Decision | Revisit when |
|---|---|---|
| [0001](0001-modular-monolith-not-microservices.md) | Modular monolith, not microservices | A domain needs independent scaling or deploy cadence |
| [0002](0002-protobuf-contracts-from-day-one-served-by-connect-go.md) | Protobuf contracts from day one, served by Connect-Go | Not expected |
| [0003](0003-flutter-talks-http-json-with-generated-dart-message-types-no.md) | Flutter uses HTTP/JSON + generated Dart models | Connect Dart tooling matures |
| [0004](0004-no-api-gateway-no-kong-for-the-mvp.md) | **No API gateway (no Kong) for the MVP** | 3+ services, external API consumers, or cross-product rate limiting |
| [0005](0005-append-only-ledger-and-exceptions-enforced-in-postgres.md) | Append-only ledger, enforced in Postgres | Table size becomes a real problem (archive, don't mutate) |
| [0006](0006-derived-values-are-never-stored.md) | Derived values are never stored | Materialization exceeds 200ms p95 |
| [0007](0007-all-money-is-int64-paisa.md) | All money is int64 paisa | Never |
| [0008](0008-postgres-row-level-security-as-a-backstop-tenant-scoping-as-.md) | RLS as a backstop, tenant scoping as primary | Never — add to it, don't remove it |
| [0009](0009-google-sign-in-for-managers-magic-link-tokens-for-members.md) | Google Sign-In for managers, magic links for members | Field feedback demands phone login, or iOS |
| [0010](0010-entitlements-as-an-interface-from-day-one-with-no-billing-co.md) | Entitlements interface from day one, no billing code | P5 implements it behind the same interface |
| [0011](0011-institution-schema-hedges-land-in-v1-0-unused.md) | Institution schema hedges land in v1.0, unused | P3 activates them |
| [0012](0012-online-only-for-v1-0-offline-is-the-paid-moat.md) | Online-only for v1.0; offline is the paid moat | P6 |
| [0013](0013-golden-test-vectors-as-shared-json.md) | Golden test vectors as shared JSON | Never — extend whenever a bug is found |
| [0014](0014-design-tokens-as-generated-code-one-source-three-clients.md) | Design tokens as generated code | Never |
| [0015](0015-single-repository-all-services-docs-and-harness-together.md) | Single repository | A product outgrows the shared pipeline |
| [0016](0016-admin-reads-across-tenants-via-a-read-only-bypassrls-role.md) | Admin reads across tenants via a read-only BYPASSRLS role | Admin must mutate customer data, or a reporting replica is added |
