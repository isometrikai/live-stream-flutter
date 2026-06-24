import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveModeratorsSheet extends StatelessWidget {
  const IsmLiveModeratorsSheet({
    super.key,
  });

  static const String updateId = 'stream-moderator-sheet';
  static const double _moderatorPaginationTriggerExtent = 240;

  Future<void> _loadMoreModeratorsIfNeeded(
    IsmLiveStreamController controller,
  ) async {
    if (controller.isModeratorsApiCall) {
      return;
    }
    if (!controller.moderatorListController.hasClients) {
      return;
    }

    final position = controller.moderatorListController.position;
    if (!position.hasContentDimensions) {
      return;
    }

    if (position.extentAfter > _moderatorPaginationTriggerExtent) {
      return;
    }

    final streamId = controller.streamId;
    if (streamId == null || streamId.isEmpty) {
      return;
    }

    controller.isModeratorsApiCall = true;
    try {
      await controller.fetchModerators(
        forceFetch: true,
        streamId: streamId,
        skip: controller.moderatorsList.length,
        searchTag: controller.searchModeratorFieldController.text.trim().isEmpty
            ? null
            : controller.searchModeratorFieldController.text.trim(),
      );
    } finally {
      controller.isModeratorsApiCall = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return GetBuilder<IsmLiveStreamController>(
      id: updateId,
      initState: (state) {
        Get.find<IsmLiveStreamController>()
          ..searchModeratorFieldController.clear();
      },
      builder: (controller) => Container(
        constraints: BoxConstraints(
          // Prevent full-screen height; roughly match reference design
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          minHeight: 260,
        ),
        decoration: BoxDecoration(
          color: context.liveTheme?.backgroundColor ??
              (isDarkMode ? const Color(0xFF121212) : Colors.white),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                  IsmLiveDimens.thirty,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildModeratorsHeader(context, textColor),
                    _buildModeratorsSearchBar(
                      context,
                      textColor,
                      controller,
                      isDarkMode,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.axis != Axis.vertical) {
                            return false;
                          }
                          _loadMoreModeratorsIfNeeded(controller);
                          return false;
                        },
                        child: IsmLiveScrollSheet(
                          showHeader: false,
                          showSearchBar: false,
                          placeHolder:
                              IsmLiveAssetConstants.moderator_placeholder,
                          placeHolderText: IsmLiveStrings.noModerator,
                          controller: controller.moderatorListController,
                          title: IsmLiveStrings.moderators,
                          itemCount: controller.moderatorsList
                              .where(
                                (moderator) =>
                                    moderator.userId !=
                                        controller.hostDetails?.userId &&
                                    moderator.userIdentifier !=
                                        controller.hostDetails?.userIdentifier,
                              )
                              .length,
                          itemBuilder: (context, index) {
                            final filteredModerators =
                                controller.moderatorsList.where(
                              (moderator) =>
                                  moderator.userId !=
                                      controller.hostDetails?.userId &&
                                  moderator.userIdentifier !=
                                      controller.hostDetails?.userIdentifier,
                            );
                            final moderator =
                                filteredModerators.elementAt(index);
                            final imageUrl = IsmLiveDelegate.getUserProfileUrl
                                    ?.call(moderator.profileUrl) ??
                                moderator.profileUrl;
                            return InkWell(
                              onTap: () {
                                IsmLiveUtility.openBottomSheet(
                                  StreamLiveSheet(
                                    widget: IsmLiveImage.network(
                                      imageUrl,
                                      isProfileImage: true,
                                      name: moderator.name,
                                      initials: moderator.profileInitials,
                                      height: IsmLiveDimens.hundred,
                                      width: IsmLiveDimens.hundred,
                                    ),
                                    title: moderator.name,
                                    subTitle: null,
                                    buttonLable: IsmLiveStrings.viewProfile,
                                    onTap: () {
                                      IsmLiveDelegate.openUserProfileView
                                          ?.call(moderator.userIdentifier);
                                    },
                                  ),
                                  isScrollController: true,
                                );
                              },
                              child: ListTile(
                                leading: IsmLiveImage.network(
                                  imageUrl,
                                  name: moderator.name,
                                  initials: moderator.profileInitials,
                                  dimensions: IsmLiveDimens.forty,
                                  isProfileImage: true,
                                ),
                                title: Text(
                                  moderator.name,
                                  style: TextStyle(color: textColor),
                                ),
                                subtitle: moderator.displayUserName !=
                                        moderator.fullName
                                    ? Text(
                                        moderator.displayUserName,
                                        style: TextStyle(
                                          color: context.liveTheme
                                                  ?.unselectedTextColor ??
                                              (isDarkMode
                                                  ? const Color(0xFFB0B0B0)
                                                  : Colors.grey),
                                        ),
                                      )
                                    : null,
                                trailing: (moderator.userId !=
                                            controller.user?.userId &&
                                        controller.isHost == true)
                                    ? IconButton(
                                        iconSize: 24,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const IsmLiveImage.svg(
                                          IsmLiveAssetConstants.removeModerator,
                                        ),
                                        onPressed: () {
                                          // Show confirmation bottom sheet
                                          final name = moderator.name;
                                          IsmLiveUtility.openBottomSheet(
                                            _RemoveModeratorConfirmSheet(
                                              moderatorName: name,
                                              onConfirm: () async {
                                                final streamId =
                                                    controller.streamId ?? '';
                                                final moderatorId =
                                                    moderator.userId;
                                                final removed = await controller
                                                    .removeModerator(
                                                  streamId: streamId,
                                                  moderatorId: moderatorId,
                                                );
                                                if (removed) {
                                                  controller.moderatorsList
                                                      .removeWhere(
                                                    (m) =>
                                                        m.userId ==
                                                        moderatorId,
                                                  );
                                                  controller.update([
                                                    IsmLiveModeratorsSheet
                                                        .updateId
                                                  ]);
                                                }
                                              },
                                            ),
                                            isScrollController: true,
                                            backgroundColor: context
                                                    .liveTheme
                                                    ?.backgroundColor ??
                                                (Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? const Color(0xFF121212)
                                                    : Colors.white),
                                          );
                                        },
                                      )
                                    : controller.isModerator &&
                                            controller.isHost != true &&
                                            (controller.user?.userId ==
                                                moderator.userId)
                                        ? IsmLiveButton.icon(
                                            icon: Icons.exit_to_app_rounded,
                                            onTap: () {
                                              IsmLiveRoute.pop();
                                              controller.leaveModerator(
                                                controller.streamId ?? '',
                                              );
                                            },
                                          )
                                        : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isHost == true)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: context.liveTheme?.primaryColor ??
                              IsmLiveColors.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: context.liveTheme?.primaryColor ??
                            IsmLiveColors.primary,
                      ),
                      onPressed: () {
                        IsmLiveRoute.pop();
                        final ctx = IsmLiveUtility.navigatorKey.currentContext!;
                        IsmLiveUtility.openBottomSheet(
                          const AddModeratorsListBottomSheet(),
                          isScrollController: true,
                          backgroundColor: ctx.liveTheme?.backgroundColor ??
                              (Theme.of(ctx).brightness == Brightness.dark
                                  ? const Color(0xFF121212)
                                  : Colors.white),
                        );
                      },
                      child: const Text(
                        IsmLiveStrings.addModerator,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildModeratorsHeader(BuildContext context, Color textColor) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const SizedBox(width: 24), // spacer to balance close icon
          Expanded(
            child: Center(
              child: Text(
                IsmLiveStrings.moderators,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: IsmLiveRoute.pop,
            child: Icon(
              Icons.close,
              size: 20,
              color: textColor,
            ),
          ),
        ],
      ),
    );

Widget _buildModeratorsSearchBar(
  BuildContext context,
  Color textColor,
  IsmLiveStreamController controller,
  bool isDarkMode,
) {
  final fillColor = isDarkMode
      ? Colors.white.withValues(alpha: 0.06)
      : const Color(0xFFF5F5F5);

  return Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
    decoration: BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(
          Icons.search,
          color: context.liveTheme?.unselectedTextColor ?? Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller.searchModeratorFieldController,
            style: TextStyle(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: IsmLiveStrings.searchModerators,
              hintStyle: TextStyle(
                color: context.liveTheme?.unselectedTextColor ?? Colors.grey,
                fontSize: 14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              isDense: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            onChanged: controller.searchModerators,
          ),
        ),
        if (controller.searchModeratorFieldController.text.isNotEmpty)
          InkWell(
            onTap: () {
              controller.searchModeratorFieldController.clear();
              controller.searchModerators('');
            },
            child: Icon(
              Icons.clear,
              color: context.liveTheme?.unselectedTextColor ?? Colors.grey,
              size: 18,
            ),
          ),
      ],
    ),
  );
}

class _RemoveModeratorConfirmSheet extends StatelessWidget {
  const _RemoveModeratorConfirmSheet({
    required this.moderatorName,
    required this.onConfirm,
  });

  final String moderatorName;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final titleColor = isDarkMode ? Colors.white : Colors.black;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                IsmLiveDimens.thirty,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        ismLiveBottomSheetActionBottomInset(context, designBottom: 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              InkWell(
                onTap: IsmLiveRoute.pop,
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Are you sure you want to remove $moderatorName as moderator?',
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: IsmLiveButton.secondary(
                  label: IsmLiveStrings.cancel,
                  onTap: IsmLiveRoute.pop,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: IsmLiveButton(
                  label: IsmLiveStrings.delete,
                  onTap: () async {
                    await onConfirm();
                    IsmLiveRoute.pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
