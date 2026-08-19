// This is a generated file - do not edit.
//
// Generated from tinbela/money/v1/money.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'money.pb.dart' as $1;
import 'money.pbjson.dart';

export 'money.pb.dart';

abstract class MoneyServiceBase extends $pb.GeneratedService {
  $async.Future<$1.AddLedgerEntryResponse> addLedgerEntry(
      $pb.ServerContext ctx, $1.AddLedgerEntryRequest request);
  $async.Future<$1.VoidLedgerEntryResponse> voidLedgerEntry(
      $pb.ServerContext ctx, $1.VoidLedgerEntryRequest request);
  $async.Future<$1.GetAccountsResponse> getAccounts(
      $pb.ServerContext ctx, $1.GetAccountsRequest request);
  $async.Future<$1.PreviewCloseResponse> previewClose(
      $pb.ServerContext ctx, $1.PreviewCloseRequest request);
  $async.Future<$1.ClosePeriodResponse> closePeriod(
      $pb.ServerContext ctx, $1.ClosePeriodRequest request);
  $async.Future<$1.GetStatementResponse> getStatement(
      $pb.ServerContext ctx, $1.GetStatementRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'AddLedgerEntry':
        return $1.AddLedgerEntryRequest();
      case 'VoidLedgerEntry':
        return $1.VoidLedgerEntryRequest();
      case 'GetAccounts':
        return $1.GetAccountsRequest();
      case 'PreviewClose':
        return $1.PreviewCloseRequest();
      case 'ClosePeriod':
        return $1.ClosePeriodRequest();
      case 'GetStatement':
        return $1.GetStatementRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'AddLedgerEntry':
        return addLedgerEntry(ctx, request as $1.AddLedgerEntryRequest);
      case 'VoidLedgerEntry':
        return voidLedgerEntry(ctx, request as $1.VoidLedgerEntryRequest);
      case 'GetAccounts':
        return getAccounts(ctx, request as $1.GetAccountsRequest);
      case 'PreviewClose':
        return previewClose(ctx, request as $1.PreviewCloseRequest);
      case 'ClosePeriod':
        return closePeriod(ctx, request as $1.ClosePeriodRequest);
      case 'GetStatement':
        return getStatement(ctx, request as $1.GetStatementRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MoneyServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => MoneyServiceBase$messageJson;
}
