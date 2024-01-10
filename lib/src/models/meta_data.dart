import 'dart:convert';

class IsmLiveMetaData {
  const IsmLiveMetaData({
    this.country = 'India',
    this.openMeeting = false,
    this.openStream = false,
    this.secretMessage = false,
    this.profilePic,
  });

  factory IsmLiveMetaData.fromMap(Map<String, dynamic> map) => IsmLiveMetaData(
        country: map['country'] as String? ?? '',
        openMeeting: map['open meeting'] as bool? ?? false,
        profilePic: map['profilePic'] as String?,
        openStream: map['open stream'] as bool? ?? false,
        secretMessage: map['secretMessage'] as bool? ?? false,
      );

  factory IsmLiveMetaData.fromJson(String source) => IsmLiveMetaData.fromMap(json.decode(source) as Map<String, dynamic>);

  final String country;
  final bool openMeeting;
  final String? profilePic;
  final bool openStream;
  final bool secretMessage;

  IsmLiveMetaData copyWith({
    String? country,
    bool? openMeeting,
    String? profilePic,
    bool? openStream,
    bool? secretMessage,
  }) =>
      IsmLiveMetaData(
        country: country ?? this.country,
        openMeeting: openMeeting ?? this.openMeeting,
        profilePic: profilePic ?? this.profilePic,
        openStream: openStream ?? this.openStream,
        secretMessage: secretMessage ?? this.secretMessage,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'country': country,
        'openMeeting': openMeeting,
        'profilePic': profilePic,
        'openStream': openStream,
        'secretMessage': secretMessage,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveMetaData(country: $country, openMeeting: $openMeeting, profilePic: $profilePic, openStream: $openStream, secretMessage: $secretMessage)';

  @override
  bool operator ==(covariant IsmLiveMetaData other) {
    if (identical(this, other)) return true;

    return other.country == country &&
        other.openMeeting == openMeeting &&
        other.profilePic == profilePic &&
        other.openStream == openStream &&
        other.secretMessage == secretMessage;
  }

  @override
  int get hashCode => country.hashCode ^ openMeeting.hashCode ^ profilePic.hashCode ^ openStream.hashCode ^ secretMessage.hashCode;
}
