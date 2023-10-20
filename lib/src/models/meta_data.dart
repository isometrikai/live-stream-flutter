import 'dart:convert';

class IsmLiveMetaData {
  const IsmLiveMetaData({
    this.country = '',
    this.openMeeting = false,
    this.profilePic,
  });

  factory IsmLiveMetaData.fromMap(Map<String, dynamic> map) => IsmLiveMetaData(
        country: map['country'] as String,
        openMeeting: map['open meeting'] as bool? ?? false,
        profilePic: map['profilePic'] as String?,
      );

  factory IsmLiveMetaData.fromJson(String source) =>
      IsmLiveMetaData.fromMap(json.decode(source) as Map<String, dynamic>);

  final String country;
  final bool openMeeting;
  final String? profilePic;

  IsmLiveMetaData copyWith({
    String? country,
    bool? openMeeting,
    String? profilePic,
  }) =>
      IsmLiveMetaData(
        country: country ?? this.country,
        openMeeting: openMeeting ?? this.openMeeting,
        profilePic: profilePic ?? this.profilePic,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'country': country,
        'openMeeting': openMeeting,
        'profilePic': profilePic,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveMetaData(country: $country, openMeeting: $openMeeting, profilePic: $profilePic)';

  @override
  bool operator ==(covariant IsmLiveMetaData other) {
    if (identical(this, other)) return true;

    return other.country == country &&
        other.openMeeting == openMeeting &&
        other.profilePic == profilePic;
  }

  @override
  int get hashCode =>
      country.hashCode ^ openMeeting.hashCode ^ profilePic.hashCode;
}
