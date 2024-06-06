import 'dart:convert';

class IsmLiveGiftGroupModel {
  IsmLiveGiftGroupModel({
    this.id,
    this.giftTitle,
    this.giftImage,
    this.giftCount,
    this.applicationId,
    this.clientName,
  });

  factory IsmLiveGiftGroupModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveGiftGroupModel(
        id: map['id'] != null ? map['id'] as String : null,
        giftTitle: map['giftTitle'] != null ? map['giftTitle'] as String : null,
        giftImage: map['giftImage'] != null ? map['giftImage'] as String : null,
        giftCount: map['giftCount'] != null ? map['giftCount'] as int : null,
        applicationId: map['applicationId'] != null
            ? map['applicationId'] as String
            : null,
        clientName:
            map['clientName'] != null ? map['clientName'] as String : null,
      );

  factory IsmLiveGiftGroupModel.fromJson(String source) =>
      IsmLiveGiftGroupModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final String? id;
  final String? giftTitle;
  final String? giftImage;
  final int? giftCount;
  final String? applicationId;
  final String? clientName;

  IsmLiveGiftGroupModel copyWith({
    String? id,
    String? giftTitle,
    String? giftImage,
    int? giftCount,
    String? applicationId,
    String? clientName,
  }) =>
      IsmLiveGiftGroupModel(
        id: id ?? this.id,
        giftTitle: giftTitle ?? this.giftTitle,
        giftImage: giftImage ?? this.giftImage,
        giftCount: giftCount ?? this.giftCount,
        applicationId: applicationId ?? this.applicationId,
        clientName: clientName ?? this.clientName,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'giftTitle': giftTitle,
        'giftImage': giftImage,
        'giftCount': giftCount,
        'applicationId': applicationId,
        'clientName': clientName,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveGiftGroupModel(id: $id, giftTitle: $giftTitle, giftImage: $giftImage, giftCount: $giftCount, applicationId: $applicationId, clientName: $clientName)';

  @override
  bool operator ==(covariant IsmLiveGiftGroupModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.giftTitle == giftTitle &&
        other.giftImage == giftImage &&
        other.giftCount == giftCount &&
        other.applicationId == applicationId &&
        other.clientName == clientName;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      giftTitle.hashCode ^
      giftImage.hashCode ^
      giftCount.hashCode ^
      applicationId.hashCode ^
      clientName.hashCode;
}
