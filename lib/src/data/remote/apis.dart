/// This class is used for all the APIs endpoints
class IsmLiveApis {
  const IsmLiveApis._();

  static const String baseUrl = 'https://apis.isometrik.io';

  static const String wsUrl = 'wss://streaming.isometrik.io';
  static const String productDetails =
      'https://admin-apis.isometrik.io/v1/get_product_details';
  static const String agentauthenticate =
      'https://admin-apis.isometrik.io/v1/agent';
  static const String user = '/chat/user';
  static const String allUsers = '/chat/users';
  static const String userDetails = '$user/details';
  static const String authenticate = '$user/authenticate';
  static const String presignedurl = '$user/presignedurl/create';
  static const String agentSendOtp = '/send/otp';
  static const String agentLogin = '/login/otp';

  static const String userSubscription = '/gs/v2/subscription';

//PK apis end point
  static const String baseUrlStream = 'https://service-apis.isometrik.io';

  static const String _live = '/live/v2';
  static const String newStream = '$_live/stream';
  static const String fetchStream = '$_live/streams';
  static const String streamAnalytics = '$_live/stream/analytics';
  static const String fetchScheduledStream = '$_live/streams/scheduled';
  // static const String streamAnalyticsViewers =
  //     '$_live/analytics/stream/viewers';
  static const String streamAnalyticsViewers = '$_live/stream/viewer';
  static const String fetchCoins = '/v1/wallet/user';
  static const String fetchTransactions = '/v1/transaction/user';
  static const String getUsersToInviteForPK = '$_live/invite/users';
  static const String sendInvitationToUserForPK = '$_live/invite/users';
  static const String invitaionPK = '$_live/invites';
  static const String publish = '$_streaming/publish';
  static const String pkStatus = '$_live/pk/stream/stats';
  static const String pkStart = '$_live/pk/start';
  static const String pkStop = '$_live/pk/stop';
  static const String pkEnd = '$_live/pk/end';
  static const String pkWinner = '$_live/pk/winner';
  static const String sendHearts = '$_live/stream/like';
  static const String buyStream = '$_live/buy/stream';
  static const String getGiftCategories = '/v1/app/giftGroup';
  static const String getGiftsForACategory = '/v1/app/virtualGifts';
  static const String sendGiftToStreamer = '/live/v4/giftTransfer';
  static const String getCurrencyPlans = '/v1/currencyPlan/isometrikAuth';
  static const String purchaseCoinsPlans = '/v1/appWallet/tokenPurchase';

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
  static const String getUserDetails = '$_streaming/user/details';
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
