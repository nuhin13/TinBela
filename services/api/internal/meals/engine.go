// Package meals contains the TinBela meal materialization engine.
//
// ★ HAND-OWNED (Epic 02). A pre-edit hook blocks agents from editing this
// file. The founder writes it. This is where money bugs live, and money bugs
// destroy the only thing TinBela sells: trust.
//
// PURITY: this file imports nothing from db, context, or time.Now. It is a
// pure function of its inputs. That is what makes it
//
//	(a) testable with property tests,
//	(b) portable to Dart for P6 offline sync.
package meals

import (
	"time"

	"github.com/google/uuid"
)

// Date is a calendar day in Asia/Dhaka. A meal belongs to a day, not an
// instant. Never use time.Time for a meal date.
type Date struct {
	Year  int
	Month int
	Day   int
}

// Weekday bit positions. Bangladesh week starts Saturday.
// bit 0 = Saturday ... bit 6 = Friday
const (
	Sat = 1 << iota
	Sun
	Mon
	Tue
	Wed
	Thu
	Fri
	AllDays = Sat | Sun | Mon | Tue | Wed | Thu | Fri // 127
)

type Action string

const (
	ActionOff    Action = "OFF"
	ActionOn     Action = "ON"
	ActionSetQty Action = "SET_QTY"
	ActionGuest  Action = "GUEST"
)

type Membership struct {
	ID       uuid.UUID
	JoinedAt Date
	LeftAt   *Date // nil = still a member
}

type Slot struct {
	ID     uuid.UUID
	Order  int
	Active bool
}

type Pattern struct {
	MembershipID  uuid.UUID
	SlotID        uuid.UUID
	DowMask       int16
	Qty           int16
	EffectiveFrom Date
}

type DayFlag struct {
	Date Date
	Kind string // FEAST | OFF_DAY
}

type Exception struct {
	ID           uuid.UUID
	MembershipID uuid.UUID
	SlotID       *uuid.UUID // nil = every active slot
	DateFrom     Date
	DateTo       Date
	Action       Action
	Qty          *int16
	VoidOf       *uuid.UUID
	CreatedAt    time.Time // ordering only — never a date boundary
}

type Input struct {
	Memberships []Membership
	Slots       []Slot
	Patterns    []Pattern
	Exceptions  []Exception
	DayFlags    []DayFlag
}

// Key identifies one materialized cell.
type Key struct {
	MembershipID uuid.UUID
	SlotID       uuid.UUID
	Date         Date
}

// Materialize computes meal quantities for a date range.
//
// Daily meal counts are NEVER stored (Invariant 3). They are always derived
// here, from patterns ⊕ exceptions ⊕ day flags.
//
// RESOLUTION ORDER — apply in EXACTLY this sequence:
//
//  1. PATTERN
//     qty if dow_mask has the weekday bit, else 0.
//     Use the pattern whose EffectiveFrom is the latest one <= date.
//
//  2. TENURE
//     Zero any date outside [JoinedAt, LeftAt).
//     Inclusive of JoinedAt, exclusive of LeftAt.
//
//  3. DAY FLAGS
//     OFF_DAY zeroes every slot on that date.
//
//  4. VOIDS
//     Resolve BEFORE step 5. An exception with VoidOf set removes its
//     target from consideration AND is not itself applied.
//
//  5. EXCEPTIONS, in CreatedAt order (later wins on the same key):
//     OFF     → qty  = 0
//     ON      → qty  = max(qty, 1)
//     SET_QTY → qty  = e.Qty
//     GUEST   → qty += e.Qty      ← guests ADD, they never replace
//     A nil SlotID applies to every active slot that day.
//
// TODO(Epic 02, task 02.3): implement. Write the nine property tests first.
func Materialize(in Input, from, to Date) map[Key]int {
	panic("Epic 02 task 02.3: not implemented — write the property tests first")
}
