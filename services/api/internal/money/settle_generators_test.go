package money_test

// Epic 02 task 02.2 — the machinery for the settlement properties (P1, P7).
//
// settle.go is founder-owned (★) and still panics; these generators and the
// bodies in settle_test.go are written first so the founder implements Settle
// against a red suite. Verified now via TestMoneyGeneratorsValid, which never
// calls the unimplemented engine.

import (
	"testing"

	"github.com/google/uuid"
	"pgregory.net/rapid"

	"github.com/droidbuilder/tinbela/services/api/internal/meals"
	"github.com/droidbuilder/tinbela/services/api/internal/money"
)

func mDate(day int) meals.Date { return meals.Date{Year: 2026, Month: 7, Day: day} }

// settle calls the engine through a var so the property bodies read cleanly
// while Settle is still a panic stub (02.4) — see the note on materialize in
// the meals package. A zero-cost alias once the engine returns normally.
var settle = money.Settle

// genMemberships draws a few members. Tenure is irrelevant to Settle — it is
// handed materialized cells — so joined_at is a fixed placeholder.
func genMemberships(rt *rapid.T) []meals.Membership {
	n := rapid.IntRange(1, 3).Draw(rt, "nMembers")
	ms := make([]meals.Membership, n)
	for i := range ms {
		ms[i] = meals.Membership{ID: uuid.New(), JoinedAt: mDate(1)}
	}
	return ms
}

// genCells draws the materialized meal counts for those members. May be empty:
// a month with zero meals is the guard case, and conservation must still hold.
func genCells(rt *rapid.T, members []meals.Membership) map[meals.Key]int {
	nSlots := rapid.IntRange(1, 2).Draw(rt, "nSlots")
	slots := make([]uuid.UUID, nSlots)
	for i := range slots {
		slots[i] = uuid.New()
	}

	cells := map[meals.Key]int{}
	for _, m := range members {
		for i, n := 0, rapid.IntRange(0, 4).Draw(rt, "nCells"); i < n; i++ {
			k := meals.Key{
				MembershipID: m.ID,
				SlotID:       slots[rapid.IntRange(0, nSlots-1).Draw(rt, "cellSlot")],
				Date:         mDate(rapid.IntRange(1, 31).Draw(rt, "cellDay")),
			}
			cells[k] = rapid.IntRange(0, 3).Draw(rt, "cellQty")
		}
	}
	return cells
}

// genEntries draws FOOD_COST, DEPOSIT and the occasional void. The exact void
// semantics are the founder's to choose; conservation is asserted on the OUTPUT
// (sum of member food cost + remainder == food_paisa), so it holds whatever
// food_paisa the engine derives.
func genEntries(rt *rapid.T, members []meals.Membership) []money.Entry {
	var entries []money.Entry

	var foodIDs []uuid.UUID
	for i, n := 0, rapid.IntRange(1, 4).Draw(rt, "nFood"); i < n; i++ {
		id := uuid.New()
		foodIDs = append(foodIDs, id)
		entries = append(entries, money.Entry{
			ID:          id,
			Kind:        money.FoodCost,
			AmountPaisa: int64(rapid.IntRange(100, 500000).Draw(rt, "foodPaisa")),
			OccurredOn:  mDate(1),
		})
	}

	if rapid.Bool().Draw(rt, "voidFood") {
		target := foodIDs[rapid.IntRange(0, len(foodIDs)-1).Draw(rt, "voidTarget")]
		entries = append(entries, money.Entry{
			ID:          uuid.New(),
			Kind:        money.FoodCost,
			AmountPaisa: 0,
			VoidOf:      &target,
			OccurredOn:  mDate(1),
		})
	}

	for i, n := 0, rapid.IntRange(0, 3).Draw(rt, "nDeposits"); i < n; i++ {
		// A DEPOSIT must be attributable to a member (money schema CHECK).
		mid := members[rapid.IntRange(0, len(members)-1).Draw(rt, "depMember")].ID
		entries = append(entries, money.Entry{
			ID:           uuid.New(),
			Kind:         money.Deposit,
			AmountPaisa:  int64(rapid.IntRange(100, 1000000).Draw(rt, "depositPaisa")),
			MembershipID: &mid,
			OccurredOn:   mDate(1),
		})
	}

	return entries
}

// TestMoneyGeneratorsValid runs now: it guards the settlement properties
// against a generator that emits entries the schema would reject.
func TestMoneyGeneratorsValid(t *testing.T) {
	rapid.Check(t, func(rt *rapid.T) {
		members := genMemberships(rt)
		ids := map[uuid.UUID]bool{}
		for _, m := range members {
			ids[m.ID] = true
		}

		for _, e := range genEntries(rt, members) {
			if e.AmountPaisa < 0 {
				rt.Fatalf("negative amount_paisa %d", e.AmountPaisa)
			}
			if e.Kind == money.Deposit && e.MembershipID == nil {
				rt.Fatal("a DEPOSIT must carry a membership id")
			}
		}

		for k := range genCells(rt, members) {
			if !ids[k.MembershipID] {
				rt.Fatal("a cell references an unknown membership")
			}
		}
	})
}
