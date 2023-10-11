import 'dart:convert';

class IsmLiveResponseModel {
  factory IsmLiveResponseModel.error() => const IsmLiveResponseModel(
        data: '',
        statusCode: 1000,
        hasError: true,
      );

  factory IsmLiveResponseModel.message(
    String message, {
    bool isSuccess = false,
    int statusCode = 1000,
  }) =>
      IsmLiveResponseModel(
        data: jsonEncode({'error': message}),
        hasError: !isSuccess,
        statusCode: statusCode,
      );

  factory IsmLiveResponseModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveResponseModel(
        data: map['data'] as String,
        hasError: map['hasError'] as bool,
        statusCode: map['statusCode'] != null ? map['statusCode'] as int : 1000,
      );

  factory IsmLiveResponseModel.fromJson(String source) =>
      IsmLiveResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  const IsmLiveResponseModel({
    required this.data,
    required this.hasError,
    this.statusCode = 1000,
  });

  Map<String, dynamic> decode() => jsonDecode(data) as Map<String, dynamic>;

  final String data;
  final bool hasError;
  final int statusCode;

  IsmLiveResponseModel copyWith({
    String? data,
    bool? hasError,
    int? statusCode,
  }) =>
      IsmLiveResponseModel(
        data: data ?? this.data,
        hasError: hasError ?? this.hasError,
        statusCode: statusCode ?? this.statusCode,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'data': data,
        'hasError': hasError,
        'statusCode': statusCode,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveResponseModel(data: $data, hasError: $hasError, statusCode: $statusCode)';

  @override
  bool operator ==(covariant IsmLiveResponseModel other) {
    if (identical(this, other)) return true;

    return other.data == data &&
        other.hasError == hasError &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode => data.hashCode ^ hasError.hashCode ^ statusCode.hashCode;
}
