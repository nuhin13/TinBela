package money

import "testing"

// Task 06.2: the seeded expense categories exist and are localised bn/en.
func TestExpenseCategories(t *testing.T) {
	cats := ExpenseCategories()
	if len(cats) == 0 {
		t.Fatal("no seeded categories")
	}

	seen := make(map[string]bool, len(cats))
	for _, c := range cats {
		if c.Code == "" {
			t.Errorf("category %+v has an empty code", c)
		}
		if c.Bn == "" || c.En == "" {
			t.Errorf("category %q is not localised bn/en (bn=%q en=%q)", c.Code, c.Bn, c.En)
		}
		if seen[c.Code] {
			t.Errorf("duplicate category code %q", c.Code)
		}
		seen[c.Code] = true
	}

	// bazar is the common case and must be present and first.
	if cats[0].Code != "bazar" {
		t.Errorf("first category = %q, want bazar", cats[0].Code)
	}
}

func TestIsKnownCategory(t *testing.T) {
	if !IsKnownCategory("bazar") {
		t.Error("bazar should be a known category")
	}
	if IsKnownCategory("") {
		t.Error("empty string is not a known category")
	}
	if IsKnownCategory("wedding_feast") {
		t.Error("an unseeded code should not be known")
	}
}

// ExpenseCategories returns a copy: mutating the result must not touch the seed.
func TestExpenseCategoriesIsCopy(t *testing.T) {
	ExpenseCategories()[0].Bn = "মুছে ফেলা"
	if ExpenseCategories()[0].Bn != "বাজার" {
		t.Fatal("the seed was mutated through the returned slice")
	}
}
