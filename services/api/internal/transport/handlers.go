package transport

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"connectrpc.com/connect"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/droidbuilder/tinbela/services/api/internal/core"
	"github.com/droidbuilder/tinbela/services/api/internal/invites"

	"github.com/droidbuilder/tinbela/services/api/internal/db"
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

// LeaveMember marks a member gone as of today (Asia/Dhaka). It is a SOFT
// leave: left_at is set, nothing is deleted, and every meal the member ate
// while present still counts (property P8, task 04.8). Their meal_exceptions
// and ledger rows are untouched, so a closed month's numbers cannot change
// under them.
//
// It is manager-only by the fail-closed interceptor (task 04.7); requireManager
// re-checks in the same defence-in-depth spirit as the other writes.
func (s coreService) LeaveMember(ctx context.Context, req *connect.Request[corev1.LeaveMemberRequest]) (*connect.Response[corev1.LeaveMemberResponse], error) {
	scope, err := requireManager(ctx)
	if err != nil {
		return nil, err
	}
	if err := sameMess(req.Msg.GetMessId(), scope); err != nil {
		return nil, err
	}
	memberID, err := uuid.Parse(req.Msg.GetMemberId())
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("member_id is not a valid id"))
	}
	tx, ok := TxFrom(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeInternal, nil)
	}
	q := db.New(tx)

	// Look the row up first, under tenant scope: it separates "no such member
	// here" from "already left", and it is where the manager guard reads the
	// target's role. RLS makes a member of another mess indistinguishable from
	// one that does not exist -- both are ErrNotFound.
	existing, err := q.GetMembership(ctx, db.GetMembershipParams{
		TenantID: scope.TenantID, ID: memberID,
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, core.ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	if existing.Role == roleManager {
		// Removing the mess's manager would orphan it, and v1.0 has no
		// hand-off. A manager leaving is account deletion (Epic 13), not this.
		return nil, core.ErrCannotLeaveManager
	}
	if existing.LeftAt.Valid {
		return nil, core.ErrAlreadyLeft
	}

	m, err := q.LeaveMembership(ctx, db.LeaveMembershipParams{
		TenantID: scope.TenantID, ID: memberID, LeftAt: pgDate(todayDhaka()),
	})
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&corev1.LeaveMemberResponse{
		Member: &corev1.Member{
			Id:          m.ID.String(),
			DisplayName: m.DisplayName,
			Role:        protoRole(m.Role),
			JoinedAt:    protoDate(m.JoinedAt),
			LeftAt:      protoDate(m.LeftAt),
		},
	}), nil
}

// requireManager returns the authorised scope, and re-checks the role.
//
// roleInterceptor (task 04.7) is the primary gate and rejects a MEMBER before
// any handler runs, so the role check here is defence in depth in the same
// spirit as RLS behind tenant scoping: two independent failures should be
// required to write something the caller may not write.
func requireManager(ctx context.Context) (TenantScope, error) {
	scope, ok := TenantFrom(ctx)
	if !ok {
		return TenantScope{}, core.ErrNotMember
	}
	if scope.Role != roleManager {
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

// todayDhaka is the current calendar day in Asia/Dhaka (Invariant 5). A leave
// date is a day, not an instant, and it is the server's to decide -- a manager
// on a trip does not move when their member left.
func todayDhaka() time.Time {
	loc, err := time.LoadLocation("Asia/Dhaka")
	if err != nil {
		loc = time.UTC
	}
	now := time.Now().In(loc)
	return time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, loc)
}

// protoDate renders a nullable Postgres date as the contract's Date
// ("YYYY-MM-DD"), or nil when the column is NULL -- a member who has not left
// carries no left_at.
func protoDate(d pgtype.Date) *corev1.Date {
	if !d.Valid {
		return nil
	}
	return &corev1.Date{Value: d.Time.Format("2006-01-02")}
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
func (mealsService) CreateException(ctx context.Context, req *connect.Request[mealsv1.CreateExceptionRequest]) (*connect.Response[mealsv1.CreateExceptionResponse], error) {
	scope, err := requireManager(ctx)
	if err != nil {
		return nil, err
	}
	if err := sameMess(req.Msg.GetMessId(), scope); err != nil {
		return nil, err
	}
	caller, ok := CallerFrom(ctx)
	if !ok {
		return nil, core.ErrUnauthenticated
	}
	tx, ok := TxFrom(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeInternal, nil)
	}
	q := db.New(tx)

	// The exception is attributed to a member; the lookup is tenant-scoped, so
	// it both authorises the member is in this mess and gives the name to echo.
	memberID, err := uuid.Parse(req.Msg.GetMembershipId())
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("membership_id is required"))
	}
	member, err := q.GetMembership(ctx, db.GetMembershipParams{TenantID: scope.TenantID, ID: memberID})
	if err != nil {
		return nil, core.ErrNotFound
	}

	action := req.Msg.GetAction()
	actionStr := exceptionActionString(action)
	if actionStr == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("action must be OFF, ON, SET_QTY or GUEST"))
	}

	// qty is meaningful only for SET_QTY (how many) and GUEST (how many extra
	// plates); it is null for the on/off actions. A guest is at least one
	// plate. The upper bound keeps a typo out of the int16 column.
	var qty *int16
	switch action {
	case mealsv1.ExceptionAction_EXCEPTION_ACTION_SET_QTY:
		n := req.Msg.GetQty()
		if n < 0 || n > 99 {
			return nil, connect.NewError(connect.CodeInvalidArgument,
				errors.New("qty must be between 0 and 99"))
		}
		v := int16(n)
		qty = &v
	case mealsv1.ExceptionAction_EXCEPTION_ACTION_GUEST:
		n := req.Msg.GetQty()
		if n < 1 || n > 99 {
			return nil, connect.NewError(connect.CodeInvalidArgument,
				errors.New("a guest exception needs a qty between 1 and 99"))
		}
		v := int16(n)
		qty = &v
	}

	// The range defaults to today (Asia/Dhaka, Invariant 5); an empty date_to
	// means a single day.
	from, err := exceptionDate(req.Msg.GetDateFrom().GetValue())
	if err != nil {
		return nil, err
	}
	to := from
	if v := req.Msg.GetDateTo().GetValue(); v != "" {
		to, err = exceptionDate(v)
		if err != nil {
			return nil, err
		}
	}
	if to.Before(from) {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("date_to cannot be before date_from"))
	}

	params := db.InsertMealExceptionParams{
		ID:           uuid.New(),
		TenantID:     scope.TenantID,
		MembershipID: memberID,
		DateFrom:     pgDate(from),
		DateTo:       pgDate(to),
		Action:       actionStr,
		Qty:          qty,
		MarkedBy:     caller.UserID,
		// after_cutoff is the cutoff audit flag (05.7). Whether a mark lands
		// after its slot's cutoff — and whether to refuse it — is the cutoff
		// decision in Asia/Dhaka with clock-skew handling, task 05.6 ★. Until
		// that lands, every mark is recorded as on-time; this is the seam.
		AfterCutoff: false,
	}

	// An empty slot means every active slot. A named slot must belong to this
	// mess: the FK alone would accept another tenant's slot id (RLS does not
	// cover reference checks), so validate it against the tenant's own slots.
	if s := req.Msg.GetSlotId(); s != "" {
		slotID, perr := uuid.Parse(s)
		if perr != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("slot_id is not a valid id"))
		}
		if !tenantOwnsSlot(ctx, q, scope.TenantID, slotID) {
			return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("slot_id is not a slot of this mess"))
		}
		params.SlotID = pgUUID(slotID)
	}

	// group_id (P3 institution batch) is never set by the v1.0 mess app and is
	// ignored here.

	ex, err := q.InsertMealException(ctx, params)
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&mealsv1.CreateExceptionResponse{
		Exception: exceptionProto(ex, member.DisplayName, displayNameFor(ctx, q, caller)),
	}), nil
}
func (mealsService) VoidException(context.Context, *connect.Request[mealsv1.VoidExceptionRequest]) (*connect.Response[mealsv1.VoidExceptionResponse], error) {
	return nil, notYet("05", "05.5")
}
func (mealsService) GetDay(context.Context, *connect.Request[mealsv1.GetDayRequest]) (*connect.Response[mealsv1.GetDayResponse], error) {
	return nil, notYet("05", "05.4")
}

// exceptionDate parses a contract Date ("YYYY-MM-DD") in Asia/Dhaka, or
// returns today there when the field is empty (Invariant 5).
func exceptionDate(v string) (time.Time, error) {
	if v == "" {
		return todayDhaka(), nil
	}
	d, err := time.ParseInLocation("2006-01-02", v, dhakaLoc())
	if err != nil {
		return time.Time{}, connect.NewError(connect.CodeInvalidArgument,
			errors.New("date must be YYYY-MM-DD"))
	}
	return d, nil
}

// exceptionActionString maps the contract action to the meal_exceptions CHECK
// value. UNSPECIFIED returns "" so the caller can reject it.
func exceptionActionString(a mealsv1.ExceptionAction) string {
	switch a {
	case mealsv1.ExceptionAction_EXCEPTION_ACTION_OFF:
		return "OFF"
	case mealsv1.ExceptionAction_EXCEPTION_ACTION_ON:
		return "ON"
	case mealsv1.ExceptionAction_EXCEPTION_ACTION_SET_QTY:
		return "SET_QTY"
	case mealsv1.ExceptionAction_EXCEPTION_ACTION_GUEST:
		return "GUEST"
	default:
		return ""
	}
}

// protoExceptionAction is the reverse: the stored string back to the enum.
func protoExceptionAction(s string) mealsv1.ExceptionAction {
	switch s {
	case "OFF":
		return mealsv1.ExceptionAction_EXCEPTION_ACTION_OFF
	case "ON":
		return mealsv1.ExceptionAction_EXCEPTION_ACTION_ON
	case "SET_QTY":
		return mealsv1.ExceptionAction_EXCEPTION_ACTION_SET_QTY
	case "GUEST":
		return mealsv1.ExceptionAction_EXCEPTION_ACTION_GUEST
	default:
		return mealsv1.ExceptionAction_EXCEPTION_ACTION_UNSPECIFIED
	}
}

// tenantOwnsSlot reports whether slotID is an active slot of this tenant. The
// slot_id FK is checked as the table owner and so does not see RLS; this is
// the tenant scope that keeps one mess's exception off another's slot.
func tenantOwnsSlot(ctx context.Context, q *db.Queries, tenantID, slotID uuid.UUID) bool {
	slots, err := q.ListActiveSlots(ctx, tenantID)
	if err != nil {
		return false
	}
	for _, s := range slots {
		if s.ID == slotID {
			return true
		}
	}
	return false
}

// exceptionProto maps a stored row to the contract. A freshly inserted row is
// never itself voided; that is a property of a later void_of row (05.5 ★).
func exceptionProto(e db.MealException, memberName, markedByName string) *mealsv1.Exception {
	out := &mealsv1.Exception{
		Id:                e.ID.String(),
		MembershipId:      e.MembershipID.String(),
		MemberDisplayName: memberName,
		Action:            protoExceptionAction(e.Action),
		MarkedByName:      markedByName,
		AfterCutoff:       e.AfterCutoff,
		Range: &corev1.DateRange{
			From: &corev1.Date{Value: e.DateFrom.Time.Format("2006-01-02")},
			To:   &corev1.Date{Value: e.DateTo.Time.Format("2006-01-02")},
		},
	}
	if e.SlotID.Valid {
		out.SlotId = uuid.UUID(e.SlotID.Bytes).String()
	}
	if e.Qty != nil {
		out.Qty = int32(*e.Qty)
	}
	if e.CreatedAt.Valid {
		out.CreatedAt = e.CreatedAt.Time.Format(time.RFC3339)
	}
	return out
}

// moneyService implements tinbela.money.v1.MoneyService (Epics 06, 07).
type moneyService struct{}

func (moneyService) AddLedgerEntry(ctx context.Context, req *connect.Request[moneyv1.AddLedgerEntryRequest]) (*connect.Response[moneyv1.AddLedgerEntryResponse], error) {
	scope, err := requireManager(ctx)
	if err != nil {
		return nil, err
	}
	if err := sameMess(req.Msg.GetMessId(), scope); err != nil {
		return nil, err
	}
	caller, ok := CallerFrom(ctx)
	if !ok {
		return nil, core.ErrUnauthenticated
	}
	tx, ok := TxFrom(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeInternal, nil)
	}
	q := db.New(tx)

	// v1.0 records two kinds by hand: a mess food cost, and a member deposit.
	// SHARED_COST / RENT_PAYOUT are P2; ADJUST is written by close (06.6 ★),
	// never by a manager.
	kind := req.Msg.GetKind()
	if kind != moneyv1.EntryKind_ENTRY_KIND_FOOD_COST && kind != moneyv1.EntryKind_ENTRY_KIND_DEPOSIT {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("kind must be FOOD_COST or DEPOSIT"))
	}

	// Strictly positive: a correction is a void (06.3) that inserts its own
	// negative counterpart, never a negative entry typed in here. That is what
	// keeps the ledger append-only and auditable (Invariant 2).
	amount := req.Msg.GetAmountPaisa()
	if amount <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("amount_paisa must be greater than zero; a correction is a void, not a negative entry"))
	}

	// An entry belongs to a day, decided server-side (Invariant 5): default to
	// today in Asia/Dhaka. Refuse a date outside the open period so a cost can
	// never land in a month already closed and made immutable (Invariants 2, 3).
	occurred := todayDhaka()
	if v := req.Msg.GetOccurredOn().GetValue(); v != "" {
		d, perr := time.ParseInLocation("2006-01-02", v, dhakaLoc())
		if perr != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument,
				errors.New("occurred_on must be YYYY-MM-DD"))
		}
		occurred = d
	}
	period, err := q.GetOpenPeriod(ctx, scope.TenantID)
	if err != nil || occurred.Before(period.StartDate.Time) || occurred.After(period.EndDate.Time) {
		return nil, core.ErrPeriodClosed
	}

	params := db.InsertLedgerEntryParams{
		ID:          uuid.New(),
		TenantID:    scope.TenantID,
		Kind:        entryKindString(kind),
		AmountPaisa: amount,
		OccurredOn:  pgDate(occurred),
		EnteredBy:   caller.UserID,
	}
	if note := strings.TrimSpace(req.Msg.GetNote()); note != "" {
		params.Note = &note
	}

	// A category labels a food cost (06.2). It is meaningless on a deposit,
	// which is attributed to a member instead.
	memberName := ""
	switch kind {
	case moneyv1.EntryKind_ENTRY_KIND_FOOD_COST:
		if cat := strings.TrimSpace(req.Msg.GetCategory()); cat != "" {
			params.Category = &cat
		}
	case moneyv1.EntryKind_ENTRY_KIND_DEPOSIT:
		memberID, perr := uuid.Parse(req.Msg.GetMembershipId())
		if perr != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument,
				errors.New("membership_id is required for a deposit"))
		}
		// Tenant-scoped: this both authorises the member is in this mess and
		// gives us the name to echo back.
		m, merr := q.GetMembership(ctx, db.GetMembershipParams{TenantID: scope.TenantID, ID: memberID})
		if merr != nil {
			return nil, core.ErrNotFound
		}
		params.MembershipID = pgUUID(memberID)
		memberName = m.DisplayName
	}

	entry, err := q.InsertLedgerEntry(ctx, params)
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&moneyv1.AddLedgerEntryResponse{
		Entry: ledgerEntryProto(entry, memberName, displayNameFor(ctx, q, caller)),
	}), nil
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

// entryKindString maps the two v1.0 hand-recorded kinds to the ledger's CHECK
// values. Only FOOD_COST and DEPOSIT reach it; AddLedgerEntry rejects the rest.
func entryKindString(k moneyv1.EntryKind) string {
	switch k {
	case moneyv1.EntryKind_ENTRY_KIND_FOOD_COST:
		return "FOOD_COST"
	case moneyv1.EntryKind_ENTRY_KIND_DEPOSIT:
		return "DEPOSIT"
	default:
		return ""
	}
}

// protoEntryKind is the reverse: the stored string back to the contract enum.
func protoEntryKind(s string) moneyv1.EntryKind {
	switch s {
	case "FOOD_COST":
		return moneyv1.EntryKind_ENTRY_KIND_FOOD_COST
	case "DEPOSIT":
		return moneyv1.EntryKind_ENTRY_KIND_DEPOSIT
	case "SHARED_COST":
		return moneyv1.EntryKind_ENTRY_KIND_SHARED_COST
	case "RENT_PAYOUT":
		return moneyv1.EntryKind_ENTRY_KIND_RENT_PAYOUT
	case "ADJUST":
		return moneyv1.EntryKind_ENTRY_KIND_ADJUST
	default:
		return moneyv1.EntryKind_ENTRY_KIND_UNSPECIFIED
	}
}

// ledgerEntryProto maps a stored row to the contract. The Money carries only
// paisa: the localised `display` is the money formatting service's job (06.9)
// and `math` is for computed values (06.5 ★), not a raw recorded amount. A
// freshly inserted row is never itself voided — that is a property of a later
// void_of row pointing back at it, resolved when the ledger is listed.
func ledgerEntryProto(e db.LedgerEntry, memberName, enteredByName string) *moneyv1.LedgerEntry {
	out := &moneyv1.LedgerEntry{
		Id:                e.ID.String(),
		Kind:              protoEntryKind(e.Kind),
		Amount:            &corev1.Money{Paisa: e.AmountPaisa},
		MemberDisplayName: memberName,
		EnteredByName:     enteredByName,
		Voided:            e.VoidOf.Valid,
	}
	if e.Category != nil {
		out.Category = *e.Category
	}
	if e.MembershipID.Valid {
		out.MembershipId = uuid.UUID(e.MembershipID.Bytes).String()
	}
	if e.OccurredOn.Valid {
		out.OccurredOn = &corev1.Date{Value: e.OccurredOn.Time.Format("2006-01-02")}
	}
	if e.Note != nil {
		out.Note = *e.Note
	}
	return out
}

// adminService (tinbela.admin.v1.AdminService, Epic 16) is implemented in
// admin_handlers.go. It is mounted without the tenant interceptor and carries
// its own staff authorisation (admin.go), reading through the read-only
// tinbela_admin pool (ADR-0016).
