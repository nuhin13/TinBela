// This is a generated file - do not edit.
//
// Generated from tinbela/money/v1/money.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class EntryKind extends $pb.ProtobufEnum {
  static const EntryKind ENTRY_KIND_UNSPECIFIED =
      EntryKind._(0, _omitEnumNames ? '' : 'ENTRY_KIND_UNSPECIFIED');
  static const EntryKind ENTRY_KIND_FOOD_COST =
      EntryKind._(1, _omitEnumNames ? '' : 'ENTRY_KIND_FOOD_COST');
  static const EntryKind ENTRY_KIND_DEPOSIT =
      EntryKind._(2, _omitEnumNames ? '' : 'ENTRY_KIND_DEPOSIT');
  static const EntryKind ENTRY_KIND_SHARED_COST =
      EntryKind._(3, _omitEnumNames ? '' : 'ENTRY_KIND_SHARED_COST');
  static const EntryKind ENTRY_KIND_RENT_PAYOUT =
      EntryKind._(4, _omitEnumNames ? '' : 'ENTRY_KIND_RENT_PAYOUT');
  static const EntryKind ENTRY_KIND_ADJUST =
      EntryKind._(5, _omitEnumNames ? '' : 'ENTRY_KIND_ADJUST');

  static const $core.List<EntryKind> values = <EntryKind>[
    ENTRY_KIND_UNSPECIFIED,
    ENTRY_KIND_FOOD_COST,
    ENTRY_KIND_DEPOSIT,
    ENTRY_KIND_SHARED_COST,
    ENTRY_KIND_RENT_PAYOUT,
    ENTRY_KIND_ADJUST,
  ];

  static final $core.List<EntryKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static EntryKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EntryKind._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
