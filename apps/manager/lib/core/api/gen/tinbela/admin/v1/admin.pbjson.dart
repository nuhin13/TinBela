// This is a generated file - do not edit.
//
// Generated from tinbela/admin/v1/admin.proto.

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

@$core.Deprecated('Use listTenantsRequestDescriptor instead')
const ListTenantsRequest$json = {
  '1': 'ListTenantsRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'page', '3': 2, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `ListTenantsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTenantsRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0VGVuYW50c1JlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5EhIKBHBhZ2UYAiABKA'
    'VSBHBhZ2USGwoJcGFnZV9zaXplGAMgASgFUghwYWdlU2l6ZQ==');

@$core.Deprecated('Use listTenantsResponseDescriptor instead')
const ListTenantsResponse$json = {
  '1': 'ListTenantsResponse',
  '2': [
    {
      '1': 'tenants',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tinbela.admin.v1.TenantSummary',
      '10': 'tenants'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `ListTenantsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTenantsResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0VGVuYW50c1Jlc3BvbnNlEjkKB3RlbmFudHMYASADKAsyHy50aW5iZWxhLmFkbWluLn'
    'YxLlRlbmFudFN1bW1hcnlSB3RlbmFudHMSFAoFdG90YWwYAiABKAVSBXRvdGFs');

@$core.Deprecated('Use tenantSummaryDescriptor instead')
const TenantSummary$json = {
  '1': 'TenantSummary',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'kind', '3': 3, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'member_count', '3': 4, '4': 1, '5': 5, '10': 'memberCount'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'last_activity_at', '3': 6, '4': 1, '5': 9, '10': 'lastActivityAt'},
  ],
};

/// Descriptor for `TenantSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tenantSummaryDescriptor = $convert.base64Decode(
    'Cg1UZW5hbnRTdW1tYXJ5Eg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhIKBG'
    'tpbmQYAyABKAlSBGtpbmQSIQoMbWVtYmVyX2NvdW50GAQgASgFUgttZW1iZXJDb3VudBIdCgpj'
    'cmVhdGVkX2F0GAUgASgJUgljcmVhdGVkQXQSKAoQbGFzdF9hY3Rpdml0eV9hdBgGIAEoCVIObG'
    'FzdEFjdGl2aXR5QXQ=');

@$core.Deprecated('Use getTenantRequestDescriptor instead')
const GetTenantRequest$json = {
  '1': 'GetTenantRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `GetTenantRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTenantRequestDescriptor = $convert.base64Decode(
    'ChBHZXRUZW5hbnRSZXF1ZXN0EhsKCXRlbmFudF9pZBgBIAEoCVIIdGVuYW50SWQ=');

@$core.Deprecated('Use getTenantResponseDescriptor instead')
const GetTenantResponse$json = {
  '1': 'GetTenantResponse',
  '2': [
    {
      '1': 'summary',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tinbela.admin.v1.TenantSummary',
      '10': 'summary'
    },
    {'1': 'members_json', '3': 2, '4': 1, '5': 9, '10': 'membersJson'},
    {'1': 'ledger_json', '3': 3, '4': 1, '5': 9, '10': 'ledgerJson'},
    {'1': 'exceptions_json', '3': 4, '4': 1, '5': 9, '10': 'exceptionsJson'},
  ],
};

/// Descriptor for `GetTenantResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTenantResponseDescriptor = $convert.base64Decode(
    'ChFHZXRUZW5hbnRSZXNwb25zZRI5CgdzdW1tYXJ5GAEgASgLMh8udGluYmVsYS5hZG1pbi52MS'
    '5UZW5hbnRTdW1tYXJ5UgdzdW1tYXJ5EiEKDG1lbWJlcnNfanNvbhgCIAEoCVILbWVtYmVyc0pz'
    'b24SHwoLbGVkZ2VyX2pzb24YAyABKAlSCmxlZGdlckpzb24SJwoPZXhjZXB0aW9uc19qc29uGA'
    'QgASgJUg5leGNlcHRpb25zSnNvbg==');

@$core.Deprecated('Use findUserRequestDescriptor instead')
const FindUserRequest$json = {
  '1': 'FindUserRequest',
  '2': [
    {'1': 'phone_e164', '3': 1, '4': 1, '5': 9, '10': 'phoneE164'},
    {'1': 'firebase_uid', '3': 2, '4': 1, '5': 9, '10': 'firebaseUid'},
  ],
};

/// Descriptor for `FindUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List findUserRequestDescriptor = $convert.base64Decode(
    'Cg9GaW5kVXNlclJlcXVlc3QSHQoKcGhvbmVfZTE2NBgBIAEoCVIJcGhvbmVFMTY0EiEKDGZpcm'
    'ViYXNlX3VpZBgCIAEoCVILZmlyZWJhc2VVaWQ=');

@$core.Deprecated('Use findUserResponseDescriptor instead')
const FindUserResponse$json = {
  '1': 'FindUserResponse',
  '2': [
    {'1': 'user_json', '3': 1, '4': 1, '5': 9, '10': 'userJson'},
  ],
};

/// Descriptor for `FindUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List findUserResponseDescriptor = $convert.base64Decode(
    'ChBGaW5kVXNlclJlc3BvbnNlEhsKCXVzZXJfanNvbhgBIAEoCVIIdXNlckpzb24=');

@$core.Deprecated('Use getMetricsRequestDescriptor instead')
const GetMetricsRequest$json = {
  '1': 'GetMetricsRequest',
  '2': [
    {'1': 'from', '3': 1, '4': 1, '5': 9, '10': 'from'},
    {'1': 'to', '3': 2, '4': 1, '5': 9, '10': 'to'},
  ],
};

/// Descriptor for `GetMetricsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMetricsRequestDescriptor = $convert.base64Decode(
    'ChFHZXRNZXRyaWNzUmVxdWVzdBISCgRmcm9tGAEgASgJUgRmcm9tEg4KAnRvGAIgASgJUgJ0bw'
    '==');

@$core.Deprecated('Use getMetricsResponseDescriptor instead')
const GetMetricsResponse$json = {
  '1': 'GetMetricsResponse',
  '2': [
    {'1': 'active_messes', '3': 1, '4': 1, '5': 5, '10': 'activeMesses'},
    {'1': 'exceptions_today', '3': 2, '4': 1, '5': 5, '10': 'exceptionsToday'},
    {'1': 'closes_this_month', '3': 3, '4': 1, '5': 5, '10': 'closesThisMonth'},
    {
      '1': 'member_links_opened',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'memberLinksOpened'
    },
  ],
};

/// Descriptor for `GetMetricsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMetricsResponseDescriptor = $convert.base64Decode(
    'ChJHZXRNZXRyaWNzUmVzcG9uc2USIwoNYWN0aXZlX21lc3NlcxgBIAEoBVIMYWN0aXZlTWVzc2'
    'VzEikKEGV4Y2VwdGlvbnNfdG9kYXkYAiABKAVSD2V4Y2VwdGlvbnNUb2RheRIqChFjbG9zZXNf'
    'dGhpc19tb250aBgDIAEoBVIPY2xvc2VzVGhpc01vbnRoEi4KE21lbWJlcl9saW5rc19vcGVuZW'
    'QYBCABKAVSEW1lbWJlckxpbmtzT3BlbmVk');

@$core.Deprecated('Use getFlagsRequestDescriptor instead')
const GetFlagsRequest$json = {
  '1': 'GetFlagsRequest',
};

/// Descriptor for `GetFlagsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFlagsRequestDescriptor =
    $convert.base64Decode('Cg9HZXRGbGFnc1JlcXVlc3Q=');

@$core.Deprecated('Use getFlagsResponseDescriptor instead')
const GetFlagsResponse$json = {
  '1': 'GetFlagsResponse',
  '2': [
    {
      '1': 'flags',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.tinbela.admin.v1.GetFlagsResponse.FlagsEntry',
      '10': 'flags'
    },
  ],
  '3': [GetFlagsResponse_FlagsEntry$json],
};

@$core.Deprecated('Use getFlagsResponseDescriptor instead')
const GetFlagsResponse_FlagsEntry$json = {
  '1': 'FlagsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 8, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `GetFlagsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFlagsResponseDescriptor = $convert.base64Decode(
    'ChBHZXRGbGFnc1Jlc3BvbnNlEkMKBWZsYWdzGAEgAygLMi0udGluYmVsYS5hZG1pbi52MS5HZX'
    'RGbGFnc1Jlc3BvbnNlLkZsYWdzRW50cnlSBWZsYWdzGjgKCkZsYWdzRW50cnkSEAoDa2V5GAEg'
    'ASgJUgNrZXkSFAoFdmFsdWUYAiABKAhSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use setFlagRequestDescriptor instead')
const SetFlagRequest$json = {
  '1': 'SetFlagRequest',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 8, '10': 'value'},
  ],
};

/// Descriptor for `SetFlagRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFlagRequestDescriptor = $convert.base64Decode(
    'Cg5TZXRGbGFnUmVxdWVzdBIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCFIFdmFsdW'
    'U=');

@$core.Deprecated('Use setFlagResponseDescriptor instead')
const SetFlagResponse$json = {
  '1': 'SetFlagResponse',
};

/// Descriptor for `SetFlagResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFlagResponseDescriptor =
    $convert.base64Decode('Cg9TZXRGbGFnUmVzcG9uc2U=');

const $core.Map<$core.String, $core.dynamic> AdminServiceBase$json = {
  '1': 'AdminService',
  '2': [
    {
      '1': 'ListTenants',
      '2': '.tinbela.admin.v1.ListTenantsRequest',
      '3': '.tinbela.admin.v1.ListTenantsResponse'
    },
    {
      '1': 'GetTenant',
      '2': '.tinbela.admin.v1.GetTenantRequest',
      '3': '.tinbela.admin.v1.GetTenantResponse'
    },
    {
      '1': 'FindUser',
      '2': '.tinbela.admin.v1.FindUserRequest',
      '3': '.tinbela.admin.v1.FindUserResponse'
    },
    {
      '1': 'GetMetrics',
      '2': '.tinbela.admin.v1.GetMetricsRequest',
      '3': '.tinbela.admin.v1.GetMetricsResponse'
    },
    {
      '1': 'GetFlags',
      '2': '.tinbela.admin.v1.GetFlagsRequest',
      '3': '.tinbela.admin.v1.GetFlagsResponse'
    },
    {
      '1': 'SetFlag',
      '2': '.tinbela.admin.v1.SetFlagRequest',
      '3': '.tinbela.admin.v1.SetFlagResponse'
    },
  ],
};

@$core.Deprecated('Use adminServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    AdminServiceBase$messageJson = {
  '.tinbela.admin.v1.ListTenantsRequest': ListTenantsRequest$json,
  '.tinbela.admin.v1.ListTenantsResponse': ListTenantsResponse$json,
  '.tinbela.admin.v1.TenantSummary': TenantSummary$json,
  '.tinbela.admin.v1.GetTenantRequest': GetTenantRequest$json,
  '.tinbela.admin.v1.GetTenantResponse': GetTenantResponse$json,
  '.tinbela.admin.v1.FindUserRequest': FindUserRequest$json,
  '.tinbela.admin.v1.FindUserResponse': FindUserResponse$json,
  '.tinbela.admin.v1.GetMetricsRequest': GetMetricsRequest$json,
  '.tinbela.admin.v1.GetMetricsResponse': GetMetricsResponse$json,
  '.tinbela.admin.v1.GetFlagsRequest': GetFlagsRequest$json,
  '.tinbela.admin.v1.GetFlagsResponse': GetFlagsResponse$json,
  '.tinbela.admin.v1.GetFlagsResponse.FlagsEntry':
      GetFlagsResponse_FlagsEntry$json,
  '.tinbela.admin.v1.SetFlagRequest': SetFlagRequest$json,
  '.tinbela.admin.v1.SetFlagResponse': SetFlagResponse$json,
};

/// Descriptor for `AdminService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List adminServiceDescriptor = $convert.base64Decode(
    'CgxBZG1pblNlcnZpY2USWgoLTGlzdFRlbmFudHMSJC50aW5iZWxhLmFkbWluLnYxLkxpc3RUZW'
    '5hbnRzUmVxdWVzdBolLnRpbmJlbGEuYWRtaW4udjEuTGlzdFRlbmFudHNSZXNwb25zZRJUCglH'
    'ZXRUZW5hbnQSIi50aW5iZWxhLmFkbWluLnYxLkdldFRlbmFudFJlcXVlc3QaIy50aW5iZWxhLm'
    'FkbWluLnYxLkdldFRlbmFudFJlc3BvbnNlElEKCEZpbmRVc2VyEiEudGluYmVsYS5hZG1pbi52'
    'MS5GaW5kVXNlclJlcXVlc3QaIi50aW5iZWxhLmFkbWluLnYxLkZpbmRVc2VyUmVzcG9uc2USVw'
    'oKR2V0TWV0cmljcxIjLnRpbmJlbGEuYWRtaW4udjEuR2V0TWV0cmljc1JlcXVlc3QaJC50aW5i'
    'ZWxhLmFkbWluLnYxLkdldE1ldHJpY3NSZXNwb25zZRJRCghHZXRGbGFncxIhLnRpbmJlbGEuYW'
    'RtaW4udjEuR2V0RmxhZ3NSZXF1ZXN0GiIudGluYmVsYS5hZG1pbi52MS5HZXRGbGFnc1Jlc3Bv'
    'bnNlEk4KB1NldEZsYWcSIC50aW5iZWxhLmFkbWluLnYxLlNldEZsYWdSZXF1ZXN0GiEudGluYm'
    'VsYS5hZG1pbi52MS5TZXRGbGFnUmVzcG9uc2U=');
