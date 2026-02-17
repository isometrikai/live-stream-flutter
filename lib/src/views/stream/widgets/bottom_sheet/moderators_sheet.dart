import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveModeratorsSheet extends StatelessWidget {
  const IsmLiveModeratorsSheet({
    super.key,
  });

  static const String updateId = 'stream-moderator-sheet';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return GetBuilder<IsmLiveStreamController>(
      id: updateId,
      initState: (state) {
        Get.find<IsmLiveStreamController>()
          ..fetchModerators(
            streamId: Get.find<IsmLiveStreamController>().streamId ?? '',
          )
          ..searchModeratorFieldController.clear();
      },
      builder: (controller) => Container(
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
          child: IsmLiveScrollSheet(
            showSearchBar: true,
            placeHolder: IsmLiveAssetConstants.moderator_placeholder,
            placeHolderText: IsmLiveStrings.noModerator,
            onPressClearIcon: () {
              controller.searchModeratorFieldController.clear();
              controller.searchModerators(
                  controller.searchModeratorFieldController.text);
            },
            trailing: controller.isHost == true
                ? IsmLiveButton.icon(
                    icon: Icons.person_add_rounded,
                    onTap: () {
                      IsmLiveRoute.pop();
                      final ctx = IsmLiveUtility.navigatorKey.currentContext!;
                      IsmLiveUtility.openBottomSheet(
                        const IsmLiveUsersSheet(),
                        backgroundColor: ctx.liveTheme?.backgroundColor ??
                            (Theme.of(ctx).brightness == Brightness.dark
                                ? const Color(0xFF121212)
                                : Colors.white),
                      );
                    },
                  )
                : null,
            textEditingController: controller.searchModeratorFieldController,
            hintText: IsmLiveStrings.searchModerators,
            onchange: controller.searchModerators,
            title: IsmLiveStrings.moderators,
            controller: controller.moderatorListController,
            itemCount: controller.moderatorsList.length,
            itemBuilder: (context, index) {
              final moderator = controller.moderatorsList[index];
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
                        name: moderator.userName,
                        height: IsmLiveDimens.hundred,
                        width: IsmLiveDimens.hundred,
                      ),
                      title: moderator.userName,
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
                    name: moderator.userName,
                    dimensions: IsmLiveDimens.forty,
                    isProfileImage: true,
                  ),
                  title: Text(
                    moderator.userName,
                    style: TextStyle(color: textColor),
                  ),
                  subtitle: Text(
                    moderator.userName,
                    style: TextStyle(
                      color: context.liveTheme?.unselectedTextColor ??
                          (isDarkMode
                              ? const Color(0xFFB0B0B0)
                              : Colors.grey),
                    ),
                  ),
                  trailing: (moderator.userId != controller.user?.userId &&
                          controller.isHost == true)
                      ? IsmLiveButton.icon(
                          icon: Icons.person_remove_rounded,
                          onTap: () {
                            IsmLiveRoute.pop();
                            controller.removeModerator(
                              moderatorId: moderator.userId,
                              streamId: controller.streamId ?? '',
                            );
                          },
                        )
                      : controller.isModerator &&
                              controller.isHost != true &&
                              (controller.user?.userId == moderator.userId)
                          ? IsmLiveButton.icon(
                              icon: Icons.exit_to_app_rounded,
                              onTap: () {
                                IsmLiveRoute.pop();
                                controller
                                    .leaveModerator(controller.streamId ?? '');
                              },
                            )
                          : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
