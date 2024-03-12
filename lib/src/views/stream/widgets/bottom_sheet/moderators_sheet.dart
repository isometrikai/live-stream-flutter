import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveModeratorsSheet extends StatelessWidget {
  const IsmLiveModeratorsSheet({
    super.key,
  });

  static const String updateId = 'stream-moderator-sheet';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) {
          Get.find<IsmLiveStreamController>().fetchModerators(
            streamId: Get.find<IsmLiveStreamController>().streamId ?? '',
            forceFetch: true,
          );
        },
        builder: (controller) => IsmLiveScrollSheet(
          showSearchBar: true,
          trailing: controller.isHost == true
              ? IsmLiveButton.icon(
                  icon: Icons.person_add_rounded,
                  onTap: () {
                    Get.back();
                    IsmLiveUtility.openBottomSheet(const IsmLiveUsersSheet());
                  },
                )
              : null,
          textEditingController: controller.searchModeratorFieldController,
          hintText: 'Search Moderators',
          onchange: controller.searchModerators,
          title: 'Moderators',
          controller: controller.moderatorListController,
          itemCount: controller.moderatorsList.length,
          itemBuilder: (context, index) {
            final moderator = controller.moderatorsList[index];
            return ListTile(
              leading: IsmLiveImage.network(
                moderator.profileUrl,
                dimensions: IsmLiveDimens.forty,
                isProfileImage: true,
              ),
              title: Text(moderator.userName),
              subtitle: Text(moderator.userIdentifier),
              trailing: (moderator.userId != controller.user?.userId &&
                      controller.isHost == true)
                  ? IsmLiveButton.icon(
                      icon: Icons.person_remove_rounded,
                      onTap: () {
                        controller.removeModerator(
                          moderatorId: moderator.userId,
                          streamId: controller.streamId ?? '',
                        );
                      },
                    )
                  : controller.isModerator && controller.isHost != true
                      ? IsmLiveButton.icon(
                          icon: Icons.exit_to_app_rounded,
                          onTap: () {
                            controller
                                .leaveModerator(controller.streamId ?? '');
                          },
                        )
                      : null,
            );
          },
        ),
      );
}
