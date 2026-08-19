// This is a generated file - do not edit.
//
// Generated from tinbela/money/v1/money.proto.

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

@$core.Deprecated('Use entryKindDescriptor instead')
const EntryKind$json = {
  '1': 'EntryKind',
  '2': [
    {'1': 'ENTRY_KIND_UNSPECIFIED', '2': 0},
    {'1': 'ENTRY_KIND_FOOD_COST', '2': 1},
    {'1': 'ENTRY_KIND_DEPOSIT', '2': 2},
    {'1': 'ENTRY_KIND_SHARED_COST', '2': 3},
    {'1': 'ENTRY_KIND_RENT_PAYOUT', '2': 4},
    {'1': 'ENTRY_KIND_ADJUST', '2': 5},
  ],
};

/// Descriptor for `EntryKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List entryKindDescriptor = $convert.base64Decode(
    'CglFbnRyeUtpbmQSGgoWRU5UUllfS0lORF9VTlNQRUNJRklFRBAAEhgKFEVOVFJZX0tJTkRfRk'
    '9PRF9DT1NUEAESFgoSRU5UUllfS0lORF9ERVBPU0lUEAISGgoWRU5UUllfS0lORF9TSEFSRURf'
    'Q09TVBADEhoKFkVOVFJZX0tJTkRfUkVOVF9QQVlPVVQQBBIVChFFTlRSWV9LSU5EX0FESlVTVB'
    'AF');

@$core.Deprecated('Use addLedgerEntryRequestDescriptor instead')
const AddLedgerEntryRequest$json = {
  '1': 'AddLedgerEntryRequest',
  '2': [
    {'1': 'mess_id', '3': 1, '4': 1, '5': 9, '10': 'messId'},
    {
      '1': 'kind',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.tinbela.money.v1.EntryKind',
      '10': 'kind'
    },
    {'1': 'amount_paisa', '3': 3, '4': 1, '5': 3, '10': 'amountPaisa'},
    {'1': 'category', '3': 4, '4': 1, '5': 9, '10': 'category'},
    {'1': 'membership_id', '3': 5, '4': 1, '5': 9, '10': 'membershipId'},
    {
      '1': 'occurred_on',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Date',
      '10': 'occurredOn'
    },
    {'1': 'note', '3': 7, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `AddLedgerEntryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addLedgerEntryRequestDescriptor = $convert.base64Decode(
    'ChVBZGRMZWRnZXJFbnRyeVJlcXVlc3QSFwoHbWVzc19pZBgBIAEoCVIGbWVzc0lkEi8KBGtpbm'
    'QYAiABKA4yGy50aW5iZWxhLm1vbmV5LnYxLkVudHJ5S2luZFIEa2luZBIhCgxhbW91bnRfcGFp'
    'c2EYAyABKANSC2Ftb3VudFBhaXNhEhoKCGNhdGVnb3J5GAQgASgJUghjYXRlZ29yeRIjCg1tZW'
    '1iZXJzaGlwX2lkGAUgASgJUgxtZW1iZXJzaGlwSWQSNgoLb2NjdXJyZWRfb24YBiABKAsyFS50'
    'aW5iZWxhLmNvcmUudjEuRGF0ZVIKb2NjdXJyZWRPbhISCgRub3RlGAcgASgJUgRub3Rl');

@$core.Deprecated('Use addLedgerEntryResponseDescriptor instead')
const AddLedgerEntryResponse$json = {
  '1': 'AddLedgerEntryResponse',
  '2': [
    {
      '1': 'entry',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tinbela.money.v1.LedgerEntry',
      '10': 'entry'
    },
  ],
};

/// Descriptor for `AddLedgerEntryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addLedgerEntryResponseDescriptor =
    $convert.base64Decode(
        'ChZBZGRMZWRnZXJFbnRyeVJlc3BvbnNlEjMKBWVudHJ5GAEgASgLMh0udGluYmVsYS5tb25leS'
        '52MS5MZWRnZXJFbnRyeVIFZW50cnk=');

@$core.Deprecated('Use ledgerEntryDescriptor instead')
const LedgerEntry$json = {
  '1': 'LedgerEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'kind',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.tinbela.money.v1.EntryKind',
      '10': 'kind'
    },
    {
      '1': 'amount',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Money',
      '10': 'amount'
    },
    {'1': 'category', '3': 4, '4': 1, '5': 9, '10': 'category'},
    {'1': 'membership_id', '3': 5, '4': 1, '5': 9, '10': 'membershipId'},
    {
      '1': 'member_display_name',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'memberDisplayName'
    },
    {
      '1': 'occurred_on',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Date',
      '10': 'occurredOn'
    },
    {'1': 'note', '3': 8, '4': 1, '5': 9, '10': 'note'},
    {'1': 'entered_by_name', '3': 9, '4': 1, '5': 9, '10': 'enteredByName'},
    {'1': 'voided', '3': 10, '4': 1, '5': 8, '10': 'voided'},
  ],
};

/// Descriptor for `LedgerEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ledgerEntryDescriptor = $convert.base64Decode(
    'CgtMZWRnZXJFbnRyeRIOCgJpZBgBIAEoCVICaWQSLwoEa2luZBgCIAEoDjIbLnRpbmJlbGEubW'
    '9uZXkudjEuRW50cnlLaW5kUgRraW5kEi4KBmFtb3VudBgDIAEoCzIWLnRpbmJlbGEuY29yZS52'
    'MS5Nb25leVIGYW1vdW50EhoKCGNhdGVnb3J5GAQgASgJUghjYXRlZ29yeRIjCg1tZW1iZXJzaG'
    'lwX2lkGAUgASgJUgxtZW1iZXJzaGlwSWQSLgoTbWVtYmVyX2Rpc3BsYXlfbmFtZRgGIAEoCVIR'
    'bWVtYmVyRGlzcGxheU5hbWUSNgoLb2NjdXJyZWRfb24YByABKAsyFS50aW5iZWxhLmNvcmUudj'
    'EuRGF0ZVIKb2NjdXJyZWRPbhISCgRub3RlGAggASgJUgRub3RlEiYKD2VudGVyZWRfYnlfbmFt'
    'ZRgJIAEoCVINZW50ZXJlZEJ5TmFtZRIWCgZ2b2lkZWQYCiABKAhSBnZvaWRlZA==');

@$core.Deprecated('Use voidLedgerEntryRequestDescriptor instead')
const VoidLedgerEntryRequest$json = {
  '1': 'VoidLedgerEntryRequest',
  '2': [
    {'1': 'mess_id', '3': 1, '4': 1, '5': 9, '10': 'messId'},
    {'1': 'entry_id', '3': 2, '4': 1, '5': 9, '10': 'entryId'},
  ],
};

/// Descriptor for `VoidLedgerEntryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voidLedgerEntryRequestDescriptor =
    $convert.base64Decode(
        'ChZWb2lkTGVkZ2VyRW50cnlSZXF1ZXN0EhcKB21lc3NfaWQYASABKAlSBm1lc3NJZBIZCghlbn'
        'RyeV9pZBgCIAEoCVIHZW50cnlJZA==');

@$core.Deprecated('Use voidLedgerEntryResponseDescriptor instead')
const VoidLedgerEntryResponse$json = {
  '1': 'VoidLedgerEntryResponse',
};

/// Descriptor for `VoidLedgerEntryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voidLedgerEntryResponseDescriptor =
    $convert.base64Decode('ChdWb2lkTGVkZ2VyRW50cnlSZXNwb25zZQ==');

@$core.Deprecated('Use getAccountsRequestDescriptor instead')
const GetAccountsRequest$json = {
  '1': 'GetAccountsRequest',
  '2': [
    {'1': 'mess_id', '3': 1, '4': 1, '5': 9, '10': 'messId'},
    {'1': 'period_id', '3': 2, '4': 1, '5': 9, '10': 'periodId'},
  ],
};

/// Descriptor for `GetAccountsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAccountsRequestDescriptor = $convert.base64Decode(
    'ChJHZXRBY2NvdW50c1JlcXVlc3QSFwoHbWVzc19pZBgBIAEoCVIGbWVzc0lkEhsKCXBlcmlvZF'
    '9pZBgCIAEoCVIIcGVyaW9kSWQ=');

@$core.Deprecated('Use getAccountsResponseDescriptor instead')
const GetAccountsResponse$json = {
  '1': 'GetAccountsResponse',
  '2': [
    {
      '1': 'meal_rate',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Money',
      '10': 'mealRate'
    },
    {
      '1': 'total_food',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Money',
      '10': 'totalFood'
    },
    {
      '1': 'total_deposits',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Money',
      '10': 'totalDeposits'
    },
    {'1': 'total_meals', '3': 4, '4': 1, '5': 5, '10': 'totalMeals'},
    {
      '1': 'remainder',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Money',
      '10': 'remainder'
    },
    {
      '1': 'members',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.tinbela.money.v1.MemberBalance',
      '10': 'members'
    },
  ],
};

/// Descriptor for `GetAccountsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAccountsResponseDescriptor = $convert.base64Decode(
    'ChNHZXRBY2NvdW50c1Jlc3BvbnNlEjMKCW1lYWxfcmF0ZRgBIAEoCzIWLnRpbmJlbGEuY29yZS'
    '52MS5Nb25leVIIbWVhbFJhdGUSNQoKdG90YWxfZm9vZBgCIAEoCzIWLnRpbmJlbGEuY29yZS52'
    'MS5Nb25leVIJdG90YWxGb29kEj0KDnRvdGFsX2RlcG9zaXRzGAMgASgLMhYudGluYmVsYS5jb3'
    'JlLnYxLk1vbmV5Ug10b3RhbERlcG9zaXRzEh8KC3RvdGFsX21lYWxzGAQgASgFUgp0b3RhbE1l'
    'YWxzEjQKCXJlbWFpbmRlchgFIAEoCzIWLnRpbmJlbGEuY29yZS52MS5Nb25leVIJcmVtYWluZG'
    'VyEjkKB21lbWJlcnMYBiADKAsyHy50aW5iZWxhLm1vbmV5LnYxLk1lbWJlckJhbGFuY2VSB21l'
    'bWJlcnM=');

@$core.Deprecated('Use memberBalanceDescriptor instead')
const MemberBalance$json = {
  '1': 'MemberBalance',
  '2': [
    {'1': 'membership_id', '3': 1, '4': 1, '5': 9, '10': 'membershipId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'meals_qty', '3': 3, '4': 1, '5': 5, '10': 'mealsQty'},
    {
      '1': 'food_cost',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Money',
      '10': 'foodCost'
    },
    {
      '1': 'deposits',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Money',
      '10': 'deposits'
    },
    {
      '1': 'balance',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.tinbela.core.v1.Money',
      '10': 'balance'
    },
  ],
};

/// Descriptor for `MemberBalance`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List memberBalanceDescriptor = $convert.base64Decode(
    'Cg1NZW1iZXJCYWxhbmNlEiMKDW1lbWJlcnNoaXBfaWQYASABKAlSDG1lbWJlcnNoaXBJZBIhCg'
    'xkaXNwbGF5X25hbWUYAiABKAlSC2Rpc3BsYXlOYW1lEhsKCW1lYWxzX3F0eRgDIAEoBVIIbWVh'
    'bHNRdHkSMwoJZm9vZF9jb3N0GAQgASgLMhYudGluYmVsYS5jb3JlLnYxLk1vbmV5Ughmb29kQ2'
    '9zdBIyCghkZXBvc2l0cxgFIAEoCzIWLnRpbmJlbGEuY29yZS52MS5Nb25leVIIZGVwb3NpdHMS'
    'MAoHYmFsYW5jZRgGIAEoCzIWLnRpbmJlbGEuY29yZS52MS5Nb25leVIHYmFsYW5jZQ==');

@$core.Deprecated('Use previewCloseRequestDescriptor instead')
const PreviewCloseRequest$json = {
  '1': 'PreviewCloseRequest',
  '2': [
    {'1': 'mess_id', '3': 1, '4': 1, '5': 9, '10': 'messId'},
    {'1': 'period_id', '3': 2, '4': 1, '5': 9, '10': 'periodId'},
  ],
};

/// Descriptor for `PreviewCloseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List previewCloseRequestDescriptor = $convert.base64Decode(
    'ChNQcmV2aWV3Q2xvc2VSZXF1ZXN0EhcKB21lc3NfaWQYASABKAlSBm1lc3NJZBIbCglwZXJpb2'
    'RfaWQYAiABKAlSCHBlcmlvZElk');

@$core.Deprecated('Use previewCloseResponseDescriptor instead')
const PreviewCloseResponse$json = {
  '1': 'PreviewCloseResponse',
  '2': [
    {
      '1': 'accounts',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.tinbela.money.v1.GetAccountsResponse',
      '10': 'accounts'
    },
    {'1': 'warnings', '3': 2, '4': 3, '5': 9, '10': 'warnings'},
  ],
};

/// Descriptor for `PreviewCloseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List previewCloseResponseDescriptor = $convert.base64Decode(
    'ChRQcmV2aWV3Q2xvc2VSZXNwb25zZRJBCghhY2NvdW50cxgBIAEoCzIlLnRpbmJlbGEubW9uZX'
    'kudjEuR2V0QWNjb3VudHNSZXNwb25zZVIIYWNjb3VudHMSGgoId2FybmluZ3MYAiADKAlSCHdh'
    'cm5pbmdz');

@$core.Deprecated('Use closePeriodRequestDescriptor instead')
const ClosePeriodRequest$json = {
  '1': 'ClosePeriodRequest',
  '2': [
    {'1': 'mess_id', '3': 1, '4': 1, '5': 9, '10': 'messId'},
    {'1': 'period_id', '3': 2, '4': 1, '5': 9, '10': 'periodId'},
  ],
};

/// Descriptor for `ClosePeriodRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closePeriodRequestDescriptor = $convert.base64Decode(
    'ChJDbG9zZVBlcmlvZFJlcXVlc3QSFwoHbWVzc19pZBgBIAEoCVIGbWVzc0lkEhsKCXBlcmlvZF'
    '9pZBgCIAEoCVIIcGVyaW9kSWQ=');

@$core.Deprecated('Use closePeriodResponseDescriptor instead')
const ClosePeriodResponse$json = {
  '1': 'ClosePeriodResponse',
  '2': [
    {'1': 'statement_id', '3': 1, '4': 1, '5': 9, '10': 'statementId'},
    {'1': 'next_period_id', '3': 2, '4': 1, '5': 9, '10': 'nextPeriodId'},
  ],
};

/// Descriptor for `ClosePeriodResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List closePeriodResponseDescriptor = $convert.base64Decode(
    'ChNDbG9zZVBlcmlvZFJlc3BvbnNlEiEKDHN0YXRlbWVudF9pZBgBIAEoCVILc3RhdGVtZW50SW'
    'QSJAoObmV4dF9wZXJpb2RfaWQYAiABKAlSDG5leHRQZXJpb2RJZA==');

@$core.Deprecated('Use getStatementRequestDescriptor instead')
const GetStatementRequest$json = {
  '1': 'GetStatementRequest',
  '2': [
    {'1': 'mess_id', '3': 1, '4': 1, '5': 9, '10': 'messId'},
    {'1': 'period_id', '3': 2, '4': 1, '5': 9, '10': 'periodId'},
  ],
};

/// Descriptor for `GetStatementRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatementRequestDescriptor = $convert.base64Decode(
    'ChNHZXRTdGF0ZW1lbnRSZXF1ZXN0EhcKB21lc3NfaWQYASABKAlSBm1lc3NJZBIbCglwZXJpb2'
    'RfaWQYAiABKAlSCHBlcmlvZElk');

@$core.Deprecated('Use getStatementResponseDescriptor instead')
const GetStatementResponse$json = {
  '1': 'GetStatementResponse',
  '2': [
    {'1': 'period_label', '3': 1, '4': 1, '5': 9, '10': 'periodLabel'},
    {
      '1': 'accounts',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.tinbela.money.v1.GetAccountsResponse',
      '10': 'accounts'
    },
    {'1': 'closed_at', '3': 3, '4': 1, '5': 9, '10': 'closedAt'},
    {'1': 'immutable', '3': 4, '4': 1, '5': 8, '10': 'immutable'},
  ],
};

/// Descriptor for `GetStatementResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatementResponseDescriptor = $convert.base64Decode(
    'ChRHZXRTdGF0ZW1lbnRSZXNwb25zZRIhCgxwZXJpb2RfbGFiZWwYASABKAlSC3BlcmlvZExhYm'
    'VsEkEKCGFjY291bnRzGAIgASgLMiUudGluYmVsYS5tb25leS52MS5HZXRBY2NvdW50c1Jlc3Bv'
    'bnNlUghhY2NvdW50cxIbCgljbG9zZWRfYXQYAyABKAlSCGNsb3NlZEF0EhwKCWltbXV0YWJsZR'
    'gEIAEoCFIJaW1tdXRhYmxl');

const $core.Map<$core.String, $core.dynamic> MoneyServiceBase$json = {
  '1': 'MoneyService',
  '2': [
    {
      '1': 'AddLedgerEntry',
      '2': '.tinbela.money.v1.AddLedgerEntryRequest',
      '3': '.tinbela.money.v1.AddLedgerEntryResponse'
    },
    {
      '1': 'VoidLedgerEntry',
      '2': '.tinbela.money.v1.VoidLedgerEntryRequest',
      '3': '.tinbela.money.v1.VoidLedgerEntryResponse'
    },
    {
      '1': 'GetAccounts',
      '2': '.tinbela.money.v1.GetAccountsRequest',
      '3': '.tinbela.money.v1.GetAccountsResponse'
    },
    {
      '1': 'PreviewClose',
      '2': '.tinbela.money.v1.PreviewCloseRequest',
      '3': '.tinbela.money.v1.PreviewCloseResponse'
    },
    {
      '1': 'ClosePeriod',
      '2': '.tinbela.money.v1.ClosePeriodRequest',
      '3': '.tinbela.money.v1.ClosePeriodResponse'
    },
    {
      '1': 'GetStatement',
      '2': '.tinbela.money.v1.GetStatementRequest',
      '3': '.tinbela.money.v1.GetStatementResponse'
    },
  ],
};

@$core.Deprecated('Use moneyServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    MoneyServiceBase$messageJson = {
  '.tinbela.money.v1.AddLedgerEntryRequest': AddLedgerEntryRequest$json,
  '.tinbela.core.v1.Date': $0.Date$json,
  '.tinbela.money.v1.AddLedgerEntryResponse': AddLedgerEntryResponse$json,
  '.tinbela.money.v1.LedgerEntry': LedgerEntry$json,
  '.tinbela.core.v1.Money': $0.Money$json,
  '.tinbela.core.v1.MathExplain': $0.MathExplain$json,
  '.tinbela.core.v1.MathTerm': $0.MathTerm$json,
  '.tinbela.money.v1.VoidLedgerEntryRequest': VoidLedgerEntryRequest$json,
  '.tinbela.money.v1.VoidLedgerEntryResponse': VoidLedgerEntryResponse$json,
  '.tinbela.money.v1.GetAccountsRequest': GetAccountsRequest$json,
  '.tinbela.money.v1.GetAccountsResponse': GetAccountsResponse$json,
  '.tinbela.money.v1.MemberBalance': MemberBalance$json,
  '.tinbela.money.v1.PreviewCloseRequest': PreviewCloseRequest$json,
  '.tinbela.money.v1.PreviewCloseResponse': PreviewCloseResponse$json,
  '.tinbela.money.v1.ClosePeriodRequest': ClosePeriodRequest$json,
  '.tinbela.money.v1.ClosePeriodResponse': ClosePeriodResponse$json,
  '.tinbela.money.v1.GetStatementRequest': GetStatementRequest$json,
  '.tinbela.money.v1.GetStatementResponse': GetStatementResponse$json,
};

/// Descriptor for `MoneyService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List moneyServiceDescriptor = $convert.base64Decode(
    'CgxNb25leVNlcnZpY2USYwoOQWRkTGVkZ2VyRW50cnkSJy50aW5iZWxhLm1vbmV5LnYxLkFkZE'
    'xlZGdlckVudHJ5UmVxdWVzdBooLnRpbmJlbGEubW9uZXkudjEuQWRkTGVkZ2VyRW50cnlSZXNw'
    'b25zZRJmCg9Wb2lkTGVkZ2VyRW50cnkSKC50aW5iZWxhLm1vbmV5LnYxLlZvaWRMZWRnZXJFbn'
    'RyeVJlcXVlc3QaKS50aW5iZWxhLm1vbmV5LnYxLlZvaWRMZWRnZXJFbnRyeVJlc3BvbnNlEloK'
    'C0dldEFjY291bnRzEiQudGluYmVsYS5tb25leS52MS5HZXRBY2NvdW50c1JlcXVlc3QaJS50aW'
    '5iZWxhLm1vbmV5LnYxLkdldEFjY291bnRzUmVzcG9uc2USXQoMUHJldmlld0Nsb3NlEiUudGlu'
    'YmVsYS5tb25leS52MS5QcmV2aWV3Q2xvc2VSZXF1ZXN0GiYudGluYmVsYS5tb25leS52MS5Qcm'
    'V2aWV3Q2xvc2VSZXNwb25zZRJaCgtDbG9zZVBlcmlvZBIkLnRpbmJlbGEubW9uZXkudjEuQ2xv'
    'c2VQZXJpb2RSZXF1ZXN0GiUudGluYmVsYS5tb25leS52MS5DbG9zZVBlcmlvZFJlc3BvbnNlEl'
    '0KDEdldFN0YXRlbWVudBIlLnRpbmJlbGEubW9uZXkudjEuR2V0U3RhdGVtZW50UmVxdWVzdBom'
    'LnRpbmJlbGEubW9uZXkudjEuR2V0U3RhdGVtZW50UmVzcG9uc2U=');
