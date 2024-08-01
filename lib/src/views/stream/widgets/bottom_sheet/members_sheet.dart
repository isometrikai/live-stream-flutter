import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveMembersSheet extends StatelessWidget {
  const IsmLiveMembersSheet({super.key});

  static const String updateId = 'members_sheet';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (_) {
          Get.find<IsmLiveStreamController>()
            ..searchExistingMembesFieldController.clear();
        },
        builder: (controller) => IsmLiveScrollSheet(
          showSearchBar: true,
          onPressClearIcon: () {
            controller.searchExistingMembesFieldController.clear();
            controller.searchMember(
                controller.searchExistingMembesFieldController.text);
          },
          textEditingController: controller.searchExistingMembesFieldController,
          hintText: 'Search Copublisher',
          onchange: controller.searchMember,
          title: 'Members',
          controller: controller.existingMembersListController,
          itemCount: controller.streamMembersList.length,
          itemBuilder: (context, index) {
            final existingMember = controller.streamMembersList[index];
            return ListTile(
              leading: IsmLiveImage.network(
                existingMember.userProfileImageUrl,
                name: existingMember.userName,
                dimensions: IsmLiveDimens.forty,
                isProfileImage: true,
              ),
              title: Text(existingMember.userName),
              subtitle: Text(existingMember.userIdentifier),
              trailing: (controller.isHost) &&
                      controller.user?.userId != existingMember.userId
                  ? IsmLiveButton.icon(
                      icon: Icons.person_remove_rounded,
                      onTap: () {
                        controller.removeMember(
                          streamId: controller.streamId ?? '',
                          memberId: existingMember.userId,
                        );
                      },
                    )
                  : (controller.user?.userId == existingMember.userId) &&
                          (controller.isHost == false)
                      ? IsmLiveButton.icon(
                          icon: Icons.exit_to_app_rounded,
                          onTap: () {
                            Get.back();
                            controller.disconnectStream(
                              isHost: false,
                              streamId: controller.streamId ?? '',
                              endStream: false,
                              goBack: false,
                            );
                          },
                        )
                      : null,
            );
          },
        ),
      );
}
