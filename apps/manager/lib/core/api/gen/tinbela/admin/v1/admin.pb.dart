// This is a generated file - do not edit.
//
// Generated from tinbela/admin/v1/admin.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ListTenantsRequest extends $pb.GeneratedMessage {
  factory ListTenantsRequest({
    $core.String? query,
    $core.int? page,
    $core.int? pageSize,
  }) {
    final result = create();
    if (query != null) result.query = query;
    if (page != null) result.page = page;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  ListTenantsRequest._();

  factory ListTenantsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTenantsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTenantsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aI(2, _omitFieldNames ? '' : 'page')
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTenantsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTenantsRequest copyWith(void Function(ListTenantsRequest) updates) =>
      super.copyWith((message) => updates(message as ListTenantsRequest))
          as ListTenantsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTenantsRequest create() => ListTenantsRequest._();
  @$core.override
  ListTenantsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTenantsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTenantsRequest>(create);
  static ListTenantsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get page => $_getIZ(1);
  @$pb.TagNumber(2)
  set page($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPage() => $_has(1);
  @$pb.TagNumber(2)
  void clearPage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);
}

class ListTenantsResponse extends $pb.GeneratedMessage {
  factory ListTenantsResponse({
    $core.Iterable<TenantSummary>? tenants,
    $core.int? total,
  }) {
    final result = create();
    if (tenants != null) result.tenants.addAll(tenants);
    if (total != null) result.total = total;
    return result;
  }

  ListTenantsResponse._();

  factory ListTenantsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTenantsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTenantsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..pPM<TenantSummary>(1, _omitFieldNames ? '' : 'tenants',
        subBuilder: TenantSummary.create)
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTenantsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTenantsResponse copyWith(void Function(ListTenantsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTenantsResponse))
          as ListTenantsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTenantsResponse create() => ListTenantsResponse._();
  @$core.override
  ListTenantsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTenantsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTenantsResponse>(create);
  static ListTenantsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TenantSummary> get tenants => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

class TenantSummary extends $pb.GeneratedMessage {
  factory TenantSummary({
    $core.String? id,
    $core.String? name,
    $core.String? kind,
    $core.int? memberCount,
    $core.String? createdAt,
    $core.String? lastActivityAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (kind != null) result.kind = kind;
    if (memberCount != null) result.memberCount = memberCount;
    if (createdAt != null) result.createdAt = createdAt;
    if (lastActivityAt != null) result.lastActivityAt = lastActivityAt;
    return result;
  }

  TenantSummary._();

  factory TenantSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TenantSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TenantSummary',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'kind')
    ..aI(4, _omitFieldNames ? '' : 'memberCount')
    ..aOS(5, _omitFieldNames ? '' : 'createdAt')
    ..aOS(6, _omitFieldNames ? '' : 'lastActivityAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TenantSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TenantSummary copyWith(void Function(TenantSummary) updates) =>
      super.copyWith((message) => updates(message as TenantSummary))
          as TenantSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TenantSummary create() => TenantSummary._();
  @$core.override
  TenantSummary createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TenantSummary getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TenantSummary>(create);
  static TenantSummary? _defaultInstance;

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
  $core.String get kind => $_getSZ(2);
  @$pb.TagNumber(3)
  set kind($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get memberCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set memberCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMemberCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearMemberCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get createdAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set createdAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get lastActivityAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set lastActivityAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLastActivityAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastActivityAt() => $_clearField(6);
}

class GetTenantRequest extends $pb.GeneratedMessage {
  factory GetTenantRequest({
    $core.String? tenantId,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  GetTenantRequest._();

  factory GetTenantRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTenantRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTenantRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTenantRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTenantRequest copyWith(void Function(GetTenantRequest) updates) =>
      super.copyWith((message) => updates(message as GetTenantRequest))
          as GetTenantRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTenantRequest create() => GetTenantRequest._();
  @$core.override
  GetTenantRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTenantRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTenantRequest>(create);
  static GetTenantRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);
}

class GetTenantResponse extends $pb.GeneratedMessage {
  factory GetTenantResponse({
    TenantSummary? summary,
    $core.String? membersJson,
    $core.String? ledgerJson,
    $core.String? exceptionsJson,
  }) {
    final result = create();
    if (summary != null) result.summary = summary;
    if (membersJson != null) result.membersJson = membersJson;
    if (ledgerJson != null) result.ledgerJson = ledgerJson;
    if (exceptionsJson != null) result.exceptionsJson = exceptionsJson;
    return result;
  }

  GetTenantResponse._();

  factory GetTenantResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTenantResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTenantResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..aOM<TenantSummary>(1, _omitFieldNames ? '' : 'summary',
        subBuilder: TenantSummary.create)
    ..aOS(2, _omitFieldNames ? '' : 'membersJson')
    ..aOS(3, _omitFieldNames ? '' : 'ledgerJson')
    ..aOS(4, _omitFieldNames ? '' : 'exceptionsJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTenantResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTenantResponse copyWith(void Function(GetTenantResponse) updates) =>
      super.copyWith((message) => updates(message as GetTenantResponse))
          as GetTenantResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTenantResponse create() => GetTenantResponse._();
  @$core.override
  GetTenantResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTenantResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTenantResponse>(create);
  static GetTenantResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TenantSummary get summary => $_getN(0);
  @$pb.TagNumber(1)
  set summary(TenantSummary value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSummary() => $_has(0);
  @$pb.TagNumber(1)
  void clearSummary() => $_clearField(1);
  @$pb.TagNumber(1)
  TenantSummary ensureSummary() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get membersJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set membersJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMembersJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearMembersJson() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get ledgerJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set ledgerJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLedgerJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearLedgerJson() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get exceptionsJson => $_getSZ(3);
  @$pb.TagNumber(4)
  set exceptionsJson($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExceptionsJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearExceptionsJson() => $_clearField(4);
}

class FindUserRequest extends $pb.GeneratedMessage {
  factory FindUserRequest({
    $core.String? phoneE164,
    $core.String? firebaseUid,
  }) {
    final result = create();
    if (phoneE164 != null) result.phoneE164 = phoneE164;
    if (firebaseUid != null) result.firebaseUid = firebaseUid;
    return result;
  }

  FindUserRequest._();

  factory FindUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FindUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FindUserRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'phoneE164')
    ..aOS(2, _omitFieldNames ? '' : 'firebaseUid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FindUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FindUserRequest copyWith(void Function(FindUserRequest) updates) =>
      super.copyWith((message) => updates(message as FindUserRequest))
          as FindUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FindUserRequest create() => FindUserRequest._();
  @$core.override
  FindUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FindUserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FindUserRequest>(create);
  static FindUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get phoneE164 => $_getSZ(0);
  @$pb.TagNumber(1)
  set phoneE164($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPhoneE164() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhoneE164() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get firebaseUid => $_getSZ(1);
  @$pb.TagNumber(2)
  set firebaseUid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFirebaseUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirebaseUid() => $_clearField(2);
}

class FindUserResponse extends $pb.GeneratedMessage {
  factory FindUserResponse({
    $core.String? userJson,
  }) {
    final result = create();
    if (userJson != null) result.userJson = userJson;
    return result;
  }

  FindUserResponse._();

  factory FindUserResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FindUserResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FindUserResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FindUserResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FindUserResponse copyWith(void Function(FindUserResponse) updates) =>
      super.copyWith((message) => updates(message as FindUserResponse))
          as FindUserResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FindUserResponse create() => FindUserResponse._();
  @$core.override
  FindUserResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FindUserResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FindUserResponse>(create);
  static FindUserResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set userJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserJson() => $_clearField(1);
}

class GetMetricsRequest extends $pb.GeneratedMessage {
  factory GetMetricsRequest({
    $core.String? from,
    $core.String? to,
  }) {
    final result = create();
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    return result;
  }

  GetMetricsRequest._();

  factory GetMetricsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMetricsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMetricsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'from')
    ..aOS(2, _omitFieldNames ? '' : 'to')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricsRequest copyWith(void Function(GetMetricsRequest) updates) =>
      super.copyWith((message) => updates(message as GetMetricsRequest))
          as GetMetricsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMetricsRequest create() => GetMetricsRequest._();
  @$core.override
  GetMetricsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMetricsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMetricsRequest>(create);
  static GetMetricsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get from => $_getSZ(0);
  @$pb.TagNumber(1)
  set from($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFrom() => $_has(0);
  @$pb.TagNumber(1)
  void clearFrom() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get to => $_getSZ(1);
  @$pb.TagNumber(2)
  set to($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTo() => $_has(1);
  @$pb.TagNumber(2)
  void clearTo() => $_clearField(2);
}

class GetMetricsResponse extends $pb.GeneratedMessage {
  factory GetMetricsResponse({
    $core.int? activeMesses,
    $core.int? exceptionsToday,
    $core.int? closesThisMonth,
    $core.int? memberLinksOpened,
  }) {
    final result = create();
    if (activeMesses != null) result.activeMesses = activeMesses;
    if (exceptionsToday != null) result.exceptionsToday = exceptionsToday;
    if (closesThisMonth != null) result.closesThisMonth = closesThisMonth;
    if (memberLinksOpened != null) result.memberLinksOpened = memberLinksOpened;
    return result;
  }

  GetMetricsResponse._();

  factory GetMetricsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMetricsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMetricsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'activeMesses')
    ..aI(2, _omitFieldNames ? '' : 'exceptionsToday')
    ..aI(3, _omitFieldNames ? '' : 'closesThisMonth')
    ..aI(4, _omitFieldNames ? '' : 'memberLinksOpened')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMetricsResponse copyWith(void Function(GetMetricsResponse) updates) =>
      super.copyWith((message) => updates(message as GetMetricsResponse))
          as GetMetricsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMetricsResponse create() => GetMetricsResponse._();
  @$core.override
  GetMetricsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMetricsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMetricsResponse>(create);
  static GetMetricsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get activeMesses => $_getIZ(0);
  @$pb.TagNumber(1)
  set activeMesses($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActiveMesses() => $_has(0);
  @$pb.TagNumber(1)
  void clearActiveMesses() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get exceptionsToday => $_getIZ(1);
  @$pb.TagNumber(2)
  set exceptionsToday($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExceptionsToday() => $_has(1);
  @$pb.TagNumber(2)
  void clearExceptionsToday() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get closesThisMonth => $_getIZ(2);
  @$pb.TagNumber(3)
  set closesThisMonth($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClosesThisMonth() => $_has(2);
  @$pb.TagNumber(3)
  void clearClosesThisMonth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get memberLinksOpened => $_getIZ(3);
  @$pb.TagNumber(4)
  set memberLinksOpened($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMemberLinksOpened() => $_has(3);
  @$pb.TagNumber(4)
  void clearMemberLinksOpened() => $_clearField(4);
}

class GetFlagsRequest extends $pb.GeneratedMessage {
  factory GetFlagsRequest() => create();

  GetFlagsRequest._();

  factory GetFlagsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFlagsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFlagsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFlagsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFlagsRequest copyWith(void Function(GetFlagsRequest) updates) =>
      super.copyWith((message) => updates(message as GetFlagsRequest))
          as GetFlagsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFlagsRequest create() => GetFlagsRequest._();
  @$core.override
  GetFlagsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFlagsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFlagsRequest>(create);
  static GetFlagsRequest? _defaultInstance;
}

class GetFlagsResponse extends $pb.GeneratedMessage {
  factory GetFlagsResponse({
    $core.Iterable<$core.MapEntry<$core.String, $core.bool>>? flags,
  }) {
    final result = create();
    if (flags != null) result.flags.addEntries(flags);
    return result;
  }

  GetFlagsResponse._();

  factory GetFlagsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFlagsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFlagsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..m<$core.String, $core.bool>(1, _omitFieldNames ? '' : 'flags',
        entryClassName: 'GetFlagsResponse.FlagsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OB,
        packageName: const $pb.PackageName('tinbela.admin.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFlagsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFlagsResponse copyWith(void Function(GetFlagsResponse) updates) =>
      super.copyWith((message) => updates(message as GetFlagsResponse))
          as GetFlagsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFlagsResponse create() => GetFlagsResponse._();
  @$core.override
  GetFlagsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFlagsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFlagsResponse>(create);
  static GetFlagsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.bool> get flags => $_getMap(0);
}

class SetFlagRequest extends $pb.GeneratedMessage {
  factory SetFlagRequest({
    $core.String? key,
    $core.bool? value,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (value != null) result.value = value;
    return result;
  }

  SetFlagRequest._();

  factory SetFlagRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFlagRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFlagRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOB(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFlagRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFlagRequest copyWith(void Function(SetFlagRequest) updates) =>
      super.copyWith((message) => updates(message as SetFlagRequest))
          as SetFlagRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFlagRequest create() => SetFlagRequest._();
  @$core.override
  SetFlagRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetFlagRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFlagRequest>(create);
  static SetFlagRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get value => $_getBF(1);
  @$pb.TagNumber(2)
  set value($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class SetFlagResponse extends $pb.GeneratedMessage {
  factory SetFlagResponse() => create();

  SetFlagResponse._();

  factory SetFlagResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFlagResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFlagResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.admin.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFlagResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFlagResponse copyWith(void Function(SetFlagResponse) updates) =>
      super.copyWith((message) => updates(message as SetFlagResponse))
          as SetFlagResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFlagResponse create() => SetFlagResponse._();
  @$core.override
  SetFlagResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetFlagResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFlagResponse>(create);
  static SetFlagResponse? _defaultInstance;
}

/// READ-ONLY on customer data. The admin portal is a window, not a lever.
/// The only writes in this service are feature flags.
class AdminServiceApi {
  final $pb.RpcClient _client;

  AdminServiceApi(this._client);

  $async.Future<ListTenantsResponse> listTenants(
          $pb.ClientContext? ctx, ListTenantsRequest request) =>
      _client.invoke<ListTenantsResponse>(
          ctx, 'AdminService', 'ListTenants', request, ListTenantsResponse());
  $async.Future<GetTenantResponse> getTenant(
          $pb.ClientContext? ctx, GetTenantRequest request) =>
      _client.invoke<GetTenantResponse>(
          ctx, 'AdminService', 'GetTenant', request, GetTenantResponse());
  $async.Future<FindUserResponse> findUser(
          $pb.ClientContext? ctx, FindUserRequest request) =>
      _client.invoke<FindUserResponse>(
          ctx, 'AdminService', 'FindUser', request, FindUserResponse());
  $async.Future<GetMetricsResponse> getMetrics(
          $pb.ClientContext? ctx, GetMetricsRequest request) =>
      _client.invoke<GetMetricsResponse>(
          ctx, 'AdminService', 'GetMetrics', request, GetMetricsResponse());
  $async.Future<GetFlagsResponse> getFlags(
          $pb.ClientContext? ctx, GetFlagsRequest request) =>
      _client.invoke<GetFlagsResponse>(
          ctx, 'AdminService', 'GetFlags', request, GetFlagsResponse());
  $async.Future<SetFlagResponse> setFlag(
          $pb.ClientContext? ctx, SetFlagRequest request) =>
      _client.invoke<SetFlagResponse>(
          ctx, 'AdminService', 'SetFlag', request, SetFlagResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
