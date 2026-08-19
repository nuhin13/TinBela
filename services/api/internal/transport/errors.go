package transport

import (
	"errors"

	"connectrpc.com/connect"

	"github.com/droidbuilder/tinbela/services/api/internal/core"
)

// localised is one row of the table in docs/eng/errors.md.
type localised struct {
	code connect.Code
	bn   string
	en   string
}

// errorTable is the single source of truth for how a domain error reaches a
// client. Keep it in step with docs/eng/errors.md.
var errorTable = map[error]localised{
	core.ErrNotFound:        {connect.CodeNotFound, "পাওয়া যায়নি", "Not found"},
	core.ErrNotMember:       {connect.CodePermissionDenied, "আপনি এই মেসের সদস্য নন", "You are not a member of this mess"},
	core.ErrNotManager:      {connect.CodePermissionDenied, "শুধু ম্যানেজার এটি করতে পারেন", "Only the manager can do this"},
	core.ErrCutoffPassed:    {connect.CodeFailedPrecondition, "কাটঅফের সময় শেষ, ম্যানেজারকে বলুন", "Cutoff has passed — ask the manager"},
	core.ErrPeriodClosed:    {connect.CodeFailedPrecondition, "এই মাস বন্ধ হয়ে গেছে", "This month is already closed"},
	core.ErrPeriodOverlap:   {connect.CodeInvalidArgument, "সময়কাল আগের মাসের সাথে মিলে যাচ্ছে", "Period overlaps an existing one"},
	core.ErrNoMeals:         {connect.CodeFailedPrecondition, "কোনো মিল নেই, মাস শেষ করা যাবে না", "No meals recorded — cannot close"},
	core.ErrInvalidToken:    {connect.CodeUnauthenticated, "লিংকটি আর কাজ করছে না", "This link is no longer valid"},
	core.ErrAlreadyVoided:   {connect.CodeFailedPrecondition, "এটি আগেই বাতিল হয়েছে", "Already voided"},
	core.ErrUnauthenticated: {connect.CodeUnauthenticated, "আবার সাইন ইন করুন", "Please sign in again"},

	// docs/eng/errors.md specifies permission_denied with a generic
	// "not found" MESSAGE. Following the table as written.
	//
	// Worth flagging rather than quietly "fixing": the stated intent is
	// "never confirm that another tenant's resource exists", but the code
	// itself confirms it. A caller can tell permission_denied (the row
	// exists, in someone else's mess) from not_found (no such row) without
	// reading the message at all. If the intent is what matters, this row
	// wants CodeNotFound; if the code is what matters, the intent line
	// overstates the protection. That is a decision for whoever owns the
	// taxonomy, not one to make silently here.
	core.ErrTenantMismatch: {connect.CodePermissionDenied, "পাওয়া যায়নি", "Not found"},
}

// locale picks the message language. Bangla is the default: most managers
// read it more comfortably than English, and the app ships bn-first.
func message(l localised, locale string) string {
	if locale == "en" {
		return l.en
	}
	return l.bn
}

// toConnect converts a domain error into the error a client sees.
//
// An error with no table entry becomes a bare `internal` with no detail.
// That is deliberate: an unmapped error is by definition one nobody decided
// how to phrase, and leaking a pgx or driver string to a manager's phone is
// worse than saying nothing. The full error still reaches the log with the
// request id attached.
func toConnect(err error, locale string) *connect.Error {
	if err == nil {
		return nil
	}
	var ce *connect.Error
	if errors.As(err, &ce) {
		return ce
	}
	for domain, l := range errorTable {
		if errors.Is(err, domain) {
			return connect.NewError(l.code, errors.New(message(l, locale)))
		}
	}
	return connect.NewError(connect.CodeInternal, errors.New("internal error"))
}
