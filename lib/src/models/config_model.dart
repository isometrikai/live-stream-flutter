// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class IsmLiveMeetingConfig {
  final bool pushNotifications;
  IsmLiveMeetingConfig({
    required this.pushNotifications,
  });

  IsmLiveMeetingConfig copyWith({
    bool? pushNotifications,
  }) =>
      IsmLiveMeetingConfig(
        pushNotifications: pushNotifications ?? this.pushNotifications,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'pushNotifications': pushNotifications,
      };

  factory IsmLiveMeetingConfig.fromMap(Map<String, dynamic> map) =>
      IsmLiveMeetingConfig(
        pushNotifications: map['pushNotifications'] as bool,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveMeetingConfig.fromJson(String source) =>
      IsmLiveMeetingConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveMeetingConfig(pushNotifications: $pushNotifications)';

  @override
  bool operator ==(covariant IsmLiveMeetingConfig other) {
    if (identical(this, other)) return true;

    return other.pushNotifications == pushNotifications;
  }

  @override
  int get hashCode => pushNotifications.hashCode;
}
