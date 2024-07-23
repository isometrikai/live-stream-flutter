// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class IsmLiveGiftModel {
  final String? message;
  final String? giftName;
  final String? giftCategoryName;
  final int? coinsValue;
  final String? giftThumbnailUrl;
  final String? reciverStreamUserId;
  final String? receiverName;
  final int? totalCoinsRecived;
  IsmLiveGiftModel({
    this.message,
    this.giftName,
    this.giftCategoryName,
    this.coinsValue,
    this.giftThumbnailUrl,
    this.reciverStreamUserId,
    this.receiverName,
    this.totalCoinsRecived,
  });

  IsmLiveGiftModel copyWith({
    String? message,
    String? giftName,
    String? giftCategoryName,
    int? coinsValue,
    String? giftThumbnailUrl,
    String? reciverStreamUserId,
    String? receiverName,
    int? totalCoinsRecived,
  }) =>
      IsmLiveGiftModel(
        message: message ?? this.message,
        giftName: giftName ?? this.giftName,
        giftCategoryName: giftCategoryName ?? this.giftCategoryName,
        coinsValue: coinsValue ?? this.coinsValue,
        giftThumbnailUrl: giftThumbnailUrl ?? this.giftThumbnailUrl,
        reciverStreamUserId: reciverStreamUserId ?? this.reciverStreamUserId,
        receiverName: receiverName ?? this.receiverName,
        totalCoinsRecived: totalCoinsRecived ?? this.totalCoinsRecived,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'message': message,
        'giftName': giftName,
        'giftCategoryName': giftCategoryName,
        'coinsValue': coinsValue,
        'giftThumbnailUrl': giftThumbnailUrl,
        'reciverStreamUserId': reciverStreamUserId,
        'receiverName': receiverName,
        'totalCoinsRecived': totalCoinsRecived,
      };

  factory IsmLiveGiftModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveGiftModel(
        message: map['message'] != null ? map['message'] as String : null,
        giftName: map['giftName'] != null ? map['giftName'] as String : null,
        giftCategoryName: map['giftCategoryName'] != null
            ? map['giftCategoryName'] as String
            : null,
        coinsValue: map['coinsValue'] != null ? map['coinsValue'] as int : null,
        giftThumbnailUrl: map['giftThumbnailUrl'] != null
            ? map['giftThumbnailUrl'] as String
            : null,
        reciverStreamUserId: map['reciverStreamUserId'] != null
            ? map['reciverStreamUserId'] as String
            : null,
        receiverName:
            map['receiverName'] != null ? map['receiverName'] as String : null,
        totalCoinsRecived: map['totalCoinsRecived'] != null
            ? map['totalCoinsRecived'] as int
            : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveGiftModel.fromJson(String source) =>
      IsmLiveGiftModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveGiftModel(message: $message, giftName: $giftName, giftCategoryName: $giftCategoryName, coinsValue: $coinsValue, giftThumbnailUrl: $giftThumbnailUrl, reciverStreamUserId: $reciverStreamUserId, receiverName: $receiverName, totalCoinsRecived: $totalCoinsRecived)';

  @override
  bool operator ==(covariant IsmLiveGiftModel other) {
    if (identical(this, other)) return true;

    return other.message == message &&
        other.giftName == giftName &&
        other.giftCategoryName == giftCategoryName &&
        other.coinsValue == coinsValue &&
        other.giftThumbnailUrl == giftThumbnailUrl &&
        other.reciverStreamUserId == reciverStreamUserId &&
        other.receiverName == receiverName &&
        other.totalCoinsRecived == totalCoinsRecived;
  }

  @override
  int get hashCode =>
      message.hashCode ^
      giftName.hashCode ^
      giftCategoryName.hashCode ^
      coinsValue.hashCode ^
      giftThumbnailUrl.hashCode ^
      reciverStreamUserId.hashCode ^
      receiverName.hashCode ^
      totalCoinsRecived.hashCode;
}
