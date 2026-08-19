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

	"pgregory.net/rapid"
)

// ─────────────────────────────────────────────────────────────
// P1  CONSERVATION  (lives in money/settle_test.go — see that file)
//     Sum of member food_cost + remainder == sum of FOOD_COST, always.
// ─────────────────────────────────────────────────────────────

// P2 VOID SYMMETRY
// Applying an exception and then voiding it must return the EXACT same
// materialization as never applying it at all.
func TestPropertyVoidSymmetry(t *testing.T) {
	t.Skip("Epic 02 task 02.3")
	rapid.Check(t, func(rt *rapid.T) {
		// base := genInput(rt)
		// exc  := genException(rt, base)
		// withVoid := applyThenVoid(base, exc)
		// require.Equal(rt, Materialize(base, from, to), Materialize(withVoid, from, to))
	})
}

// P3 ORDER INDEPENDENCE
// Shuffling the input slices must never change the output.
// This guards the bug that will bite you in P6 offline sync, where rows
// arrive in arbitrary order.
func TestPropertyOrderIndependence(t *testing.T) {
	t.Skip("Epic 02 task 02.3")
	rapid.Check(t, func(rt *rapid.T) {
		// in := genInput(rt)
		// a := Materialize(in, from, to)
		// b := Materialize(shuffleAll(rt, in), from, to)
		// require.Equal(rt, a, b)
	})
}

// P4 RANGE EQUALS UNION OF DAYS
// One exception over [d1..d5] must produce exactly the same result as five
// single-day exceptions.
func TestPropertyRangeEqualsUnion(t *testing.T) {
	t.Skip("Epic 02 task 02.3")
	rapid.Check(t, func(rt *rapid.T) {})
}

// P5 EMPTY DAY IS FREE  ← Law 1 stated as a test. This IS the product.
// A member with a full pattern and zero exceptions over 30 days yields
// exactly pattern_qty × matching weekdays.
func TestPropertyEmptyDayIsFree(t *testing.T) {
	t.Skip("Epic 02 task 02.3")
	rapid.Check(t, func(rt *rapid.T) {})
}

// P6 NON-NEGATIVE
// qty >= 0 in every cell, for any mix of exceptions. No arrangement of
// OFF/ON/SET_QTY/GUEST may produce a negative meal count.
func TestPropertyNonNegative(t *testing.T) {
	t.Skip("Epic 02 task 02.3")
	rapid.Check(t, func(rt *rapid.T) {})
}

// P8 TENURE BOUNDARY
// A member joining d and leaving d+n has zero meals outside that window,
// regardless of pattern or exceptions.
func TestPropertyTenureBoundary(t *testing.T) {
	t.Skip("Epic 02 task 02.3")
	rapid.Check(t, func(rt *rapid.T) {})
}

// P9 GUEST ADDITIVITY
// n GUEST exceptions of qty 1 must equal one GUEST exception of qty n.
// Guests ADD to the member's own meal; they never replace it.
func TestPropertyGuestAdditivity(t *testing.T) {
	t.Skip("Epic 02 task 02.3")
	rapid.Check(t, func(rt *rapid.T) {})
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
