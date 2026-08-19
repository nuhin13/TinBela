// This is a generated file - do not edit.
//
// Generated from tinbela/admin/v1/admin.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'admin.pb.dart' as $0;
import 'admin.pbjson.dart';

export 'admin.pb.dart';

abstract class AdminServiceBase extends $pb.GeneratedService {
  $async.Future<$0.ListTenantsResponse> listTenants(
      $pb.ServerContext ctx, $0.ListTenantsRequest request);
  $async.Future<$0.GetTenantResponse> getTenant(
      $pb.ServerContext ctx, $0.GetTenantRequest request);
  $async.Future<$0.FindUserResponse> findUser(
      $pb.ServerContext ctx, $0.FindUserRequest request);
  $async.Future<$0.GetMetricsResponse> getMetrics(
      $pb.ServerContext ctx, $0.GetMetricsRequest request);
  $async.Future<$0.GetFlagsResponse> getFlags(
      $pb.ServerContext ctx, $0.GetFlagsRequest request);
  $async.Future<$0.SetFlagResponse> setFlag(
      $pb.ServerContext ctx, $0.SetFlagRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListTenants':
        return $0.ListTenantsRequest();
      case 'GetTenant':
        return $0.GetTenantRequest();
      case 'FindUser':
        return $0.FindUserRequest();
      case 'GetMetrics':
        return $0.GetMetricsRequest();
      case 'GetFlags':
        return $0.GetFlagsRequest();
      case 'SetFlag':
        return $0.SetFlagRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListTenants':
        return listTenants(ctx, request as $0.ListTenantsRequest);
      case 'GetTenant':
        return getTenant(ctx, request as $0.GetTenantRequest);
      case 'FindUser':
        return findUser(ctx, request as $0.FindUserRequest);
      case 'GetMetrics':
        return getMetrics(ctx, request as $0.GetMetricsRequest);
      case 'GetFlags':
        return getFlags(ctx, request as $0.GetFlagsRequest);
      case 'SetFlag':
        return setFlag(ctx, request as $0.SetFlagRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => AdminServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => AdminServiceBase$messageJson;
}
