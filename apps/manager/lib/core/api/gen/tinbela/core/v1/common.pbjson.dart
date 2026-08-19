// This is a generated file - do not edit.
//
// Generated from tinbela/core/v1/common.proto.

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

@$core.Deprecated('Use moneyDescriptor instead')
const Money$json = {
  '1': 'Money',
  '2': [
    {'1': 'paisa', '3': 1, '4': 1, '5': 3, '10': 'paisa'},
    {'1': 'display', '3': 2, '4': 1, '5': 9, '10': 'display'},
    {
      '1': 'math',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.MathExplain',
      '10': 'math'
    },
  ],
};

/// Descriptor for `Money`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List moneyDescriptor = $convert.base64Decode(
    'CgVNb25leRIUCgVwYWlzYRgBIAEoA1IFcGFpc2ESGAoHZGlzcGxheRgCIAEoCVIHZGlzcGxheR'
    'IwCgRtYXRoGAMgASgLMhwudGluYmVsYS5jb3JlLnYxLk1hdGhFeHBsYWluUgRtYXRo');

@$core.Deprecated('Use mathExplainDescriptor instead')
const MathExplain$json = {
  '1': 'MathExplain',
  '2': [
    {'1': 'formula', '3': 1, '4': 1, '5': 9, '10': 'formula'},
    {
      '1': 'terms',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.tinbela.core.v1.MathTerm',
      '10': 'terms'
    },
    {'1': 'note', '3': 3, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `MathExplain`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mathExplainDescriptor = $convert.base64Decode(
    'CgtNYXRoRXhwbGFpbhIYCgdmb3JtdWxhGAEgASgJUgdmb3JtdWxhEi8KBXRlcm1zGAIgAygLMh'
    'kudGluYmVsYS5jb3JlLnYxLk1hdGhUZXJtUgV0ZXJtcxISCgRub3RlGAMgASgJUgRub3Rl');

@$core.Deprecated('Use mathTermDescriptor instead')
const MathTerm$json = {
  '1': 'MathTerm',
  '2': [
    {'1': 'label', '3': 1, '4': 1, '5': 9, '10': 'label'},
    {'1': 'display', '3': 2, '4': 1, '5': 9, '10': 'display'},
  ],
};

/// Descriptor for `MathTerm`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mathTermDescriptor = $convert.base64Decode(
    'CghNYXRoVGVybRIUCgVsYWJlbBgBIAEoCVIFbGFiZWwSGAoHZGlzcGxheRgCIAEoCVIHZGlzcG'
    'xheQ==');

@$core.Deprecated('Use dateDescriptor instead')
const Date$json = {
  '1': 'Date',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `Date`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dateDescriptor =
    $convert.base64Decode('CgREYXRlEhQKBXZhbHVlGAEgASgJUgV2YWx1ZQ==');

@$core.Deprecated('Use dateRangeDescriptor instead')
const DateRange$json = {
  '1': 'DateRange',
  '2': [
    {
      '1': 'from',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Date',
      '10': 'from'
    },
    {
      '1': 'to',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Date',
      '10': 'to'
    },
  ],
};

/// Descriptor for `DateRange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dateRangeDescriptor = $convert.base64Decode(
    'CglEYXRlUmFuZ2USKQoEZnJvbRgBIAEoCzIVLnRpbmJlbGEuY29yZS52MS5EYXRlUgRmcm9tEi'
    'UKAnRvGAIgASgLMhUudGluYmVsYS5jb3JlLnYxLkRhdGVSAnRv');
