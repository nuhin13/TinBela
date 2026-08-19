// This is a generated file - do not edit.
//
// Generated from tinbela/meals/v1/meals.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../core/v1/common.pb.dart' as $0;
import 'meals.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'meals.pbenum.dart';

/// The weekly default (Law 1). A normal day needs ZERO entries.
class Pattern extends $pb.GeneratedMessage {
  factory Pattern({
    $core.String? membershipId,
    $core.String? slotId,
    $core.int? dowMask,
    $core.int? qty,
  }) {
    final result = create();
    if (membershipId != null) result.membershipId = membershipId;
    if (slotId != null) result.slotId = slotId;
    if (dowMask != null) result.dowMask = dowMask;
    if (qty != null) result.qty = qty;
    return result;
  }

  Pattern._();

  factory Pattern.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Pattern.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pattern',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.meals.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'membershipId')
    ..aOS(2, _omitFieldNames ? '' : 'slotId')
    ..aI(3, _omitFieldNames ? '' : 'dowMask')
    ..aI(4, _omitFieldNames ? '' : 'qty')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pattern clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pattern copyWith(void Function(Pattern) updates) =>
      super.copyWith((message) => updates(message as Pattern)) as Pattern;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Pattern create() => Pattern._();
  @$core.override
  Pattern createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Pattern getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Pattern>(create);
  static Pattern? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get membershipId => $_getSZ(0);
  @$pb.TagNumber(1)
  set membershipId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMembershipId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMembershipId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get slotId => $_getSZ(1);
  @$pb.TagNumber(2)
  set slotId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSlotId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSlotId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get dowMask => $_getIZ(2);
  @$pb.TagNumber(3)
  set dowMask($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDowMask() => $_has(2);
  @$pb.TagNumber(3)
  void clearDowMask() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get qty => $_getIZ(3);
  @$pb.TagNumber(4)
  set qty($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasQty() => $_has(3);
  @$pb.TagNumber(4)
  void clearQty() => $_clearField(4);
}

class SetPatternsRequest extends $pb.GeneratedMessage {
  factory SetPatternsRequest({
    $core.String? messId,
    $core.String? membershipId,
    $core.Iterable<Pattern>? patterns,
  }) {
    final result = create();
    if (messId != null) result.messId = messId;
    if (membershipId != null) result.membershipId = membershipId;
    if (patterns != null) result.patterns.addAll(patterns);
    return result;
  }

  SetPatternsRequest._();

  factory SetPatternsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetPatternsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetPatternsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.meals.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messId')
    ..aOS(2, _omitFieldNames ? '' : 'membershipId')
    ..pPM<Pattern>(3, _omitFieldNames ? '' : 'patterns',
        subBuilder: Pattern.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPatternsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPatternsRequest copyWith(void Function(SetPatternsRequest) updates) =>
      super.copyWith((message) => updates(message as SetPatternsRequest))
          as SetPatternsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetPatternsRequest create() => SetPatternsRequest._();
  @$core.override
  SetPatternsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetPatternsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetPatternsRequest>(create);
  static SetPatternsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get membershipId => $_getSZ(1);
  @$pb.TagNumber(2)
  set membershipId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMembershipId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMembershipId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<Pattern> get patterns => $_getList(2);
}

class SetPatternsResponse extends $pb.GeneratedMessage {
  factory SetPatternsResponse({
    $core.Iterable<Pattern>? patterns,
  }) {
    final result = create();
    if (patterns != null) result.patterns.addAll(patterns);
    return result;
  }

  SetPatternsResponse._();

  factory SetPatternsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetPatternsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetPatternsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.meals.v1'),
      createEmptyInstance: create)
    ..pPM<Pattern>(1, _omitFieldNames ? '' : 'patterns',
        subBuilder: Pattern.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPatternsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPatternsResponse copyWith(void Function(SetPatternsResponse) updates) =>
      super.copyWith((message) => updates(message as SetPatternsResponse))
          as SetPatternsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetPatternsResponse create() => SetPatternsResponse._();
  @$core.override
  SetPatternsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetPatternsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetPatternsResponse>(create);
  static SetPatternsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Pattern> get patterns => $_getList(0);
}

/// Law 2. Append-only — this never updates an existing row.
class CreateExceptionRequest extends $pb.GeneratedMessage {
  factory CreateExceptionRequest({
    $core.String? messId,
    $core.String? membershipId,
    $core.String? groupId,
    $core.String? slotId,
    $0.Date? dateFrom,
    $0.Date? dateTo,
    ExceptionAction? action,
    $core.int? qty,
  }) {
    final result = create();
    if (messId != null) result.messId = messId;
    if (membershipId != null) result.membershipId = membershipId;
    if (groupId != null) result.groupId = groupId;
    if (slotId != null) result.slotId = slotId;
    if (dateFrom != null) result.dateFrom = dateFrom;
    if (dateTo != null) result.dateTo = dateTo;
    if (action != null) result.action = action;
    if (qty != null) result.qty = qty;
    return result;
  }

  CreateExceptionRequest._();

  factory CreateExceptionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateExceptionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateExceptionRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.meals.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messId')
    ..aOS(2, _omitFieldNames ? '' : 'membershipId')
    ..aOS(3, _omitFieldNames ? '' : 'groupId')
    ..aOS(4, _omitFieldNames ? '' : 'slotId')
    ..aOM<$0.Date>(5, _omitFieldNames ? '' : 'dateFrom',
        subBuilder: $0.Date.create)
    ..aOM<$0.Date>(6, _omitFieldNames ? '' : 'dateTo',
        subBuilder: $0.Date.create)
    ..aE<ExceptionAction>(7, _omitFieldNames ? '' : 'action',
        enumValues: ExceptionAction.values)
    ..aI(8, _omitFieldNames ? '' : 'qty')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateExceptionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateExceptionRequest copyWith(
          void Function(CreateExceptionRequest) updates) =>
      super.copyWith((message) => updates(message as CreateExceptionRequest))
          as CreateExceptionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateExceptionRequest create() => CreateExceptionRequest._();
  @$core.override
  CreateExceptionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateExceptionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateExceptionRequest>(create);
  static CreateExceptionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get membershipId => $_getSZ(1);
  @$pb.TagNumber(2)
  set membershipId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMembershipId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMembershipId() => $_clearField(2);

  /// P3 institution mode sends this to mark a whole batch at once.
  /// The v1.0 mess app never sets it.
  @$pb.TagNumber(3)
  $core.String get groupId => $_getSZ(2);
  @$pb.TagNumber(3)
  set groupId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroupId() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get slotId => $_getSZ(3);
  @$pb.TagNumber(4)
  set slotId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSlotId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSlotId() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Date get dateFrom => $_getN(4);
  @$pb.TagNumber(5)
  set dateFrom($0.Date value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDateFrom() => $_has(4);
  @$pb.TagNumber(5)
  void clearDateFrom() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Date ensureDateFrom() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.Date get dateTo => $_getN(5);
  @$pb.TagNumber(6)
  set dateTo($0.Date value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasDateTo() => $_has(5);
  @$pb.TagNumber(6)
  void clearDateTo() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Date ensureDateTo() => $_ensure(5);

  @$pb.TagNumber(7)
  ExceptionAction get action => $_getN(6);
  @$pb.TagNumber(7)
  set action(ExceptionAction value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasAction() => $_has(6);
  @$pb.TagNumber(7)
  void clearAction() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get qty => $_getIZ(7);
  @$pb.TagNumber(8)
  set qty($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasQty() => $_has(7);
  @$pb.TagNumber(8)
  void clearQty() => $_clearField(8);
}

class CreateExceptionResponse extends $pb.GeneratedMessage {
  factory CreateExceptionResponse({
    Exception? exception,
  }) {
    final result = create();
    if (exception != null) result.exception = exception;
    return result;
  }

  CreateExceptionResponse._();

  factory CreateExceptionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateExceptionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateExceptionResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.meals.v1'),
      createEmptyInstance: create)
    ..aOM<Exception>(1, _omitFieldNames ? '' : 'exception',
        subBuilder: Exception.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateExceptionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateExceptionResponse copyWith(
          void Function(CreateExceptionResponse) updates) =>
      super.copyWith((message) => updates(message as CreateExceptionResponse))
          as CreateExceptionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateExceptionResponse create() => CreateExceptionResponse._();
  @$core.override
  CreateExceptionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateExceptionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateExceptionResponse>(create);
  static CreateExceptionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Exception get exception => $_getN(0);
  @$pb.TagNumber(1)
  set exception(Exception value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasException() => $_has(0);
  @$pb.TagNumber(1)
  void clearException() => $_clearField(1);
  @$pb.TagNumber(1)
  Exception ensureException() => $_ensure(0);
}

class Exception extends $pb.GeneratedMessage {
  factory Exception({
    $core.String? id,
    $core.String? membershipId,
    $core.String? memberDisplayName,
    $core.String? slotId,
    $0.DateRange? range,
    ExceptionAction? action,
    $core.int? qty,
    $core.String? markedByName,
    $core.bool? afterCutoff,
    $core.String? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (membershipId != null) result.membershipId = membershipId;
    if (memberDisplayName != null) result.memberDisplayName = memberDisplayName;
    if (slotId != null) result.slotId = slotId;
    if (range != null) result.range = range;
    if (action != null) result.action = action;
    if (qty != null) result.qty = qty;
    if (markedByName != null) result.markedByName = markedByName;
    if (afterCutoff != null) result.afterCutoff = afterCutoff;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  Exception._();

  factory Exception.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Exception.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Exception',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.meals.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'membershipId')
    ..aOS(3, _omitFieldNames ? '' : 'memberDisplayName')
    ..aOS(4, _omitFieldNames ? '' : 'slotId')
    ..aOM<$0.DateRange>(5, _omitFieldNames ? '' : 'range',
        subBuilder: $0.DateRange.create)
    ..aE<ExceptionAction>(6, _omitFieldNames ? '' : 'action',
        enumValues: ExceptionAction.values)
    ..aI(7, _omitFieldNames ? '' : 'qty')
    ..aOS(8, _omitFieldNames ? '' : 'markedByName')
    ..aOB(9, _omitFieldNames ? '' : 'afterCutoff')
    ..aOS(10, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Exception clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Exception copyWith(void Function(Exception) updates) =>
      super.copyWith((message) => updates(message as Exception)) as Exception;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Exception create() => Exception._();
  @$core.override
  Exception createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Exception getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Exception>(create);
  static Exception? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get membershipId => $_getSZ(1);
  @$pb.TagNumber(2)
  set membershipId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMembershipId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMembershipId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get memberDisplayName => $_getSZ(2);
  @$pb.TagNumber(3)
  set memberDisplayName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMemberDisplayName() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberDisplayName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get slotId => $_getSZ(3);
  @$pb.TagNumber(4)
  set slotId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSlotId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSlotId() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.DateRange get range => $_getN(4);
  @$pb.TagNumber(5)
  set range($0.DateRange value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRange() => $_has(4);
  @$pb.TagNumber(5)
  void clearRange() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.DateRange ensureRange() => $_ensure(4);

  @$pb.TagNumber(6)
  ExceptionAction get action => $_getN(5);
  @$pb.TagNumber(6)
  set action(ExceptionAction value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAction() => $_has(5);
  @$pb.TagNumber(6)
  void clearAction() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get qty => $_getIZ(6);
  @$pb.TagNumber(7)
  set qty($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasQty() => $_has(6);
  @$pb.TagNumber(7)
  void clearQty() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get markedByName => $_getSZ(7);
  @$pb.TagNumber(8)
  set markedByName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMarkedByName() => $_has(7);
  @$pb.TagNumber(8)
  void clearMarkedByName() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get afterCutoff => $_getBF(8);
  @$pb.TagNumber(9)
  set afterCutoff($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAfterCutoff() => $_has(8);
  @$pb.TagNumber(9)
  void clearAfterCutoff() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get createdAt => $_getSZ(9);
  @$pb.TagNumber(10)
  set createdAt($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
}

class VoidExceptionRequest extends $pb.GeneratedMessage {
  factory VoidExceptionRequest({
    $core.String? messId,
    $core.String? exceptionId,
  }) {
    final result = create();
    if (messId != null) result.messId = messId;
    if (exceptionId != null) result.exceptionId = exceptionId;
    return result;
  }

  VoidExceptionRequest._();

  factory VoidExceptionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VoidExceptionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoidExceptionRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.meals.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messId')
    ..aOS(2, _omitFieldNames ? '' : 'exceptionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoidExceptionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoidExceptionRequest copyWith(void Function(VoidExceptionRequest) updates) =>
      super.copyWith((message) => updates(message as VoidExceptionRequest))
          as VoidExceptionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoidExceptionRequest create() => VoidExceptionRequest._();
  @$core.override
  VoidExceptionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VoidExceptionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VoidExceptionRequest>(create);
  static VoidExceptionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get exceptionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set exceptionId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExceptionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearExceptionId() => $_clearField(2);
}

class VoidExceptionResponse extends $pb.GeneratedMessage {
  factory VoidExceptionResponse() => create();

  VoidExceptionResponse._();

  factory VoidExceptionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VoidExceptionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoidExceptionResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.meals.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoidExceptionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoidExceptionResponse copyWith(
          void Function(VoidExceptionResponse) updates) =>
      super.copyWith((message) => updates(message as VoidExceptionResponse))
          as VoidExceptionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoidExceptionResponse create() => VoidExceptionResponse._();
  @$core.override
  VoidExceptionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VoidExceptionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VoidExceptionResponse>(create);
  static VoidExceptionResponse? _defaultInstance;
}

/// GetDay renders the entire Today screen in one call.
class GetDayRequest extends $pb.GeneratedMessage {
  factory GetDayRequest({
    $core.String? messId,
    $0.Date? date,
  }) {
    final result = create();
    if (messId != null) result.messId = messId;
    if (date != null) result.date = date;
    return result;
  }

  GetDayRequest._();

  factory GetDayRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDayRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDayRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.meals.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messId')
    ..aOM<$0.Date>(2, _omitFieldNames ? '' : 'date', subBuilder: $0.Date.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDayRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDayRequest copyWith(void Function(GetDayRequest) updates) =>
      super.copyWith((message) => updates(message as GetDayRequest))
          as GetDayRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDayRequest create() => GetDayRequest._();
  @$core.override
  GetDayRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDayRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDayRequest>(create);
  static GetDayRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Date get date => $_getN(1);
  @$pb.TagNumber(2)
  set date($0.Date value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearDate() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Date ensureDate() => $_ensure(1);
}

class GetDayResponse extends $pb.GeneratedMessage {
  factory GetDayResponse({
    $0.Date? date,
    $core.Iterable<SlotHeadcount>? headcounts,
    $core.Iterable<MemberDay>? members,
    $core.Iterable<Exception>? exceptions,
    $core.bool? allDefault,
  }) {
    final result = create();
    if (date != null) result.date = date;
    if (headcounts != null) result.headcounts.addAll(headcounts);
    if (members != null) result.members.addAll(members);
    if (exceptions != null) result.exceptions.addAll(exceptions);
    if (allDefault != null) result.allDefault = allDefault;
    return result;
  }

  GetDayResponse._();

  factory GetDayResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDayResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDayResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.meals.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Date>(1, _omitFieldNames ? '' : 'date', subBuilder: $0.Date.create)
    ..pPM<SlotHeadcount>(2, _omitFieldNames ? '' : 'headcounts',
        subBuilder: SlotHeadcount.create)
    ..pPM<MemberDay>(3, _omitFieldNames ? '' : 'members',
        subBuilder: MemberDay.create)
    ..pPM<Exception>(4, _omitFieldNames ? '' : 'exceptions',
        subBuilder: Exception.create)
    ..aOB(5, _omitFieldNames ? '' : 'allDefault')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDayResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDayResponse copyWith(void Function(GetDayResponse) updates) =>
      super.copyWith((message) => updates(message as GetDayResponse))
          as GetDayResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDayResponse create() => GetDayResponse._();
  @$core.override
  GetDayResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDayResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDayResponse>(create);
  static GetDayResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Date get date => $_getN(0);
  @$pb.TagNumber(1)
  set date($0.Date value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Date ensureDate() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<SlotHeadcount> get headcounts => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<MemberDay> get members => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<Exception> get exceptions => $_getList(3);

  /// True when every member is on their default pattern. The client shows
  /// "বাকি সবাই ডিফল্ট প্যাটার্নে ✓ / কিছু করার নেই" — a SUCCESS state.
  @$pb.TagNumber(5)
  $core.bool get allDefault => $_getBF(4);
  @$pb.TagNumber(5)
  set allDefault($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAllDefault() => $_has(4);
  @$pb.TagNumber(5)
  void clearAllDefault() => $_clearField(5);
}

class SlotHeadcount extends $pb.GeneratedMessage {
  factory SlotHeadcount({
    $core.String? slotId,
    $core.String? nameBn,
    $core.int? count,
    $core.int? guestCount,
    $core.bool? cutoffPassed,
    $core.int? secondsToCutoff,
  }) {
    final result = create();
    if (slotId != null) result.slotId = slotId;
    if (nameBn != null) result.nameBn = nameBn;
    if (count != null) result.count = count;
    if (guestCount != null) result.guestCount = guestCount;
    if (cutoffPassed != null) result.cutoffPassed = cutoffPassed;
    if (secondsToCutoff != null) result.secondsToCutoff = secondsToCutoff;
    return result;
  }

  SlotHeadcount._();

  factory SlotHeadcount.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SlotHeadcount.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SlotHeadcount',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.meals.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'slotId')
    ..aOS(2, _omitFieldNames ? '' : 'nameBn')
    ..aI(3, _omitFieldNames ? '' : 'count')
    ..aI(4, _omitFieldNames ? '' : 'guestCount')
    ..aOB(5, _omitFieldNames ? '' : 'cutoffPassed')
    ..aI(6, _omitFieldNames ? '' : 'secondsToCutoff')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotHeadcount clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SlotHeadcount copyWith(void Function(SlotHeadcount) updates) =>
      super.copyWith((message) => updates(message as SlotHeadcount))
          as SlotHeadcount;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SlotHeadcount create() => SlotHeadcount._();
  @$core.override
  SlotHeadcount createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SlotHeadcount getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SlotHeadcount>(create);
  static SlotHeadcount? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get slotId => $_getSZ(0);
  @$pb.TagNumber(1)
  set slotId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlotId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlotId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get nameBn => $_getSZ(1);
  @$pb.TagNumber(2)
  set nameBn($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNameBn() => $_has(1);
  @$pb.TagNumber(2)
  void clearNameBn() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get count => $_getIZ(2);
  @$pb.TagNumber(3)
  set count($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get guestCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set guestCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGuestCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearGuestCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get cutoffPassed => $_getBF(4);
  @$pb.TagNumber(5)
  set cutoffPassed($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCutoffPassed() => $_has(4);
  @$pb.TagNumber(5)
  void clearCutoffPassed() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get secondsToCutoff => $_getIZ(5);
  @$pb.TagNumber(6)
  set secondsToCutoff($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSecondsToCutoff() => $_has(5);
  @$pb.TagNumber(6)
  void clearSecondsToCutoff() => $_clearField(6);
}

class MemberDay extends $pb.GeneratedMessage {
  factory MemberDay({
    $core.String? membershipId,
    $core.String? displayName,
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>? qtyBySlot,
  }) {
    final result = create();
    if (membershipId != null) result.membershipId = membershipId;
    if (displayName != null) result.displayName = displayName;
    if (qtyBySlot != null) result.qtyBySlot.addEntries(qtyBySlot);
    return result;
  }

  MemberDay._();

  factory MemberDay.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MemberDay.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MemberDay',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.meals.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'membershipId')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..m<$core.String, $core.int>(3, _omitFieldNames ? '' : 'qtyBySlot',
        entryClassName: 'MemberDay.QtyBySlotEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('tinbela.meals.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberDay clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MemberDay copyWith(void Function(MemberDay) updates) =>
      super.copyWith((message) => updates(message as MemberDay)) as MemberDay;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MemberDay create() => MemberDay._();
  @$core.override
  MemberDay createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MemberDay getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MemberDay>(create);
  static MemberDay? _defaultInstance;

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
  $pb.PbMap<$core.String, $core.int> get qtyBySlot => $_getMap(2);
}

class MealsServiceApi {
  final $pb.RpcClient _client;

  MealsServiceApi(this._client);

  $async.Future<SetPatternsResponse> setPatterns(
          $pb.ClientContext? ctx, SetPatternsRequest request) =>
      _client.invoke<SetPatternsResponse>(
          ctx, 'MealsService', 'SetPatterns', request, SetPatternsResponse());
  $async.Future<CreateExceptionResponse> createException(
          $pb.ClientContext? ctx, CreateExceptionRequest request) =>
      _client.invoke<CreateExceptionResponse>(ctx, 'MealsService',
          'CreateException', request, CreateExceptionResponse());
  $async.Future<VoidExceptionResponse> voidException(
          $pb.ClientContext? ctx, VoidExceptionRequest request) =>
      _client.invoke<VoidExceptionResponse>(ctx, 'MealsService',
          'VoidException', request, VoidExceptionResponse());
  $async.Future<GetDayResponse> getDay(
          $pb.ClientContext? ctx, GetDayRequest request) =>
      _client.invoke<GetDayResponse>(
          ctx, 'MealsService', 'GetDay', request, GetDayResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
