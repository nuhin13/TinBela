package transport

// Epic 16 — the admin portal's read handlers.
//
// Every read runs through the read-only tinbela_admin pool (ADR-0016), so
// nothing here can mutate a mess even by mistake, and every read writes an
// audit row (task 16.8). Staff authorisation happens above, in adminGuard.
//
// GetTenant — the read-only tenant inspector (task 16.4) — is founder-owned
// (★) and left unimplemented on purpose. The transport, the staff gate and the
// read-only role are all in place for it to drop into.

import (
	"context"
	"encoding/json"
	"errors"
	"strings"
	"time"

	"connectrpc.com/connect"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/droidbuilder/tinbela/services/api/internal/db"
	adminv1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/admin/v1"
)

type adminService struct {
	pool *pgxpool.Pool
}

func (s adminService) q() *db.Queries { return db.New(s.pool) }

// ListTenants — tenant search + list, most-recently-active first (task 16.3).
func (s adminService) ListTenants(ctx context.Context, req *connect.Request[adminv1.ListTenantsRequest]) (*connect.Response[adminv1.ListTenantsResponse], error) {
	q := s.q()

	size := req.Msg.GetPageSize()
	if size <= 0 || size > 100 {
		size = 20
	}
	page := req.Msg.GetPage()
	if page < 0 {
		page = 0
	}
	query := strings.TrimSpace(req.Msg.GetQuery())

	rows, err := q.ListTenantsAdmin(ctx, db.ListTenantsAdminParams{
		Query: query, Lim: size, Off: page * size,
	})
	if err != nil {
		return nil, err
	}
	total, err := q.CountTenantsAdmin(ctx, query)
	if err != nil {
		return nil, err
	}

	out := &adminv1.ListTenantsResponse{Total: total}
	for _, r := range rows {
		out.Tenants = append(out.Tenants, &adminv1.TenantSummary{
			Id:             r.ID.String(),
			Name:           r.Name,
			Kind:           r.Kind,
			MemberCount:    r.MemberCount,
			CreatedAt:      tsString(r.CreatedAt),
			LastActivityAt: tsString(r.LastActivityAt),
		})
	}
	s.audit(ctx, q, "ListTenants", query)
	return connect.NewResponse(out), nil
}

// GetTenant — the READ-ONLY tenant inspector (task 16.4 ★). Founder-owned.
func (s adminService) GetTenant(context.Context, *connect.Request[adminv1.GetTenantRequest]) (*connect.Response[adminv1.GetTenantResponse], error) {
	return nil, notYet("16", "16.4")
}

// FindUser — lookup by phone or firebase uid (task 16.5). A missing user is a
// normal answer (empty user_json), not an error.
func (s adminService) FindUser(ctx context.Context, req *connect.Request[adminv1.FindUserRequest]) (*connect.Response[adminv1.FindUserResponse], error) {
	q := s.q()

	phone := strings.TrimSpace(req.Msg.GetPhoneE164())
	uid := strings.TrimSpace(req.Msg.GetFirebaseUid())

	var (
		user   db.User
		err    error
		target string
	)
	switch {
	case phone != "":
		target = phone
		user, err = q.FindUserByPhoneAdmin(ctx, &phone)
	case uid != "":
		target = uid
		user, err = q.FindUserByFirebaseAdmin(ctx, &uid)
	default:
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("phone_e164 or firebase_uid is required"))
	}

	s.audit(ctx, q, "FindUser", target)

	if errors.Is(err, pgx.ErrNoRows) {
		return connect.NewResponse(&adminv1.FindUserResponse{UserJson: ""}), nil
	}
	if err != nil {
		return nil, err
	}

	js, err := json.Marshal(userView{
		ID:                user.ID.String(),
		Name:              user.Name,
		PhoneE164:         deref(user.PhoneE164),
		FirebaseUID:       deref(user.FirebaseUid),
		Locale:            user.Locale,
		UseBanglaNumerals: user.UseBanglaNumerals,
		CreatedAt:         tsString(user.CreatedAt),
	})
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&adminv1.FindUserResponse{UserJson: string(js)}), nil
}

// GetMetrics — the dashboard numbers (task 16.2/16.7). Windows are Asia/Dhaka
// and server-owned (Invariant 5): "today" and "this month" are the server's to
// decide, not the operator's browser.
func (s adminService) GetMetrics(ctx context.Context, req *connect.Request[adminv1.GetMetricsRequest]) (*connect.Response[adminv1.GetMetricsResponse], error) {
	q := s.q()

	loc := dhakaLoc()
	now := time.Now().In(loc)
	dayStart := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, loc)
	monthStart := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, loc)

	active, err := q.CountActiveMessesAdmin(ctx)
	if err != nil {
		return nil, err
	}
	exToday, err := q.CountExceptionsBetweenAdmin(ctx, db.CountExceptionsBetweenAdminParams{
		Since: ts(dayStart), Until: ts(dayStart.AddDate(0, 0, 1)),
	})
	if err != nil {
		return nil, err
	}
	closes, err := q.CountClosesBetweenAdmin(ctx, db.CountClosesBetweenAdminParams{
		Since: ts(monthStart), Until: ts(monthStart.AddDate(0, 1, 0)),
	})
	if err != nil {
		return nil, err
	}
	links, err := q.CountMemberLinksOpenedAdmin(ctx)
	if err != nil {
		return nil, err
	}

	s.audit(ctx, q, "GetMetrics", "")
	return connect.NewResponse(&adminv1.GetMetricsResponse{
		ActiveMesses:      active,
		ExceptionsToday:   exToday,
		ClosesThisMonth:   closes,
		MemberLinksOpened: links,
	}), nil
}

// GetFlags / SetFlag — the feature-flag switches (task 16.6). SetFlag is the
// only write in the whole admin service, and it touches no customer data.
func (s adminService) GetFlags(ctx context.Context, _ *connect.Request[adminv1.GetFlagsRequest]) (*connect.Response[adminv1.GetFlagsResponse], error) {
	q := s.q()
	rows, err := q.ListFeatureFlags(ctx)
	if err != nil {
		return nil, err
	}
	flags := make(map[string]bool, len(rows))
	for _, r := range rows {
		flags[r.Key] = r.Value
	}
	s.audit(ctx, q, "GetFlags", "")
	return connect.NewResponse(&adminv1.GetFlagsResponse{Flags: flags}), nil
}

func (s adminService) SetFlag(ctx context.Context, req *connect.Request[adminv1.SetFlagRequest]) (*connect.Response[adminv1.SetFlagResponse], error) {
	q := s.q()
	key := strings.TrimSpace(req.Msg.GetKey())
	if key == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("key is required"))
	}
	caller, _ := CallerFrom(ctx)
	by := caller.FirebaseUID
	if err := q.SetFeatureFlag(ctx, db.SetFeatureFlagParams{
		Key: key, Value: req.Msg.GetValue(), UpdatedBy: &by,
	}); err != nil {
		return nil, err
	}
	s.audit(ctx, q, "SetFlag", key)
	return connect.NewResponse(&adminv1.SetFlagResponse{}), nil
}

// audit records the read (task 16.8). Best-effort: the tinbela_admin role is
// granted INSERT on this table, so a failure means the database is unwell, not
// that the write was refused, and a failed audit must not fail the read the
// operator is legitimately allowed to make.
func (s adminService) audit(ctx context.Context, q *db.Queries, action, target string) {
	caller, _ := CallerFrom(ctx)
	rid := RequestID(ctx)
	_ = q.InsertAdminAudit(ctx, db.InsertAdminAuditParams{
		ID:        uuid.New(),
		StaffUid:  caller.FirebaseUID,
		Action:    action,
		Target:    strPtr(target),
		RequestID: strPtr(rid),
	})
}

type userView struct {
	ID                string `json:"id"`
	Name              string `json:"name"`
	PhoneE164         string `json:"phone_e164,omitempty"`
	FirebaseUID       string `json:"firebase_uid,omitempty"`
	Locale            string `json:"locale"`
	UseBanglaNumerals bool   `json:"use_bangla_numerals"`
	CreatedAt         string `json:"created_at,omitempty"`
}

func dhakaLoc() *time.Location {
	loc, err := time.LoadLocation("Asia/Dhaka")
	if err != nil {
		return time.UTC
	}
	return loc
}

func ts(t time.Time) pgtype.Timestamptz {
	return pgtype.Timestamptz{Time: t, Valid: true}
}

func tsString(t pgtype.Timestamptz) string {
	if !t.Valid {
		return ""
	}
	return t.Time.UTC().Format(time.RFC3339)
}

func deref(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}

// strPtr maps "" to NULL, so an empty target or request id is a NULL column
// rather than an empty string masquerading as a value.
func strPtr(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}
