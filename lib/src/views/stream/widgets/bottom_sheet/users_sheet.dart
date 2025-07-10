import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveUsersSheet extends StatelessWidget {
  const IsmLiveUsersSheet({super.key});

  static const String updateId = 'stream-users-sheet';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (_) {
          Get.find<IsmLiveStreamController>()
            ..searchUserFieldController.clear()
            ..usersList.clear()
            ..fetchUsers(forceFetch: true);
        },
        builder: (controller) => IsmLiveScrollSheet(
          showSearchBar: true,
          onPressClearIcon: () {
            controller.searchUserFieldController.clear();
            controller.searchUser(controller.searchUserFieldController.text);
          },
          textEditingController: controller.searchUserFieldController,
          hintText: 'Search Users',
          onchange: controller.searchUser,
          title: 'Users',
          controller: controller.userListController,
          itemCount: controller.usersList.length,
          itemBuilder: (context, index) {
            final user = controller.usersList[index];
            final imageUrl = IsmLiveDelegate.getUserProfileUrl?.call(user.profileUrl) ?? user.profileUrl;
            var notShowbotton = controller.checkCanMakeModerator(user.userId);

            return InkWell(
              onTap: (){
                IsmLiveUtility.openBottomSheet(
                  StreamLiveSheet(
                    widget: IsmLiveImage.network(
                      imageUrl,
                      isProfileImage: true,
                      name: user.userName,
                      height: IsmLiveDimens.hundred,
                      width: IsmLiveDimens.hundred,
                    ),
                    title: user.userName,
                    subTitle: null ,
                    buttonLable: 'View Profile',
                    onTap: () {
                      IsmLiveDelegate.openUserProfileView?.call(user.userIdentifier);
                    },
                  ),
                  isScrollController: true,
                );
              },
              child: ListTile(
                leading: IsmLiveImage.network(
                  imageUrl,
                  name: user.userName,
                  dimensions: IsmLiveDimens.forty,
                  isProfileImage: true,
                ),
                title: Text(user.userName),
                subtitle: Text(user.userName),
                trailing: notShowbotton
                    ? null
                    : IsmLiveButton.icon(
                        icon: Icons.person_add_rounded,
                        onTap: () {
                          controller.makeModerator(
                            moderatorId: user.userId,
                            streamId: controller.streamId ?? '',
                          );

                          Get.back();
                          Get.back();
                        },
                      ),
              ),
            );
          },
        ),
      );
}
