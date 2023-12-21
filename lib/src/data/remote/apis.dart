/// This class is used for all the APIs endpoints
class IsmLiveApis {
  const IsmLiveApis._();

  static const String baseUrl = 'https://apis.isometrik.io';

  static const String wsUrl = 'wss://streaming.isometrik.io';
  static const String user = '/chat/user';
  static const String allUsers = '/chat/users';
  static const String userDetails = '$user/details';
  static const String authenticate = '$user/authenticate';
  static const String presignedurl = '$user/presignedurl/create';

  static const String userSubscription = '/gs/v2/subscription';

  // Streams
  static const String getStreams = '/streaming/v2/streams';
}
