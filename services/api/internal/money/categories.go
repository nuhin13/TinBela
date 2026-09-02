package money

// Expense categories (task 06.2). The seeded set a manager picks from when
// recording a FOOD_COST — bazar, gas, rice, fish and the rest. "Seeded,
// editable later" (EPICS 06.2): v1.0 ships this fixed list; a mess-editable
// set is a later lift. It lives here, in the domain package, as the single
// source of truth so the eventual ListCategories RPC and every client render
// the same labels rather than each inventing their own.
//
// Every category is localised bn/en (the 06.2 done-when). The code is the
// stable identifier stored on the ledger row; the labels are for display only
// and are never persisted (Invariant 1: format at the edge, not in data).

// Category is one seeded expense kind with its two labels.
type Category struct {
	Code string // stable id, stored on the ledger row
	Bn   string // Bangla label — the default the manager sees
	En   string // English label
}

// expenseCategories is the v1.0 seed, in the order a manager sees them.
// বাজার (the general grocery run) is first because it is the common case.
var expenseCategories = []Category{
	{Code: "bazar", Bn: "বাজার", En: "Bazar"},
	{Code: "rice", Bn: "চাল", En: "Rice"},
	{Code: "fish", Bn: "মাছ", En: "Fish"},
	{Code: "meat", Bn: "মাংস", En: "Meat"},
	{Code: "vegetables", Bn: "সবজি", En: "Vegetables"},
	{Code: "egg", Bn: "ডিম", En: "Egg"},
	{Code: "oil_spice", Bn: "তেল-মসলা", En: "Oil & spices"},
	{Code: "gas", Bn: "গ্যাস", En: "Gas"},
	{Code: "other", Bn: "অন্যান্য", En: "Other"},
}

// ExpenseCategories returns the seeded list. It returns a fresh copy so a
// caller cannot mutate the seed.
func ExpenseCategories() []Category {
	out := make([]Category, len(expenseCategories))
	copy(out, expenseCategories)
	return out
}

// IsKnownCategory reports whether code is one of the seeded categories. An
// empty code is not "known" — callers decide whether empty is allowed.
func IsKnownCategory(code string) bool {
	for _, c := range expenseCategories {
		if c.Code == code {
			return true
		}
	}
	return false
}
