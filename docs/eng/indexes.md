# Index verification (Epic 01 task 01.8)

`EXPLAIN` evidence that the two hot-path indexes are used at realistic
volume. Re-run any time the schema or the query shapes change.

## Method

An empty table always seq-scans, so a demo-sized database proves nothing.
These numbers come from a scratch database (`tinbela_idx`) loaded with
**500 tenants x 400 days = 200,000 rows** in each of `ledger_entries` and
`meal_exceptions`, then `ANALYZE`d. That is roughly the load target in
`harness/load/` (500 messes, 5k members).

```sh
docker exec tinbela-postgres-1 psql -U tinbela -d postgres \
  -c 'CREATE DATABASE tinbela_idx;'
migrate -path services/api/migrations \
  -database 'postgres://tinbela:tinbela@localhost:5432/tinbela_idx?sslmode=disable' up
# bulk load with generate_series, then ANALYZE
```

## The day query — `meal_exceptions_lookup_idx (tenant_id, date_from, date_to)`

```sql
SELECT * FROM meal_exceptions
WHERE tenant_id = $1 AND date_from <= $2 AND date_to >= $2;
```

```
Bitmap Heap Scan on meal_exceptions (actual time=0.032..0.033 rows=1 loops=1)
  ->  Bitmap Index Scan on meal_exceptions_lookup_idx (actual time=0.026..0.026 rows=1)
        Index Cond: ((tenant_id = ...) AND (date_from <= ...) AND (date_to >= ...))
Execution Time: 0.106 ms
```

Index used, all three columns in the index condition. 5 shared buffers hit.

## The ledger query — `ledger_tenant_date_idx (tenant_id, occurred_on)`

```sql
SELECT * FROM ledger_entries
WHERE tenant_id = $1 AND occurred_on BETWEEN $2 AND $3;
```

```
Bitmap Heap Scan on ledger_entries (actual time=0.047..0.271 rows=31 loops=1)
  ->  Bitmap Index Scan on ledger_tenant_date_idx (actual time=0.036..0.036 rows=31)
        Index Cond: ((tenant_id = ...) AND (occurred_on >= ...) AND (occurred_on <= ...))
Execution Time: 0.303 ms
```

Index used. 34 shared buffers for a full month of one tenant's ledger.

## Note found while measuring — RLS is not a backstop yet

While this database was loaded, `app.tenant_id` was set to a single tenant
and the app role still saw **all 200,000 rows across all 500 tenants**:

```
SET app.tenant_id = '...042';
SELECT count(*), count(DISTINCT tenant_id) FROM ledger_entries;
 200000 | 500
```

`ENABLE ROW LEVEL SECURITY` does not apply to a table's owner. It needs
`FORCE ROW LEVEL SECURITY`, or the application must connect as a role that
does not own the tables. `docker-compose.yml` connects the API as
`tinbela`, which owns everything, so the policies in `000001_init.up.sql`
never evaluate.

This is task 01.7 (★) and Epic 01's gate -- "cross-tenant read returns zero
rows in a test". Left for the founder; the two-tenant test would have
caught it.
