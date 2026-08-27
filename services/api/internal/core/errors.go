// Package core holds the domain vocabulary shared by every service: the
// typed errors, and the identities that interceptors resolve.
//
// Domain errors are values, not strings. transport/ maps them to Connect
// codes and localised messages (docs/eng/errors.md). Nothing below this
// package knows what a Connect code is.
package core

import "errors"

var (
	ErrNotFound           = errors.New("not found")
	ErrNotMember          = errors.New("not a member of this mess")
	ErrNotManager         = errors.New("only the manager can do this")
	ErrCutoffPassed       = errors.New("cutoff has passed")
	ErrPeriodClosed       = errors.New("period is closed")
	ErrPeriodOverlap      = errors.New("period overlaps an existing one")
	ErrNoMeals            = errors.New("no meals recorded")
	ErrInvalidToken       = errors.New("token is not valid")
	ErrAlreadyVoided      = errors.New("already voided")
	ErrAlreadyLeft        = errors.New("member has already left")
	ErrCannotLeaveManager = errors.New("the manager cannot be removed this way")
	ErrTenantMismatch     = errors.New("tenant mismatch")
	ErrUnauthenticated    = errors.New("unauthenticated")
	ErrNotStaff           = errors.New("not staff")
)
