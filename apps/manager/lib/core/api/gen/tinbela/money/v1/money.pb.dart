// This is a generated file - do not edit.
//
// Generated from tinbela/money/v1/money.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../core/v1/common.pb.dart' as $0;
import 'money.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'money.pbenum.dart';

class AddLedgerEntryRequest extends $pb.GeneratedMessage {
  factory AddLedgerEntryRequest({
    $core.String? messId,
    EntryKind? kind,
    $fixnum.Int64? amountPaisa,
    $core.String? category,
    $core.String? membershipId,
    $0.Date? occurredOn,
    $core.String? note,
  }) {
    final result = create();
    if (messId != null) result.messId = messId;
    if (kind != null) result.kind = kind;
    if (amountPaisa != null) result.amountPaisa = amountPaisa;
    if (category != null) result.category = category;
    if (membershipId != null) result.membershipId = membershipId;
    if (occurredOn != null) result.occurredOn = occurredOn;
    if (note != null) result.note = note;
    return result;
  }

  AddLedgerEntryRequest._();

  factory AddLedgerEntryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddLedgerEntryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddLedgerEntryRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messId')
    ..aE<EntryKind>(2, _omitFieldNames ? '' : 'kind',
        enumValues: EntryKind.values)
    ..aInt64(3, _omitFieldNames ? '' : 'amountPaisa')
    ..aOS(4, _omitFieldNames ? '' : 'category')
    ..aOS(5, _omitFieldNames ? '' : 'membershipId')
    ..aOM<$0.Date>(6, _omitFieldNames ? '' : 'occurredOn',
        subBuilder: $0.Date.create)
    ..aOS(7, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddLedgerEntryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddLedgerEntryRequest copyWith(
          void Function(AddLedgerEntryRequest) updates) =>
      super.copyWith((message) => updates(message as AddLedgerEntryRequest))
          as AddLedgerEntryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddLedgerEntryRequest create() => AddLedgerEntryRequest._();
  @$core.override
  AddLedgerEntryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddLedgerEntryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddLedgerEntryRequest>(create);
  static AddLedgerEntryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessId() => $_clearField(1);

  @$pb.TagNumber(2)
  EntryKind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(EntryKind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amountPaisa => $_getI64(2);
  @$pb.TagNumber(3)
  set amountPaisa($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmountPaisa() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmountPaisa() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get category => $_getSZ(3);
  @$pb.TagNumber(4)
  set category($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCategory() => $_has(3);
  @$pb.TagNumber(4)
  void clearCategory() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get membershipId => $_getSZ(4);
  @$pb.TagNumber(5)
  set membershipId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMembershipId() => $_has(4);
  @$pb.TagNumber(5)
  void clearMembershipId() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Date get occurredOn => $_getN(5);
  @$pb.TagNumber(6)
  set occurredOn($0.Date value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasOccurredOn() => $_has(5);
  @$pb.TagNumber(6)
  void clearOccurredOn() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Date ensureOccurredOn() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get note => $_getSZ(6);
  @$pb.TagNumber(7)
  set note($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNote() => $_has(6);
  @$pb.TagNumber(7)
  void clearNote() => $_clearField(7);
}

class AddLedgerEntryResponse extends $pb.GeneratedMessage {
  factory AddLedgerEntryResponse({
    LedgerEntry? entry,
  }) {
    final result = create();
    if (entry != null) result.entry = entry;
    return result;
  }

  AddLedgerEntryResponse._();

  factory AddLedgerEntryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddLedgerEntryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddLedgerEntryResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOM<LedgerEntry>(1, _omitFieldNames ? '' : 'entry',
        subBuilder: LedgerEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddLedgerEntryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddLedgerEntryResponse copyWith(
          void Function(AddLedgerEntryResponse) updates) =>
      super.copyWith((message) => updates(message as AddLedgerEntryResponse))
          as AddLedgerEntryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddLedgerEntryResponse create() => AddLedgerEntryResponse._();
  @$core.override
  AddLedgerEntryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddLedgerEntryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddLedgerEntryResponse>(create);
  static AddLedgerEntryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LedgerEntry get entry => $_getN(0);
  @$pb.TagNumber(1)
  set entry(LedgerEntry value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntry() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntry() => $_clearField(1);
  @$pb.TagNumber(1)
  LedgerEntry ensureEntry() => $_ensure(0);
}

class LedgerEntry extends $pb.GeneratedMessage {
  factory LedgerEntry({
    $core.String? id,
    EntryKind? kind,
    $0.Money? amount,
    $core.String? category,
    $core.String? membershipId,
    $core.String? memberDisplayName,
    $0.Date? occurredOn,
    $core.String? note,
    $core.String? enteredByName,
    $core.bool? voided,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (kind != null) result.kind = kind;
    if (amount != null) result.amount = amount;
    if (category != null) result.category = category;
    if (membershipId != null) result.membershipId = membershipId;
    if (memberDisplayName != null) result.memberDisplayName = memberDisplayName;
    if (occurredOn != null) result.occurredOn = occurredOn;
    if (note != null) result.note = note;
    if (enteredByName != null) result.enteredByName = enteredByName;
    if (voided != null) result.voided = voided;
    return result;
  }

  LedgerEntry._();

  factory LedgerEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LedgerEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LedgerEntry',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<EntryKind>(2, _omitFieldNames ? '' : 'kind',
        enumValues: EntryKind.values)
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'amount',
        subBuilder: $0.Money.create)
    ..aOS(4, _omitFieldNames ? '' : 'category')
    ..aOS(5, _omitFieldNames ? '' : 'membershipId')
    ..aOS(6, _omitFieldNames ? '' : 'memberDisplayName')
    ..aOM<$0.Date>(7, _omitFieldNames ? '' : 'occurredOn',
        subBuilder: $0.Date.create)
    ..aOS(8, _omitFieldNames ? '' : 'note')
    ..aOS(9, _omitFieldNames ? '' : 'enteredByName')
    ..aOB(10, _omitFieldNames ? '' : 'voided')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LedgerEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LedgerEntry copyWith(void Function(LedgerEntry) updates) =>
      super.copyWith((message) => updates(message as LedgerEntry))
          as LedgerEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LedgerEntry create() => LedgerEntry._();
  @$core.override
  LedgerEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LedgerEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LedgerEntry>(create);
  static LedgerEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  EntryKind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(EntryKind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Money get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($0.Money value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Money ensureAmount() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get category => $_getSZ(3);
  @$pb.TagNumber(4)
  set category($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCategory() => $_has(3);
  @$pb.TagNumber(4)
  void clearCategory() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get membershipId => $_getSZ(4);
  @$pb.TagNumber(5)
  set membershipId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMembershipId() => $_has(4);
  @$pb.TagNumber(5)
  void clearMembershipId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get memberDisplayName => $_getSZ(5);
  @$pb.TagNumber(6)
  set memberDisplayName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMemberDisplayName() => $_has(5);
  @$pb.TagNumber(6)
  void clearMemberDisplayName() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Date get occurredOn => $_getN(6);
  @$pb.TagNumber(7)
  set occurredOn($0.Date value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasOccurredOn() => $_has(6);
  @$pb.TagNumber(7)
  void clearOccurredOn() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Date ensureOccurredOn() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get note => $_getSZ(7);
  @$pb.TagNumber(8)
  set note($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNote() => $_has(7);
  @$pb.TagNumber(8)
  void clearNote() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get enteredByName => $_getSZ(8);
  @$pb.TagNumber(9)
  set enteredByName($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasEnteredByName() => $_has(8);
  @$pb.TagNumber(9)
  void clearEnteredByName() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get voided => $_getBF(9);
  @$pb.TagNumber(10)
  set voided($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasVoided() => $_has(9);
  @$pb.TagNumber(10)
  void clearVoided() => $_clearField(10);
}

class VoidLedgerEntryRequest extends $pb.GeneratedMessage {
  factory VoidLedgerEntryRequest({
    $core.String? messId,
    $core.String? entryId,
  }) {
    final result = create();
    if (messId != null) result.messId = messId;
    if (entryId != null) result.entryId = entryId;
    return result;
  }

  VoidLedgerEntryRequest._();

  factory VoidLedgerEntryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VoidLedgerEntryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoidLedgerEntryRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messId')
    ..aOS(2, _omitFieldNames ? '' : 'entryId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoidLedgerEntryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoidLedgerEntryRequest copyWith(
          void Function(VoidLedgerEntryRequest) updates) =>
      super.copyWith((message) => updates(message as VoidLedgerEntryRequest))
          as VoidLedgerEntryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoidLedgerEntryRequest create() => VoidLedgerEntryRequest._();
  @$core.override
  VoidLedgerEntryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VoidLedgerEntryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VoidLedgerEntryRequest>(create);
  static VoidLedgerEntryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get entryId => $_getSZ(1);
  @$pb.TagNumber(2)
  set entryId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEntryId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntryId() => $_clearField(2);
}

class VoidLedgerEntryResponse extends $pb.GeneratedMessage {
  factory VoidLedgerEntryResponse() => create();

  VoidLedgerEntryResponse._();

  factory VoidLedgerEntryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VoidLedgerEntryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoidLedgerEntryResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoidLedgerEntryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoidLedgerEntryResponse copyWith(
          void Function(VoidLedgerEntryResponse) updates) =>
      super.copyWith((message) => updates(message as VoidLedgerEntryResponse))
          as VoidLedgerEntryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoidLedgerEntryResponse create() => VoidLedgerEntryResponse._();
  @$core.override
  VoidLedgerEntryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VoidLedgerEntryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VoidLedgerEntryResponse>(create);
  static VoidLedgerEntryResponse? _defaultInstance;
}

/// Every Money field below carries its MathExplain. That is non-negotiable.
class GetAccountsRequest extends $pb.GeneratedMessage {
  factory GetAccountsRequest({
    $core.String? messId,
    $core.String? periodId,
  }) {
    final result = create();
    if (messId != null) result.messId = messId;
    if (periodId != null) result.periodId = periodId;
    return result;
  }

  GetAccountsRequest._();

  factory GetAccountsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAccountsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAccountsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messId')
    ..aOS(2, _omitFieldNames ? '' : 'periodId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAccountsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAccountsRequest copyWith(void Function(GetAccountsRequest) updates) =>
      super.copyWith((message) => updates(message as GetAccountsRequest))
          as GetAccountsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAccountsRequest create() => GetAccountsRequest._();
  @$core.override
  GetAccountsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAccountsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAccountsRequest>(create);
  static GetAccountsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get periodId => $_getSZ(1);
  @$pb.TagNumber(2)
  set periodId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeriodId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeriodId() => $_clearField(2);
}

class GetAccountsResponse extends $pb.GeneratedMessage {
  factory GetAccountsResponse({
    $0.Money? mealRate,
    $0.Money? totalFood,
    $0.Money? totalDeposits,
    $core.int? totalMeals,
    $0.Money? remainder,
    $core.Iterable<MemberBalance>? members,
  }) {
    final result = create();
    if (mealRate != null) result.mealRate = mealRate;
    if (totalFood != null) result.totalFood = totalFood;
    if (totalDeposits != null) result.totalDeposits = totalDeposits;
    if (totalMeals != null) result.totalMeals = totalMeals;
    if (remainder != null) result.remainder = remainder;
    if (members != null) result.members.addAll(members);
    return result;
  }

  GetAccountsResponse._();

  factory GetAccountsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAccountsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAccountsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Money>(1, _omitFieldNames ? '' : 'mealRate',
        subBuilder: $0.Money.create)
    ..aOM<$0.Money>(2, _omitFieldNames ? '' : 'totalFood',
        subBuilder: $0.Money.create)
    ..aOM<$0.Money>(3, _omitFieldNames ? '' : 'totalDeposits',
        subBuilder: $0.Money.create)
    ..aI(4, _omitFieldNames ? '' : 'totalMeals')
    ..aOM<$0.Money>(5, _omitFieldNames ? '' : 'remainder',
        subBuilder: $0.Money.create)
    ..pPM<MemberBalance>(6, _omitFieldNames ? '' : 'members',
        subBuilder: MemberBalance.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAccountsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAccountsResponse copyWith(void Function(GetAccountsResponse) updates) =>
      super.copyWith((message) => updates(message as GetAccountsResponse))
          as GetAccountsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAccountsResponse create() => GetAccountsResponse._();
  @$core.override
  GetAccountsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAccountsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAccountsResponse>(create);
  static GetAccountsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Money get mealRate => $_getN(0);
  @$pb.TagNumber(1)
  set mealRate($0.Money value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMealRate() => $_has(0);
  @$pb.TagNumber(1)
  void clearMealRate() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Money ensureMealRate() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Money get totalFood => $_getN(1);
  @$pb.TagNumber(2)
  set totalFood($0.Money value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalFood() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalFood() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Money ensureTotalFood() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.Money get totalDeposits => $_getN(2);
  @$pb.TagNumber(3)
  set totalDeposits($0.Money value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalDeposits() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalDeposits() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Money ensureTotalDeposits() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.int get totalMeals => $_getIZ(3);
  @$pb.TagNumber(4)
  set totalMeals($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalMeals() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalMeals() => $_clearField(4);

  /// The floor-division remainder. Visible, owned by the mess, never
  /// silently absorbed by a member.
  @$pb.TagNumber(5)
  $0.Money get remainder => $_getN(4);
  @$pb.TagNumber(5)
  set remainder($0.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRemainder() => $_has(4);
  @$pb.TagNumber(5)
  void clearRemainder() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Money ensureRemainder() => $_ensure(4);

  @$pb.TagNumber(6)
  $pb.PbList<MemberBalance> get members => $_getList(5);
}

class MemberBalance extends $pb.GeneratedMessage {
  factory MemberBalance({
    $core.String? membershipId,
    $core.String? displayName,
    $core.int? mealsQty,
    $0.Money? foodCost,
    $0.Money? deposits,
    $0.Money? balance,
  }) {
    final result = create();
    if (membershipId != null) result.membershipId = membershipId;
    if (displayName != null) result.displayName = displayName;
    if (mealsQty != null) result.mealsQty = mealsQty;
    if (foodCost != null) result.foodCost = foodCost;
    if (deposits != null) result.deposits = deposits;
    if (balance != null) result.balance = balance;
    return result;
  }

  MemberBalance._();

  factory MemberBalance.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MemberBalance.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MemberBalance',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'membershipId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aI(3, _omitFieldNames ? '' : 'mealsQty')
    ..aOM<$0.Money>(4, _omitFieldNames ? '' : 'foodCost',
        subBuilder: $0.Money.create)
    ..aOM<$0.Money>(5, _omitFieldNames ? '' : 'deposits',
        subBuilder: $0.Money.create)
    ..aOM<$0.Money>(6, _omitFieldNames ? '' : 'balance',
        subBuilder: $0.Money.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberBalance clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberBalance copyWith(void Function(MemberBalance) updates) =>
      super.copyWith((message) => updates(message as MemberBalance))
          as MemberBalance;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MemberBalance create() => MemberBalance._();
  @$core.override
  MemberBalance createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MemberBalance getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MemberBalance>(create);
  static MemberBalance? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get membershipId => $_getSZ(0);
  @$pb.TagNumber(1)
  set membershipId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMembershipId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMembershipId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get mealsQty => $_getIZ(2);
  @$pb.TagNumber(3)
  set mealsQty($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMealsQty() => $_has(2);
  @$pb.TagNumber(3)
  void clearMealsQty() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Money get foodCost => $_getN(3);
  @$pb.TagNumber(4)
  set foodCost($0.Money value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFoodCost() => $_has(3);
  @$pb.TagNumber(4)
  void clearFoodCost() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Money ensureFoodCost() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Money get deposits => $_getN(4);
  @$pb.TagNumber(5)
  set deposits($0.Money value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDeposits() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeposits() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Money ensureDeposits() => $_ensure(4);

  /// positive = ফেরত পাবেন · negative = দিতে হবে
  @$pb.TagNumber(6)
  $0.Money get balance => $_getN(5);
  @$pb.TagNumber(6)
  set balance($0.Money value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasBalance() => $_has(5);
  @$pb.TagNumber(6)
  void clearBalance() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Money ensureBalance() => $_ensure(5);
}

class PreviewCloseRequest extends $pb.GeneratedMessage {
  factory PreviewCloseRequest({
    $core.String? messId,
    $core.String? periodId,
  }) {
    final result = create();
    if (messId != null) result.messId = messId;
    if (periodId != null) result.periodId = periodId;
    return result;
  }

  PreviewCloseRequest._();

  factory PreviewCloseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PreviewCloseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PreviewCloseRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messId')
    ..aOS(2, _omitFieldNames ? '' : 'periodId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewCloseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewCloseRequest copyWith(void Function(PreviewCloseRequest) updates) =>
      super.copyWith((message) => updates(message as PreviewCloseRequest))
          as PreviewCloseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PreviewCloseRequest create() => PreviewCloseRequest._();
  @$core.override
  PreviewCloseRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PreviewCloseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PreviewCloseRequest>(create);
  static PreviewCloseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get periodId => $_getSZ(1);
  @$pb.TagNumber(2)
  set periodId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeriodId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeriodId() => $_clearField(2);
}

class PreviewCloseResponse extends $pb.GeneratedMessage {
  factory PreviewCloseResponse({
    GetAccountsResponse? accounts,
    $core.Iterable<$core.String>? warnings,
  }) {
    final result = create();
    if (accounts != null) result.accounts = accounts;
    if (warnings != null) result.warnings.addAll(warnings);
    return result;
  }

  PreviewCloseResponse._();

  factory PreviewCloseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PreviewCloseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PreviewCloseResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOM<GetAccountsResponse>(1, _omitFieldNames ? '' : 'accounts',
        subBuilder: GetAccountsResponse.create)
    ..pPS(2, _omitFieldNames ? '' : 'warnings')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewCloseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewCloseResponse copyWith(void Function(PreviewCloseResponse) updates) =>
      super.copyWith((message) => updates(message as PreviewCloseResponse))
          as PreviewCloseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PreviewCloseResponse create() => PreviewCloseResponse._();
  @$core.override
  PreviewCloseResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PreviewCloseResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PreviewCloseResponse>(create);
  static PreviewCloseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GetAccountsResponse get accounts => $_getN(0);
  @$pb.TagNumber(1)
  set accounts(GetAccountsResponse value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAccounts() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccounts() => $_clearField(1);
  @$pb.TagNumber(1)
  GetAccountsResponse ensureAccounts() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get warnings => $_getList(1);
}

class ClosePeriodRequest extends $pb.GeneratedMessage {
  factory ClosePeriodRequest({
    $core.String? messId,
    $core.String? periodId,
  }) {
    final result = create();
    if (messId != null) result.messId = messId;
    if (periodId != null) result.periodId = periodId;
    return result;
  }

  ClosePeriodRequest._();

  factory ClosePeriodRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClosePeriodRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClosePeriodRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messId')
    ..aOS(2, _omitFieldNames ? '' : 'periodId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClosePeriodRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClosePeriodRequest copyWith(void Function(ClosePeriodRequest) updates) =>
      super.copyWith((message) => updates(message as ClosePeriodRequest))
          as ClosePeriodRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClosePeriodRequest create() => ClosePeriodRequest._();
  @$core.override
  ClosePeriodRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClosePeriodRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClosePeriodRequest>(create);
  static ClosePeriodRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get periodId => $_getSZ(1);
  @$pb.TagNumber(2)
  set periodId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeriodId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeriodId() => $_clearField(2);
}

class ClosePeriodResponse extends $pb.GeneratedMessage {
  factory ClosePeriodResponse({
    $core.String? statementId,
    $core.String? nextPeriodId,
  }) {
    final result = create();
    if (statementId != null) result.statementId = statementId;
    if (nextPeriodId != null) result.nextPeriodId = nextPeriodId;
    return result;
  }

  ClosePeriodResponse._();

  factory ClosePeriodResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClosePeriodResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClosePeriodResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'statementId')
    ..aOS(2, _omitFieldNames ? '' : 'nextPeriodId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClosePeriodResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClosePeriodResponse copyWith(void Function(ClosePeriodResponse) updates) =>
      super.copyWith((message) => updates(message as ClosePeriodResponse))
          as ClosePeriodResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClosePeriodResponse create() => ClosePeriodResponse._();
  @$core.override
  ClosePeriodResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClosePeriodResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClosePeriodResponse>(create);
  static ClosePeriodResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get statementId => $_getSZ(0);
  @$pb.TagNumber(1)
  set statementId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatementId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatementId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nextPeriodId => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPeriodId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPeriodId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPeriodId() => $_clearField(2);
}

class GetStatementRequest extends $pb.GeneratedMessage {
  factory GetStatementRequest({
    $core.String? messId,
    $core.String? periodId,
  }) {
    final result = create();
    if (messId != null) result.messId = messId;
    if (periodId != null) result.periodId = periodId;
    return result;
  }

  GetStatementRequest._();

  factory GetStatementRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatementRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatementRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messId')
    ..aOS(2, _omitFieldNames ? '' : 'periodId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatementRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatementRequest copyWith(void Function(GetStatementRequest) updates) =>
      super.copyWith((message) => updates(message as GetStatementRequest))
          as GetStatementRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatementRequest create() => GetStatementRequest._();
  @$core.override
  GetStatementRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatementRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatementRequest>(create);
  static GetStatementRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get periodId => $_getSZ(1);
  @$pb.TagNumber(2)
  set periodId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeriodId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeriodId() => $_clearField(2);
}

class GetStatementResponse extends $pb.GeneratedMessage {
  factory GetStatementResponse({
    $core.String? periodLabel,
    GetAccountsResponse? accounts,
    $core.String? closedAt,
    $core.bool? immutable,
  }) {
    final result = create();
    if (periodLabel != null) result.periodLabel = periodLabel;
    if (accounts != null) result.accounts = accounts;
    if (closedAt != null) result.closedAt = closedAt;
    if (immutable != null) result.immutable = immutable;
    return result;
  }

  GetStatementResponse._();

  factory GetStatementResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatementResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatementResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.money.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'periodLabel')
    ..aOM<GetAccountsResponse>(2, _omitFieldNames ? '' : 'accounts',
        subBuilder: GetAccountsResponse.create)
    ..aOS(3, _omitFieldNames ? '' : 'closedAt')
    ..aOB(4, _omitFieldNames ? '' : 'immutable')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatementResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatementResponse copyWith(void Function(GetStatementResponse) updates) =>
      super.copyWith((message) => updates(message as GetStatementResponse))
          as GetStatementResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatementResponse create() => GetStatementResponse._();
  @$core.override
  GetStatementResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatementResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatementResponse>(create);
  static GetStatementResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get periodLabel => $_getSZ(0);
  @$pb.TagNumber(1)
  set periodLabel($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPeriodLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeriodLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  GetAccountsResponse get accounts => $_getN(1);
  @$pb.TagNumber(2)
  set accounts(GetAccountsResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAccounts() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccounts() => $_clearField(2);
  @$pb.TagNumber(2)
  GetAccountsResponse ensureAccounts() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get closedAt => $_getSZ(2);
  @$pb.TagNumber(3)
  set closedAt($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClosedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearClosedAt() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get immutable => $_getBF(3);
  @$pb.TagNumber(4)
  set immutable($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasImmutable() => $_has(3);
  @$pb.TagNumber(4)
  void clearImmutable() => $_clearField(4);
}

class MoneyServiceApi {
  final $pb.RpcClient _client;

  MoneyServiceApi(this._client);

  $async.Future<AddLedgerEntryResponse> addLedgerEntry(
          $pb.ClientContext? ctx, AddLedgerEntryRequest request) =>
      _client.invoke<AddLedgerEntryResponse>(ctx, 'MoneyService',
          'AddLedgerEntry', request, AddLedgerEntryResponse());
  $async.Future<VoidLedgerEntryResponse> voidLedgerEntry(
          $pb.ClientContext? ctx, VoidLedgerEntryRequest request) =>
      _client.invoke<VoidLedgerEntryResponse>(ctx, 'MoneyService',
          'VoidLedgerEntry', request, VoidLedgerEntryResponse());
  $async.Future<GetAccountsResponse> getAccounts(
          $pb.ClientContext? ctx, GetAccountsRequest request) =>
      _client.invoke<GetAccountsResponse>(
          ctx, 'MoneyService', 'GetAccounts', request, GetAccountsResponse());
  $async.Future<PreviewCloseResponse> previewClose(
          $pb.ClientContext? ctx, PreviewCloseRequest request) =>
      _client.invoke<PreviewCloseResponse>(
          ctx, 'MoneyService', 'PreviewClose', request, PreviewCloseResponse());
  $async.Future<ClosePeriodResponse> closePeriod(
          $pb.ClientContext? ctx, ClosePeriodRequest request) =>
      _client.invoke<ClosePeriodResponse>(
          ctx, 'MoneyService', 'ClosePeriod', request, ClosePeriodResponse());
  $async.Future<GetStatementResponse> getStatement(
          $pb.ClientContext? ctx, GetStatementRequest request) =>
      _client.invoke<GetStatementResponse>(
          ctx, 'MoneyService', 'GetStatement', request, GetStatementResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
