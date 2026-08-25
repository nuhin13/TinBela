// The one place generated protobuf types become domain types.
//
// Everything above core/data speaks the vocabulary in core/domain. This file
// is the seam, and it is deliberately the ONLY file that imports both.
//
// Unknown enum values map to `unknown` rather than throwing. The server can
// be a deploy ahead of an installed app -- ROLE_ACCOUNTANT and the other P3
// roles are already in the contract -- and an app that crashes on a value it
// has not heard of is an app that a server deploy can brick.

import '../api/gen/tinbela/core/v1/common.pb.dart' as pb;
import '../api/gen/tinbela/core/v1/core.pb.dart' as pb;
import '../domain/models.dart';

extension UserMapper on pb.User {
  User toDomain() => User(
        id: id,
        name: name,
        phoneE164: phoneE164,
        locale: locale.isEmpty ? 'bn' : locale,
        useBanglaNumerals: useBanglaNumerals,
      );
}

extension MessMapper on pb.Mess {
  Mess toDomain() => Mess(
        id: id,
        name: name,
        kind: switch (kind) {
          pb.TenantKind.TENANT_KIND_MESS => MessKind.mess,
          pb.TenantKind.TENANT_KIND_INSTITUTION => MessKind.institution,
          pb.TenantKind.TENANT_KIND_HOME => MessKind.home,
          _ => MessKind.unknown,
        },
        slots: slots.map((s) => s.toDomain()).toList(growable: false),
        // Proto3 has no null for a string: "not set" and "" are the same
        // wire state. The domain type says null, because "no period is open"
        // is a real state screens must branch on.
        currentPeriodId: currentPeriodId.isEmpty ? null : currentPeriodId,
      );
}

extension SlotMapper on pb.Slot {
  Slot toDomain() => Slot(
        id: id,
        nameBn: nameBn,
        nameEn: nameEn,
        sortOrder: sortOrder,
        cutoffLocal: cutoffLocal,
        active: active,
      );
}

extension MemberMapper on pb.Member {
  Member toDomain() => Member(
        id: id,
        displayName: displayName,
        role: switch (role) {
          pb.Role.ROLE_MANAGER => MemberRole.manager,
          pb.Role.ROLE_MEMBER => MemberRole.member,
          _ => MemberRole.unknown,
        },
        phoneE164: phoneE164.isEmpty ? null : phoneE164,
        joinedAt: hasJoinedAt() ? joinedAt.toDomain() : null,
        leftAt: hasLeftAt() ? leftAt.toDomain() : null,
        inviteProgress: switch (inviteState) {
          pb.InviteState.INVITE_STATE_SENT => InviteProgress.sent,
          pb.InviteState.INVITE_STATE_OPENED => InviteProgress.opened,
          pb.InviteState.INVITE_STATE_LINKED => InviteProgress.linked,
          _ => InviteProgress.unknown,
        },
      );
}

extension DateMapper on pb.Date {
  MessDate toDomain() => MessDate(value);
}

extension GetMeMapper on pb.GetMeResponse {
  Session toDomain() => Session(
        user: user.toDomain(),
        messes: messes.map((m) => m.toDomain()).toList(growable: false),
      );
}
