// This is a generated file - do not edit.
//
// Generated from tinbela/core/v1/core.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'core.pb.dart' as $1;
import 'core.pbjson.dart';

export 'core.pb.dart';

abstract class CoreServiceBase extends $pb.GeneratedService {
  $async.Future<$1.GetMeResponse> getMe(
      $pb.ServerContext ctx, $1.GetMeRequest request);
  $async.Future<$1.CreateMessResponse> createMess(
      $pb.ServerContext ctx, $1.CreateMessRequest request);
  $async.Future<$1.AddMemberResponse> addMember(
      $pb.ServerContext ctx, $1.AddMemberRequest request);
  $async.Future<$1.ListMembersResponse> listMembers(
      $pb.ServerContext ctx, $1.ListMembersRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetMe':
        return $1.GetMeRequest();
      case 'CreateMess':
        return $1.CreateMessRequest();
      case 'AddMember':
        return $1.AddMemberRequest();
      case 'ListMembers':
        return $1.ListMembersRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetMe':
        return getMe(ctx, request as $1.GetMeRequest);
      case 'CreateMess':
        return createMess(ctx, request as $1.CreateMessRequest);
      case 'AddMember':
        return addMember(ctx, request as $1.AddMemberRequest);
      case 'ListMembers':
        return listMembers(ctx, request as $1.ListMembersRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CoreServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => CoreServiceBase$messageJson;
}
