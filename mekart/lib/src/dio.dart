// Version 1.0.0

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

String stringifyDioException(DioException exception) {
  final buffer = StringBuffer(defaultDioExceptionReadableStringBuilder(exception));
  if (exception.error case final CheckedFromJsonException exception) {
    buffer.writeln(jsonEncode(exception.map));
    buffer.writeln(exception.innerStack);
  }
  buffer.writeln(exception.stackTrace);
  return buffer.toString();
}

extension ResponseExtensions<T> on Response<T> {
  R convert<R>(R Function(T data) converter) {
    try {
      final data = this.data as T;
      return converter(data);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: requestOptions,
        response: this,
        error: error,
        stackTrace: stackTrace,
        message: 'Could not convert data to `$R`.',
      );
    }
  }
}

extension JsonMapResponseExtensions on Response<Map<String, dynamic>> {
  R convertKey<R>(String key, R Function(Object? data) converter) =>
      convert((data) => data.convert(key, converter));
}

extension MapDioExtensions on Map<String, dynamic> {
  R convert<R>(String key, R Function(Object? data) converter) =>
      $checkedConvert(this, key, converter);
}
