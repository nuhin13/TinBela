// This is a generated file - do not edit.
//
// Generated from tinbela/meals/v1/meals.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'meals.pb.dart' as $1;
import 'meals.pbjson.dart';

export 'meals.pb.dart';

abstract class MealsServiceBase extends $pb.GeneratedService {
  $async.Future<$1.SetPatternsResponse> setPatterns(
      $pb.ServerContext ctx, $1.SetPatternsRequest request);
  $async.Future<$1.CreateExceptionResponse> createException(
      $pb.ServerContext ctx, $1.CreateExceptionRequest request);
  $async.Future<$1.VoidExceptionResponse> voidException(
      $pb.ServerContext ctx, $1.VoidExceptionRequest request);
  $async.Future<$1.GetDayResponse> getDay(
      $pb.ServerContext ctx, $1.GetDayRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SetPatterns':
        return $1.SetPatternsRequest();
      case 'CreateException':
        return $1.CreateExceptionRequest();
      case 'VoidException':
        return $1.VoidExceptionRequest();
      case 'GetDay':
        return $1.GetDayRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SetPatterns':
        return setPatterns(ctx, request as $1.SetPatternsRequest);
      case 'CreateException':
        return createException(ctx, request as $1.CreateExceptionRequest);
      case 'VoidException':
        return voidException(ctx, request as $1.VoidExceptionRequest);
      case 'GetDay':
        return getDay(ctx, request as $1.GetDayRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MealsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => MealsServiceBase$messageJson;
}
