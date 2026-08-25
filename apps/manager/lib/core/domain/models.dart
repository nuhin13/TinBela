// The app's own vocabulary.
//
// These are NOT the generated protobuf types. Screens depend on this file;
// nothing above core/data imports anything from core/api. Three reasons, in
// increasing order of how much they will matter:
//
//  1. A generated type changes shape whenever the proto does. Letting those
//     reach widgets means a field rename in proto/ becomes a diff across
//     every screen.
//  2. Generated messages are mutable and have no useful equality, so a
//     widget holding one cannot be const and cannot be compared cheaply.
//  3. P6 offline sync (ADR-0012) needs rows that came from a local database
//     to be indistinguishable from rows that came from the wire. They can
//     only be indistinguishable if neither is a DTO.

/// A calendar day in Asia/Dhaka.
///
/// Deliberately not DateTime. A meal belongs to a day, not an instant, and
/// DateTime drags a timezone and a clock into a value that has neither.
/// Invariant 5: the server owns date boundaries, never the device.
class MessDate implements Comparable<MessDate> {
  const MessDate(this.value);

  /// ISO `YYYY-MM-DD`, exactly as the server sent it.
  final String value;

  @override
  int compareTo(MessDate other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is MessDate && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// What a person may do inside one mess.
///
/// v1.0 ships MANAGER and MEMBER. The others exist in the contract for P3
/// institutions (ADR-0011) and must map to [unknown] here rather than crash:
/// a client that throws on an unfamiliar enum value cannot survive a server
/// that is one deploy ahead of it.
enum MemberRole { manager, member, unknown }

/// How far along an invite is. Drives the "অপেক্ষমাণ" chip on the members
/// list (task 13.1).
enum InviteProgress { sent, opened, linked, unknown }

/// The kind of tenant. v1.0 only creates messes; the rest are P3/P4 hedges.
enum MessKind { mess, institution, home, unknown }

class User {
  const User({
    required this.id,
    required this.name,
    required this.phoneE164,
    required this.locale,
    required this.useBanglaNumerals,
  });

  final String id;
  final String name;
  final String phoneE164;

  /// 'bn' or 'en'. bn is the default and the source of truth.
  final String locale;

  /// Whether to render ১২৩ or 123. A per-user preference, not a locale
  /// consequence: plenty of bn readers prefer Latin digits for money.
  final bool useBanglaNumerals;
}

class Mess {
  const Mess({
    required this.id,
    required this.name,
    required this.kind,
    this.slots = const [],
    this.currentPeriodId,
  });

  final String id;
  final String name;
  final MessKind kind;
  final List<Slot> slots;

  /// Null when no period is open — the state right after a month closes and
  /// before the next opens. Screens must handle it rather than assume.
  final String? currentPeriodId;
}

class Slot {
  const Slot({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.sortOrder,
    required this.cutoffLocal,
    required this.active,
  });

  final String id;
  final String nameBn;
  final String nameEn;
  final int sortOrder;

  /// `HH:MM` in Asia/Dhaka. Rendered, never compared against the device
  /// clock — whether the cutoff has passed is the server's answer
  /// (Invariant 5).
  final String cutoffLocal;

  final bool active;
}

class Member {
  const Member({
    required this.id,
    required this.displayName,
    required this.role,
    this.phoneE164,
    this.joinedAt,
    this.leftAt,
    this.inviteProgress = InviteProgress.unknown,
  });

  final String id;
  final String displayName;
  final MemberRole role;

  /// Optional: a manager can add someone by name alone, before any phone
  /// number or account exists (task 04.4).
  final String? phoneE164;

  final MessDate? joinedAt;

  /// Non-null once they have left. Their prior meals still count — leaving
  /// is soft, and the statement for a closed month must not change (04.8).
  final MessDate? leftAt;

  final InviteProgress inviteProgress;

  bool get hasLeft => leftAt != null;
}

/// Who the caller is and which messes they belong to. The answer to `GetMe`.
class Session {
  const Session({required this.user, required this.messes});

  final User user;
  final List<Mess> messes;

  /// A manager with no mess yet goes to onboarding (Epic 09), not to an
  /// empty Today screen.
  bool get needsOnboarding => messes.isEmpty;
}
