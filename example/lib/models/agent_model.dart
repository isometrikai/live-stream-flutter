import 'dart:convert';

class AgentModel {
  AgentModel({
    required this.clientName,
    required this.createdUnderProjectId,
    required this.phone,
    required this.countryCode,
    required this.phoneIsoCode,
    this.otp,
  });

  factory AgentModel.fromMap(Map<String, dynamic> map) => AgentModel(
        clientName: map['clientName'] as String,
        createdUnderProjectId: map['createdUnderProjectId'] as String,
        phone: map['phone'] as String,
        countryCode: map['countryCode'] as String,
        phoneIsoCode: map['phoneIsoCode'] as String,
        otp: map['otp'] != null ? map['otp'] as String : null,
      );

  factory AgentModel.fromJson(String source) =>
      AgentModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final String clientName;
  final String createdUnderProjectId;
  final String phone;
  final String countryCode;
  final String phoneIsoCode;
  final String? otp;

  AgentModel copyWith({
    String? clientName,
    String? createdUnderProjectId,
    String? phone,
    String? countryCode,
    String? phoneIsoCode,
    String? otp,
  }) =>
      AgentModel(
        clientName: clientName ?? this.clientName,
        createdUnderProjectId:
            createdUnderProjectId ?? this.createdUnderProjectId,
        phone: phone ?? this.phone,
        countryCode: countryCode ?? this.countryCode,
        phoneIsoCode: phoneIsoCode ?? this.phoneIsoCode,
        otp: otp ?? this.otp,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'clientName': clientName,
        'createdUnderProjectId': createdUnderProjectId,
        'phone': phone,
        'countryCode': countryCode,
        'phoneIsoCode': phoneIsoCode,
        'otp': otp,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'AgentModel(clientName: $clientName, createdUnderProjectId: $createdUnderProjectId, phone: $phone, countryCode: $countryCode, phoneIsoCode: $phoneIsoCode, otp: $otp)';

  @override
  bool operator ==(covariant AgentModel other) {
    if (identical(this, other)) return true;

    return other.clientName == clientName &&
        other.createdUnderProjectId == createdUnderProjectId &&
        other.phone == phone &&
        other.countryCode == countryCode &&
        other.phoneIsoCode == phoneIsoCode &&
        other.otp == otp;
  }

  @override
  int get hashCode =>
      clientName.hashCode ^
      createdUnderProjectId.hashCode ^
      phone.hashCode ^
      countryCode.hashCode ^
      phoneIsoCode.hashCode ^
      otp.hashCode;
}
