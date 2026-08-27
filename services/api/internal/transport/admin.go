package transport

// Epic 16 task 16.1 — the admin surface's own authorisation.
//
// The admin service is mounted without the tenant/role interceptors, because
// it reads across every mess (ADR-0016). That freedom is exactly why it needs
// its own gate: a valid manager token must NOT reach it. Two independent
// checks, both here, before any admin handler runs:
//
//   1. staff — the authenticated caller's Firebase uid is on the staff list.
//   2. ip    — the request came from an allow-listed address.
//
// The read-only role (tinbela_admin) is the floor beneath this, not a
// substitute for it: it stops admin from mutating customer data, but says
// nothing about who may look.

import (
	"context"
	"net"
	"strings"

	"connectrpc.com/connect"

	"github.com/droidbuilder/tinbela/services/api/internal/core"
)

// StaffPolicy is the set of Firebase uids allowed into the admin surface.
type StaffPolicy struct {
	uids map[string]bool
}

// NewStaffPolicy builds the staff set from a list of Firebase uids (in prod,
// from the STAFF_UIDS env). An empty policy admits no one — the admin surface
// is closed until a staff member is named, which is the safe default.
func NewStaffPolicy(uids []string) StaffPolicy {
	set := make(map[string]bool, len(uids))
	for _, u := range uids {
		if u = strings.TrimSpace(u); u != "" {
			set[u] = true
		}
	}
	return StaffPolicy{uids: set}
}

func (p StaffPolicy) isStaff(firebaseUID string) bool {
	return firebaseUID != "" && p.uids[firebaseUID]
}

// IPAllowList is a set of client addresses permitted to reach the admin
// surface. Empty means "no app-level restriction" — the dev server enforces
// the network boundary at nginx (task 16.1); this is defence in depth.
type IPAllowList struct {
	ips map[string]bool
}

func NewIPAllowList(ips []string) IPAllowList {
	set := make(map[string]bool, len(ips))
	for _, ip := range ips {
		if ip = strings.TrimSpace(ip); ip != "" {
			set[ip] = true
		}
	}
	return IPAllowList{ips: set}
}

func (a IPAllowList) allows(addr string) bool {
	if len(a.ips) == 0 {
		return true
	}
	host, _, err := net.SplitHostPort(addr)
	if err != nil {
		host = addr
	}
	return a.ips[host]
}

// adminGuard rejects everything that is not an allow-listed staff caller,
// before the handler runs. A non-staff caller — even a perfectly valid manager
// — gets permission_denied (task 16.1's "non-staff gets 403").
func adminGuard(staff StaffPolicy, allow IPAllowList) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			if !allow.allows(req.Peer().Addr) {
				return nil, core.ErrNotStaff
			}
			caller, ok := CallerFrom(ctx)
			if !ok {
				return nil, core.ErrUnauthenticated
			}
			if !staff.isStaff(caller.FirebaseUID) {
				return nil, core.ErrNotStaff
			}
			return next(ctx, req)
		}
	}
}
