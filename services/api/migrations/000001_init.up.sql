-- TinBela initial schema
-- Invariants: int64 paisa · append-only · tenant_id everywhere · RLS
-- Institution hedges (groups, group_id, billing_mode, fee_category) are
-- created now and NOT exposed in v1.0 UI. See ADR-0011.

CREATE EXTENSION IF NOT EXISTS btree_gist;

-- ─────────────────────────── CORE ───────────────────────────

CREATE TABLE tenants (
    id           uuid PRIMARY KEY,
    name         text NOT NULL,
    kind         text NOT NULL CHECK (kind IN ('MESS','INSTITUTION','HOME')),
    billing_mode text NOT NULL DEFAULT 'RATE_BASED'
                 CHECK (billing_mode IN ('RATE_BASED','FIXED_FEE')),
    timezone     text NOT NULL DEFAULT 'Asia/Dhaka',
    created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE users (
    id                  uuid PRIMARY KEY,
    firebase_uid        text UNIQUE,
    phone_e164          text,
    name                text NOT NULL,
    locale              text NOT NULL DEFAULT 'bn',
    use_bangla_numerals boolean NOT NULL DEFAULT true,
    created_at          timestamptz NOT NULL DEFAULT now(),
    deleted_at          timestamptz
);
CREATE UNIQUE INDEX users_phone_uniq ON users (phone_e164)
    WHERE phone_e164 IS NOT NULL AND deleted_at IS NULL;

-- HEDGE (ADR-0011): unused in v1.0, activated in P3 institution mode
CREATE TABLE groups (
    id        uuid PRIMARY KEY,
    tenant_id uuid NOT NULL REFERENCES tenants ON DELETE CASCADE,
    parent_id uuid REFERENCES groups,
    name      text NOT NULL,
    kind      text CHECK (kind IN ('BATCH','BLOCK','ROOM'))
);
CREATE INDEX groups_tenant_idx ON groups (tenant_id);

CREATE TABLE memberships (
    id               uuid PRIMARY KEY,
    tenant_id        uuid NOT NULL REFERENCES tenants ON DELETE CASCADE,
    user_id          uuid NOT NULL REFERENCES users,
    group_id         uuid REFERENCES groups,                        -- hedge
    role             text NOT NULL CHECK (role IN
                     ('MANAGER','MEMBER','ACCOUNTANT','WARDEN','GUARDIAN')),
    fee_category     text CHECK (fee_category IN
                     ('FULL','SUBSIDIZED','FREE')),                 -- hedge
    display_name     text NOT NULL,
    joined_at        date NOT NULL,
    left_at          date,
    invite_token     text UNIQUE,
    invite_opened_at timestamptz,
    created_at       timestamptz NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, user_id),
    CHECK (left_at IS NULL OR left_at >= joined_at)
);
CREATE INDEX memberships_tenant_idx ON memberships (tenant_id);

-- ──────────────────────── MEAL ENGINE ───────────────────────

CREATE TABLE slots (
    id           uuid PRIMARY KEY,
    tenant_id    uuid NOT NULL REFERENCES tenants ON DELETE CASCADE,
    name_bn      text NOT NULL,
    name_en      text NOT NULL,
    sort_order   int  NOT NULL,
    cutoff_local time NOT NULL,
    active       boolean NOT NULL DEFAULT true,
    UNIQUE (tenant_id, sort_order)
);

-- Law 1: the weekly default. dow_mask bit 0 = Saturday (Bangladesh week).
CREATE TABLE patterns (
    id             uuid PRIMARY KEY,
    tenant_id      uuid NOT NULL REFERENCES tenants ON DELETE CASCADE,
    membership_id  uuid NOT NULL REFERENCES memberships ON DELETE CASCADE,
    slot_id        uuid NOT NULL REFERENCES slots ON DELETE CASCADE,
    dow_mask       smallint NOT NULL DEFAULT 127 CHECK (dow_mask BETWEEN 0 AND 127),
    qty            smallint NOT NULL DEFAULT 1 CHECK (qty >= 0),
    effective_from date NOT NULL,
    created_at     timestamptz NOT NULL DEFAULT now(),
    UNIQUE (membership_id, slot_id, effective_from)
);
CREATE INDEX patterns_tenant_idx ON patterns (tenant_id);

CREATE TABLE day_flags (
    id        uuid PRIMARY KEY,
    tenant_id uuid NOT NULL REFERENCES tenants ON DELETE CASCADE,
    date      date NOT NULL,
    kind      text NOT NULL CHECK (kind IN ('FEAST','OFF_DAY')),
    note      text,
    UNIQUE (tenant_id, date, kind)
);

-- Law 2 + Law 5. APPEND-ONLY.
CREATE TABLE meal_exceptions (
    id            uuid PRIMARY KEY,
    tenant_id     uuid NOT NULL REFERENCES tenants ON DELETE CASCADE,
    membership_id uuid NOT NULL REFERENCES memberships ON DELETE CASCADE,
    slot_id       uuid REFERENCES slots,          -- null = every active slot
    date_from     date NOT NULL,
    date_to       date NOT NULL,
    action        text NOT NULL CHECK (action IN ('OFF','ON','SET_QTY','GUEST')),
    qty           smallint CHECK (qty IS NULL OR qty >= 0),
    marked_by     uuid NOT NULL REFERENCES users,
    after_cutoff  boolean NOT NULL DEFAULT false,
    void_of       uuid REFERENCES meal_exceptions,
    created_at    timestamptz NOT NULL DEFAULT now(),
    CHECK (date_to >= date_from),
    CHECK (action <> 'SET_QTY' OR qty IS NOT NULL),
    CHECK (action <> 'GUEST'   OR qty IS NOT NULL)
);
CREATE INDEX meal_exceptions_lookup_idx
    ON meal_exceptions (tenant_id, date_from, date_to);
CREATE INDEX meal_exceptions_member_idx
    ON meal_exceptions (membership_id, date_from);

-- ─────────────────────────── MONEY ──────────────────────────

-- Law 5. APPEND-ONLY. All amounts int64 PAISA — never float, never numeric.
CREATE TABLE ledger_entries (
    id            uuid PRIMARY KEY,
    tenant_id     uuid NOT NULL REFERENCES tenants ON DELETE CASCADE,
    kind          text NOT NULL CHECK (kind IN
                  ('FOOD_COST','SHARED_COST','DEPOSIT','RENT_PAYOUT',
                   'STAFF_SALARY','FIXED_FEE','ADJUST')),
    amount_paisa  bigint NOT NULL,
    category      text,
    membership_id uuid REFERENCES memberships,
    occurred_on   date NOT NULL,
    note          text,
    photo_url     text,                            -- P2
    entered_by    uuid NOT NULL REFERENCES users,
    void_of       uuid REFERENCES ledger_entries,
    created_at    timestamptz NOT NULL DEFAULT now(),
    -- a DEPOSIT must be attributable to a member
    CHECK (kind <> 'DEPOSIT' OR membership_id IS NOT NULL)
);
CREATE INDEX ledger_tenant_date_idx ON ledger_entries (tenant_id, occurred_on);
CREATE INDEX ledger_member_idx      ON ledger_entries (membership_id);

CREATE TABLE periods (
    id         uuid PRIMARY KEY,
    tenant_id  uuid NOT NULL REFERENCES tenants ON DELETE CASCADE,
    start_date date NOT NULL,
    end_date   date NOT NULL,
    status     text NOT NULL CHECK (status IN ('OPEN','CLOSED')),
    closed_at  timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    CHECK (end_date >= start_date),
    -- no two periods for one tenant may overlap
    EXCLUDE USING gist (
        tenant_id WITH =,
        daterange(start_date, end_date, '[]') WITH &&
    )
);

-- Law 6. Written ONCE at close. IMMUTABLE.
CREATE TABLE period_statements (
    id                uuid PRIMARY KEY,
    tenant_id         uuid NOT NULL REFERENCES tenants ON DELETE CASCADE,
    period_id         uuid NOT NULL REFERENCES periods,
    membership_id     uuid NOT NULL REFERENCES memberships,
    meals_qty         int    NOT NULL,
    meal_rate_paisa   bigint NOT NULL,
    food_cost_paisa   bigint NOT NULL,
    shared_cost_paisa bigint NOT NULL DEFAULT 0,
    deposits_paisa    bigint NOT NULL,
    balance_paisa     bigint NOT NULL,   -- positive = the mess owes the member
    closed_at         timestamptz NOT NULL,
    UNIQUE (period_id, membership_id)
);

-- ──────────────── APPEND-ONLY ENFORCEMENT ───────────────────
-- If application code needs an UPDATE here, the design is wrong.
-- Corrections INSERT a new row with void_of set.

CREATE RULE no_update_exceptions AS ON UPDATE TO meal_exceptions   DO INSTEAD NOTHING;
CREATE RULE no_delete_exceptions AS ON DELETE TO meal_exceptions   DO INSTEAD NOTHING;
CREATE RULE no_update_ledger     AS ON UPDATE TO ledger_entries    DO INSTEAD NOTHING;
CREATE RULE no_delete_ledger     AS ON DELETE TO ledger_entries    DO INSTEAD NOTHING;
CREATE RULE no_update_statements AS ON UPDATE TO period_statements DO INSTEAD NOTHING;
CREATE RULE no_delete_statements AS ON DELETE TO period_statements DO INSTEAD NOTHING;

-- ───────────────────── ROW LEVEL SECURITY ───────────────────
-- Backstop only. Application code scopes every query by tenant as well.
-- The transport interceptor sets: SET LOCAL app.tenant_id = '<uuid>';

ALTER TABLE tenants           ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups            ENABLE ROW LEVEL SECURITY;
ALTER TABLE memberships       ENABLE ROW LEVEL SECURITY;
ALTER TABLE slots             ENABLE ROW LEVEL SECURITY;
ALTER TABLE patterns          ENABLE ROW LEVEL SECURITY;
ALTER TABLE day_flags         ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_exceptions   ENABLE ROW LEVEL SECURITY;
ALTER TABLE ledger_entries    ENABLE ROW LEVEL SECURITY;
ALTER TABLE periods           ENABLE ROW LEVEL SECURITY;
ALTER TABLE period_statements ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON tenants
    USING (id = current_setting('app.tenant_id', true)::uuid);

CREATE POLICY tenant_isolation ON groups
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);
CREATE POLICY tenant_isolation ON memberships
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);
CREATE POLICY tenant_isolation ON slots
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);
CREATE POLICY tenant_isolation ON patterns
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);
CREATE POLICY tenant_isolation ON day_flags
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);
CREATE POLICY tenant_isolation ON meal_exceptions
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);
CREATE POLICY tenant_isolation ON ledger_entries
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);
CREATE POLICY tenant_isolation ON periods
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);
CREATE POLICY tenant_isolation ON period_statements
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);
