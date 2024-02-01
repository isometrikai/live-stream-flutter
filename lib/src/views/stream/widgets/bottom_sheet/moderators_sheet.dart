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
        initState: (_) {
          var controller = Get.find<IsmLiveStreamController>();
          controller.moderatorsList.clear();
          controller.fetchModerators(
              forceFetch: true, streamId: controller.streamId ?? '');
        },
        builder: (controller) => IsmLiveScrollSheet(
          showSearchBar: true,
          trailing: controller.isHost == true
              ? SizedBox(
                  width: IsmLiveDimens.eighty,
                  child: IsmLiveButton(
                    label: 'Add',
                    small: true,
                    onTap: () {
                      Get.back();
                      IsmLiveUtility.openBottomSheet(const IsmLiveUsersSheet());
                    },
                  ),
                )
              : null,
          textEditingController: controller.searchModeratorFieldController,
          hintText: 'Search Moderators',
          onchange: controller.searchModerators,
          title: 'Moderatorsrs',
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
                  ? SizedBox(
                      width: IsmLiveDimens.eighty,
                      child: IsmLiveButton(
                        label: 'Remove',
                        small: true,
                        onTap: () {
                          controller.removeModerator(
                            moderatorId: moderator.userId,
                            streamId: controller.streamId ?? '',
                          );
                        },
                      ),
                    )
                  : moderator.userId == controller.user?.userId
                      ? SizedBox(
                          width: IsmLiveDimens.eighty,
                          child: IsmLiveButton(
                            label: 'Leave',
                            small: true,
                            onTap: () {
                              controller
                                  .leaveModerator(controller.streamId ?? '');
                            },
                          ),
                        )
                      : null,
            );
          },
        ),
      );
}
