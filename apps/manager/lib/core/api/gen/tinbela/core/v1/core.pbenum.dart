// This is a generated file - do not edit.
//
// Generated from tinbela/core/v1/core.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class TenantKind extends $pb.ProtobufEnum {
  static const TenantKind TENANT_KIND_UNSPECIFIED =
      TenantKind._(0, _omitEnumNames ? '' : 'TENANT_KIND_UNSPECIFIED');
  static const TenantKind TENANT_KIND_MESS =
      TenantKind._(1, _omitEnumNames ? '' : 'TENANT_KIND_MESS');
  static const TenantKind TENANT_KIND_INSTITUTION =
      TenantKind._(2, _omitEnumNames ? '' : 'TENANT_KIND_INSTITUTION');
  static const TenantKind TENANT_KIND_HOME =
      TenantKind._(3, _omitEnumNames ? '' : 'TENANT_KIND_HOME');

  static const $core.List<TenantKind> values = <TenantKind>[
    TENANT_KIND_UNSPECIFIED,
    TENANT_KIND_MESS,
    TENANT_KIND_INSTITUTION,
    TENANT_KIND_HOME,
  ];

  static final $core.List<TenantKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static TenantKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TenantKind._(super.value, super.name);
}

class Role extends $pb.ProtobufEnum {
  static const Role ROLE_UNSPECIFIED =
      Role._(0, _omitEnumNames ? '' : 'ROLE_UNSPECIFIED');
  static const Role ROLE_MANAGER =
      Role._(1, _omitEnumNames ? '' : 'ROLE_MANAGER');
  static const Role ROLE_MEMBER =
      Role._(2, _omitEnumNames ? '' : 'ROLE_MEMBER');
  static const Role ROLE_ACCOUNTANT =
      Role._(3, _omitEnumNames ? '' : 'ROLE_ACCOUNTANT');
  static const Role ROLE_WARDEN =
      Role._(4, _omitEnumNames ? '' : 'ROLE_WARDEN');
  static const Role ROLE_GUARDIAN =
      Role._(5, _omitEnumNames ? '' : 'ROLE_GUARDIAN');

  static const $core.List<Role> values = <Role>[
    ROLE_UNSPECIFIED,
    ROLE_MANAGER,
    ROLE_MEMBER,
    ROLE_ACCOUNTANT,
    ROLE_WARDEN,
    ROLE_GUARDIAN,
  ];

  static final $core.List<Role?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static Role? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Role._(super.value, super.name);
}

class InviteState extends $pb.ProtobufEnum {
  static const InviteState INVITE_STATE_UNSPECIFIED =
      InviteState._(0, _omitEnumNames ? '' : 'INVITE_STATE_UNSPECIFIED');
  static const InviteState INVITE_STATE_SENT =
      InviteState._(1, _omitEnumNames ? '' : 'INVITE_STATE_SENT');
  static const InviteState INVITE_STATE_OPENED =
      InviteState._(2, _omitEnumNames ? '' : 'INVITE_STATE_OPENED');
  static const InviteState INVITE_STATE_LINKED =
      InviteState._(3, _omitEnumNames ? '' : 'INVITE_STATE_LINKED');

  static const $core.List<InviteState> values = <InviteState>[
    INVITE_STATE_UNSPECIFIED,
    INVITE_STATE_SENT,
    INVITE_STATE_OPENED,
    INVITE_STATE_LINKED,
  ];

  static final $core.List<InviteState?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static InviteState? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const InviteState._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
