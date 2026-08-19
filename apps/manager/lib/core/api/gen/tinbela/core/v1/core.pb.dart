// This is a generated file - do not edit.
//
// Generated from tinbela/core/v1/core.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $0;
import 'core.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'core.pbenum.dart';

class User extends $pb.GeneratedMessage {
  factory User({
    $core.String? id,
    $core.String? name,
    $core.String? phoneE164,
    $core.String? locale,
    $core.bool? useBanglaNumerals,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (phoneE164 != null) result.phoneE164 = phoneE164;
    if (locale != null) result.locale = locale;
    if (useBanglaNumerals != null) result.useBanglaNumerals = useBanglaNumerals;
    return result;
  }

  User._();

  factory User.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory User.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'User',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'phoneE164')
    ..aOS(4, _omitFieldNames ? '' : 'locale')
    ..aOB(5, _omitFieldNames ? '' : 'useBanglaNumerals')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User copyWith(void Function(User) updates) =>
      super.copyWith((message) => updates(message as User)) as User;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  @$core.override
  User createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static User getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get phoneE164 => $_getSZ(2);
  @$pb.TagNumber(3)
  set phoneE164($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPhoneE164() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhoneE164() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get locale => $_getSZ(3);
  @$pb.TagNumber(4)
  set locale($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLocale() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocale() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get useBanglaNumerals => $_getBF(4);
  @$pb.TagNumber(5)
  set useBanglaNumerals($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUseBanglaNumerals() => $_has(4);
  @$pb.TagNumber(5)
  void clearUseBanglaNumerals() => $_clearField(5);
}

class Mess extends $pb.GeneratedMessage {
  factory Mess({
    $core.String? id,
    $core.String? name,
    TenantKind? kind,
    $core.Iterable<Slot>? slots,
    $core.String? currentPeriodId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (kind != null) result.kind = kind;
    if (slots != null) result.slots.addAll(slots);
    if (currentPeriodId != null) result.currentPeriodId = currentPeriodId;
    return result;
  }

  Mess._();

  factory Mess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Mess.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Mess',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aE<TenantKind>(3, _omitFieldNames ? '' : 'kind',
        enumValues: TenantKind.values)
    ..pPM<Slot>(4, _omitFieldNames ? '' : 'slots', subBuilder: Slot.create)
    ..aOS(5, _omitFieldNames ? '' : 'currentPeriodId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Mess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Mess copyWith(void Function(Mess) updates) =>
      super.copyWith((message) => updates(message as Mess)) as Mess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Mess create() => Mess._();
  @$core.override
  Mess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Mess getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Mess>(create);
  static Mess? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  TenantKind get kind => $_getN(2);
  @$pb.TagNumber(3)
  set kind(TenantKind value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<Slot> get slots => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get currentPeriodId => $_getSZ(4);
  @$pb.TagNumber(5)
  set currentPeriodId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCurrentPeriodId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCurrentPeriodId() => $_clearField(5);
}

class Slot extends $pb.GeneratedMessage {
  factory Slot({
    $core.String? id,
    $core.String? nameBn,
    $core.String? nameEn,
    $core.int? sortOrder,
    $core.String? cutoffLocal,
    $core.bool? active,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (nameBn != null) result.nameBn = nameBn;
    if (nameEn != null) result.nameEn = nameEn;
    if (sortOrder != null) result.sortOrder = sortOrder;
    if (cutoffLocal != null) result.cutoffLocal = cutoffLocal;
    if (active != null) result.active = active;
    return result;
  }

  Slot._();

  factory Slot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Slot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Slot',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'nameBn')
    ..aOS(3, _omitFieldNames ? '' : 'nameEn')
    ..aI(4, _omitFieldNames ? '' : 'sortOrder')
    ..aOS(5, _omitFieldNames ? '' : 'cutoffLocal')
    ..aOB(6, _omitFieldNames ? '' : 'active')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Slot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Slot copyWith(void Function(Slot) updates) =>
      super.copyWith((message) => updates(message as Slot)) as Slot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Slot create() => Slot._();
  @$core.override
  Slot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Slot getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Slot>(create);
  static Slot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nameBn => $_getSZ(1);
  @$pb.TagNumber(2)
  set nameBn($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNameBn() => $_has(1);
  @$pb.TagNumber(2)
  void clearNameBn() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get nameEn => $_getSZ(2);
  @$pb.TagNumber(3)
  set nameEn($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNameEn() => $_has(2);
  @$pb.TagNumber(3)
  void clearNameEn() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get sortOrder => $_getIZ(3);
  @$pb.TagNumber(4)
  set sortOrder($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSortOrder() => $_has(3);
  @$pb.TagNumber(4)
  void clearSortOrder() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cutoffLocal => $_getSZ(4);
  @$pb.TagNumber(5)
  set cutoffLocal($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCutoffLocal() => $_has(4);
  @$pb.TagNumber(5)
  void clearCutoffLocal() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get active => $_getBF(5);
  @$pb.TagNumber(6)
  set active($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActive() => $_has(5);
  @$pb.TagNumber(6)
  void clearActive() => $_clearField(6);
}

class Member extends $pb.GeneratedMessage {
  factory Member({
    $core.String? id,
    $core.String? displayName,
    $core.String? phoneE164,
    Role? role,
    $0.Date? joinedAt,
    $0.Date? leftAt,
    InviteState? inviteState,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (displayName != null) result.displayName = displayName;
    if (phoneE164 != null) result.phoneE164 = phoneE164;
    if (role != null) result.role = role;
    if (joinedAt != null) result.joinedAt = joinedAt;
    if (leftAt != null) result.leftAt = leftAt;
    if (inviteState != null) result.inviteState = inviteState;
    return result;
  }

  Member._();

  factory Member.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Member.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Member',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'phoneE164')
    ..aE<Role>(4, _omitFieldNames ? '' : 'role', enumValues: Role.values)
    ..aOM<$0.Date>(5, _omitFieldNames ? '' : 'joinedAt',
        subBuilder: $0.Date.create)
    ..aOM<$0.Date>(6, _omitFieldNames ? '' : 'leftAt',
        subBuilder: $0.Date.create)
    ..aE<InviteState>(7, _omitFieldNames ? '' : 'inviteState',
        enumValues: InviteState.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Member clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Member copyWith(void Function(Member) updates) =>
      super.copyWith((message) => updates(message as Member)) as Member;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Member create() => Member._();
  @$core.override
  Member createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Member getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Member>(create);
  static Member? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get phoneE164 => $_getSZ(2);
  @$pb.TagNumber(3)
  set phoneE164($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPhoneE164() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhoneE164() => $_clearField(3);

  @$pb.TagNumber(4)
  Role get role => $_getN(3);
  @$pb.TagNumber(4)
  set role(Role value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearRole() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Date get joinedAt => $_getN(4);
  @$pb.TagNumber(5)
  set joinedAt($0.Date value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasJoinedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearJoinedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Date ensureJoinedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.Date get leftAt => $_getN(5);
  @$pb.TagNumber(6)
  set leftAt($0.Date value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasLeftAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearLeftAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Date ensureLeftAt() => $_ensure(5);

  @$pb.TagNumber(7)
  InviteState get inviteState => $_getN(6);
  @$pb.TagNumber(7)
  set inviteState(InviteState value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasInviteState() => $_has(6);
  @$pb.TagNumber(7)
  void clearInviteState() => $_clearField(7);
}

class GetMeRequest extends $pb.GeneratedMessage {
  factory GetMeRequest() => create();

  GetMeRequest._();

  factory GetMeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMeRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMeRequest copyWith(void Function(GetMeRequest) updates) =>
      super.copyWith((message) => updates(message as GetMeRequest))
          as GetMeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMeRequest create() => GetMeRequest._();
  @$core.override
  GetMeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMeRequest>(create);
  static GetMeRequest? _defaultInstance;
}

class GetMeResponse extends $pb.GeneratedMessage {
  factory GetMeResponse({
    User? user,
    $core.Iterable<Mess>? messes,
  }) {
    final result = create();
    if (user != null) result.user = user;
    if (messes != null) result.messes.addAll(messes);
    return result;
  }

  GetMeResponse._();

  factory GetMeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMeResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOM<User>(1, _omitFieldNames ? '' : 'user', subBuilder: User.create)
    ..pPM<Mess>(2, _omitFieldNames ? '' : 'messes', subBuilder: Mess.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMeResponse copyWith(void Function(GetMeResponse) updates) =>
      super.copyWith((message) => updates(message as GetMeResponse))
          as GetMeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMeResponse create() => GetMeResponse._();
  @$core.override
  GetMeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMeResponse>(create);
  static GetMeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  User get user => $_getN(0);
  @$pb.TagNumber(1)
  set user(User value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => $_clearField(1);
  @$pb.TagNumber(1)
  User ensureUser() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Mess> get messes => $_getList(1);
}

class CreateMessRequest extends $pb.GeneratedMessage {
  factory CreateMessRequest({
    $core.String? name,
    TenantKind? kind,
    $core.int? slotCount,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (kind != null) result.kind = kind;
    if (slotCount != null) result.slotCount = slotCount;
    return result;
  }

  CreateMessRequest._();

  factory CreateMessRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateMessRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateMessRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aE<TenantKind>(2, _omitFieldNames ? '' : 'kind',
        enumValues: TenantKind.values)
    ..aI(3, _omitFieldNames ? '' : 'slotCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMessRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMessRequest copyWith(void Function(CreateMessRequest) updates) =>
      super.copyWith((message) => updates(message as CreateMessRequest))
          as CreateMessRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateMessRequest create() => CreateMessRequest._();
  @$core.override
  CreateMessRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateMessRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateMessRequest>(create);
  static CreateMessRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  TenantKind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(TenantKind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get slotCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set slotCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSlotCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearSlotCount() => $_clearField(3);
}

class CreateMessResponse extends $pb.GeneratedMessage {
  factory CreateMessResponse({
    Mess? mess,
    $core.String? inviteLink,
  }) {
    final result = create();
    if (mess != null) result.mess = mess;
    if (inviteLink != null) result.inviteLink = inviteLink;
    return result;
  }

  CreateMessResponse._();

  factory CreateMessResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateMessResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateMessResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOM<Mess>(1, _omitFieldNames ? '' : 'mess', subBuilder: Mess.create)
    ..aOS(2, _omitFieldNames ? '' : 'inviteLink')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMessResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMessResponse copyWith(void Function(CreateMessResponse) updates) =>
      super.copyWith((message) => updates(message as CreateMessResponse))
          as CreateMessResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateMessResponse create() => CreateMessResponse._();
  @$core.override
  CreateMessResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateMessResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateMessResponse>(create);
  static CreateMessResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Mess get mess => $_getN(0);
  @$pb.TagNumber(1)
  set mess(Mess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMess() => $_has(0);
  @$pb.TagNumber(1)
  void clearMess() => $_clearField(1);
  @$pb.TagNumber(1)
  Mess ensureMess() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get inviteLink => $_getSZ(1);
  @$pb.TagNumber(2)
  set inviteLink($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInviteLink() => $_has(1);
  @$pb.TagNumber(2)
  void clearInviteLink() => $_clearField(2);
}

class AddMemberRequest extends $pb.GeneratedMessage {
  factory AddMemberRequest({
    $core.String? messId,
    $core.String? displayName,
    $core.String? phoneE164,
  }) {
    final result = create();
    if (messId != null) result.messId = messId;
    if (displayName != null) result.displayName = displayName;
    if (phoneE164 != null) result.phoneE164 = phoneE164;
    return result;
  }

  AddMemberRequest._();

  factory AddMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddMemberRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'phoneE164')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMemberRequest copyWith(void Function(AddMemberRequest) updates) =>
      super.copyWith((message) => updates(message as AddMemberRequest))
          as AddMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMemberRequest create() => AddMemberRequest._();
  @$core.override
  AddMemberRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddMemberRequest>(create);
  static AddMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get phoneE164 => $_getSZ(2);
  @$pb.TagNumber(3)
  set phoneE164($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPhoneE164() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhoneE164() => $_clearField(3);
}

class AddMemberResponse extends $pb.GeneratedMessage {
  factory AddMemberResponse({
    Member? member,
    $core.String? inviteLink,
  }) {
    final result = create();
    if (member != null) result.member = member;
    if (inviteLink != null) result.inviteLink = inviteLink;
    return result;
  }

  AddMemberResponse._();

  factory AddMemberResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddMemberResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddMemberResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOM<Member>(1, _omitFieldNames ? '' : 'member', subBuilder: Member.create)
    ..aOS(2, _omitFieldNames ? '' : 'inviteLink')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMemberResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMemberResponse copyWith(void Function(AddMemberResponse) updates) =>
      super.copyWith((message) => updates(message as AddMemberResponse))
          as AddMemberResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMemberResponse create() => AddMemberResponse._();
  @$core.override
  AddMemberResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddMemberResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddMemberResponse>(create);
  static AddMemberResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Member get member => $_getN(0);
  @$pb.TagNumber(1)
  set member(Member value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMember() => $_has(0);
  @$pb.TagNumber(1)
  void clearMember() => $_clearField(1);
  @$pb.TagNumber(1)
  Member ensureMember() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get inviteLink => $_getSZ(1);
  @$pb.TagNumber(2)
  set inviteLink($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInviteLink() => $_has(1);
  @$pb.TagNumber(2)
  void clearInviteLink() => $_clearField(2);
}

class ListMembersRequest extends $pb.GeneratedMessage {
  factory ListMembersRequest({
    $core.String? messId,
  }) {
    final result = create();
    if (messId != null) result.messId = messId;
    return result;
  }

  ListMembersRequest._();

  factory ListMembersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListMembersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMembersRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMembersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMembersRequest copyWith(void Function(ListMembersRequest) updates) =>
      super.copyWith((message) => updates(message as ListMembersRequest))
          as ListMembersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMembersRequest create() => ListMembersRequest._();
  @$core.override
  ListMembersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListMembersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMembersRequest>(create);
  static ListMembersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessId() => $_clearField(1);
}

class ListMembersResponse extends $pb.GeneratedMessage {
  factory ListMembersResponse({
    $core.Iterable<Member>? members,
  }) {
    final result = create();
    if (members != null) result.members.addAll(members);
    return result;
  }

  ListMembersResponse._();

  factory ListMembersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListMembersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMembersResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..pPM<Member>(1, _omitFieldNames ? '' : 'members',
        subBuilder: Member.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMembersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMembersResponse copyWith(void Function(ListMembersResponse) updates) =>
      super.copyWith((message) => updates(message as ListMembersResponse))
          as ListMembersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMembersResponse create() => ListMembersResponse._();
  @$core.override
  ListMembersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListMembersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMembersResponse>(create);
  static ListMembersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Member> get members => $_getList(0);
}

class CoreServiceApi {
  final $pb.RpcClient _client;

  CoreServiceApi(this._client);

  $async.Future<GetMeResponse> getMe(
          $pb.ClientContext? ctx, GetMeRequest request) =>
      _client.invoke<GetMeResponse>(
          ctx, 'CoreService', 'GetMe', request, GetMeResponse());
  $async.Future<CreateMessResponse> createMess(
          $pb.ClientContext? ctx, CreateMessRequest request) =>
      _client.invoke<CreateMessResponse>(
          ctx, 'CoreService', 'CreateMess', request, CreateMessResponse());
  $async.Future<AddMemberResponse> addMember(
          $pb.ClientContext? ctx, AddMemberRequest request) =>
      _client.invoke<AddMemberResponse>(
          ctx, 'CoreService', 'AddMember', request, AddMemberResponse());
  $async.Future<ListMembersResponse> listMembers(
          $pb.ClientContext? ctx, ListMembersRequest request) =>
      _client.invoke<ListMembersResponse>(
          ctx, 'CoreService', 'ListMembers', request, ListMembersResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
