// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:intl/intl.dart';

class IsmLiveCoinTransactionModel {
  final num? amount;
  final num? closingBalance;
  final String? currency;
  final String? description;
  final String? initiatedBy;
  final String? notes;
  final num? openingBalance;
  final String? orderId;
  final int? txnTimeStamp;
  final String? txnType;
  final String? paymentTypeMode;
  final String? walletId;
  final String? transactionId;
  final String? accountId;
  final String? projectId;
  IsmLiveCoinTransactionModel({
    this.amount,
    this.closingBalance,
    this.currency,
    this.description,
    this.initiatedBy,
    this.notes,
    this.openingBalance,
    this.orderId,
    this.txnTimeStamp,
    this.txnType,
    this.paymentTypeMode,
    this.walletId,
    this.transactionId,
    this.accountId,
    this.projectId,
  });

  IsmLiveCoinTransactionModel copyWith({
    num? amount,
    num? closingBalance,
    String? currency,
    String? description,
    String? initiatedBy,
    String? notes,
    num? openingBalance,
    String? orderId,
    int? txnTimeStamp,
    String? txnType,
    String? paymentTypeMode,
    String? walletId,
    String? transactionId,
    String? accountId,
    String? projectId,
  }) =>
      IsmLiveCoinTransactionModel(
        amount: amount ?? this.amount,
        closingBalance: closingBalance ?? this.closingBalance,
        currency: currency ?? this.currency,
        description: description ?? this.description,
        initiatedBy: initiatedBy ?? this.initiatedBy,
        notes: notes ?? this.notes,
        openingBalance: openingBalance ?? this.openingBalance,
        orderId: orderId ?? this.orderId,
        txnTimeStamp: txnTimeStamp ?? this.txnTimeStamp,
        txnType: txnType ?? this.txnType,
        paymentTypeMode: paymentTypeMode ?? this.paymentTypeMode,
        walletId: walletId ?? this.walletId,
        transactionId: transactionId ?? this.transactionId,
        accountId: accountId ?? this.accountId,
        projectId: projectId ?? this.projectId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'amount': amount,
        'closingBalance': closingBalance,
        'currency': currency,
        'description': description,
        'initiatedBy': initiatedBy,
        'notes': notes,
        'openingBalance': openingBalance,
        'orderId': orderId,
        'txnTimeStamp': txnTimeStamp,
        'txnType': txnType,
        'paymentTypeMode': paymentTypeMode,
        'walletId': walletId,
        'transactionId': transactionId,
        'accountId': accountId,
        'projectId': projectId,
      };

  factory IsmLiveCoinTransactionModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveCoinTransactionModel(
        amount: map['amount'] != null ? map['amount'] as num : null,
        closingBalance:
            map['closingBalance'] != null ? map['closingBalance'] as num : null,
        currency: map['currency'] != null ? map['currency'] as String : null,
        description:
            map['description'] != null ? map['description'] as String : null,
        initiatedBy:
            map['initiatedBy'] != null ? map['initiatedBy'] as String : null,
        notes: map['notes'] != null ? map['notes'] as String : null,
        openingBalance:
            map['openingBalance'] != null ? map['openingBalance'] as num : null,
        orderId: map['orderId'] != null ? map['orderId'] as String : null,
        txnTimeStamp:
            map['txnTimeStamp'] != null ? map['txnTimeStamp'] as int : null,
        txnType: map['txnType'] != null ? map['txnType'] as String : null,
        paymentTypeMode: map['paymentTypeMode'] != null
            ? map['paymentTypeMode'] as String
            : null,
        walletId: map['walletId'] != null ? map['walletId'] as String : null,
        transactionId: map['transactionId'] != null
            ? map['transactionId'] as String
            : null,
        accountId: map['accountId'] != null ? map['accountId'] as String : null,
        projectId: map['projectId'] != null ? map['projectId'] as String : null,
      );

  String get formattedDuration {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(
      txnTimeStamp?.toInt() ?? 0,
    );

    return DateFormat('yyyy MMMM dd, h:mm a').format(dateTime);
  }

  String toJson() => json.encode(toMap());

  factory IsmLiveCoinTransactionModel.fromJson(String source) =>
      IsmLiveCoinTransactionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveCoinTransactionModel(amount: $amount, closingBalance: $closingBalance, currency: $currency, description: $description, initiatedBy: $initiatedBy, notes: $notes, openingBalance: $openingBalance, orderId: $orderId, txnTimeStamp: $txnTimeStamp, txnType: $txnType, paymentTypeMode: $paymentTypeMode, walletId: $walletId, transactionId: $transactionId, accountId: $accountId, projectId: $projectId)';

  @override
  bool operator ==(covariant IsmLiveCoinTransactionModel other) {
    if (identical(this, other)) return true;

    return other.amount == amount &&
        other.closingBalance == closingBalance &&
        other.currency == currency &&
        other.description == description &&
        other.initiatedBy == initiatedBy &&
        other.notes == notes &&
        other.openingBalance == openingBalance &&
        other.orderId == orderId &&
        other.txnTimeStamp == txnTimeStamp &&
        other.txnType == txnType &&
        other.paymentTypeMode == paymentTypeMode &&
        other.walletId == walletId &&
        other.transactionId == transactionId &&
        other.accountId == accountId &&
        other.projectId == projectId;
  }

  @override
  int get hashCode =>
      amount.hashCode ^
      closingBalance.hashCode ^
      currency.hashCode ^
      description.hashCode ^
      initiatedBy.hashCode ^
      notes.hashCode ^
      openingBalance.hashCode ^
      orderId.hashCode ^
      txnTimeStamp.hashCode ^
      txnType.hashCode ^
      paymentTypeMode.hashCode ^
      walletId.hashCode ^
      transactionId.hashCode ^
      accountId.hashCode ^
      projectId.hashCode;
}
