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
  static const String _streaming = '/streaming/v2';
  static const String stream = '$_streaming/stream';
  static const String getStreams = '$_streaming/streams';
  static const String viewer = '$_streaming/viewer';
  static const String getStreamMembers = '$_streaming/members';
  static const String getStreamViewer = '$_streaming/viewers';
  static const String leaveStream = '$viewer/leave';
  static const String postMessage = '$_streaming/message';
  static const String getMessages = '$_streaming/messages';
  // static const String getEndStream = '$_streaming/analytics';
}
