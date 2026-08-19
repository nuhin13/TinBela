package transport

import (
	"context"
	"fmt"

	"connectrpc.com/connect"
	"github.com/jackc/pgx/v5/pgxpool"

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
	rows, err := q.ListMessesForUser(ctx, caller.UserID)
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

func (coreService) CreateMess(context.Context, *connect.Request[corev1.CreateMessRequest]) (*connect.Response[corev1.CreateMessResponse], error) {
	return nil, notYet("04", "04.3")
}
func (coreService) AddMember(context.Context, *connect.Request[corev1.AddMemberRequest]) (*connect.Response[corev1.AddMemberResponse], error) {
	return nil, notYet("04", "04.4")
}
func (coreService) ListMembers(context.Context, *connect.Request[corev1.ListMembersRequest]) (*connect.Response[corev1.ListMembersResponse], error) {
	return nil, notYet("04", "04.7")
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
