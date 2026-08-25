// Epic 08 task 08.6 -- the repository seam.
//
// Repositories are declared as interfaces and consumed as interfaces. In
// v1.0 there is exactly one implementation of each and it goes straight to
// the network (ADR-0012: online-only; offline is the paid moat).
//
// THE SEAM IS THE POINT. P6 adds a local store, and it must arrive as a new
// implementation of these same interfaces -- a cache decorator wrapping the
// remote one -- not as an `if (offline)` inside every screen. Screens ask a
// repository a question and get domain types back; where the answer came
// from is not their business, and if it ever becomes their business the
// offline work will have to touch every feature instead of this directory.
//
// That is also why these return domain types and never DTOs: a cached row
// read from SQLite has to be indistinguishable from one that arrived on the
// wire, and it cannot be if the wire type leaks upward.

import '../api/connect_client.dart';
import '../api/gen/tinbela/core/v1/core.pb.dart' as pb;
import '../domain/models.dart';
import 'mappers.dart';

/// Who the caller is, and which messes they are in.
abstract interface class SessionRepository {
  /// Throws [ApiException] on failure -- screens branch on
  /// `ApiErrorCode`/`isRetryable` to choose between retry and re-auth
  /// (task 08.8).
  Future<Session> getMe();
}

/// Bringing a mess into existence.
abstract interface class MessesRepository {
  /// Creates the tenant, its default slots, the first open period and the
  /// manager's own membership -- atomically, server-side (task 04.3).
  ///
  /// Returns the invite link alongside the mess: it is minted once during
  /// creation and is not re-derivable by the client.
  Future<({Mess mess, String inviteLink})> create({
    required String name,
    required int slotCount,
  });
}

/// The people in one mess.
abstract interface class MembersRepository {
  Future<List<Member>> list({required String messId});

  /// Returns the new member and the invite link to share. The link is the
  /// member's only credential (ADR-0009), so it is returned once and is not
  /// re-derivable client-side.
  Future<({Member member, String inviteLink})> add({
    required String messId,
    required String displayName,
    String? phoneE164,
  });
}

// ─────────────────────────── remote implementations ───────────────────────

class RemoteSessionRepository implements SessionRepository {
  const RemoteSessionRepository(this._client);

  final ConnectClient _client;

  @override
  Future<Session> getMe() async {
    final res = await _client.unary(
      'tinbela.core.v1.CoreService/GetMe',
      pb.GetMeRequest(),
      pb.GetMeResponse.new,
    );
    return res.toDomain();
  }
}

class RemoteMessesRepository implements MessesRepository {
  const RemoteMessesRepository(this._client);

  final ConnectClient _client;

  @override
  Future<({Mess mess, String inviteLink})> create({
    required String name,
    required int slotCount,
  }) async {
    final res = await _client.unary(
      'tinbela.core.v1.CoreService/CreateMess',
      pb.CreateMessRequest(
        name: name,
        // v1.0 creates messes only. The other kinds are P3/P4 hedges that
        // exist in the contract and are never sent (ADR-0011).
        kind: pb.TenantKind.TENANT_KIND_MESS,
        slotCount: slotCount,
      ),
      pb.CreateMessResponse.new,
    );
    return (mess: res.mess.toDomain(), inviteLink: res.inviteLink);
  }
}

class RemoteMembersRepository implements MembersRepository {
  const RemoteMembersRepository(this._client);

  final ConnectClient _client;

  @override
  Future<List<Member>> list({required String messId}) async {
    final res = await _client.unary(
      'tinbela.core.v1.CoreService/ListMembers',
      pb.ListMembersRequest(messId: messId),
      pb.ListMembersResponse.new,
      tenantId: messId,
    );
    return res.members.map((m) => m.toDomain()).toList(growable: false);
  }

  @override
  Future<({Member member, String inviteLink})> add({
    required String messId,
    required String displayName,
    String? phoneE164,
  }) async {
    final res = await _client.unary(
      'tinbela.core.v1.CoreService/AddMember',
      pb.AddMemberRequest(
        messId: messId,
        displayName: displayName,
        // Proto3 has no null string; the server reads "" as "not given".
        phoneE164: phoneE164 ?? '',
      ),
      pb.AddMemberResponse.new,
      tenantId: messId,
    );
    return (member: res.member.toDomain(), inviteLink: res.inviteLink);
  }
}
