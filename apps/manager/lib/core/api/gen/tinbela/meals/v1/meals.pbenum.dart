// This is a generated file - do not edit.
//
// Generated from tinbela/meals/v1/meals.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ExceptionAction extends $pb.ProtobufEnum {
  static const ExceptionAction EXCEPTION_ACTION_UNSPECIFIED = ExceptionAction._(
      0, _omitEnumNames ? '' : 'EXCEPTION_ACTION_UNSPECIFIED');
  static const ExceptionAction EXCEPTION_ACTION_OFF =
      ExceptionAction._(1, _omitEnumNames ? '' : 'EXCEPTION_ACTION_OFF');
  static const ExceptionAction EXCEPTION_ACTION_ON =
      ExceptionAction._(2, _omitEnumNames ? '' : 'EXCEPTION_ACTION_ON');
  static const ExceptionAction EXCEPTION_ACTION_SET_QTY =
      ExceptionAction._(3, _omitEnumNames ? '' : 'EXCEPTION_ACTION_SET_QTY');
  static const ExceptionAction EXCEPTION_ACTION_GUEST =
      ExceptionAction._(4, _omitEnumNames ? '' : 'EXCEPTION_ACTION_GUEST');

  static const $core.List<ExceptionAction> values = <ExceptionAction>[
    EXCEPTION_ACTION_UNSPECIFIED,
    EXCEPTION_ACTION_OFF,
    EXCEPTION_ACTION_ON,
    EXCEPTION_ACTION_SET_QTY,
    EXCEPTION_ACTION_GUEST,
  ];

  static final $core.List<ExceptionAction?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static ExceptionAction? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ExceptionAction._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
