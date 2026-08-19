// This is a generated file - do not edit.
//
// Generated from tinbela/core/v1/core.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'common.pbjson.dart' as $0;

@$core.Deprecated('Use tenantKindDescriptor instead')
const TenantKind$json = {
  '1': 'TenantKind',
  '2': [
    {'1': 'TENANT_KIND_UNSPECIFIED', '2': 0},
    {'1': 'TENANT_KIND_MESS', '2': 1},
    {'1': 'TENANT_KIND_INSTITUTION', '2': 2},
    {'1': 'TENANT_KIND_HOME', '2': 3},
  ],
};

/// Descriptor for `TenantKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List tenantKindDescriptor = $convert.base64Decode(
    'CgpUZW5hbnRLaW5kEhsKF1RFTkFOVF9LSU5EX1VOU1BFQ0lGSUVEEAASFAoQVEVOQU5UX0tJTk'
    'RfTUVTUxABEhsKF1RFTkFOVF9LSU5EX0lOU1RJVFVUSU9OEAISFAoQVEVOQU5UX0tJTkRfSE9N'
    'RRAD');

@$core.Deprecated('Use roleDescriptor instead')
const Role$json = {
  '1': 'Role',
  '2': [
    {'1': 'ROLE_UNSPECIFIED', '2': 0},
    {'1': 'ROLE_MANAGER', '2': 1},
    {'1': 'ROLE_MEMBER', '2': 2},
    {'1': 'ROLE_ACCOUNTANT', '2': 3},
    {'1': 'ROLE_WARDEN', '2': 4},
    {'1': 'ROLE_GUARDIAN', '2': 5},
  ],
};

/// Descriptor for `Role`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List roleDescriptor = $convert.base64Decode(
    'CgRSb2xlEhQKEFJPTEVfVU5TUEVDSUZJRUQQABIQCgxST0xFX01BTkFHRVIQARIPCgtST0xFX0'
    '1FTUJFUhACEhMKD1JPTEVfQUNDT1VOVEFOVBADEg8KC1JPTEVfV0FSREVOEAQSEQoNUk9MRV9H'
    'VUFSRElBThAF');

@$core.Deprecated('Use inviteStateDescriptor instead')
const InviteState$json = {
  '1': 'InviteState',
  '2': [
    {'1': 'INVITE_STATE_UNSPECIFIED', '2': 0},
    {'1': 'INVITE_STATE_SENT', '2': 1},
    {'1': 'INVITE_STATE_OPENED', '2': 2},
    {'1': 'INVITE_STATE_LINKED', '2': 3},
  ],
};

/// Descriptor for `InviteState`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List inviteStateDescriptor = $convert.base64Decode(
    'CgtJbnZpdGVTdGF0ZRIcChhJTlZJVEVfU1RBVEVfVU5TUEVDSUZJRUQQABIVChFJTlZJVEVfU1'
    'RBVEVfU0VOVBABEhcKE0lOVklURV9TVEFURV9PUEVORUQQAhIXChNJTlZJVEVfU1RBVEVfTElO'
    'S0VEEAM=');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'phone_e164', '3': 3, '4': 1, '5': 9, '10': 'phoneE164'},
    {'1': 'locale', '3': 4, '4': 1, '5': 9, '10': 'locale'},
    {
      '1': 'use_bangla_numerals',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'useBanglaNumerals'
    },
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEh0KCnBob25lX2UxNj'
    'QYAyABKAlSCXBob25lRTE2NBIWCgZsb2NhbGUYBCABKAlSBmxvY2FsZRIuChN1c2VfYmFuZ2xh'
    'X251bWVyYWxzGAUgASgIUhF1c2VCYW5nbGFOdW1lcmFscw==');

@$core.Deprecated('Use messDescriptor instead')
const Mess$json = {
  '1': 'Mess',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'kind',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.tinbela.core.v1.TenantKind',
      '10': 'kind'
    },
    {
      '1': 'slots',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.tinbela.core.v1.Slot',
      '10': 'slots'
    },
    {'1': 'current_period_id', '3': 5, '4': 1, '5': 9, '10': 'currentPeriodId'},
  ],
};

/// Descriptor for `Mess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messDescriptor = $convert.base64Decode(
    'CgRNZXNzEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEi8KBGtpbmQYAyABKA'
    '4yGy50aW5iZWxhLmNvcmUudjEuVGVuYW50S2luZFIEa2luZBIrCgVzbG90cxgEIAMoCzIVLnRp'
    'bmJlbGEuY29yZS52MS5TbG90UgVzbG90cxIqChFjdXJyZW50X3BlcmlvZF9pZBgFIAEoCVIPY3'
    'VycmVudFBlcmlvZElk');

@$core.Deprecated('Use slotDescriptor instead')
const Slot$json = {
  '1': 'Slot',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name_bn', '3': 2, '4': 1, '5': 9, '10': 'nameBn'},
    {'1': 'name_en', '3': 3, '4': 1, '5': 9, '10': 'nameEn'},
    {'1': 'sort_order', '3': 4, '4': 1, '5': 5, '10': 'sortOrder'},
    {'1': 'cutoff_local', '3': 5, '4': 1, '5': 9, '10': 'cutoffLocal'},
    {'1': 'active', '3': 6, '4': 1, '5': 8, '10': 'active'},
  ],
};

/// Descriptor for `Slot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List slotDescriptor = $convert.base64Decode(
    'CgRTbG90Eg4KAmlkGAEgASgJUgJpZBIXCgduYW1lX2JuGAIgASgJUgZuYW1lQm4SFwoHbmFtZV'
    '9lbhgDIAEoCVIGbmFtZUVuEh0KCnNvcnRfb3JkZXIYBCABKAVSCXNvcnRPcmRlchIhCgxjdXRv'
    'ZmZfbG9jYWwYBSABKAlSC2N1dG9mZkxvY2FsEhYKBmFjdGl2ZRgGIAEoCFIGYWN0aXZl');

@$core.Deprecated('Use memberDescriptor instead')
const Member$json = {
  '1': 'Member',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'phone_e164', '3': 3, '4': 1, '5': 9, '10': 'phoneE164'},
    {
      '1': 'role',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.tinbela.core.v1.Role',
      '10': 'role'
    },
    {
      '1': 'joined_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Date',
      '10': 'joinedAt'
    },
    {
      '1': 'left_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Date',
      '10': 'leftAt'
    },
    {
      '1': 'invite_state',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.tinbela.core.v1.InviteState',
      '10': 'inviteState'
    },
  ],
};

/// Descriptor for `Member`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberDescriptor = $convert.base64Decode(
    'CgZNZW1iZXISDgoCaWQYASABKAlSAmlkEiEKDGRpc3BsYXlfbmFtZRgCIAEoCVILZGlzcGxheU'
    '5hbWUSHQoKcGhvbmVfZTE2NBgDIAEoCVIJcGhvbmVFMTY0EikKBHJvbGUYBCABKA4yFS50aW5i'
    'ZWxhLmNvcmUudjEuUm9sZVIEcm9sZRIyCglqb2luZWRfYXQYBSABKAsyFS50aW5iZWxhLmNvcm'
    'UudjEuRGF0ZVIIam9pbmVkQXQSLgoHbGVmdF9hdBgGIAEoCzIVLnRpbmJlbGEuY29yZS52MS5E'
    'YXRlUgZsZWZ0QXQSPwoMaW52aXRlX3N0YXRlGAcgASgOMhwudGluYmVsYS5jb3JlLnYxLkludm'
    'l0ZVN0YXRlUgtpbnZpdGVTdGF0ZQ==');

@$core.Deprecated('Use getMeRequestDescriptor instead')
const GetMeRequest$json = {
  '1': 'GetMeRequest',
};

/// Descriptor for `GetMeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMeRequestDescriptor =
    $convert.base64Decode('CgxHZXRNZVJlcXVlc3Q=');

@$core.Deprecated('Use getMeResponseDescriptor instead')
const GetMeResponse$json = {
  '1': 'GetMeResponse',
  '2': [
    {
      '1': 'user',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.User',
      '10': 'user'
    },
    {
      '1': 'messes',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.tinbela.core.v1.Mess',
      '10': 'messes'
    },
  ],
};

/// Descriptor for `GetMeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMeResponseDescriptor = $convert.base64Decode(
    'Cg1HZXRNZVJlc3BvbnNlEikKBHVzZXIYASABKAsyFS50aW5iZWxhLmNvcmUudjEuVXNlclIEdX'
    'NlchItCgZtZXNzZXMYAiADKAsyFS50aW5iZWxhLmNvcmUudjEuTWVzc1IGbWVzc2Vz');

@$core.Deprecated('Use createMessRequestDescriptor instead')
const CreateMessRequest$json = {
  '1': 'CreateMessRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'kind',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.tinbela.core.v1.TenantKind',
      '10': 'kind'
    },
    {'1': 'slot_count', '3': 3, '4': 1, '5': 5, '10': 'slotCount'},
  ],
};

/// Descriptor for `CreateMessRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createMessRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVNZXNzUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEi8KBGtpbmQYAiABKA4yGy'
    '50aW5iZWxhLmNvcmUudjEuVGVuYW50S2luZFIEa2luZBIdCgpzbG90X2NvdW50GAMgASgFUglz'
    'bG90Q291bnQ=');

@$core.Deprecated('Use createMessResponseDescriptor instead')
const CreateMessResponse$json = {
  '1': 'CreateMessResponse',
  '2': [
    {
      '1': 'mess',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Mess',
      '10': 'mess'
    },
    {'1': 'invite_link', '3': 2, '4': 1, '5': 9, '10': 'inviteLink'},
  ],
};

/// Descriptor for `CreateMessResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createMessResponseDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVNZXNzUmVzcG9uc2USKQoEbWVzcxgBIAEoCzIVLnRpbmJlbGEuY29yZS52MS5NZX'
    'NzUgRtZXNzEh8KC2ludml0ZV9saW5rGAIgASgJUgppbnZpdGVMaW5r');

@$core.Deprecated('Use addMemberRequestDescriptor instead')
const AddMemberRequest$json = {
  '1': 'AddMemberRequest',
  '2': [
    {'1': 'mess_id', '3': 1, '4': 1, '5': 9, '10': 'messId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'phone_e164', '3': 3, '4': 1, '5': 9, '10': 'phoneE164'},
  ],
};

/// Descriptor for `AddMemberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMemberRequestDescriptor = $convert.base64Decode(
    'ChBBZGRNZW1iZXJSZXF1ZXN0EhcKB21lc3NfaWQYASABKAlSBm1lc3NJZBIhCgxkaXNwbGF5X2'
    '5hbWUYAiABKAlSC2Rpc3BsYXlOYW1lEh0KCnBob25lX2UxNjQYAyABKAlSCXBob25lRTE2NA==');

@$core.Deprecated('Use addMemberResponseDescriptor instead')
const AddMemberResponse$json = {
  '1': 'AddMemberResponse',
  '2': [
    {
      '1': 'member',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Member',
      '10': 'member'
    },
    {'1': 'invite_link', '3': 2, '4': 1, '5': 9, '10': 'inviteLink'},
  ],
};

/// Descriptor for `AddMemberResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMemberResponseDescriptor = $convert.base64Decode(
    'ChFBZGRNZW1iZXJSZXNwb25zZRIvCgZtZW1iZXIYASABKAsyFy50aW5iZWxhLmNvcmUudjEuTW'
    'VtYmVyUgZtZW1iZXISHwoLaW52aXRlX2xpbmsYAiABKAlSCmludml0ZUxpbms=');

@$core.Deprecated('Use listMembersRequestDescriptor instead')
const ListMembersRequest$json = {
  '1': 'ListMembersRequest',
  '2': [
    {'1': 'mess_id', '3': 1, '4': 1, '5': 9, '10': 'messId'},
  ],
};

/// Descriptor for `ListMembersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMembersRequestDescriptor =
    $convert.base64Decode(
        'ChJMaXN0TWVtYmVyc1JlcXVlc3QSFwoHbWVzc19pZBgBIAEoCVIGbWVzc0lk');

@$core.Deprecated('Use listMembersResponseDescriptor instead')
const ListMembersResponse$json = {
  '1': 'ListMembersResponse',
  '2': [
    {
      '1': 'members',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tinbela.core.v1.Member',
      '10': 'members'
    },
  ],
};

/// Descriptor for `ListMembersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMembersResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0TWVtYmVyc1Jlc3BvbnNlEjEKB21lbWJlcnMYASADKAsyFy50aW5iZWxhLmNvcmUudj'
    'EuTWVtYmVyUgdtZW1iZXJz');

const $core.Map<$core.String, $core.dynamic> CoreServiceBase$json = {
  '1': 'CoreService',
  '2': [
    {
      '1': 'GetMe',
      '2': '.tinbela.core.v1.GetMeRequest',
      '3': '.tinbela.core.v1.GetMeResponse'
    },
    {
      '1': 'CreateMess',
      '2': '.tinbela.core.v1.CreateMessRequest',
      '3': '.tinbela.core.v1.CreateMessResponse'
    },
    {
      '1': 'AddMember',
      '2': '.tinbela.core.v1.AddMemberRequest',
      '3': '.tinbela.core.v1.AddMemberResponse'
    },
    {
      '1': 'ListMembers',
      '2': '.tinbela.core.v1.ListMembersRequest',
      '3': '.tinbela.core.v1.ListMembersResponse'
    },
  ],
};

@$core.Deprecated('Use coreServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    CoreServiceBase$messageJson = {
  '.tinbela.core.v1.GetMeRequest': GetMeRequest$json,
  '.tinbela.core.v1.GetMeResponse': GetMeResponse$json,
  '.tinbela.core.v1.User': User$json,
  '.tinbela.core.v1.Mess': Mess$json,
  '.tinbela.core.v1.Slot': Slot$json,
  '.tinbela.core.v1.CreateMessRequest': CreateMessRequest$json,
  '.tinbela.core.v1.CreateMessResponse': CreateMessResponse$json,
  '.tinbela.core.v1.AddMemberRequest': AddMemberRequest$json,
  '.tinbela.core.v1.AddMemberResponse': AddMemberResponse$json,
  '.tinbela.core.v1.Member': Member$json,
  '.tinbela.core.v1.Date': $0.Date$json,
  '.tinbela.core.v1.ListMembersRequest': ListMembersRequest$json,
  '.tinbela.core.v1.ListMembersResponse': ListMembersResponse$json,
};

/// Descriptor for `CoreService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List coreServiceDescriptor = $convert.base64Decode(
    'CgtDb3JlU2VydmljZRJGCgVHZXRNZRIdLnRpbmJlbGEuY29yZS52MS5HZXRNZVJlcXVlc3QaHi'
    '50aW5iZWxhLmNvcmUudjEuR2V0TWVSZXNwb25zZRJVCgpDcmVhdGVNZXNzEiIudGluYmVsYS5j'
    'b3JlLnYxLkNyZWF0ZU1lc3NSZXF1ZXN0GiMudGluYmVsYS5jb3JlLnYxLkNyZWF0ZU1lc3NSZX'
    'Nwb25zZRJSCglBZGRNZW1iZXISIS50aW5iZWxhLmNvcmUudjEuQWRkTWVtYmVyUmVxdWVzdBoi'
    'LnRpbmJlbGEuY29yZS52MS5BZGRNZW1iZXJSZXNwb25zZRJYCgtMaXN0TWVtYmVycxIjLnRpbm'
    'JlbGEuY29yZS52MS5MaXN0TWVtYmVyc1JlcXVlc3QaJC50aW5iZWxhLmNvcmUudjEuTGlzdE1l'
    'bWJlcnNSZXNwb25zZQ==');
