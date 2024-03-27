import 'dart:convert';

class AgentDetailsModel {
  AgentDetailsModel({
    required this.clientName,
    required this.userId,
    required this.keycloakUserId,
    required this.userType,
    required this.userToken,
    required this.isometrikUserId,
    required this.licenseKey,
    required this.projectId,
    required this.appSecret,
    required this.keysetId,
    required this.accountId,
    required this.name,
    required this.phoneNumber,
    required this.phoneIsoCode,
    required this.phoneCountryCode,
    required this.phoneVerified,
    required this.token,
    required this.userProfileUrl,
    required this.isFirstTimeLogin,
  });

  factory AgentDetailsModel.fromMap(Map<String, dynamic> map) =>
      AgentDetailsModel(
        clientName: map['clientName'] as String,
        userId: map['userId'] as String,
        keycloakUserId: map['keycloakUserId'] as String,
        userType: map['userType'] as String,
        userToken: map['userToken'] as String,
        isometrikUserId: map['isometrikUserId'] as String,
        licenseKey: map['licenseKey'] as String,
        projectId: map['projectId'] as String,
        appSecret: map['appSecret'] as String,
        keysetId: map['keysetId'] as String,
        accountId: map['accountId'] as String,
        name: map['name'] as String,
        phoneNumber: map['phoneNumber'] as String,
        phoneIsoCode: map['phoneIsoCode'] as String,
        phoneCountryCode: map['phoneCountryCode'] as String,
        phoneVerified: map['phoneVerified'] as bool,
        token: TokenModel.fromMap(map['token'] as Map<String, dynamic>),
        userProfileUrl: map['userProfileUrl'] as String,
        isFirstTimeLogin: map['isFirstTimeLogin'] as bool,
      );

  factory AgentDetailsModel.fromJson(String source) =>
      AgentDetailsModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final String clientName;
  final String userId;
  final String keycloakUserId;
  final String userType;
  final String userToken;
  final String isometrikUserId;
  final String licenseKey;
  final String projectId;
  final String appSecret;
  final String keysetId;
  final String accountId;
  final String name;
  final String phoneNumber;
  final String phoneIsoCode;
  final String phoneCountryCode;
  final bool phoneVerified;
  final TokenModel token;
  final String userProfileUrl;
  final bool isFirstTimeLogin;

  AgentDetailsModel copyWith({
    String? clientName,
    String? userId,
    String? keycloakUserId,
    String? userType,
    String? userToken,
    String? isometrikUserId,
    String? licenseKey,
    String? projectId,
    String? appSecret,
    String? keysetId,
    String? accountId,
    String? name,
    String? phoneNumber,
    String? phoneIsoCode,
    String? phoneCountryCode,
    bool? phoneVerified,
    TokenModel? token,
    String? userProfileUrl,
    bool? isFirstTimeLogin,
  }) =>
      AgentDetailsModel(
        clientName: clientName ?? this.clientName,
        userId: userId ?? this.userId,
        keycloakUserId: keycloakUserId ?? this.keycloakUserId,
        userType: userType ?? this.userType,
        userToken: userToken ?? this.userToken,
        isometrikUserId: isometrikUserId ?? this.isometrikUserId,
        licenseKey: licenseKey ?? this.licenseKey,
        projectId: projectId ?? this.projectId,
        appSecret: appSecret ?? this.appSecret,
        keysetId: keysetId ?? this.keysetId,
        accountId: accountId ?? this.accountId,
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        phoneIsoCode: phoneIsoCode ?? this.phoneIsoCode,
        phoneCountryCode: phoneCountryCode ?? this.phoneCountryCode,
        phoneVerified: phoneVerified ?? this.phoneVerified,
        token: token ?? this.token,
        userProfileUrl: userProfileUrl ?? this.userProfileUrl,
        isFirstTimeLogin: isFirstTimeLogin ?? this.isFirstTimeLogin,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'clientName': clientName,
        'userId': userId,
        'keycloakUserId': keycloakUserId,
        'userType': userType,
        'userToken': userToken,
        'isometrikUserId': isometrikUserId,
        'licenseKey': licenseKey,
        'projectId': projectId,
        'appSecret': appSecret,
        'keysetId': keysetId,
        'accountId': accountId,
        'name': name,
        'phoneNumber': phoneNumber,
        'phoneIsoCode': phoneIsoCode,
        'phoneCountryCode': phoneCountryCode,
        'phoneVerified': phoneVerified,
        'token': token.toMap(),
        'userProfileUrl': userProfileUrl,
        'isFirstTimeLogin': isFirstTimeLogin,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'AgentDetailsModel(clientName: $clientName, userId: $userId, keycloakUserId: $keycloakUserId, userType: $userType, userToken: $userToken, isometrikUserId: $isometrikUserId, licenseKey: $licenseKey, projectId: $projectId, appSecret: $appSecret, keysetId: $keysetId, accountId: $accountId, name: $name, phoneNumber: $phoneNumber, phoneIsoCode: $phoneIsoCode, phoneCountryCode: $phoneCountryCode, phoneVerified: $phoneVerified, token: $token, userProfileUrl: $userProfileUrl, isFirstTimeLogin: $isFirstTimeLogin)';

  @override
  bool operator ==(covariant AgentDetailsModel other) {
    if (identical(this, other)) return true;

    return other.clientName == clientName &&
        other.userId == userId &&
        other.keycloakUserId == keycloakUserId &&
        other.userType == userType &&
        other.userToken == userToken &&
        other.isometrikUserId == isometrikUserId &&
        other.licenseKey == licenseKey &&
        other.projectId == projectId &&
        other.appSecret == appSecret &&
        other.keysetId == keysetId &&
        other.accountId == accountId &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.phoneIsoCode == phoneIsoCode &&
        other.phoneCountryCode == phoneCountryCode &&
        other.phoneVerified == phoneVerified &&
        other.token == token &&
        other.userProfileUrl == userProfileUrl &&
        other.isFirstTimeLogin == isFirstTimeLogin;
  }

  @override
  int get hashCode =>
      clientName.hashCode ^
      userId.hashCode ^
      keycloakUserId.hashCode ^
      userType.hashCode ^
      userToken.hashCode ^
      isometrikUserId.hashCode ^
      licenseKey.hashCode ^
      projectId.hashCode ^
      appSecret.hashCode ^
      keysetId.hashCode ^
      accountId.hashCode ^
      name.hashCode ^
      phoneNumber.hashCode ^
      phoneIsoCode.hashCode ^
      phoneCountryCode.hashCode ^
      phoneVerified.hashCode ^
      token.hashCode ^
      userProfileUrl.hashCode ^
      isFirstTimeLogin.hashCode;
}

class TokenModel {
  TokenModel({
    required this.accessToken,
    required this.expiresIn,
    required this.notBeforepolicy,
    required this.refreshExpiresIn,
    required this.refreshToken,
    required this.scope,
    required this.sessionState,
    required this.tokenType,
  });

  factory TokenModel.fromMap(Map<String, dynamic> map) => TokenModel(
        accessToken: map['access_token'] as String,
        expiresIn: map['expires_in'] as num,
        notBeforepolicy: map['not-before-policy'] as int,
        refreshExpiresIn: map['refresh_expires_in'] as num,
        refreshToken: map['refresh_token'] as String,
        scope: map['scope'] as String,
        sessionState: map['session_state'] as String,
        tokenType: map['token_type'] as String,
      );

  factory TokenModel.fromJson(String source) =>
      TokenModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final String accessToken;
  final num expiresIn;
  final int notBeforepolicy;
  final num refreshExpiresIn;
  final String refreshToken;
  final String scope;
  final String sessionState;
  final String tokenType;

  TokenModel copyWith({
    String? accessToken,
    num? expiresIn,
    int? notBeforepolicy,
    num? refreshExpiresIn,
    String? refreshToken,
    String? scope,
    String? sessionState,
    String? tokenType,
  }) =>
      TokenModel(
        accessToken: accessToken ?? this.accessToken,
        expiresIn: expiresIn ?? this.expiresIn,
        notBeforepolicy: notBeforepolicy ?? this.notBeforepolicy,
        refreshExpiresIn: refreshExpiresIn ?? this.refreshExpiresIn,
        refreshToken: refreshToken ?? this.refreshToken,
        scope: scope ?? this.scope,
        sessionState: sessionState ?? this.sessionState,
        tokenType: tokenType ?? this.tokenType,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'access_token': accessToken,
        'expires_in': expiresIn,
        'not-before-policy': notBeforepolicy,
        'refresh_expires_in': refreshExpiresIn,
        'refresh_token': refreshToken,
        'scope': scope,
        'session_state': sessionState,
        'token_type': tokenType,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'TokenModel(accessToken: $accessToken, expiresIn: $expiresIn, notBeforepolicy: $notBeforepolicy, refreshExpiresIn: $refreshExpiresIn, refreshToken: $refreshToken, scope: $scope, sessionState: $sessionState, tokenType: $tokenType)';

  @override
  bool operator ==(covariant TokenModel other) {
    if (identical(this, other)) return true;

    return other.accessToken == accessToken &&
        other.expiresIn == expiresIn &&
        other.notBeforepolicy == notBeforepolicy &&
        other.refreshExpiresIn == refreshExpiresIn &&
        other.refreshToken == refreshToken &&
        other.scope == scope &&
        other.sessionState == sessionState &&
        other.tokenType == tokenType;
  }

  @override
  int get hashCode =>
      accessToken.hashCode ^
      expiresIn.hashCode ^
      notBeforepolicy.hashCode ^
      refreshExpiresIn.hashCode ^
      refreshToken.hashCode ^
      scope.hashCode ^
      sessionState.hashCode ^
      tokenType.hashCode;
}
