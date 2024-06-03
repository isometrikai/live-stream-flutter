// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class IsmLiveSendGiftModel {
  final String? messageStreamId;
  final String? senderId;
  final String? giftThumbnailUrl;

  final String? amount;
  final String? giftId;
  final String? deviceId;
  final String? giftUrl;
  final String? receiverUserId;
  final String? reciverUserType;
  final String? receiverName;
  final String? pkId;
  final String? receiverStreamId;
  final String? receiverCurrency;
  final String? isometricToken;
  final String? giftTitle;
  final bool? IsGiftVideo;
  final String? currency;
  final bool? isPk;
  IsmLiveSendGiftModel({
    this.messageStreamId,
    this.senderId,
    this.giftThumbnailUrl,
    this.amount,
    this.giftId,
    this.deviceId,
    this.giftUrl,
    this.receiverUserId,
    this.reciverUserType,
    this.receiverName,
    this.pkId,
    this.receiverStreamId,
    this.receiverCurrency,
    this.isometricToken,
    this.giftTitle,
    this.IsGiftVideo,
    this.currency,
    this.isPk,
  });

  IsmLiveSendGiftModel copyWith({
    String? messageStreamId,
    String? senderId,
    String? giftThumbnailUrl,
    String? amount,
    String? giftId,
    String? deviceId,
    String? giftUrl,
    String? receiverUserId,
    String? reciverUserType,
    String? receiverName,
    String? pkId,
    String? receiverStreamId,
    String? receiverCurrency,
    String? isometricToken,
    String? giftTitle,
    bool? IsGiftVideo,
    String? currency,
    bool? isPk,
  }) =>
      IsmLiveSendGiftModel(
        messageStreamId: messageStreamId ?? this.messageStreamId,
        senderId: senderId ?? this.senderId,
        giftThumbnailUrl: giftThumbnailUrl ?? this.giftThumbnailUrl,
        amount: amount ?? this.amount,
        giftId: giftId ?? this.giftId,
        deviceId: deviceId ?? this.deviceId,
        giftUrl: giftUrl ?? this.giftUrl,
        receiverUserId: receiverUserId ?? this.receiverUserId,
        reciverUserType: reciverUserType ?? this.reciverUserType,
        receiverName: receiverName ?? this.receiverName,
        pkId: pkId ?? this.pkId,
        receiverStreamId: receiverStreamId ?? this.receiverStreamId,
        receiverCurrency: receiverCurrency ?? this.receiverCurrency,
        isometricToken: isometricToken ?? this.isometricToken,
        giftTitle: giftTitle ?? this.giftTitle,
        IsGiftVideo: IsGiftVideo ?? this.IsGiftVideo,
        currency: currency ?? this.currency,
        isPk: isPk ?? this.isPk,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'messageStreamId': messageStreamId,
        'senderId': senderId,
        'giftThumbnailUrl': giftThumbnailUrl,
        'amount': amount,
        'giftId': giftId,
        'deviceId': deviceId,
        'giftUrl': giftUrl,
        'receiverUserId': receiverUserId,
        'reciverUserType': reciverUserType,
        'receiverName': receiverName,
        'pkId': pkId,
        'receiverStreamId': receiverStreamId,
        'receiverCurrency': receiverCurrency,
        'isometricToken': isometricToken,
        'giftTitle': giftTitle,
        'IsGiftVideo': IsGiftVideo,
        'currency': currency,
        'isPk': isPk,
      };

  factory IsmLiveSendGiftModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveSendGiftModel(
        messageStreamId: map['messageStreamId'] != null
            ? map['messageStreamId'] as String
            : null,
        senderId: map['senderId'] != null ? map['senderId'] as String : null,
        giftThumbnailUrl: map['giftThumbnailUrl'] != null
            ? map['giftThumbnailUrl'] as String
            : null,
        amount: map['amount'] != null ? map['amount'] as String : null,
        giftId: map['giftId'] != null ? map['giftId'] as String : null,
        deviceId: map['deviceId'] != null ? map['deviceId'] as String : null,
        giftUrl: map['giftUrl'] != null ? map['giftUrl'] as String : null,
        receiverUserId: map['receiverUserId'] != null
            ? map['receiverUserId'] as String
            : null,
        reciverUserType: map['reciverUserType'] != null
            ? map['reciverUserType'] as String
            : null,
        receiverName:
            map['receiverName'] != null ? map['receiverName'] as String : null,
        pkId: map['pkId'] != null ? map['pkId'] as String : null,
        receiverStreamId: map['receiverStreamId'] != null
            ? map['receiverStreamId'] as String
            : null,
        receiverCurrency: map['receiverCurrency'] != null
            ? map['receiverCurrency'] as String
            : null,
        isometricToken: map['isometricToken'] != null
            ? map['isometricToken'] as String
            : null,
        giftTitle: map['giftTitle'] != null ? map['giftTitle'] as String : null,
        IsGiftVideo:
            map['IsGiftVideo'] != null ? map['IsGiftVideo'] as bool : null,
        currency: map['currency'] != null ? map['currency'] as String : null,
        isPk: map['isPk'] != null ? map['isPk'] as bool : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveSendGiftModel.fromJson(String source) =>
      IsmLiveSendGiftModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveSendGiftModel(messageStreamId: $messageStreamId, senderId: $senderId, giftThumbnailUrl: $giftThumbnailUrl, amount: $amount, giftId: $giftId, deviceId: $deviceId, giftUrl: $giftUrl, receiverUserId: $receiverUserId, reciverUserType: $reciverUserType, receiverName: $receiverName, pkId: $pkId, receiverStreamId: $receiverStreamId, receiverCurrency: $receiverCurrency, isometricToken: $isometricToken, giftTitle: $giftTitle, IsGiftVideo: $IsGiftVideo, currency: $currency, isPk: $isPk)';

  @override
  bool operator ==(covariant IsmLiveSendGiftModel other) {
    if (identical(this, other)) return true;

    return other.messageStreamId == messageStreamId &&
        other.senderId == senderId &&
        other.giftThumbnailUrl == giftThumbnailUrl &&
        other.amount == amount &&
        other.giftId == giftId &&
        other.deviceId == deviceId &&
        other.giftUrl == giftUrl &&
        other.receiverUserId == receiverUserId &&
        other.reciverUserType == reciverUserType &&
        other.receiverName == receiverName &&
        other.pkId == pkId &&
        other.receiverStreamId == receiverStreamId &&
        other.receiverCurrency == receiverCurrency &&
        other.isometricToken == isometricToken &&
        other.giftTitle == giftTitle &&
        other.IsGiftVideo == IsGiftVideo &&
        other.currency == currency &&
        other.isPk == isPk;
  }

  @override
  int get hashCode =>
      messageStreamId.hashCode ^
      senderId.hashCode ^
      giftThumbnailUrl.hashCode ^
      amount.hashCode ^
      giftId.hashCode ^
      deviceId.hashCode ^
      giftUrl.hashCode ^
      receiverUserId.hashCode ^
      reciverUserType.hashCode ^
      receiverName.hashCode ^
      pkId.hashCode ^
      receiverStreamId.hashCode ^
      receiverCurrency.hashCode ^
      isometricToken.hashCode ^
      giftTitle.hashCode ^
      IsGiftVideo.hashCode ^
      currency.hashCode ^
      isPk.hashCode;
}
