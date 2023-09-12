/// This class is used for all the APIs endpoints
class Apis {
  const Apis._();

  static const String baseUrl = 'https://apis.isometrik.io';

  static const String user = '/chat/user';
  static const String allUsers = '/chat/users';
  static const String authenticate = '$user/authenticate';
  static const String presignedurl = '$user/presignedurl/create';
}
