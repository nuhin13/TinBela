// This is a generated file - do not edit.
//
// Generated from tinbela/core/v1/common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Money is ALWAYS integer paisa. Never a float, never a decimal string.
/// ৳12.40 is paisa = 1240.
class Money extends $pb.GeneratedMessage {
  factory Money({
    $fixnum.Int64? paisa,
    $core.String? display,
    MathExplain? math,
  }) {
    final result = create();
    if (paisa != null) result.paisa = paisa;
    if (display != null) result.display = display;
    if (math != null) result.math = math;
    return result;
  }

  Money._();

  factory Money.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Money.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Money',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'paisa')
    ..aOS(2, _omitFieldNames ? '' : 'display')
    ..aOM<MathExplain>(3, _omitFieldNames ? '' : 'math',
        subBuilder: MathExplain.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Money clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Money copyWith(void Function(Money) updates) =>
      super.copyWith((message) => updates(message as Money)) as Money;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Money create() => Money._();
  @$core.override
  Money createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Money getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Money>(create);
  static Money? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get paisa => $_getI64(0);
  @$pb.TagNumber(1)
  set paisa($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPaisa() => $_has(0);
  @$pb.TagNumber(1)
  void clearPaisa() => $_clearField(1);

  /// Server-formatted for the caller's locale and numeral preference,
  /// e.g. "৳১,২৪০" or "৳1,240". Clients never format money themselves.
  @$pb.TagNumber(2)
  $core.String get display => $_getSZ(1);
  @$pb.TagNumber(2)
  set display($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplay() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplay() => $_clearField(2);

  /// How this number was derived. Wedge 3 — trust — expressed in the
  /// contract so a client cannot quietly drop it.
  @$pb.TagNumber(3)
  MathExplain get math => $_getN(2);
  @$pb.TagNumber(3)
  set math(MathExplain value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMath() => $_has(2);
  @$pb.TagNumber(3)
  void clearMath() => $_clearField(3);
  @$pb.TagNumber(3)
  MathExplain ensureMath() => $_ensure(2);
}

/// MathExplain powers the tappable math sheet. Every money value in every
/// response carries one. The client RENDERS this; it never recomputes.
class MathExplain extends $pb.GeneratedMessage {
  factory MathExplain({
    $core.String? formula,
    $core.Iterable<MathTerm>? terms,
    $core.String? note,
  }) {
    final result = create();
    if (formula != null) result.formula = formula;
    if (terms != null) result.terms.addAll(terms);
    if (note != null) result.note = note;
    return result;
  }

  MathExplain._();

  factory MathExplain.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MathExplain.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MathExplain',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'formula')
    ..pPM<MathTerm>(2, _omitFieldNames ? '' : 'terms',
        subBuilder: MathTerm.create)
    ..aOS(3, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MathExplain clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MathExplain copyWith(void Function(MathExplain) updates) =>
      super.copyWith((message) => updates(message as MathExplain))
          as MathExplain;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MathExplain create() => MathExplain._();
  @$core.override
  MathExplain createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MathExplain getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MathExplain>(create);
  static MathExplain? _defaultInstance;

  /// e.g. "মোট বাজার ÷ মোট মিল"
  @$pb.TagNumber(1)
  $core.String get formula => $_getSZ(0);
  @$pb.TagNumber(1)
  set formula($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFormula() => $_has(0);
  @$pb.TagNumber(1)
  void clearFormula() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<MathTerm> get terms => $_getList(1);

  /// e.g. "বাকি ৳০ মেসের হিসাবে যোগ আছে"
  @$pb.TagNumber(3)
  $core.String get note => $_getSZ(2);
  @$pb.TagNumber(3)
  set note($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNote() => $_has(2);
  @$pb.TagNumber(3)
  void clearNote() => $_clearField(3);
}

class MathTerm extends $pb.GeneratedMessage {
  factory MathTerm({
    $core.String? label,
    $core.String? display,
  }) {
    final result = create();
    if (label != null) result.label = label;
    if (display != null) result.display = display;
    return result;
  }

  MathTerm._();

  factory MathTerm.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MathTerm.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MathTerm',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOS(2, _omitFieldNames ? '' : 'display')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MathTerm clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MathTerm copyWith(void Function(MathTerm) updates) =>
      super.copyWith((message) => updates(message as MathTerm)) as MathTerm;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MathTerm create() => MathTerm._();
  @$core.override
  MathTerm createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MathTerm getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MathTerm>(create);
  static MathTerm? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get display => $_getSZ(1);
  @$pb.TagNumber(2)
  set display($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplay() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplay() => $_clearField(2);
}

/// A calendar day in the tenant timezone (Asia/Dhaka). "YYYY-MM-DD".
/// A meal belongs to a day, not an instant — never use a timestamp here.
class Date extends $pb.GeneratedMessage {
  factory Date({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Date._();

  factory Date.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Date.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Date',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Date clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Date copyWith(void Function(Date) updates) =>
      super.copyWith((message) => updates(message as Date)) as Date;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Date create() => Date._();
  @$core.override
  Date createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Date getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Date>(create);
  static Date? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class DateRange extends $pb.GeneratedMessage {
  factory DateRange({
    Date? from,
    Date? to,
  }) {
    final result = create();
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    return result;
  }

  DateRange._();

  factory DateRange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DateRange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DateRange',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'tinbela.core.v1'),
      createEmptyInstance: create)
    ..aOM<Date>(1, _omitFieldNames ? '' : 'from', subBuilder: Date.create)
    ..aOM<Date>(2, _omitFieldNames ? '' : 'to', subBuilder: Date.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DateRange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DateRange copyWith(void Function(DateRange) updates) =>
      super.copyWith((message) => updates(message as DateRange)) as DateRange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DateRange create() => DateRange._();
  @$core.override
  DateRange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DateRange getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DateRange>(create);
  static DateRange? _defaultInstance;

  @$pb.TagNumber(1)
  Date get from => $_getN(0);
  @$pb.TagNumber(1)
  set from(Date value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFrom() => $_has(0);
  @$pb.TagNumber(1)
  void clearFrom() => $_clearField(1);
  @$pb.TagNumber(1)
  Date ensureFrom() => $_ensure(0);

  @$pb.TagNumber(2)
  Date get to => $_getN(1);
  @$pb.TagNumber(2)
  set to(Date value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTo() => $_has(1);
  @$pb.TagNumber(2)
  void clearTo() => $_clearField(2);
  @$pb.TagNumber(2)
  Date ensureTo() => $_ensure(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
