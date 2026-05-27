part of '../stream_view.dart';

class _StreamHeader extends StatelessWidget {
  const _StreamHeader({
    required this.streamId,
  });

  final String streamId;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmLiveStreamView.updateId,
        builder: (controller) => SafeArea(
          bottom: false,
          child: IsmLiveStreamHeader(
            streamCoins: controller.premiumStreamCoinsController.text,
            isBattleTie: controller.pkWinnerId != null,
            winnerName: controller.findWinner(controller.pkWinnerId),
            description: controller.descriptionController.text,
            name: controller.hostDetails?.name ?? 'U',
            handle: '',
            initials: controller.hostDetails?.profileInitials ?? '',
            imageUrl: controller.hostDetails?.image ?? '',
            userIdentifier: controller.hostDetails?.userIdentifier ?? '',
            pkCompleted: (controller.pkStages?.isPkStop ?? false) &&
                controller.participantTracks.length == 2,
            isPaidStream: controller.isPremium,
            onTapModerators: () async {
              // If user is a moderator (not host), show moderator status bottom sheet
              if (controller.isModerator && !controller.isHost) {
                IsmLiveUtility.openBottomSheet(
                  IsmLiveModeratorBottomSheet(
                    type: IsmLiveModeratorBottomSheetType.currentlyModerating,
                    streamId: streamId,
                  ),
                  isDismissible: true,
                );
                return;
              }

              // Check if host app wants to handle the moderators list tap
              final moderatorsCallback = IsmLiveDelegate.moderatorsListCallback;
              if (moderatorsCallback != null) {
                final handled = await moderatorsCallback(
                  context,
                  streamId,
                  controller.isHost,
                  controller.isModerator,
                  controller.moderatorsList,
                  controller.hostDetails,
                );

                // If host app handled the tap, don't show default moderators sheet
                if (handled) {
                  return;
                }
              }

              // Ensure we have latest moderators before deciding flow
              await controller.fetchModerators(
                forceFetch: true,
                streamId: streamId,
              );

              final hostUserId = controller.hostDetails?.userId;
              final hostIdentifier = controller.hostDetails?.userIdentifier;

              final nonHostModerators = controller.moderatorsList.where(
                (moderator) {
                  if (hostUserId != null && moderator.userId == hostUserId) {
                    return false;
                  }
                  if (hostIdentifier != null &&
                      moderator.userIdentifier == hostIdentifier) {
                    return false;
                  }
                  return true;
                },
              ).toList();

              final sheetContext =
                  IsmLiveUtility.navigatorKey.currentContext ?? context;

              // If no moderators (excluding host), open Add Moderator flow
              if (nonHostModerators.isEmpty) {
                IsmLiveUtility.openBottomSheet(
                  const AddModeratorsListBottomSheet(),
                  isScrollController: true,
                  backgroundColor: sheetContext.liveTheme?.backgroundColor ??
                      (Theme.of(sheetContext).brightness == Brightness.dark
                          ? const Color(0xFF121212)
                          : Colors.white),
                );
                return;
              }

              // If we have moderators, show moderators sheet first
              IsmLiveUtility.openBottomSheet(
                const IsmLiveModeratorsSheet(),
                isScrollController: true,
                backgroundColor: sheetContext.liveTheme?.backgroundColor ??
                    (Theme.of(sheetContext).brightness == Brightness.dark
                        ? const Color(0xFF121212)
                        : Colors.white),
              );
            },
            onTapViewers: (viewerList) async {
              // Check if host app wants to handle the viewers list tap
              final viewersCallback = IsmLiveDelegate.topViewersListCallback;
              if (viewersCallback != null) {
                final handled = await viewersCallback(
                  context,
                  viewerList,
                  streamId,
                  controller.isHost,
                  controller.isModerator,
                  controller.streamViewersList,
                );

                // If host app handled the tap, don't show default viewers sheet
                if (handled) {
                  return;
                }
              }

              // Default behavior: show viewers sheet
              IsmLiveUtility.openBottomSheet(
                GetBuilder<IsmLiveStreamController>(
                  initState: (state) {
                    IsmLiveUtility.updateLater(
                        () => controller.getStreamViewer(streamId: streamId));
                  },
                  id: IsmLiveStreamView.updateId,
                  builder: (controller) => IsmLiveListSheet(
                    scrollController: controller.viewerListController,
                    items: controller.streamViewersList,
                    trailing: (_, viewer) =>
                        controller.isModerator || controller.isHost
                            ? viewer.userId == controller.user?.userId
                                ? IsmLiveDimens.box0
                                : SizedBox(
                                    width: IsmLiveDimens.hundred,
                                    child: IsmLiveButton(
                                      label: 'kick out',
                                      onTap: () {
                                        controller.kickoutViewer(
                                          streamId: streamId,
                                          viewerId: viewer.userId,
                                        );
                                      },
                                    ),
                                  )
                            : IsmLiveDimens.box0,
                    onViewerProfileTap: (viewer, index) {
                      if (!IsmLiveDelegate.restrictProfileSheetOnProfileClick) {
                        IsmLiveUtility.openBottomSheet(
                          StreamLiveSheet(
                            widget: IsmLiveImage.network(
                              IsmLiveDelegate.getUserProfileUrl
                                      ?.call(viewer.imageUrl ?? '') ??
                                  viewer.imageUrl ??
                                  '',
                              isProfileImage: true,
                              name: viewer.userName,
                              height: IsmLiveDimens.hundred,
                              width: IsmLiveDimens.hundred,
                            ),
                            title: viewer.userName,
                            subTitle: null,
                            buttonLable: 'View Profile',
                            onTap: () {
                              IsmLiveDelegate.openUserProfileView
                                  ?.call(viewer.identifier);
                            },
                          ),
                          isScrollController: true,
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
}