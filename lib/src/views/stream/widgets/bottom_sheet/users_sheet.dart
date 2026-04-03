import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveUsersSheet extends StatelessWidget {
  const IsmLiveUsersSheet({super.key});

  static const String updateId = 'stream-users-sheet';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);

    return GetBuilder<IsmLiveStreamController>(
      id: updateId,
      initState: (_) {
        Get.find<IsmLiveStreamController>()
          ..searchUserFieldController.clear()
          ..usersList.clear()
          ..fetchUsers(forceFetch: true);
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
        child: IsmLiveScrollSheet(
          showSearchBar: true,
          onPressClearIcon: () {
            controller.searchUserFieldController.clear();
            controller.searchUser(controller.searchUserFieldController.text);
          },
          textEditingController: controller.searchUserFieldController,
          hintText: IsmLiveStrings.searchUsers,
          onchange: controller.searchUser,
          title: IsmLiveStrings.users,
          controller: controller.userListController,
          itemCount: controller.usersList.length,
          itemBuilder: (context, index) {
            final user = controller.usersList[index];
            final imageUrl =
                IsmLiveDelegate.getUserProfileUrl?.call(user.profileUrl) ??
                    user.profileUrl;
            var notShowbotton = controller.checkCanMakeModerator(user.userId);

            return InkWell(
              onTap: IsmLiveDelegate.restrictProfileSheetOnProfileClick
                  ? null
                  : () {
                      IsmLiveUtility.openBottomSheet(
                        StreamLiveSheet(
                          widget: IsmLiveImage.network(
                            imageUrl,
                            isProfileImage: true,
                            name: user.name,
                            initials: user.profileInitials,
                            height: IsmLiveDimens.hundred,
                            width: IsmLiveDimens.hundred,
                          ),
                          title: user.name,
                          subTitle: null,
                          buttonLable: IsmLiveStrings.viewProfile,
                          onTap: () {
                            IsmLiveDelegate.openUserProfileView
                                ?.call(user.userIdentifier);
                          },
                        ),
                        isScrollController: true,
                      );
                    },
              child: ListTile(
                leading: IsmLiveImage.network(
                  imageUrl,
                  name: user.name,
                  initials: user.profileInitials,
                  dimensions: IsmLiveDimens.forty,
                  isProfileImage: true,
                ),
                title: Text(user.name, style: TextStyle(color: textColor)),
                subtitle: user.displayUserName != user.fullName
                    ? Text(
                        user.displayUserName,
                        style: TextStyle(color: subtitleColor),
                      )
                    : null,
                trailing: notShowbotton
                    ? null
                    : IsmLiveButton.icon(
                        icon: Icons.person_add_rounded,
                        onTap: () {
                          controller.makeModerator(
                            moderatorId: user.userId,
                            streamId: controller.streamId ?? '',
                          );

                          IsmLiveRoute.pop();
                        },
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
