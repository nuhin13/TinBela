package transport_test

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/droidbuilder/tinbela/services/api/internal/dbtest"
	corev1 "github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/core/v1"
	"github.com/droidbuilder/tinbela/services/api/internal/gen/tinbela/core/v1/corev1connect"
	"github.com/droidbuilder/tinbela/services/api/internal/transport"
)

// TestEpic04Gate is Epic 04's gate: create a mess, add 7 members, get 7
// invite links -- entirely through the generated client, as a manager would.
func TestEpic04Gate(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	core, cleanup := newAPI(ctx, t, "tinbela_epic04_test", "dev-manager", "aaaa0000-0000-0000-0000-0000000004a1")
	defer cleanup()

	auth := func(r interface{ Header() http.Header }, tenant string) {
		r.Header().Set(transport.HeaderAuthorization, "Bearer dev:dev-manager")
		if tenant != "" {
			r.Header().Set(transport.HeaderTenantID, tenant)
		}
	}

	// ── create the mess ────────────────────────────────────────────────
	createReq := connect.NewRequest(&corev1.CreateMessRequest{
		Name: "নীলক্ষেত মেস", Kind: corev1.TenantKind_TENANT_KIND_MESS, SlotCount: 3,
	})
	auth(createReq, "") // CreateMess is tenant-free by definition
	created, err := core.CreateMess(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateMess: %v", err)
	}

	mess := created.Msg.GetMess()
	messID := mess.GetId()
	if messID == "" {
		t.Fatal("CreateMess returned no mess id")
	}
	if n := len(mess.GetSlots()); n != 3 {
		t.Errorf("slots = %d, want 3", n)
	}
	if mess.GetCurrentPeriodId() == "" {
		t.Error("no open period was created; the month would have nowhere to land")
	}

	// ── add seven members, collect seven links ─────────────────────────
	names := []string{"সাদিয়া", "তানভীর", "নুসরাত", "ইমরান", "মেহেদী", "ফারহানা", "আরিফুল"}
	links := make(map[string]bool)
	for _, n := range names {
		req := connect.NewRequest(&corev1.AddMemberRequest{MessId: messID, DisplayName: n})
		auth(req, messID)
		res, err := core.AddMember(ctx, req)
		if err != nil {
			t.Fatalf("AddMember(%s): %v", n, err)
		}
		link := res.Msg.GetInviteLink()
		if link == "" {
			t.Fatalf("AddMember(%s) returned no invite link", n)
		}
		if links[link] {
			t.Fatalf("AddMember(%s) reused an invite link", n)
		}
		links[link] = true
		if got := res.Msg.GetMember().GetInviteState(); got != corev1.InviteState_INVITE_STATE_SENT {
			t.Errorf("%s invite state = %v, want SENT", n, got)
		}
	}
	if len(links) != 7 {
		t.Fatalf("collected %d distinct invite links, want 7", len(links))
	}

	// ── the mess reads back ────────────────────────────────────────────
	listReq := connect.NewRequest(&corev1.ListMembersRequest{MessId: messID})
	auth(listReq, messID)
	list, err := core.ListMembers(ctx, listReq)
	if err != nil {
		t.Fatalf("ListMembers: %v", err)
	}
	// Seven members plus the manager's own membership.
	if n := len(list.Msg.GetMembers()); n != 8 {
		t.Errorf("members = %d, want 8 (7 added + the manager)", n)
	}

	t.Run("a member cannot add members", func(t *testing.T) {
		// Task 04.7: MANAGER writes, MEMBER reads.
		memberReq := connect.NewRequest(&corev1.AddMemberRequest{
			MessId: messID, DisplayName: "smuggled",
		})
		memberReq.Header().Set(transport.HeaderAuthorization, "Bearer dev:dev-member")
		memberReq.Header().Set(transport.HeaderTenantID, messID)
		_, err := core.AddMember(ctx, memberReq)
		if got := connect.CodeOf(err); got != connect.CodePermissionDenied {
			t.Fatalf("code = %v, want permission_denied", got)
		}
	})

	t.Run("mess_id in the body cannot override the authorised scope", func(t *testing.T) {
		req := connect.NewRequest(&corev1.AddMemberRequest{
			MessId: "99999999-9999-9999-9999-999999999999", DisplayName: "elsewhere",
		})
		auth(req, messID)
		_, err := core.AddMember(ctx, req)
		if got := connect.CodeOf(err); got != connect.CodePermissionDenied {
			t.Fatalf("code = %v, want permission_denied", got)
		}
	})
}

// newAPI spins the whole stack on a throwaway database and returns a
// generated client for it.
func newAPI(ctx context.Context, t *testing.T, dbName, firebaseUID, userID string) (corev1connect.CoreServiceClient, func()) {
	t.Helper()

	owner, appDSN := dbtest.NewTestDatabase(ctx, t, dbName)
	seedUser(ctx, t, owner, userID, firebaseUID)

	pool, err := pgxpool.New(ctx, appDSN)
	if err != nil {
		t.Fatalf("pool: %v", err)
	}

	t.Setenv("APP_ENV", "dev")
	verifier, err := transport.NewDevVerifier()
	if err != nil {
		t.Fatalf("verifier: %v", err)
	}

	mux := http.NewServeMux()
	transport.Register(mux, transport.Deps{
		Pool:        pool,
		Logger:      slog.New(slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{Level: slog.LevelError})),
		Verifier:    verifier,
		RateLimiter: transport.NewRateLimiter(1000, 1000),
		Timeout:     30 * time.Second,
	})
	srv := httptest.NewServer(mux)

	return corev1connect.NewCoreServiceClient(srv.Client(), srv.URL), func() {
		srv.Close()
		pool.Close()
	}
}

func seedUser(ctx context.Context, t *testing.T, conn *pgx.Conn, userID, firebaseUID string) {
	t.Helper()
	if _, err := conn.Exec(ctx, fmt.Sprintf(
		`INSERT INTO users (id, firebase_uid, name, locale) VALUES ('%s', '%s', 'ম্যানেজার', 'bn')`,
		userID, firebaseUID)); err != nil {
		t.Fatalf("seed user: %v", err)
	}
}
