class IsmLiveUserConfig {
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
}
