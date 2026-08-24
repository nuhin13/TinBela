package transport

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"connectrpc.com/connect"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/droidbuilder/tinbela/services/api/internal/core"
	"github.com/droidbuilder/tinbela/services/api/internal/invites"

	"github.com/droidbuilder/tinbela/services/api/internal/db"
	adminv1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/admin/v1"
	corev1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/core/v1"
	mealsv1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/meals/v1"
	moneyv1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/money/v1"
)

// notYet reports a procedure whose transport is wired but whose behaviour
// belongs to a later epic. It names the epic so the caller -- usually us --
// knows where to look rather than guessing whether it is a bug.
func notYet(epic, task string) error {
	return connect.NewError(connect.CodeUnimplemented,
		fmt.Errorf("not implemented yet: Epic %s task %s", epic, task))
}

// coreService implements tinbela.core.v1.CoreService.
type coreService struct{ pool *pgxpool.Pool }

// GetMe answers "who am I, and which messes am I in".
//
// It is the one procedure that must work without a tenant: a client calls it
// precisely to discover which messes exist for them. See tenantFreeProcedures.
func (s coreService) GetMe(ctx context.Context, _ *connect.Request[corev1.GetMeRequest]) (*connect.Response[corev1.GetMeResponse], error) {
	caller, ok := CallerFrom(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, nil)
	}

	// The request transaction, not the pool: app.user_id is SET LOCAL on it
	// and the self-discovery policies (migration 000004) depend on that.
	tx, ok := TxFrom(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeInternal, nil)
	}
	q := db.New(tx)
	u, err := q.GetUser(ctx, caller.UserID)
	if err != nil {
		return nil, err
	}
	rows, err := q.ListMessesForUser(ctx, pgUUID(caller.UserID))
	if err != nil {
		return nil, err
	}

	out := &corev1.GetMeResponse{
		User: &corev1.User{
			Id:                u.ID.String(),
			Name:              u.Name,
			Locale:            u.Locale,
			UseBanglaNumerals: u.UseBanglaNumerals,
		},
	}
	if u.PhoneE164 != nil {
		out.User.PhoneE164 = *u.PhoneE164
	}
	for _, r := range rows {
		out.Messes = append(out.Messes, &corev1.Mess{
			Id:   r.ID.String(),
			Name: r.Name,
			Kind: tenantKind(r.Kind),
		})
	}
	return connect.NewResponse(out), nil
}

// tenantKind maps the database's text enum to the proto enum. The database
// and the contract are allowed to disagree about spelling; they are not
// allowed to disagree silently, so an unknown value is UNSPECIFIED rather
// than a guess.
func tenantKind(s string) corev1.TenantKind {
	switch s {
	case "MESS":
		return corev1.TenantKind_TENANT_KIND_MESS
	case "INSTITUTION":
		return corev1.TenantKind_TENANT_KIND_INSTITUTION
	case "HOME":
		return corev1.TenantKind_TENANT_KIND_HOME
	default:
		return corev1.TenantKind_TENANT_KIND_UNSPECIFIED
	}
}

// defaultSlots are the meal slots a new mess starts with, in the order a
// day happens. slot_count picks from the END of this list, because a mess
// that serves two meals serves lunch and dinner -- breakfast is the one
// people skip (Epic 09's third onboarding question).
var defaultSlots = []struct {
	bn, en, cutoff string
}{
	{"সকাল", "Breakfast", "07:00"},
	{"দুপুর", "Lunch", "10:30"},
	{"রাত", "Dinner", "17:00"},
}

// CreateMess brings a mess into existence: tenant, slots, the first open
// period, and the caller's manager membership.
//
// All of it in the request transaction, so a partial failure leaves
// nothing -- a mess with no slots or no period is worse than no mess,
// because the manager cannot tell it is broken until the month ends.
func (s coreService) CreateMess(ctx context.Context, req *connect.Request[corev1.CreateMessRequest]) (*connect.Response[corev1.CreateMessResponse], error) {
	caller, ok := CallerFrom(ctx)
	if !ok {
		return nil, core.ErrUnauthenticated
	}
	tx, ok := TxFrom(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeInternal, nil)
	}

	name := strings.TrimSpace(req.Msg.GetName())
	if name == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("mess name is required"))
	}
	slotCount := int(req.Msg.GetSlotCount())
	if slotCount < 1 || slotCount > len(defaultSlots) {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("slot_count must be between 1 and %d", len(defaultSlots)))
	}

	tenantID := uuid.New()

	// The caller has no membership in a mess that does not exist yet, so
	// app.tenant_id is unset and the RLS WITH CHECK would reject every
	// INSERT below. Scoping the transaction to the id we are about to
	// create is what makes creation possible without loosening a policy.
	if _, err := tx.Exec(ctx,
		"SELECT set_config('app.tenant_id', $1, true)", tenantID.String()); err != nil {
		return nil, err
	}

	q := db.New(tx)
	kind := "MESS"
	if req.Msg.GetKind() == corev1.TenantKind_TENANT_KIND_HOME {
		kind = "HOME"
	}
	tenant, err := q.CreateTenant(ctx, db.CreateTenantParams{
		ID: tenantID, Name: name, Kind: kind,
	})
	if err != nil {
		return nil, err
	}

	slots := defaultSlots[len(defaultSlots)-slotCount:]
	outSlots := make([]*corev1.Slot, 0, len(slots))
	for i, sl := range slots {
		created, err := q.CreateSlot(ctx, db.CreateSlotParams{
			ID: uuid.New(), TenantID: tenantID,
			NameBn: sl.bn, NameEn: sl.en,
			SortOrder: int32(i + 1), CutoffLocal: pgTime(sl.cutoff),
		})
		if err != nil {
			return nil, err
		}
		outSlots = append(outSlots, &corev1.Slot{
			Id: created.ID.String(), NameBn: created.NameBn, NameEn: created.NameEn,
			SortOrder: created.SortOrder, CutoffLocal: sl.cutoff, Active: created.Active,
		})
	}

	// The first period is the current month in Asia/Dhaka. Boundaries are a
	// server-side concern (Invariant 5) -- a manager travelling does not
	// move their month.
	start, end := currentMonth()
	period, err := q.CreatePeriod(ctx, db.CreatePeriodParams{
		ID: uuid.New(), TenantID: tenantID,
		StartDate: pgDate(start), EndDate: pgDate(end),
	})
	if err != nil {
		return nil, err
	}

	if _, err := q.CreateMembership(ctx, db.CreateMembershipParams{
		ID: uuid.New(), TenantID: tenantID, UserID: pgUUID(caller.UserID),
		Role: "MANAGER", DisplayName: displayNameFor(ctx, q, caller),
		JoinedAt: pgDate(start),
	}); err != nil {
		return nil, err
	}

	return connect.NewResponse(&corev1.CreateMessResponse{
		Mess: &corev1.Mess{
			Id: tenant.ID.String(), Name: tenant.Name,
			Kind: tenantKind(tenant.Kind), Slots: outSlots,
			CurrentPeriodId: period.ID.String(),
		},
		// InviteLink is deliberately empty. The schema has no mess-level
		// invite -- invite_token is per membership -- so there is nothing
		// to put here. Per-member links come from AddMember. Whether this
		// field should exist at all is a product decision, not one to
		// invent a value for.
	}), nil
}

// AddMember adds someone by name and mints their invite link.
//
// No user account is required: the manager types a name, and the link is
// what turns that name into an account later. That ordering is the whole
// onboarding design -- a manager can set up the entire mess alone, at
// night, without anyone else installing anything.
func (s coreService) AddMember(ctx context.Context, req *connect.Request[corev1.AddMemberRequest]) (*connect.Response[corev1.AddMemberResponse], error) {
	scope, err := requireManager(ctx)
	if err != nil {
		return nil, err
	}
	if err := sameMess(req.Msg.GetMessId(), scope); err != nil {
		return nil, err
	}
	tx, ok := TxFrom(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeInternal, nil)
	}

	name := strings.TrimSpace(req.Msg.GetDisplayName())
	if name == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("display_name is required"))
	}

	token, err := invites.NewToken()
	if err != nil {
		return nil, err
	}

	start, _ := currentMonth()
	m, err := db.New(tx).CreateMembership(ctx, db.CreateMembershipParams{
		ID: uuid.New(), TenantID: scope.TenantID,
		Role: "MEMBER", DisplayName: name, JoinedAt: pgDate(start),
		InviteToken: &token,
	})
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&corev1.AddMemberResponse{
		Member: &corev1.Member{
			Id: m.ID.String(), DisplayName: m.DisplayName,
			PhoneE164: req.Msg.GetPhoneE164(),
			Role:      corev1.Role_ROLE_MEMBER,
			// SENT, not LINKED: the link exists, nobody has opened it.
			InviteState: corev1.InviteState_INVITE_STATE_SENT,
		},
		InviteLink: invites.Link(token),
	}), nil
}

func (s coreService) ListMembers(ctx context.Context, req *connect.Request[corev1.ListMembersRequest]) (*connect.Response[corev1.ListMembersResponse], error) {
	scope, ok := TenantFrom(ctx)
	if !ok {
		return nil, core.ErrNotMember
	}
	if err := sameMess(req.Msg.GetMessId(), scope); err != nil {
		return nil, err
	}
	tx, ok := TxFrom(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeInternal, nil)
	}

	rows, err := db.New(tx).ListMembersWithUser(ctx, scope.TenantID)
	if err != nil {
		return nil, err
	}

	out := &corev1.ListMembersResponse{}
	for _, r := range rows {
		mem := &corev1.Member{
			Id: r.ID.String(), DisplayName: r.DisplayName,
			Role:        protoRole(r.Role),
			InviteState: inviteState(r),
		}
		if r.UserPhone != nil {
			mem.PhoneE164 = *r.UserPhone
		}
		out.Members = append(out.Members, mem)
	}
	return connect.NewResponse(out), nil
}

// requireManager is task 04.7 in one place. A MEMBER may read their mess;
// only a MANAGER changes it. Enforcing it per-handler rather than per-role
// map keeps the check next to the operation it guards.
func requireManager(ctx context.Context) (TenantScope, error) {
	scope, ok := TenantFrom(ctx)
	if !ok {
		return TenantScope{}, core.ErrNotMember
	}
	if scope.Role != "MANAGER" {
		return TenantScope{}, core.ErrNotManager
	}
	return scope, nil
}

// sameMess reconciles the mess_id in the request body with the scope the
// interceptor authorised from the X-Tenant-Id header.
//
// Only the header is authorised, so the body field can never be the one we
// act on. But silently ignoring it is worse than it looks: a client that
// sets mess_id to a different mess would see the call succeed against a
// mess it did not name. Disagreement is treated as a cross-tenant attempt,
// which means the caller learns nothing about whether that other mess
// exists.
func sameMess(messID string, scope TenantScope) error {
	if messID == "" {
		return nil
	}
	if messID != scope.TenantID.String() {
		return core.ErrTenantMismatch
	}
	return nil
}

func protoRole(s string) corev1.Role {
	switch s {
	case "MANAGER":
		return corev1.Role_ROLE_MANAGER
	case "MEMBER":
		return corev1.Role_ROLE_MEMBER
	default:
		return corev1.Role_ROLE_UNSPECIFIED
	}
}

// inviteState reads the member's progress from the columns that record it:
// a linked user beats an opened link, which beats a link merely minted.
func inviteState(r db.ListMembersWithUserRow) corev1.InviteState {
	switch {
	case r.UserID.Valid:
		return corev1.InviteState_INVITE_STATE_LINKED
	case r.InviteOpenedAt.Valid:
		return corev1.InviteState_INVITE_STATE_OPENED
	case r.InviteToken != nil:
		return corev1.InviteState_INVITE_STATE_SENT
	default:
		return corev1.InviteState_INVITE_STATE_UNSPECIFIED
	}
}

// currentMonth is the Asia/Dhaka month containing now (Invariant 5).
func currentMonth() (time.Time, time.Time) {
	loc, err := time.LoadLocation("Asia/Dhaka")
	if err != nil {
		loc = time.UTC
	}
	now := time.Now().In(loc)
	start := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, loc)
	return start, start.AddDate(0, 1, -1)
}

// pgTime converts "HH:MM" to Postgres time-of-day. Cutoffs are wall-clock
// times in Asia/Dhaka, not instants, so there is no date or zone involved.
func pgTime(hhmm string) pgtype.Time {
	var h, m int
	_, _ = fmt.Sscanf(hhmm, "%d:%d", &h, &m)
	return pgtype.Time{
		Microseconds: int64(h)*3600*1_000_000 + int64(m)*60*1_000_000,
		Valid:        true,
	}
}

func pgDate(t time.Time) pgtype.Date {
	return pgtype.Date{Time: t, Valid: true}
}

// pgUUID wraps a known id for a column that is now nullable (migration
// 000005). The zero pgtype.UUID is Valid:false, which is how a pending
// membership -- a member with no account yet -- reaches the database as
// NULL without anyone having to spell it.
func pgUUID(id uuid.UUID) pgtype.UUID {
	return pgtype.UUID{Bytes: id, Valid: true}
}

// displayNameFor falls back to the account name for the manager's own
// membership. A mess where the manager shows up as "" is a bug the manager
// sees on the first screen.
func displayNameFor(ctx context.Context, q *db.Queries, c Caller) string {
	if u, err := q.GetUser(ctx, c.UserID); err == nil && u.Name != "" {
		return u.Name
	}
	return "ম্যানেজার"
}

// mealsService implements tinbela.meals.v1.MealsService (Epic 05).
type mealsService struct{}

func (mealsService) SetPatterns(context.Context, *connect.Request[mealsv1.SetPatternsRequest]) (*connect.Response[mealsv1.SetPatternsResponse], error) {
	return nil, notYet("05", "05.2")
}
func (mealsService) CreateException(context.Context, *connect.Request[mealsv1.CreateExceptionRequest]) (*connect.Response[mealsv1.CreateExceptionResponse], error) {
	return nil, notYet("05", "05.3")
}
func (mealsService) VoidException(context.Context, *connect.Request[mealsv1.VoidExceptionRequest]) (*connect.Response[mealsv1.VoidExceptionResponse], error) {
	return nil, notYet("05", "05.5")
}
func (mealsService) GetDay(context.Context, *connect.Request[mealsv1.GetDayRequest]) (*connect.Response[mealsv1.GetDayResponse], error) {
	return nil, notYet("05", "05.4")
}

// moneyService implements tinbela.money.v1.MoneyService (Epics 06, 07).
type moneyService struct{}

func (moneyService) AddLedgerEntry(context.Context, *connect.Request[moneyv1.AddLedgerEntryRequest]) (*connect.Response[moneyv1.AddLedgerEntryResponse], error) {
	return nil, notYet("06", "06.2")
}
func (moneyService) VoidLedgerEntry(context.Context, *connect.Request[moneyv1.VoidLedgerEntryRequest]) (*connect.Response[moneyv1.VoidLedgerEntryResponse], error) {
	return nil, notYet("06", "06.3")
}
func (moneyService) GetAccounts(context.Context, *connect.Request[moneyv1.GetAccountsRequest]) (*connect.Response[moneyv1.GetAccountsResponse], error) {
	return nil, notYet("06", "06.4")
}
func (moneyService) PreviewClose(context.Context, *connect.Request[moneyv1.PreviewCloseRequest]) (*connect.Response[moneyv1.PreviewCloseResponse], error) {
	return nil, notYet("07", "07.2")
}
func (moneyService) ClosePeriod(context.Context, *connect.Request[moneyv1.ClosePeriodRequest]) (*connect.Response[moneyv1.ClosePeriodResponse], error) {
	return nil, notYet("07", "07.3")
}
func (moneyService) GetStatement(context.Context, *connect.Request[moneyv1.GetStatementRequest]) (*connect.Response[moneyv1.GetStatementResponse], error) {
	return nil, notYet("07", "07.5")
}

// adminService implements tinbela.admin.v1.AdminService (Epic 16).
//
// Mounted without the tenant interceptor: the admin surface reads across
// messes by definition, so it needs its own authorisation, not this one.
type adminService struct{}

func (adminService) ListTenants(context.Context, *connect.Request[adminv1.ListTenantsRequest]) (*connect.Response[adminv1.ListTenantsResponse], error) {
	return nil, notYet("16", "16.3")
}
func (adminService) GetTenant(context.Context, *connect.Request[adminv1.GetTenantRequest]) (*connect.Response[adminv1.GetTenantResponse], error) {
	return nil, notYet("16", "16.4")
}
func (adminService) FindUser(context.Context, *connect.Request[adminv1.FindUserRequest]) (*connect.Response[adminv1.FindUserResponse], error) {
	return nil, notYet("16", "16.5")
}
func (adminService) GetMetrics(context.Context, *connect.Request[adminv1.GetMetricsRequest]) (*connect.Response[adminv1.GetMetricsResponse], error) {
	return nil, notYet("16", "16.6")
}
func (adminService) GetFlags(context.Context, *connect.Request[adminv1.GetFlagsRequest]) (*connect.Response[adminv1.GetFlagsResponse], error) {
	return nil, notYet("16", "16.7")
}
func (adminService) SetFlag(context.Context, *connect.Request[adminv1.SetFlagRequest]) (*connect.Response[adminv1.SetFlagResponse], error) {
	return nil, notYet("16", "16.7")
}
