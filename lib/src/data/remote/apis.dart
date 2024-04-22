/// This class is used for all the APIs endpoints
class IsmLiveApis {
  const IsmLiveApis._();

  static const String baseUrl = 'https://apis.isometrik.io';

  // static const String baseUrlStream = 'https://service-apis.isometrik.io';
  static const String baseUrlStream = 'https://admin-apis.isometrik.io/live/v2';

  // static const String devBaseUrl = 'https://admin-apis.isometrik.io';
  static const String devBaseUrl = 'https://admin-apis.isometrik.io/live';

  static const String wsUrl = 'wss://streaming.isometrik.io';
  static const String productDetails =
      'https://admin-apis.isometrik.io/v1/get_product_details';
  static const String agentauthenticate =
      'https://admin-apis.isometrik.io/v1/agent';
  static const String user = '/chat/user';
  static const String stream1 = '/stream';
  static const String allUsers = '/chat/users';
  static const String userDetails = '$user/details';
  static const String authenticate = '$user/authenticate';
  static const String presignedurl = '$user/presignedurl/create';
  static const String agentSendOtp = '/send/otp';
  static const String agentLogin = '/login/otp';

  static const String userSubscription = '/gs/v2/subscription';

  static const String streamAnalytics = '/v2/stream/analytics';
  static const String streamAnalyticsViewers = '/v2/analytics/stream/viewers';
  static const String getUsersToInviteForPK = '/v2/invite/users';
  static const String sendInvitationToUserForPK = '/v2/invite/users';

  // Streams
  static const String _streaming = '/streaming/v2';
  static const String stream = '$_streaming/stream';
  static const String getStreams = '$_streaming/streams';
  static const String viewer = '$_streaming/viewer';
  static const String getStreamMembers = '$_streaming/members';
  static const String getStreamViewer = '$_streaming/viewers';
  static const String leaveStream = '$viewer/leave';
  static const String postMessage = '$_streaming/message';
  static const String deleteMessage = '$_streaming/message';
  static const String messages = '$_streaming/messages';
  static const String messagesCount = '$_streaming/messages/count';
  static const String replyMessage = '$_streaming/message/reply';
  static const String getUsers = '$_streaming/users';
  static const String moderator = '$_streaming/moderator';
  static const String leaveModerator = '$moderator/leave';
  static const String getModerators = '$_streaming/moderators';
  static const String copublisherRequest = '$_streaming/copublish/request';
  static const String acceptCopublisher = '$_streaming/copublish/accept';
  static const String denyCopublisher = '$_streaming/copublish/deny';
  static const String statusCopublisher = '$_streaming/copublish/status';
  static const String copublishersRequests = '$_streaming/copublish/requests';
  static const String switchProfile = '$_streaming/switchprofile';
  static const String eligibleMembers = '$_streaming/members/eligible';
  static const String member = '$_streaming/member';
  static const String leaveMember = '$_streaming/member/leave';
  static const String products = '$_streaming/ecommerce/products';

  // static const String getEndStream = '$_streaming/analytics';
  static const String restreamChannel = '$_streaming/restream/channel';
}
