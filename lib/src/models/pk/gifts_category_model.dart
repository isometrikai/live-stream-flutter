import 'dart:convert';

class IsmLiveGiftsCategoryModel {
  IsmLiveGiftsCategoryModel({
    this.id,
    this.giftTitle,
    this.giftAnimationImage,
    this.giftImage,
    this.giftTag,
    this.virtualCurrency,
    this.giftGroupId,
    this.applicationId,
    this.clientName,
  });

  factory IsmLiveGiftsCategoryModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveGiftsCategoryModel(
        id: map['id'] != null ? map['id'] as String : null,
        giftTitle: map['giftTitle'] != null ? map['giftTitle'] as String : null,
        giftAnimationImage: map['giftAnimationImage'] != null
            ? map['giftAnimationImage'] as String
            : null,
        giftImage: map['giftImage'] != null ? map['giftImage'] as String : null,
        giftTag: map['giftTag'] != null ? map['giftTag'] as String : null,
        virtualCurrency: map['virtualCurrency'] != null
            ? map['virtualCurrency'] as int
            : null,
        giftGroupId:
            map['giftGroupId'] != null ? map['giftGroupId'] as String : null,
        applicationId: map['applicationId'] != null
            ? map['applicationId'] as String
            : null,
        clientName:
            map['clientName'] != null ? map['clientName'] as String : null,
      );

  factory IsmLiveGiftsCategoryModel.fromJson(String source) =>
      IsmLiveGiftsCategoryModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final String? id;
  final String? giftTitle;
  final String? giftAnimationImage;
  final String? giftImage;
  final String? giftTag;
  final int? virtualCurrency;
  final String? giftGroupId;
  final String? applicationId;
  final String? clientName;

  IsmLiveGiftsCategoryModel copyWith({
    String? id,
    String? giftTitle,
    String? giftAnimationImage,
    String? giftImage,
    String? giftTag,
    int? virtualCurrency,
    String? giftGroupId,
    String? applicationId,
    String? clientName,
  }) =>
      IsmLiveGiftsCategoryModel(
        id: id ?? this.id,
        giftTitle: giftTitle ?? this.giftTitle,
        giftAnimationImage: giftAnimationImage ?? this.giftAnimationImage,
        giftImage: giftImage ?? this.giftImage,
        giftTag: giftTag ?? this.giftTag,
        virtualCurrency: virtualCurrency ?? this.virtualCurrency,
        giftGroupId: giftGroupId ?? this.giftGroupId,
        applicationId: applicationId ?? this.applicationId,
        clientName: clientName ?? this.clientName,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'giftTitle': giftTitle,
        'giftAnimationImage': giftAnimationImage,
        'giftImage': giftImage,
        'giftTag': giftTag,
        'virtualCurrency': virtualCurrency,
        'giftGroupId': giftGroupId,
        'applicationId': applicationId,
        'clientName': clientName,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveGiftsCategoryModel(id: $id, giftTitle: $giftTitle, giftAnimationImage: $giftAnimationImage, giftImage: $giftImage, giftTag: $giftTag, virtualCurrency: $virtualCurrency, giftGroupId: $giftGroupId, applicationId: $applicationId, clientName: $clientName)';

  @override
  bool operator ==(covariant IsmLiveGiftsCategoryModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.giftTitle == giftTitle &&
        other.giftAnimationImage == giftAnimationImage &&
        other.giftImage == giftImage &&
        other.giftTag == giftTag &&
        other.virtualCurrency == virtualCurrency &&
        other.giftGroupId == giftGroupId &&
        other.applicationId == applicationId &&
        other.clientName == clientName;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      giftTitle.hashCode ^
      giftAnimationImage.hashCode ^
      giftImage.hashCode ^
      giftTag.hashCode ^
      virtualCurrency.hashCode ^
      giftGroupId.hashCode ^
      applicationId.hashCode ^
      clientName.hashCode;
}
