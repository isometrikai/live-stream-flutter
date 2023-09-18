import 'dart:convert';

class IsmLiveMetaDataModel {
  const IsmLiveMetaDataModel({
    this.openMeeting,
  });

  factory IsmLiveMetaDataModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveMetaDataModel(
        openMeeting: map['open meeting'] as bool? ?? false,
      );

  factory IsmLiveMetaDataModel.fromJson(String source) =>
      IsmLiveMetaDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final bool? openMeeting;

  IsmLiveMetaDataModel copyWith({
    bool? openMeeting,
  }) =>
      IsmLiveMetaDataModel(
        openMeeting: openMeeting ?? this.openMeeting,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'openMeeting': openMeeting,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'IsmLiveMetaDataModel(openMeeting: $openMeeting)';

  @override
  bool operator ==(covariant IsmLiveMetaDataModel other) {
    if (identical(this, other)) return true;

    return other.openMeeting == openMeeting;
  }

  @override
  int get hashCode => openMeeting.hashCode;
}
