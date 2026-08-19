// Package money contains the TinBela settlement engine.
//
// ★ HAND-OWNED (Epic 02). A pre-edit hook blocks agents from editing this
// file. PURE: no db, no context, no time.Now.
//
// ALL MONEY IS int64 PAISA. Never float. Never numeric. ৳12.40 is 1240.
package money

import (
	"github.com/google/uuid"

	"github.com/droidbuilder/tinbela/services/api/internal/meals"
)

type EntryKind string

const (
	FoodCost    EntryKind = "FOOD_COST"
	SharedCost  EntryKind = "SHARED_COST"
	Deposit     EntryKind = "DEPOSIT"
	RentPayout  EntryKind = "RENT_PAYOUT"
	StaffSalary EntryKind = "STAFF_SALARY"
	FixedFee    EntryKind = "FIXED_FEE"
	Adjust      EntryKind = "ADJUST"
)

type Entry struct {
	ID           uuid.UUID
	Kind         EntryKind
	AmountPaisa  int64
	MembershipID *uuid.UUID
	OccurredOn   meals.Date
	VoidOf       *uuid.UUID
}

type MemberSettlement struct {
	MembershipID    uuid.UUID
	MealsQty        int
	FoodCostPaisa   int64
	SharedCostPaisa int64
	DepositsPaisa   int64
	// BalancePaisa: positive = the mess owes the member ("ফেরত পাবেন")
	//               negative = the member owes the mess ("দিতে হবে")
	BalancePaisa int64
}

type Settlement struct {
	TotalMeals     int
	FoodPaisa      int64
	MealRatePaisa  int64
	RemainderPaisa int64 // MUST be surfaced, never silently absorbed
	Members        []MemberSettlement
}

// Settle computes the period settlement. Pure and deterministic.
//
//	total_meals = sum of qty over the period (guests included — a guest ate)
//	food_paisa  = sum FOOD_COST - sum voided FOOD_COST
//	meal_rate   = 0 if total_meals == 0 else food_paisa / total_meals  ← FLOOR
//	remainder   = food_paisa - (meal_rate * total_meals)
//	              ← surfaced as a visible ADJUST line owned by the mess.
//	                Someone always asks where the ৳3 went. Show them.
//
//	per member:
//	  meals_qty   = sum of their qty (including guests they brought)
//	  food_cost   = meal_rate * meals_qty
//	  shared_cost = 0 in v1.0 (P2 feature)
//	  deposits    = sum of their DEPOSIT - voided
//	  balance     = deposits - food_cost - shared_cost
//
// INVARIANT, asserted in code, not only in tests:
//
//	sum(member.FoodCostPaisa) + RemainderPaisa == FoodPaisa
//
// TODO(Epic 02, task 02.4): implement. Property tests first.
func Settle(
	cells map[meals.Key]int,
	entries []Entry,
	memberships []meals.Membership,
) Settlement {
	panic("Epic 02 task 02.4: not implemented — write the property tests first")
}
