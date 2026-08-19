// Command seed loads a browsable demo mess: one tenant, eight members,
// thirty days of realistic meals and money (Epic 01 task 01.10).
//
//	make seed        # or: go run ./harness/fixtures/seed
//
// Re-running is safe. Every id is a deterministic UUIDv5 derived from a
// fixed namespace, and every insert is ON CONFLICT DO NOTHING -- which
// matters because meal_exceptions and ledger_entries are append-only:
// their DELETE rules are DO INSTEAD NOTHING, so a truncate-and-reload
// seed would silently stack duplicates instead of replacing them.
//
// Those same rules make ON CONFLICT unavailable on the append-only tables
// -- Postgres rejects it for any table carrying INSERT or UPDATE rules
// (SQLSTATE 0A000) -- so those inserts guard with WHERE NOT EXISTS.
package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"os"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
)

// Fixed namespace so a re-run reproduces byte-identical ids.
var ns = uuid.MustParse("7f1c0d5e-3b8a-5c2f-9e41-2a6b8d0c4f13")

func id(parts ...string) uuid.UUID {
	s := ""
	for _, p := range parts {
		s += p + "/"
	}
	return uuid.NewSHA1(ns, []byte(s))
}

// Asia/Dhaka, always. Date boundaries are a server-side concern (Invariant 5).
var dhaka *time.Location

type member struct {
	name     string
	phone    string
	role     string
	joinDay  int     // days after the window start
	deposits []int64 // paisa
}

var members = []member{
	{"রফিকুল ইসলাম", "+8801711000001", "MANAGER", 0, []int64{500000}},
	{"সাদিয়া আক্তার", "+8801711000002", "MEMBER", 0, []int64{300000, 200000}},
	{"তানভীর হাসান", "+8801711000003", "MEMBER", 0, []int64{300000}},
	{"নুসরাত জাহান", "+8801711000004", "MEMBER", 0, []int64{250000, 150000}},
	{"ইমরান খান", "+8801711000005", "MEMBER", 3, []int64{300000}},
	{"মেহেদী হাসান", "+8801711000006", "MEMBER", 0, []int64{200000}},
	{"ফারহানা ইয়াসমিন", "+8801711000007", "MEMBER", 7, []int64{250000}},
	{"আরিফুল হক", "+8801711000008", "MEMBER", 0, []int64{300000, 100000}},
}

var slots = []struct {
	bn, en string
	order  int
	cutoff string
}{
	{"সকাল", "Breakfast", 1, "07:00"},
	{"দুপুর", "Lunch", 2, "10:30"},
	{"রাত", "Dinner", 3, "17:00"},
}

func main() {
	if err := run(); err != nil {
		log.Fatalf("seed: %v", err)
	}
}

func run() error {
	var err error
	if dhaka, err = time.LoadLocation("Asia/Dhaka"); err != nil {
		return fmt.Errorf("Asia/Dhaka unavailable: %w", err)
	}

	dsn := os.Getenv("PG_DSN")
	if dsn == "" {
		dsn = "postgres://tinbela:tinbela@localhost:5432/tinbela?sslmode=disable"
	}

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, dsn)
	if err != nil {
		return fmt.Errorf("connect: %w", err)
	}
	defer conn.Close(ctx)

	tx, err := conn.Begin(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	// The window ends today so the demo always has a populated "আজ" screen.
	end := time.Now().In(dhaka)
	end = time.Date(end.Year(), end.Month(), end.Day(), 0, 0, 0, 0, dhaka)
	start := end.AddDate(0, 0, -29)

	counts, err := seed(ctx, tx, start, end)
	if err != nil {
		return err
	}
	if err := tx.Commit(ctx); err != nil {
		return err
	}

	fmt.Printf("  ✓ seeded %s .. %s (Asia/Dhaka)\n",
		start.Format("2006-01-02"), end.Format("2006-01-02"))
	for _, k := range []string{"memberships", "slots", "patterns", "day_flags",
		"meal_exceptions", "ledger_entries", "periods"} {
		fmt.Printf("      %-16s %d\n", k, counts[k])
	}
	return nil
}

func seed(ctx context.Context, tx pgx.Tx, start, end time.Time) (map[string]int, error) {
	c := map[string]int{}
	rng := rand.New(rand.NewSource(20260819)) // fixed: same mess every run

	tenantID := id("tenant", "demo")
	if _, err := tx.Exec(ctx, `
		INSERT INTO tenants (id, name, kind, billing_mode, timezone)
		VALUES ($1, $2, 'MESS', 'RATE_BASED', 'Asia/Dhaka')
		ON CONFLICT (id) DO NOTHING`,
		tenantID, "নীলক্ষেত ব্যাচেলর মেস"); err != nil {
		return nil, fmt.Errorf("tenant: %w", err)
	}

	// ── slots ──────────────────────────────────────────────────────────
	slotIDs := make([]uuid.UUID, len(slots))
	for i, s := range slots {
		slotIDs[i] = id("slot", s.en)
		if _, err := tx.Exec(ctx, `
			INSERT INTO slots (id, tenant_id, name_bn, name_en, sort_order, cutoff_local, active)
			VALUES ($1, $2, $3, $4, $5, $6::time, true)
			ON CONFLICT (id) DO NOTHING`,
			slotIDs[i], tenantID, s.bn, s.en, s.order, s.cutoff); err != nil {
			return nil, fmt.Errorf("slot %s: %w", s.en, err)
		}
		c["slots"]++
	}

	// ── users, memberships, patterns ───────────────────────────────────
	memberIDs := make([]uuid.UUID, len(members))
	var managerUser uuid.UUID
	for i, m := range members {
		userID := id("user", m.phone)
		if i == 0 {
			managerUser = userID
		}
		if _, err := tx.Exec(ctx, `
			INSERT INTO users (id, phone_e164, name, locale, use_bangla_numerals)
			VALUES ($1, $2, $3, 'bn', true)
			ON CONFLICT (id) DO NOTHING`,
			userID, m.phone, m.name); err != nil {
			return nil, fmt.Errorf("user %s: %w", m.name, err)
		}

		memberIDs[i] = id("membership", m.phone)
		joined := start.AddDate(0, 0, m.joinDay)
		if _, err := tx.Exec(ctx, `
			INSERT INTO memberships
				(id, tenant_id, user_id, role, display_name, joined_at)
			VALUES ($1, $2, $3, $4, $5, $6)
			ON CONFLICT (id) DO NOTHING`,
			memberIDs[i], tenantID, userID, m.role, m.name, joined); err != nil {
			return nil, fmt.Errorf("membership %s: %w", m.name, err)
		}
		c["memberships"]++

		// Law 1: everyone eats every slot by default. dow_mask 127 = all days.
		// The manager skips breakfast -- a realistic default worth seeing.
		for j := range slots {
			mask := 127
			if i == 0 && j == 0 {
				mask = 0
			}
			if _, err := tx.Exec(ctx, `
				INSERT INTO patterns
					(id, tenant_id, membership_id, slot_id, dow_mask, qty, effective_from)
				VALUES ($1, $2, $3, $4, $5, 1, $6)
				ON CONFLICT (id) DO NOTHING`,
				id("pattern", m.phone, slots[j].en), tenantID, memberIDs[i],
				slotIDs[j], mask, joined); err != nil {
				return nil, fmt.Errorf("pattern %s/%s: %w", m.name, slots[j].en, err)
			}
			c["patterns"]++
		}
	}

	// ── one open period over the whole window ──────────────────────────
	if _, err := tx.Exec(ctx, `
		INSERT INTO periods (id, tenant_id, start_date, end_date, status)
		VALUES ($1, $2, $3, $4, 'OPEN')
		ON CONFLICT (id) DO NOTHING`,
		id("period", start.Format("2006-01")), tenantID, start, end); err != nil {
		return nil, fmt.Errorf("period: %w", err)
	}
	c["periods"]++

	// ── a feast day, mid-window ────────────────────────────────────────
	feast := start.AddDate(0, 0, 14)
	if _, err := tx.Exec(ctx, `
		INSERT INTO day_flags (id, tenant_id, date, kind, note)
		VALUES ($1, $2, $3, 'FEAST', $4)
		ON CONFLICT (id) DO NOTHING`,
		id("dayflag", feast.Format("2006-01-02")), tenantID, feast,
		"মেজবান — অতিথি আপ্যায়ন"); err != nil {
		return nil, fmt.Errorf("day_flag: %w", err)
	}
	c["day_flags"]++

	return seedActivity(ctx, tx, tenantID, managerUser, memberIDs, slotIDs, start, end, rng, c)
}

// seedActivity writes the thirty days: meal exceptions people actually mark,
// the daily bazaar, shared costs, and member deposits.
func seedActivity(
	ctx context.Context, tx pgx.Tx,
	tenantID, managerUser uuid.UUID,
	memberIDs, slotIDs []uuid.UUID,
	start, end time.Time, rng *rand.Rand, c map[string]int,
) (map[string]int, error) {
	days := int(end.Sub(start).Hours()/24) + 1

	for d := 0; d < days; d++ {
		day := start.AddDate(0, 0, d)

		// Law 2: people skip meals. Roughly one in eight member-days has an
		// OFF on some slot -- someone travelling, someone eating out.
		for i, mid := range memberIDs {
			if rng.Intn(8) != 0 {
				continue
			}
			slot := slotIDs[rng.Intn(len(slotIDs))]
			key := fmt.Sprintf("%d/%s", i, day.Format("2006-01-02"))
			if _, err := tx.Exec(ctx, `
				INSERT INTO meal_exceptions
					(id, tenant_id, membership_id, slot_id, date_from, date_to,
					 action, marked_by, after_cutoff)
				SELECT $1, $2, $3, $4, $5, $5, 'OFF', $6, false
				WHERE NOT EXISTS (SELECT 1 FROM meal_exceptions WHERE id = $1)`,
				id("exc-off", key), tenantID, mid, slot, day, managerUser); err != nil {
				return nil, fmt.Errorf("exception OFF %s: %w", key, err)
			}
			c["meal_exceptions"]++
		}

		// A guest every few days, on dinner -- exercises GUEST + qty.
		if d%6 == 3 {
			mid := memberIDs[rng.Intn(len(memberIDs))]
			key := day.Format("2006-01-02")
			if _, err := tx.Exec(ctx, `
				INSERT INTO meal_exceptions
					(id, tenant_id, membership_id, slot_id, date_from, date_to,
					 action, qty, marked_by, after_cutoff)
				SELECT $1, $2, $3, $4, $5, $5, 'GUEST', $6, $7, false
				WHERE NOT EXISTS (SELECT 1 FROM meal_exceptions WHERE id = $1)`,
				id("exc-guest", key), tenantID, mid, slotIDs[2], day,
				1+rng.Intn(2), managerUser); err != nil {
				return nil, fmt.Errorf("exception GUEST %s: %w", key, err)
			}
			c["meal_exceptions"]++
		}

		// The daily bazaar. ৳1,400-2,600, higher on the feast day.
		bazaar := int64(140000 + rng.Intn(120000))
		if d == 14 {
			bazaar += 350000
		}
		if _, err := tx.Exec(ctx, `
			INSERT INTO ledger_entries
				(id, tenant_id, kind, amount_paisa, category, occurred_on, note, entered_by)
			SELECT $1, $2, 'FOOD_COST', $3, 'বাজার', $4, $5, $6
			WHERE NOT EXISTS (SELECT 1 FROM ledger_entries WHERE id = $1)`,
			id("bazaar", day.Format("2006-01-02")), tenantID, bazaar, day,
			"দৈনিক বাজার", managerUser); err != nil {
			return nil, fmt.Errorf("bazaar %s: %w", day.Format("2006-01-02"), err)
		}
		c["ledger_entries"]++
	}

	// Shared costs: gas, electricity, the cook's salary -- once in the month.
	shared := []struct {
		kind, category, note string
		paisa                int64
		dayOffset            int
	}{
		{"SHARED_COST", "গ্যাস", "গ্যাস সিলিন্ডার", 180000, 2},
		{"SHARED_COST", "বিদ্যুৎ", "বিদ্যুৎ বিল", 240000, 9},
		{"STAFF_SALARY", "বুয়া", "বুয়ার বেতন", 400000, 27},
	}
	for _, s := range shared {
		day := start.AddDate(0, 0, s.dayOffset)
		if _, err := tx.Exec(ctx, `
			INSERT INTO ledger_entries
				(id, tenant_id, kind, amount_paisa, category, occurred_on, note, entered_by)
			SELECT $1, $2, $3, $4, $5, $6, $7, $8
			WHERE NOT EXISTS (SELECT 1 FROM ledger_entries WHERE id = $1)`,
			id("shared", s.note), tenantID, s.kind, s.paisa, s.category,
			day, s.note, managerUser); err != nil {
			return nil, fmt.Errorf("shared %s: %w", s.note, err)
		}
		c["ledger_entries"]++
	}

	// Deposits. A DEPOSIT must carry a membership_id (schema CHECK).
	for i, m := range members {
		for j, paisa := range m.deposits {
			day := start.AddDate(0, 0, m.joinDay+j*11)
			if day.After(end) {
				day = end
			}
			if _, err := tx.Exec(ctx, `
				INSERT INTO ledger_entries
					(id, tenant_id, kind, amount_paisa, membership_id,
					 occurred_on, note, entered_by)
				SELECT $1, $2, 'DEPOSIT', $3, $4, $5, $6, $7
				WHERE NOT EXISTS (SELECT 1 FROM ledger_entries WHERE id = $1)`,
				id("deposit", m.phone, fmt.Sprint(j)), tenantID, paisa,
				memberIDs[i], day, "জমা", managerUser); err != nil {
				return nil, fmt.Errorf("deposit %s: %w", m.name, err)
			}
			c["ledger_entries"]++
		}
	}

	return c, nil
}
