// This is a generated file - do not edit.
//
// Generated from tinbela/meals/v1/meals.proto.

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

import '../../core/v1/common.pbjson.dart' as $0;

@$core.Deprecated('Use exceptionActionDescriptor instead')
const ExceptionAction$json = {
  '1': 'ExceptionAction',
  '2': [
    {'1': 'EXCEPTION_ACTION_UNSPECIFIED', '2': 0},
    {'1': 'EXCEPTION_ACTION_OFF', '2': 1},
    {'1': 'EXCEPTION_ACTION_ON', '2': 2},
    {'1': 'EXCEPTION_ACTION_SET_QTY', '2': 3},
    {'1': 'EXCEPTION_ACTION_GUEST', '2': 4},
  ],
};

/// Descriptor for `ExceptionAction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List exceptionActionDescriptor = $convert.base64Decode(
    'Cg9FeGNlcHRpb25BY3Rpb24SIAocRVhDRVBUSU9OX0FDVElPTl9VTlNQRUNJRklFRBAAEhgKFE'
    'VYQ0VQVElPTl9BQ1RJT05fT0ZGEAESFwoTRVhDRVBUSU9OX0FDVElPTl9PThACEhwKGEVYQ0VQ'
    'VElPTl9BQ1RJT05fU0VUX1FUWRADEhoKFkVYQ0VQVElPTl9BQ1RJT05fR1VFU1QQBA==');

@$core.Deprecated('Use patternDescriptor instead')
const Pattern$json = {
  '1': 'Pattern',
  '2': [
    {'1': 'membership_id', '3': 1, '4': 1, '5': 9, '10': 'membershipId'},
    {'1': 'slot_id', '3': 2, '4': 1, '5': 9, '10': 'slotId'},
    {'1': 'dow_mask', '3': 3, '4': 1, '5': 5, '10': 'dowMask'},
    {'1': 'qty', '3': 4, '4': 1, '5': 5, '10': 'qty'},
  ],
};

/// Descriptor for `Pattern`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List patternDescriptor = $convert.base64Decode(
    'CgdQYXR0ZXJuEiMKDW1lbWJlcnNoaXBfaWQYASABKAlSDG1lbWJlcnNoaXBJZBIXCgdzbG90X2'
    'lkGAIgASgJUgZzbG90SWQSGQoIZG93X21hc2sYAyABKAVSB2Rvd01hc2sSEAoDcXR5GAQgASgF'
    'UgNxdHk=');

@$core.Deprecated('Use setPatternsRequestDescriptor instead')
const SetPatternsRequest$json = {
  '1': 'SetPatternsRequest',
  '2': [
    {'1': 'mess_id', '3': 1, '4': 1, '5': 9, '10': 'messId'},
    {'1': 'membership_id', '3': 2, '4': 1, '5': 9, '10': 'membershipId'},
    {
      '1': 'patterns',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.tinbela.meals.v1.Pattern',
      '10': 'patterns'
    },
  ],
};

/// Descriptor for `SetPatternsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPatternsRequestDescriptor = $convert.base64Decode(
    'ChJTZXRQYXR0ZXJuc1JlcXVlc3QSFwoHbWVzc19pZBgBIAEoCVIGbWVzc0lkEiMKDW1lbWJlcn'
    'NoaXBfaWQYAiABKAlSDG1lbWJlcnNoaXBJZBI1CghwYXR0ZXJucxgDIAMoCzIZLnRpbmJlbGEu'
    'bWVhbHMudjEuUGF0dGVyblIIcGF0dGVybnM=');

@$core.Deprecated('Use setPatternsResponseDescriptor instead')
const SetPatternsResponse$json = {
  '1': 'SetPatternsResponse',
  '2': [
    {
      '1': 'patterns',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tinbela.meals.v1.Pattern',
      '10': 'patterns'
    },
  ],
};

/// Descriptor for `SetPatternsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPatternsResponseDescriptor = $convert.base64Decode(
    'ChNTZXRQYXR0ZXJuc1Jlc3BvbnNlEjUKCHBhdHRlcm5zGAEgAygLMhkudGluYmVsYS5tZWFscy'
    '52MS5QYXR0ZXJuUghwYXR0ZXJucw==');

@$core.Deprecated('Use createExceptionRequestDescriptor instead')
const CreateExceptionRequest$json = {
  '1': 'CreateExceptionRequest',
  '2': [
    {'1': 'mess_id', '3': 1, '4': 1, '5': 9, '10': 'messId'},
    {'1': 'membership_id', '3': 2, '4': 1, '5': 9, '10': 'membershipId'},
    {'1': 'group_id', '3': 3, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'slot_id', '3': 4, '4': 1, '5': 9, '10': 'slotId'},
    {
      '1': 'date_from',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Date',
      '10': 'dateFrom'
    },
    {
      '1': 'date_to',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Date',
      '10': 'dateTo'
    },
    {
      '1': 'action',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.tinbela.meals.v1.ExceptionAction',
      '10': 'action'
    },
    {'1': 'qty', '3': 8, '4': 1, '5': 5, '10': 'qty'},
  ],
};

/// Descriptor for `CreateExceptionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createExceptionRequestDescriptor = $convert.base64Decode(
    'ChZDcmVhdGVFeGNlcHRpb25SZXF1ZXN0EhcKB21lc3NfaWQYASABKAlSBm1lc3NJZBIjCg1tZW'
    '1iZXJzaGlwX2lkGAIgASgJUgxtZW1iZXJzaGlwSWQSGQoIZ3JvdXBfaWQYAyABKAlSB2dyb3Vw'
    'SWQSFwoHc2xvdF9pZBgEIAEoCVIGc2xvdElkEjIKCWRhdGVfZnJvbRgFIAEoCzIVLnRpbmJlbG'
    'EuY29yZS52MS5EYXRlUghkYXRlRnJvbRIuCgdkYXRlX3RvGAYgASgLMhUudGluYmVsYS5jb3Jl'
    'LnYxLkRhdGVSBmRhdGVUbxI5CgZhY3Rpb24YByABKA4yIS50aW5iZWxhLm1lYWxzLnYxLkV4Y2'
    'VwdGlvbkFjdGlvblIGYWN0aW9uEhAKA3F0eRgIIAEoBVIDcXR5');

@$core.Deprecated('Use createExceptionResponseDescriptor instead')
const CreateExceptionResponse$json = {
  '1': 'CreateExceptionResponse',
  '2': [
    {
      '1': 'exception',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tinbela.meals.v1.Exception',
      '10': 'exception'
    },
  ],
};

/// Descriptor for `CreateExceptionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createExceptionResponseDescriptor =
    $convert.base64Decode(
        'ChdDcmVhdGVFeGNlcHRpb25SZXNwb25zZRI5CglleGNlcHRpb24YASABKAsyGy50aW5iZWxhLm'
        '1lYWxzLnYxLkV4Y2VwdGlvblIJZXhjZXB0aW9u');

@$core.Deprecated('Use exceptionDescriptor instead')
const Exception$json = {
  '1': 'Exception',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'membership_id', '3': 2, '4': 1, '5': 9, '10': 'membershipId'},
    {
      '1': 'member_display_name',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'memberDisplayName'
    },
    {'1': 'slot_id', '3': 4, '4': 1, '5': 9, '10': 'slotId'},
    {
      '1': 'range',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.DateRange',
      '10': 'range'
    },
    {
      '1': 'action',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.tinbela.meals.v1.ExceptionAction',
      '10': 'action'
    },
    {'1': 'qty', '3': 7, '4': 1, '5': 5, '10': 'qty'},
    {'1': 'marked_by_name', '3': 8, '4': 1, '5': 9, '10': 'markedByName'},
    {'1': 'after_cutoff', '3': 9, '4': 1, '5': 8, '10': 'afterCutoff'},
    {'1': 'created_at', '3': 10, '4': 1, '5': 9, '10': 'createdAt'},
  ],
};

/// Descriptor for `Exception`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exceptionDescriptor = $convert.base64Decode(
    'CglFeGNlcHRpb24SDgoCaWQYASABKAlSAmlkEiMKDW1lbWJlcnNoaXBfaWQYAiABKAlSDG1lbW'
    'JlcnNoaXBJZBIuChNtZW1iZXJfZGlzcGxheV9uYW1lGAMgASgJUhFtZW1iZXJEaXNwbGF5TmFt'
    'ZRIXCgdzbG90X2lkGAQgASgJUgZzbG90SWQSMAoFcmFuZ2UYBSABKAsyGi50aW5iZWxhLmNvcm'
    'UudjEuRGF0ZVJhbmdlUgVyYW5nZRI5CgZhY3Rpb24YBiABKA4yIS50aW5iZWxhLm1lYWxzLnYx'
    'LkV4Y2VwdGlvbkFjdGlvblIGYWN0aW9uEhAKA3F0eRgHIAEoBVIDcXR5EiQKDm1hcmtlZF9ieV'
    '9uYW1lGAggASgJUgxtYXJrZWRCeU5hbWUSIQoMYWZ0ZXJfY3V0b2ZmGAkgASgIUgthZnRlckN1'
    'dG9mZhIdCgpjcmVhdGVkX2F0GAogASgJUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use voidExceptionRequestDescriptor instead')
const VoidExceptionRequest$json = {
  '1': 'VoidExceptionRequest',
  '2': [
    {'1': 'mess_id', '3': 1, '4': 1, '5': 9, '10': 'messId'},
    {'1': 'exception_id', '3': 2, '4': 1, '5': 9, '10': 'exceptionId'},
  ],
};

/// Descriptor for `VoidExceptionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voidExceptionRequestDescriptor = $convert.base64Decode(
    'ChRWb2lkRXhjZXB0aW9uUmVxdWVzdBIXCgdtZXNzX2lkGAEgASgJUgZtZXNzSWQSIQoMZXhjZX'
    'B0aW9uX2lkGAIgASgJUgtleGNlcHRpb25JZA==');

@$core.Deprecated('Use voidExceptionResponseDescriptor instead')
const VoidExceptionResponse$json = {
  '1': 'VoidExceptionResponse',
};

/// Descriptor for `VoidExceptionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voidExceptionResponseDescriptor =
    $convert.base64Decode('ChVWb2lkRXhjZXB0aW9uUmVzcG9uc2U=');

@$core.Deprecated('Use getDayRequestDescriptor instead')
const GetDayRequest$json = {
  '1': 'GetDayRequest',
  '2': [
    {'1': 'mess_id', '3': 1, '4': 1, '5': 9, '10': 'messId'},
    {
      '1': 'date',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Date',
      '10': 'date'
    },
  ],
};

/// Descriptor for `GetDayRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDayRequestDescriptor = $convert.base64Decode(
    'Cg1HZXREYXlSZXF1ZXN0EhcKB21lc3NfaWQYASABKAlSBm1lc3NJZBIpCgRkYXRlGAIgASgLMh'
    'UudGluYmVsYS5jb3JlLnYxLkRhdGVSBGRhdGU=');

@$core.Deprecated('Use getDayResponseDescriptor instead')
const GetDayResponse$json = {
  '1': 'GetDayResponse',
  '2': [
    {
      '1': 'date',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Date',
      '10': 'date'
    },
    {
      '1': 'headcounts',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.tinbela.meals.v1.SlotHeadcount',
      '10': 'headcounts'
    },
    {
      '1': 'members',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.tinbela.meals.v1.MemberDay',
      '10': 'members'
    },
    {
      '1': 'exceptions',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.tinbela.meals.v1.Exception',
      '10': 'exceptions'
    },
    {'1': 'all_default', '3': 5, '4': 1, '5': 8, '10': 'allDefault'},
  ],
};

/// Descriptor for `GetDayResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDayResponseDescriptor = $convert.base64Decode(
    'Cg5HZXREYXlSZXNwb25zZRIpCgRkYXRlGAEgASgLMhUudGluYmVsYS5jb3JlLnYxLkRhdGVSBG'
    'RhdGUSPwoKaGVhZGNvdW50cxgCIAMoCzIfLnRpbmJlbGEubWVhbHMudjEuU2xvdEhlYWRjb3Vu'
    'dFIKaGVhZGNvdW50cxI1CgdtZW1iZXJzGAMgAygLMhsudGluYmVsYS5tZWFscy52MS5NZW1iZX'
    'JEYXlSB21lbWJlcnMSOwoKZXhjZXB0aW9ucxgEIAMoCzIbLnRpbmJlbGEubWVhbHMudjEuRXhj'
    'ZXB0aW9uUgpleGNlcHRpb25zEh8KC2FsbF9kZWZhdWx0GAUgASgIUgphbGxEZWZhdWx0');

@$core.Deprecated('Use slotHeadcountDescriptor instead')
const SlotHeadcount$json = {
  '1': 'SlotHeadcount',
  '2': [
    {'1': 'slot_id', '3': 1, '4': 1, '5': 9, '10': 'slotId'},
    {'1': 'name_bn', '3': 2, '4': 1, '5': 9, '10': 'nameBn'},
    {'1': 'count', '3': 3, '4': 1, '5': 5, '10': 'count'},
    {'1': 'guest_count', '3': 4, '4': 1, '5': 5, '10': 'guestCount'},
    {'1': 'cutoff_passed', '3': 5, '4': 1, '5': 8, '10': 'cutoffPassed'},
    {'1': 'seconds_to_cutoff', '3': 6, '4': 1, '5': 5, '10': 'secondsToCutoff'},
  ],
};

/// Descriptor for `SlotHeadcount`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List slotHeadcountDescriptor = $convert.base64Decode(
    'Cg1TbG90SGVhZGNvdW50EhcKB3Nsb3RfaWQYASABKAlSBnNsb3RJZBIXCgduYW1lX2JuGAIgAS'
    'gJUgZuYW1lQm4SFAoFY291bnQYAyABKAVSBWNvdW50Eh8KC2d1ZXN0X2NvdW50GAQgASgFUgpn'
    'dWVzdENvdW50EiMKDWN1dG9mZl9wYXNzZWQYBSABKAhSDGN1dG9mZlBhc3NlZBIqChFzZWNvbm'
    'RzX3RvX2N1dG9mZhgGIAEoBVIPc2Vjb25kc1RvQ3V0b2Zm');

@$core.Deprecated('Use memberDayDescriptor instead')
const MemberDay$json = {
  '1': 'MemberDay',
  '2': [
    {'1': 'membership_id', '3': 1, '4': 1, '5': 9, '10': 'membershipId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {
      '1': 'qty_by_slot',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.tinbela.meals.v1.MemberDay.QtyBySlotEntry',
      '10': 'qtyBySlot'
    },
  ],
  '3': [MemberDay_QtyBySlotEntry$json],
};

@$core.Deprecated('Use memberDayDescriptor instead')
const MemberDay_QtyBySlotEntry$json = {
  '1': 'QtyBySlotEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `MemberDay`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberDayDescriptor = $convert.base64Decode(
    'CglNZW1iZXJEYXkSIwoNbWVtYmVyc2hpcF9pZBgBIAEoCVIMbWVtYmVyc2hpcElkEiEKDGRpc3'
    'BsYXlfbmFtZRgCIAEoCVILZGlzcGxheU5hbWUSSgoLcXR5X2J5X3Nsb3QYAyADKAsyKi50aW5i'
    'ZWxhLm1lYWxzLnYxLk1lbWJlckRheS5RdHlCeVNsb3RFbnRyeVIJcXR5QnlTbG90GjwKDlF0eU'
    'J5U2xvdEVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZToCOAE=');

const $core.Map<$core.String, $core.dynamic> MealsServiceBase$json = {
  '1': 'MealsService',
  '2': [
    {
      '1': 'SetPatterns',
      '2': '.tinbela.meals.v1.SetPatternsRequest',
      '3': '.tinbela.meals.v1.SetPatternsResponse'
    },
    {
      '1': 'CreateException',
      '2': '.tinbela.meals.v1.CreateExceptionRequest',
      '3': '.tinbela.meals.v1.CreateExceptionResponse'
    },
    {
      '1': 'VoidException',
      '2': '.tinbela.meals.v1.VoidExceptionRequest',
      '3': '.tinbela.meals.v1.VoidExceptionResponse'
    },
    {
      '1': 'GetDay',
      '2': '.tinbela.meals.v1.GetDayRequest',
      '3': '.tinbela.meals.v1.GetDayResponse'
    },
  ],
};

@$core.Deprecated('Use mealsServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    MealsServiceBase$messageJson = {
  '.tinbela.meals.v1.SetPatternsRequest': SetPatternsRequest$json,
  '.tinbela.meals.v1.Pattern': Pattern$json,
  '.tinbela.meals.v1.SetPatternsResponse': SetPatternsResponse$json,
  '.tinbela.meals.v1.CreateExceptionRequest': CreateExceptionRequest$json,
  '.tinbela.core.v1.Date': $0.Date$json,
  '.tinbela.meals.v1.CreateExceptionResponse': CreateExceptionResponse$json,
  '.tinbela.meals.v1.Exception': Exception$json,
  '.tinbela.core.v1.DateRange': $0.DateRange$json,
  '.tinbela.meals.v1.VoidExceptionRequest': VoidExceptionRequest$json,
  '.tinbela.meals.v1.VoidExceptionResponse': VoidExceptionResponse$json,
  '.tinbela.meals.v1.GetDayRequest': GetDayRequest$json,
  '.tinbela.meals.v1.GetDayResponse': GetDayResponse$json,
  '.tinbela.meals.v1.SlotHeadcount': SlotHeadcount$json,
  '.tinbela.meals.v1.MemberDay': MemberDay$json,
  '.tinbela.meals.v1.MemberDay.QtyBySlotEntry': MemberDay_QtyBySlotEntry$json,
};

/// Descriptor for `MealsService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List mealsServiceDescriptor = $convert.base64Decode(
    'CgxNZWFsc1NlcnZpY2USWgoLU2V0UGF0dGVybnMSJC50aW5iZWxhLm1lYWxzLnYxLlNldFBhdH'
    'Rlcm5zUmVxdWVzdBolLnRpbmJlbGEubWVhbHMudjEuU2V0UGF0dGVybnNSZXNwb25zZRJmCg9D'
    'cmVhdGVFeGNlcHRpb24SKC50aW5iZWxhLm1lYWxzLnYxLkNyZWF0ZUV4Y2VwdGlvblJlcXVlc3'
    'QaKS50aW5iZWxhLm1lYWxzLnYxLkNyZWF0ZUV4Y2VwdGlvblJlc3BvbnNlEmAKDVZvaWRFeGNl'
    'cHRpb24SJi50aW5iZWxhLm1lYWxzLnYxLlZvaWRFeGNlcHRpb25SZXF1ZXN0GicudGluYmVsYS'
    '5tZWFscy52MS5Wb2lkRXhjZXB0aW9uUmVzcG9uc2USSwoGR2V0RGF5Eh8udGluYmVsYS5tZWFs'
    'cy52MS5HZXREYXlSZXF1ZXN0GiAudGluYmVsYS5tZWFscy52MS5HZXREYXlSZXNwb25zZQ==');
