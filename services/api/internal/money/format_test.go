package money

import "testing"

// Task 06.9: golden money-formatting vectors. These are the contract the three
// clients render against, so they are exhaustive about the decisions — decimals
// only when there are paisa, South Asian (lakh) grouping, and the sign.
func TestFormat(t *testing.T) {
	cases := []struct {
		paisa  int64
		bn, en string
	}{
		{0, "৳০", "৳0"},
		{500, "৳৫", "৳5"},                    // ৳5.00 → whole, no decimals
		{4000, "৳৪০", "৳40"},                 // BUILD_SPEC example
		{124000, "৳১,২৪০", "৳1,240"},         // BRD example ৳1,240
		{1240000, "৳১২,৪০০", "৳12,400"},      // BUILD_SPEC example
		{1240, "৳১২.৪০", "৳12.40"},           // paisa remainder shows two decimals
		{5, "৳০.০৫", "৳0.05"},                // sub-taka
		{10000000, "৳১,০০,০০০", "৳1,00,000"}, // one lakh — lakh grouping
		{123456789, "৳১২,৩৪,৫৬৭.৮৯", "৳12,34,567.89"},
		{-50000, "-৳৫০০", "-৳500"}, // a member who owes
		{-1240, "-৳১২.৪০", "-৳12.40"},
	}
	for _, c := range cases {
		if got := Format(c.paisa, true); got != c.bn {
			t.Errorf("Format(%d, bn) = %q, want %q", c.paisa, got, c.bn)
		}
		if got := Format(c.paisa, false); got != c.en {
			t.Errorf("Format(%d, en) = %q, want %q", c.paisa, got, c.en)
		}
	}
}

func TestFormatForLocale(t *testing.T) {
	if got := FormatForLocale(124000, "bn"); got != "৳১,২৪০" {
		t.Errorf(`FormatForLocale(124000, "bn") = %q, want ৳১,২৪০`, got)
	}
	if got := FormatForLocale(124000, "en"); got != "৳1,240" {
		t.Errorf(`FormatForLocale(124000, "en") = %q, want ৳1,240`, got)
	}
	// Anything that is not "en" falls back to the Bangla default.
	if got := FormatForLocale(124000, ""); got != "৳১,২৪০" {
		t.Errorf(`FormatForLocale(124000, "") = %q, want the bn default`, got)
	}
}
