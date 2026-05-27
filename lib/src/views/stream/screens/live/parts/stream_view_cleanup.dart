part of '../stream_view.dart';

Future<void> ismLiveStreamViewCleanupData(
  IsmLiveStreamController controller,
) async {
    try {
      // Clear all stream-related data
      // Note: streamDispose() will handle the preventDispose check internally
      controller
          .streamDispose(false); // Don't dispose animation controller here

      // Clear camera controller if exists
      controller.cameraController?.dispose();
      controller.cameraController = null;

      // Clear timer-related data
      controller.streamTimer?.cancel();
      controller.streamTimer = null;

      // Clear PK timer if exists
      if (Get.isRegistered<IsmLivePkController>()) {
        final pkController = Get.find<IsmLivePkController>();
        pkController.pkTimer?.cancel();
        pkController.pkTimer = null;
      }

      // Clear stream details and related data
      // Note: Essential data (streamId, room, listener, etc.) are already handled by streamDispose()
      controller.streamDetails = null;
      controller.pickedImage = null;
      controller.bytes = null;

      // Clear participant data
      controller.participantTracks.clear();
      controller.participantList.clear();

      // Clear user role
      controller.userRole = null;

      // Clear analytics data
      controller.streamAnalytis = null;
      controller.realtimeStreamLikeCount = 0;
      controller.analyticsViewers.clear();

      // Clear messages and viewers
      controller.streamMessagesList.clear();
      controller.streamViewersList.clear();
      controller.liveStreamViewersCount.value = null;
      controller.streamMembersList.clear();

      // Clear gift data
      controller.giftMessages.clear();
      controller.giftList.clear();
      controller.cancelHeartDebounce();
      controller.heartList.clear();

      // Clear search controllers
      controller.searchUserFieldController.clear();
      controller.searchModeratorFieldController.clear();
      controller.searchCopublisherFieldController.clear();
      controller.searchExistingMembesFieldController.clear();
      controller.searchMembersFieldController.clear();

      // Clear copublisher requests
      controller.copublisherRequestsList.clear();

      // Clear selected products
      controller.selectedProductsList.clear();

      // Reset member status
      controller.memberStatus = IsmLiveMemberStatus.notMember;

      // Reset UI states
      controller.showEmojiBoard = false;
      controller.speakerOn = true;
      controller.videoOn = true;
      controller.audioOn = true;

      // Clear gift coin balance
      controller.giftcoinBalance = 0;

      // Clear parent message
      controller.parentMessage = null;

      // Reset gift type
      controller.giftType = 0;

      // Clear premium stream coins
      controller.premiumStreamCoinsController.clear();

      // Reset all boolean flags
      controller.isHdBroadcast = false;
      controller.isRecordingBroadcast = false;
      controller.isRestreamBroadcast = false;
      controller.usePersistentStreamKey = false;
      controller.isRtmp = false;
      controller.isPremium = false;
      controller.isSchedulingBroadcast = false;
      controller.restreamFacebook = false;
      controller.restreamYoutube = false;
      controller.restreamInstagram = false;

      // Reset selected items
      controller.selectedGoLiveTabItem = IsmGoLiveTabItem.defaultLive;
      controller.selectedGoLiveStream = IsmLiveStreamTypes.free;

      // Reset schedule date
      controller.scheduleLiveDate = DateTime.now();

      // Clear text controllers
      controller.rtmlUrl.clear();
      controller.streamKey.clear();
      controller.rtmlUrlDevice.clear();
      controller.streamKeyDevice.clear();

      // Disable wakelock
      await WakelockPlus.disable();

      // Callback can also be reached from stop/disconnect flow; guard duplicate.
      controller.triggerOnStreamEndOnce();
    } catch (e) {
      IsmLiveLog.error('Error cleaning up stream data: $e');
    }
}