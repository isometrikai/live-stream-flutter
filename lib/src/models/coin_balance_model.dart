// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class IsmLiveCoinBalanceModel {
  final String? id;
  final String? currency;
  final String? currencySymbol;
  final int? hardLimit;
  final bool? isHardLimitHit;
  final bool? isSoftLimitHit;
  final int? softLimit;
  final int? balance;
  final String? status;
  final String? userId;
  final String? userType;
  final int? timestamp;
  final String? walletType;
  final String? accountId;
  final String? projectId;
  IsmLiveCoinBalanceModel({
    this.id,
    this.currency,
    this.currencySymbol,
    this.hardLimit,
    this.isHardLimitHit,
    this.isSoftLimitHit,
    this.softLimit,
    this.balance,
    this.status,
    this.userId,
    this.userType,
    this.timestamp,
    this.walletType,
    this.accountId,
    this.projectId,
  });

  IsmLiveCoinBalanceModel copyWith({
    String? id,
    String? currency,
    String? currencySymbol,
    int? hardLimit,
    bool? isHardLimitHit,
    bool? isSoftLimitHit,
    int? softLimit,
    int? balance,
    String? status,
    String? userId,
    String? userType,
    int? timestamp,
    String? walletType,
    String? accountId,
    String? projectId,
  }) =>
      IsmLiveCoinBalanceModel(
        id: id ?? this.id,
        currency: currency ?? this.currency,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        hardLimit: hardLimit ?? this.hardLimit,
        isHardLimitHit: isHardLimitHit ?? this.isHardLimitHit,
        isSoftLimitHit: isSoftLimitHit ?? this.isSoftLimitHit,
        softLimit: softLimit ?? this.softLimit,
        balance: balance ?? this.balance,
        status: status ?? this.status,
        userId: userId ?? this.userId,
        userType: userType ?? this.userType,
        timestamp: timestamp ?? this.timestamp,
        walletType: walletType ?? this.walletType,
        accountId: accountId ?? this.accountId,
        projectId: projectId ?? this.projectId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'currency': currency,
        'currencySymbol': currencySymbol,
        'hardLimit': hardLimit,
        'isHardLimitHit': isHardLimitHit,
        'isSoftLimitHit': isSoftLimitHit,
        'softLimit': softLimit,
        'balance': balance,
        'status': status,
        'userId': userId,
        'userType': userType,
        'timestamp': timestamp,
        'walletType': walletType,
        'accountId': accountId,
        'projectId': projectId,
      };

  factory IsmLiveCoinBalanceModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveCoinBalanceModel(
        id: map['id'] != null ? map['id'] as String : null,
        currency: map['currency'] != null ? map['currency'] as String : null,
        currencySymbol: map['currencySymbol'] != null
            ? map['currencySymbol'] as String
            : null,
        hardLimit: map['hardLimit'] != null ? map['hardLimit'] as int : null,
        isHardLimitHit: map['isHardLimitHit'] != null
            ? map['isHardLimitHit'] as bool
            : null,
        isSoftLimitHit: map['isSoftLimitHit'] != null
            ? map['isSoftLimitHit'] as bool
            : null,
        softLimit: map['softLimit'] != null ? map['softLimit'] as int : null,
        balance: map['balance'] != null ? map['balance'] as int : null,
        status: map['status'] != null ? map['status'] as String : null,
        userId: map['userId'] != null ? map['userId'] as String : null,
        userType: map['userType'] != null ? map['userType'] as String : null,
        timestamp: map['timestamp'] != null ? map['timestamp'] as int : null,
        walletType:
            map['walletType'] != null ? map['walletType'] as String : null,
        accountId: map['accountId'] != null ? map['accountId'] as String : null,
        projectId: map['projectId'] != null ? map['projectId'] as String : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveCoinBalanceModel.fromJson(String source) =>
      IsmLiveCoinBalanceModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveCoinBalanceModel(id: $id, currency: $currency, currencySymbol: $currencySymbol, hardLimit: $hardLimit, isHardLimitHit: $isHardLimitHit, isSoftLimitHit: $isSoftLimitHit, softLimit: $softLimit, balance: $balance, status: $status, userId: $userId, userType: $userType, timestamp: $timestamp, walletType: $walletType, accountId: $accountId, projectId: $projectId)';

  @override
  bool operator ==(covariant IsmLiveCoinBalanceModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.currency == currency &&
        other.currencySymbol == currencySymbol &&
        other.hardLimit == hardLimit &&
        other.isHardLimitHit == isHardLimitHit &&
        other.isSoftLimitHit == isSoftLimitHit &&
        other.softLimit == softLimit &&
        other.balance == balance &&
        other.status == status &&
        other.userId == userId &&
        other.userType == userType &&
        other.timestamp == timestamp &&
        other.walletType == walletType &&
        other.accountId == accountId &&
        other.projectId == projectId;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      currency.hashCode ^
      currencySymbol.hashCode ^
      hardLimit.hashCode ^
      isHardLimitHit.hashCode ^
      isSoftLimitHit.hashCode ^
      softLimit.hashCode ^
      balance.hashCode ^
      status.hashCode ^
      userId.hashCode ^
      userType.hashCode ^
      timestamp.hashCode ^
      walletType.hashCode ^
      accountId.hashCode ^
      projectId.hashCode;
}
