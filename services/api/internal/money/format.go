package money

import (
	"strconv"
	"strings"
)

// Money formatting service (task 06.9). One place turns int64 paisa into the
// string a person reads, so the number is identical on every surface — the
// manager app, the member PWA, the landing page — because they all render the
// server's `display`, never their own arithmetic (Invariant 1: format at the
// edge, and the server is that edge).
//
// Convention (docs/product/BUILD_SPEC.md §examples):
//   - paisa ÷ 100 is taka; 4000 → "৳৪০", 0 → "৳০".
//   - a non-zero paisa remainder shows two decimals: 1240 → "৳১২.৪০".
//   - the taka part is grouped in the South Asian (lakh) system, 2-2-3 from the
//     right: 10000000 paisa → "৳১,০০,০০০". Every spec example is sub-lakh and so
//     matches Western grouping too; the lakh system is the market-correct choice
//     for BDT and the one to revisit if the founder wants Western grouping.
//   - a negative amount (a member who owes) leads with a minus: -50000 → "-৳৫০০".
//
// bn is the default; en swaps the numerals only (the ৳, grouping and decimals
// are identical). "Tabular" in the task title is a client rendering concern
// (tabular-figure fonts), not part of the string.

const taka = "৳"

var bengaliDigits = [...]rune{'০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'}

// Format renders paisa as Bangladeshi Taka. bengaliNumerals selects the digit
// set: true (the default surface) yields "৳১,২৪০", false yields "৳1,240".
func Format(paisa int64, bengaliNumerals bool) string {
	negative := paisa < 0
	if negative {
		paisa = -paisa
	}
	whole := paisa / 100
	frac := paisa % 100

	var b strings.Builder
	if negative {
		b.WriteByte('-')
	}
	b.WriteString(taka)
	b.WriteString(groupLakh(strconv.FormatInt(whole, 10)))
	if frac != 0 {
		b.WriteByte('.')
		b.WriteByte(byte('0' + frac/10))
		b.WriteByte(byte('0' + frac%10))
	}

	if bengaliNumerals {
		return toBengaliDigits(b.String())
	}
	return b.String()
}

// FormatForLocale is the ergonomic form for a handler holding a caller locale:
// any locale other than "en" gets Bangla numerals, since bn is the default.
func FormatForLocale(paisa int64, locale string) string {
	return Format(paisa, locale != "en")
}

// groupLakh groups a non-negative integer string in the South Asian system:
// the last three digits, then twos. "1234567" → "12,34,567".
func groupLakh(s string) string {
	n := len(s)
	if n <= 3 {
		return s
	}
	head, tail := s[:n-3], s[n-3:]
	var parts []string
	for len(head) > 2 {
		parts = append(parts, head[len(head)-2:])
		head = head[:len(head)-2]
	}
	if head != "" {
		parts = append(parts, head)
	}
	// parts were collected right-to-left; reverse them.
	for i, j := 0, len(parts)-1; i < j; i, j = i+1, j-1 {
		parts[i], parts[j] = parts[j], parts[i]
	}
	return strings.Join(parts, ",") + "," + tail
}

// toBengaliDigits rewrites ASCII digits to Bangla ones, leaving ৳, the
// grouping commas, the decimal point and the sign untouched.
func toBengaliDigits(s string) string {
	var b strings.Builder
	b.Grow(len(s))
	for _, r := range s {
		if r >= '0' && r <= '9' {
			b.WriteRune(bengaliDigits[r-'0'])
		} else {
			b.WriteRune(r)
		}
	}
	return b.String()
}
