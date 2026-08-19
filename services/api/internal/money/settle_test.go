package money_test

// ★ HAND-OWNED (Epic 02, task 02.2). Properties P1 and P7 live here.

import (
	"testing"

	"pgregory.net/rapid"
)

// P1 CONSERVATION — the single most important test in the codebase.
// No paisa is ever created or destroyed:
//
//	sum(member.FoodCostPaisa) + RemainderPaisa == FoodPaisa
//
// for ANY generated input.
func TestPropertyConservation(t *testing.T) {
	t.Skip("Epic 02 task 02.4")
	rapid.Check(t, func(rt *rapid.T) {
		// s := Settle(genCells(rt), genEntries(rt), genMemberships(rt))
		// var sum int64
		// for _, m := range s.Members { sum += m.FoodCostPaisa }
		// require.Equal(rt, s.FoodPaisa, sum+s.RemainderPaisa)
	})
}

// P7 IDEMPOTENT CLOSE
// Settle() called twice on the same inputs returns identical numbers.
func TestPropertyIdempotentClose(t *testing.T) {
	t.Skip("Epic 02 task 02.4")
	rapid.Check(t, func(rt *rapid.T) {})
}

// No float may ever appear in a money path. `make verify` greps for this
// too, but the test documents the intent.
func TestNoFloatInMoneyPath(t *testing.T) {
	t.Skip("Epic 02 task 02.4 — covered by make invariants")
}
