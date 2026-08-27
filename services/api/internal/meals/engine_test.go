package meals_test

// ★ HAND-OWNED (Epic 02, task 02.2). WRITE THESE BEFORE THE IMPLEMENTATION.
//
// These nine properties are the specification. If they hold, the meal math is
// correct and agents can build freely on top of the engine. If you skip them,
// you discover a rate bug on the day 200 messes close their first month —
// the worst possible day.
//
// Run: make property
//
// Each test currently calls t.Skip. Remove the Skip as you implement each one.
// An agent may NOT delete or permanently skip any of these.

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"pgregory.net/rapid"

	"github.com/droidbuilder/tinbela/services/api/internal/meals"
)

// ─────────────────────────────────────────────────────────────
// P1  CONSERVATION  (lives in money/settle_test.go — see that file)
//     Sum of member food_cost + remainder == sum of FOOD_COST, always.
// ─────────────────────────────────────────────────────────────

// P2 VOID SYMMETRY
// Applying an exception and then voiding it must return the EXACT same
// materialization as never applying it at all.
func TestPropertyVoidSymmetry(t *testing.T) {
	t.Skip("Epic 02 task 02.3 — body written (02.2); unskip when Materialize lands")
	rapid.Check(t, func(rt *rapid.T) {
		base := genInput(rt)
		exc := genException(rt, base)
		withVoid := applyThenVoid(base, exc)
		requireEqualCells(rt,
			materialize(base, winStart, winEnd),
			materialize(withVoid, winStart, winEnd))
	})
}

// P3 ORDER INDEPENDENCE
// Shuffling the input slices must never change the output.
// This guards the bug that will bite you in P6 offline sync, where rows
// arrive in arbitrary order.
func TestPropertyOrderIndependence(t *testing.T) {
	t.Skip("Epic 02 task 02.3 — body written (02.2); unskip when Materialize lands")
	rapid.Check(t, func(rt *rapid.T) {
		in := genInput(rt)
		requireEqualCells(rt,
			materialize(in, winStart, winEnd),
			materialize(shuffleAll(rt, in), winStart, winEnd))
	})
}

// P4 RANGE EQUALS UNION OF DAYS
// One exception over [d1..d5] must produce exactly the same result as five
// single-day exceptions.
func TestPropertyRangeEqualsUnion(t *testing.T) {
	t.Skip("Epic 02 task 02.3 — body written (02.2); unskip when Materialize lands")
	rapid.Check(t, func(rt *rapid.T) {
		base := genSimpleBase(rt)
		m, s := base.Memberships[0], base.Slots[0]

		from := rapid.IntRange(1, daysInWindow-4).Draw(rt, "rangeFrom")
		to := rapid.IntRange(from, from+4).Draw(rt, "rangeTo")
		action, qty := genActionQty(rt)

		// One exception over [from..to].
		ranged := cloneInput(base)
		ranged.Exceptions = []meals.Exception{{
			ID: uuid.New(), MembershipID: m.ID, SlotID: &s.ID,
			DateFrom: dateOf(from), DateTo: dateOf(to),
			Action: action, Qty: qty, CreatedAt: epoch,
		}}

		// The same exception, one per day, in CreatedAt order.
		union := cloneInput(base)
		for i, day := 0, from; day <= to; i, day = i+1, day+1 {
			union.Exceptions = append(union.Exceptions, meals.Exception{
				ID: uuid.New(), MembershipID: m.ID, SlotID: &s.ID,
				DateFrom: dateOf(day), DateTo: dateOf(day),
				Action: action, Qty: qty,
				CreatedAt: epoch.Add(time.Duration(i) * time.Minute),
			})
		}

		requireEqualCells(rt,
			materialize(ranged, winStart, winEnd),
			materialize(union, winStart, winEnd))
	})
}

// P5 EMPTY DAY IS FREE  ← Law 1 stated as a test. This IS the product.
// A member with a full pattern and zero exceptions over 30 days yields
// exactly pattern_qty × matching weekdays.
func TestPropertyEmptyDayIsFree(t *testing.T) {
	t.Skip("Epic 02 task 02.3 — body written (02.2); unskip when Materialize lands")
	rapid.Check(t, func(rt *rapid.T) {
		// A member present all month with a full (dow 127) pattern and NO
		// exceptions: every in-range day is exactly the pattern qty. This is
		// Law 1 — a normal day costs nothing — stated as a test.
		base := genSimpleBase(rt)
		m, s := base.Memberships[0], base.Slots[0]
		q := int(base.Patterns[0].Qty)

		cells := materialize(base, winStart, winEnd)
		for day := 1; day <= daysInWindow; day++ {
			got := cells[meals.Key{MembershipID: m.ID, SlotID: s.ID, Date: dateOf(day)}]
			if got != q {
				rt.Fatalf("day %d: qty = %d, want the pattern qty %d", day, got, q)
			}
		}
	})
}

// P6 NON-NEGATIVE
// qty >= 0 in every cell, for any mix of exceptions. No arrangement of
// OFF/ON/SET_QTY/GUEST may produce a negative meal count.
func TestPropertyNonNegative(t *testing.T) {
	t.Skip("Epic 02 task 02.3 — body written (02.2); unskip when Materialize lands")
	rapid.Check(t, func(rt *rapid.T) {
		for k, v := range materialize(genInput(rt), winStart, winEnd) {
			if v < 0 {
				rt.Fatalf("cell %v has a negative qty %d", k, v)
			}
		}
	})
}

// P8 TENURE BOUNDARY
// A member joining d and leaving d+n has zero meals outside that window,
// regardless of pattern or exceptions.
func TestPropertyTenureBoundary(t *testing.T) {
	t.Skip("Epic 02 task 02.3 — body written (02.2); unskip when Materialize lands")
	rapid.Check(t, func(rt *rapid.T) {
		in := genInput(rt)
		tenure := map[uuid.UUID]meals.Membership{}
		for _, m := range in.Memberships {
			tenure[m.ID] = m
		}
		// Tenure is [JoinedAt, LeftAt): inclusive of joining, exclusive of
		// leaving. No cell outside that window may carry a meal.
		for k, v := range materialize(in, winStart, winEnd) {
			m := tenure[k.MembershipID]
			beforeJoin := dateLess(k.Date, m.JoinedAt)
			afterLeave := m.LeftAt != nil && !dateLess(k.Date, *m.LeftAt)
			if (beforeJoin || afterLeave) && v != 0 {
				rt.Fatalf("cell %v outside tenure [%v,%v) has qty %d", k.Date, m.JoinedAt, m.LeftAt, v)
			}
		}
	})
}

// P9 GUEST ADDITIVITY
// n GUEST exceptions of qty 1 must equal one GUEST exception of qty n.
// Guests ADD to the member's own meal; they never replace it.
func TestPropertyGuestAdditivity(t *testing.T) {
	t.Skip("Epic 02 task 02.3 — body written (02.2); unskip when Materialize lands")
	rapid.Check(t, func(rt *rapid.T) {
		base := genSimpleBase(rt)
		m, s := base.Memberships[0], base.Slots[0]
		day := rapid.IntRange(1, daysInWindow).Draw(rt, "guestDay")
		n := rapid.IntRange(1, 4).Draw(rt, "guestN")

		// One GUEST of qty n …
		one := cloneInput(base)
		one.Exceptions = []meals.Exception{guest(m, s, day, int16(n), epoch)}

		// … equals n GUESTs of qty 1. Guests ADD; they never replace.
		many := cloneInput(base)
		for i := 0; i < n; i++ {
			many.Exceptions = append(many.Exceptions,
				guest(m, s, day, 1, epoch.Add(time.Duration(i)*time.Minute)))
		}

		requireEqualCells(rt,
			materialize(one, winStart, winEnd),
			materialize(many, winStart, winEnd))
	})
}

// ─────────────────────────────────────────────────────────────
// GOLDEN VECTORS (task 02.6)
// The same JSON files are executed by the Dart engine in P6. That is the
// only practical guarantee that on-device math equals server math — and if
// they ever disagree, a mess sees two different numbers.
// ─────────────────────────────────────────────────────────────

func TestGoldenVectors(t *testing.T) {
	t.Skip("Epic 02 task 02.6")
	// for _, f := range glob("../../testdata/vectors/*.json") {
	//     v := loadVector(f)
	//     got := Materialize(v.Input, v.From, v.To)
	//     require.Equal(t, v.Expect.Cells, got, f)
	// }
}

// BENCHMARK (task 02.8): 500 members × 31 days × 3 slots must stay under
// 50ms. Record the result in ADR-0006.
func BenchmarkMaterialize500Members(b *testing.B) {
	b.Skip("Epic 02 task 02.8")
}
