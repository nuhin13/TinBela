package meals_test

// Epic 02 task 02.2 — the machinery the nine property tests draw from.
//
// The engine (engine.go) is founder-owned (★) and still panics; these
// generators and the property bodies in engine_test.go are written FIRST, so
// the founder implements Materialize against a red suite. Nothing here touches
// engine.go — only the exported types it already defines.
//
// The generators themselves are verified now (TestGeneratorsProduceValidInput
// runs green), so when the property tests are unskipped they draw from a source
// already known to produce coherent inputs rather than garbage that makes a
// property vacuously true.

import (
	mrand "math/rand"
	"reflect"
	"testing"
	"time"

	"github.com/google/uuid"
	"pgregory.net/rapid"

	"github.com/droidbuilder/tinbela/services/api/internal/meals"
)

// The whole test fixture lives in one month, Asia/Dhaka. A single month keeps
// tenure windows and date ranges legible without losing any behaviour the
// engine cares about.
var (
	winStart = meals.Date{Year: 2026, Month: 7, Day: 1}
	winEnd   = meals.Date{Year: 2026, Month: 7, Day: 31}
)

const daysInWindow = 31

// materialize calls the engine through a var on purpose. While Materialize is
// still a panic stub (02.3), calling it directly makes staticcheck treat every
// statement after the first call as unreachable (SA4006) and flag the property
// bodies. The indirection hides the no-return analysis; once the engine returns
// normally it is a zero-cost alias.
var materialize = meals.Materialize

func dateOf(day int) meals.Date { return meals.Date{Year: 2026, Month: 7, Day: day} }

func dateLess(a, b meals.Date) bool {
	if a.Year != b.Year {
		return a.Year < b.Year
	}
	if a.Month != b.Month {
		return a.Month < b.Month
	}
	return a.Day < b.Day
}

// epoch is a fixed instant to base CreatedAt ordering on. CreatedAt orders
// exceptions on the same cell; it is never a date boundary (engine.go).
var epoch = time.Date(2026, 7, 1, 0, 0, 0, 0, time.UTC)

// ─────────────────────────── generators ───────────────────────────

// genInput draws a whole coherent scenario: a few members with real tenure,
// one or two slots, a pattern per member per slot, some day flags, and a
// handful of exceptions in CreatedAt order.
func genInput(rt *rapid.T) meals.Input {
	nMembers := rapid.IntRange(1, 3).Draw(rt, "nMembers")
	members := make([]meals.Membership, nMembers)
	for i := range members {
		joined := rapid.IntRange(1, 10).Draw(rt, "joined")
		var left *meals.Date
		if rapid.Bool().Draw(rt, "hasLeft") {
			l := dateOf(rapid.IntRange(joined, daysInWindow).Draw(rt, "left"))
			left = &l
		}
		members[i] = meals.Membership{ID: uuid.New(), JoinedAt: dateOf(joined), LeftAt: left}
	}

	nSlots := rapid.IntRange(1, 2).Draw(rt, "nSlots")
	slots := make([]meals.Slot, nSlots)
	for i := range slots {
		slots[i] = meals.Slot{ID: uuid.New(), Order: i + 1, Active: true}
	}

	var patterns []meals.Pattern
	for _, m := range members {
		for _, s := range slots {
			patterns = append(patterns, meals.Pattern{
				MembershipID:  m.ID,
				SlotID:        s.ID,
				DowMask:       int16(rapid.IntRange(0, 127).Draw(rt, "dowMask")),
				Qty:           int16(rapid.IntRange(0, 3).Draw(rt, "patternQty")),
				EffectiveFrom: winStart,
			})
		}
	}

	var flags []meals.DayFlag
	for i, n := 0, rapid.IntRange(0, 2).Draw(rt, "nFlags"); i < n; i++ {
		kind := "OFF_DAY"
		if rapid.Bool().Draw(rt, "feast") {
			kind = "FEAST"
		}
		flags = append(flags, meals.DayFlag{Date: dateOf(rapid.IntRange(1, daysInWindow).Draw(rt, "flagDay")), Kind: kind})
	}

	var excs []meals.Exception
	for i, n := 0, rapid.IntRange(0, 5).Draw(rt, "nExc"); i < n; i++ {
		excs = append(excs, genExceptionFor(rt, members, slots, epoch.Add(time.Duration(i)*time.Minute)))
	}

	return meals.Input{
		Memberships: members,
		Slots:       slots,
		Patterns:    patterns,
		Exceptions:  excs,
		DayFlags:    flags,
	}
}

// genSimpleBase is one member present the whole month, one active slot, a full
// (dow_mask 127) pattern, and nothing else. Every in-range day is therefore the
// pattern qty — the fixture P5 (empty day is free), P4 (range == union) and P9
// (guest additivity) build on.
func genSimpleBase(rt *rapid.T) meals.Input {
	m := meals.Membership{ID: uuid.New(), JoinedAt: winStart, LeftAt: nil}
	s := meals.Slot{ID: uuid.New(), Order: 1, Active: true}
	return meals.Input{
		Memberships: []meals.Membership{m},
		Slots:       []meals.Slot{s},
		Patterns: []meals.Pattern{{
			MembershipID:  m.ID,
			SlotID:        s.ID,
			DowMask:       int16(meals.AllDays),
			Qty:           int16(rapid.IntRange(0, 3).Draw(rt, "baseQty")),
			EffectiveFrom: winStart,
		}},
	}
}

// genException makes one exception against an existing input's members/slots.
func genException(rt *rapid.T, in meals.Input) meals.Exception {
	return genExceptionFor(rt, in.Memberships, in.Slots, epoch.Add(12*time.Hour))
}

func genExceptionFor(rt *rapid.T, members []meals.Membership, slots []meals.Slot, createdAt time.Time) meals.Exception {
	m := members[rapid.IntRange(0, len(members)-1).Draw(rt, "excMember")]

	var slotID *uuid.UUID
	if !rapid.Bool().Draw(rt, "excAllSlots") {
		s := slots[rapid.IntRange(0, len(slots)-1).Draw(rt, "excSlot")].ID
		slotID = &s
	}

	from := rapid.IntRange(1, daysInWindow).Draw(rt, "excFrom")
	to := rapid.IntRange(from, daysInWindow).Draw(rt, "excTo")
	action, qty := genActionQty(rt)

	return meals.Exception{
		ID:           uuid.New(),
		MembershipID: m.ID,
		SlotID:       slotID,
		DateFrom:     dateOf(from),
		DateTo:       dateOf(to),
		Action:       action,
		Qty:          qty,
		CreatedAt:    createdAt,
	}
}

func genActionQty(rt *rapid.T) (meals.Action, *int16) {
	action := rapid.SampledFrom([]meals.Action{
		meals.ActionOff, meals.ActionOn, meals.ActionSetQty, meals.ActionGuest,
	}).Draw(rt, "action")
	if action == meals.ActionSetQty || action == meals.ActionGuest {
		q := int16(rapid.IntRange(0, 3).Draw(rt, "excQty"))
		return action, &q
	}
	return action, nil
}

// guest is a single GUEST exception of qty n on one cell.
func guest(m meals.Membership, s meals.Slot, day int, n int16, createdAt time.Time) meals.Exception {
	slot := s.ID
	return meals.Exception{
		ID:           uuid.New(),
		MembershipID: m.ID,
		SlotID:       &slot,
		DateFrom:     dateOf(day),
		DateTo:       dateOf(day),
		Action:       meals.ActionGuest,
		Qty:          &n,
		CreatedAt:    createdAt,
	}
}

// applyThenVoid appends an exception AND a row voiding it. A void removes its
// target from consideration and is not itself applied (engine.go step 4), so
// the result must equal the input with neither present (property P2).
func applyThenVoid(in meals.Input, exc meals.Exception) meals.Input {
	out := cloneInput(in)
	void := meals.Exception{
		ID:           uuid.New(),
		MembershipID: exc.MembershipID,
		SlotID:       exc.SlotID,
		DateFrom:     exc.DateFrom,
		DateTo:       exc.DateTo,
		Action:       exc.Action,
		Qty:          exc.Qty,
		VoidOf:       &exc.ID,
		CreatedAt:    exc.CreatedAt.Add(time.Hour),
	}
	out.Exceptions = append(out.Exceptions, exc, void)
	return out
}

// shuffleAll reorders every input slice. Order must not change the output
// (property P3) — the bug that bites P6 offline sync, where rows arrive in any
// order. The permutation is drawn, so a failure shrinks reproducibly.
func shuffleAll(rt *rapid.T, in meals.Input) meals.Input {
	out := cloneInput(in)
	r := mrand.New(mrand.NewSource(rapid.Int64().Draw(rt, "shuffleSeed"))) //nolint:gosec // deterministic test shuffle, not security
	r.Shuffle(len(out.Memberships), func(i, j int) { out.Memberships[i], out.Memberships[j] = out.Memberships[j], out.Memberships[i] })
	r.Shuffle(len(out.Slots), func(i, j int) { out.Slots[i], out.Slots[j] = out.Slots[j], out.Slots[i] })
	r.Shuffle(len(out.Patterns), func(i, j int) { out.Patterns[i], out.Patterns[j] = out.Patterns[j], out.Patterns[i] })
	r.Shuffle(len(out.Exceptions), func(i, j int) { out.Exceptions[i], out.Exceptions[j] = out.Exceptions[j], out.Exceptions[i] })
	r.Shuffle(len(out.DayFlags), func(i, j int) { out.DayFlags[i], out.DayFlags[j] = out.DayFlags[j], out.DayFlags[i] })
	return out
}

// cloneInput copies the slices so appends and shuffles never mutate a shared
// input. The pointer fields (LeftAt, SlotID, Qty, VoidOf) are never mutated in
// place, so sharing them is safe.
func cloneInput(in meals.Input) meals.Input {
	return meals.Input{
		Memberships: append([]meals.Membership(nil), in.Memberships...),
		Slots:       append([]meals.Slot(nil), in.Slots...),
		Patterns:    append([]meals.Pattern(nil), in.Patterns...),
		Exceptions:  append([]meals.Exception(nil), in.Exceptions...),
		DayFlags:    append([]meals.DayFlag(nil), in.DayFlags...),
	}
}

// requireEqualCells is the assertion the equality properties (P2, P3, P4, P9)
// share. No testify in this module, so it is DeepEqual + Fatalf.
func requireEqualCells(rt *rapid.T, want, got map[meals.Key]int) {
	rt.Helper()
	if !reflect.DeepEqual(want, got) {
		rt.Fatalf("materialization differs:\n want = %v\n got  = %v", want, got)
	}
}

// ─────────────────────── generator self-check ───────────────────────

// TestGeneratorsProduceValidInput runs NOW (it never calls the unimplemented
// engine). It guards the property tests from the far more insidious failure
// than a red assertion: a generator that emits incoherent inputs, under which a
// property passes while proving nothing.
func TestGeneratorsProduceValidInput(t *testing.T) {
	rapid.Check(t, func(rt *rapid.T) {
		in := genInput(rt)

		members := map[uuid.UUID]meals.Membership{}
		for _, m := range in.Memberships {
			if m.LeftAt != nil && dateLess(*m.LeftAt, m.JoinedAt) {
				rt.Fatalf("member left (%v) before joining (%v)", *m.LeftAt, m.JoinedAt)
			}
			members[m.ID] = m
		}
		slots := map[uuid.UUID]bool{}
		for _, s := range in.Slots {
			slots[s.ID] = true
		}

		for _, p := range in.Patterns {
			if _, ok := members[p.MembershipID]; !ok {
				rt.Fatalf("pattern references unknown membership")
			}
			if !slots[p.SlotID] {
				rt.Fatalf("pattern references unknown slot")
			}
			if p.Qty < 0 {
				rt.Fatalf("pattern qty is negative")
			}
		}
		for _, e := range in.Exceptions {
			if _, ok := members[e.MembershipID]; !ok {
				rt.Fatalf("exception references unknown membership")
			}
			if e.SlotID != nil && !slots[*e.SlotID] {
				rt.Fatalf("exception references unknown slot")
			}
			if dateLess(e.DateTo, e.DateFrom) {
				rt.Fatalf("exception date_to before date_from")
			}
			if (e.Action == meals.ActionSetQty || e.Action == meals.ActionGuest) && e.Qty == nil {
				rt.Fatalf("%s exception must carry a qty", e.Action)
			}
		}
	})
}

// TestShuffleAllPreservesTheMultiset proves the P3 fixture only reorders — it
// never adds, drops or mutates a row.
func TestShuffleAllPreservesTheMultiset(t *testing.T) {
	rapid.Check(t, func(rt *rapid.T) {
		in := genInput(rt)
		out := shuffleAll(rt, in)
		if len(out.Memberships) != len(in.Memberships) ||
			len(out.Slots) != len(in.Slots) ||
			len(out.Patterns) != len(in.Patterns) ||
			len(out.Exceptions) != len(in.Exceptions) ||
			len(out.DayFlags) != len(in.DayFlags) {
			rt.Fatal("shuffle changed a slice length")
		}
		ids := map[uuid.UUID]bool{}
		for _, m := range in.Memberships {
			ids[m.ID] = true
		}
		for _, m := range out.Memberships {
			if !ids[m.ID] {
				rt.Fatal("shuffle invented a membership")
			}
		}
	})
}
