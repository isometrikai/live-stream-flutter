import 'dart:convert';

class IsmLiveUserConfig {
  factory IsmLiveUserConfig.fromMap(Map<String, dynamic> map) =>
      IsmLiveUserConfig(
        userToken: map['userToken'] as String,
        userId: map['userId'] as String,
        firstName: map['firstName'] as String,
        lastName: map['lastName'] as String,
        userEmail: map['userEmail'] != null ? map['userEmail'] as String : null,
        userProfile:
            map['userProfile'] != null ? map['userProfile'] as String : null,
      );

  factory IsmLiveUserConfig.fromJson(String source) =>
      IsmLiveUserConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  const IsmLiveUserConfig({
    required this.userToken,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.userEmail,
    required this.userProfile,
  });

  final String userToken;
  final String userId;
  final String firstName;
  final String lastName;
  final String? userEmail;
  final String? userProfile;

  @override
  String toString() =>
      'IsmLiveUserConfig(userToken: $userToken, userId: $userId, firstName: $firstName, lastName: $lastName, userEmail: $userEmail, userProfile: $userProfile)';

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userToken': userToken,
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'userEmail': userEmail,
        'userProfile': userProfile,
      };

  String toJson() => json.encode(toMap());
}
