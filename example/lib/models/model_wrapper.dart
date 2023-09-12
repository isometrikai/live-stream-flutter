// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:appscrip_live_stream_component_example/models/models.dart';

class ModelWrapperExample<T> {
  const ModelWrapperExample({
    required this.data,
    required this.statusCode,
    required this.hasError,
  });

  factory ModelWrapperExample.errorResponse(ResponseModel model) =>
      ModelWrapperExample(
        data: null,
        statusCode: model.statusCode,
        hasError: model.hasError,
      );

  factory ModelWrapperExample.error() => const ModelWrapperExample(
        data: null,
        statusCode: 1000,
        hasError: true,
      );

  final T? data;
  final int statusCode;
  final bool hasError;

  @override
  String toString() =>
      'ModelWrapperExample(data: $data, statusCode: $statusCode, hasError: $hasError)';
}
