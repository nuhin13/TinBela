package money_test

// ★ HAND-OWNED (Epic 02, task 02.2). Properties P1 and P7 live here.

import (
	"reflect"
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
	t.Skip("Epic 02 task 02.4 — body written (02.2); unskip when Settle lands")
	rapid.Check(t, func(rt *rapid.T) {
		members := genMemberships(rt)
		s := settle(genCells(rt, members), genEntries(rt, members), members)

		var sum int64
		for _, m := range s.Members {
			sum += m.FoodCostPaisa
		}
		if sum+s.RemainderPaisa != s.FoodPaisa {
			rt.Fatalf("conservation broken: sum(food_cost)=%d + remainder=%d != food_paisa=%d",
				sum, s.RemainderPaisa, s.FoodPaisa)
		}
	})
}

// P7 IDEMPOTENT CLOSE
// Settle() called twice on the same inputs returns identical numbers.
func TestPropertyIdempotentClose(t *testing.T) {
	t.Skip("Epic 02 task 02.4 — body written (02.2); unskip when Settle lands")
	rapid.Check(t, func(rt *rapid.T) {
		members := genMemberships(rt)
		cells := genCells(rt, members)
		entries := genEntries(rt, members)
		if !reflect.DeepEqual(
			settle(cells, entries, members),
			settle(cells, entries, members)) {
			rt.Fatal("Settle returned different results for identical inputs")
		}
	})
}

// No float may ever appear in a money path. `make verify` greps for this
// too, but the test documents the intent.
func TestNoFloatInMoneyPath(t *testing.T) {
	t.Skip("Epic 02 task 02.4 — covered by make invariants")
}
