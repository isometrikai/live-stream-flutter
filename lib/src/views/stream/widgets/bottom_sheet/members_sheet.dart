import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveMembersSheet extends StatelessWidget {
  const IsmLiveMembersSheet({super.key});
  static const String updateId = 'members_sheet';
  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) {
          Get.find<IsmLiveStreamController>().getStreamMembers(
              streamId: Get.find<IsmLiveStreamController>().streamId ?? '');
        },
        builder: (controller) => IsmLiveScrollSheet(
          showSearchBar: true,
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
                dimensions: IsmLiveDimens.forty,
                isProfileImage: true,
              ),
              title: Text(existingMember.userName),
              subtitle: Text(existingMember.userIdentifier),
              trailing: (controller.isHost ?? false) &&
                      controller.user?.userId != existingMember.userId
                  ? SizedBox(
                      width: IsmLiveDimens.hundred,
                      child: IsmLiveButton(
                        label: 'Remove ',
                        small: true,
                        onTap: () {
                          controller.removeMember(
                            streamId: controller.streamId ?? '',
                            memberId: existingMember.userId,
                          );
                        },
                      ),
                    )
                  : (controller.user?.userId == existingMember.userId) &&
                          (controller.isHost == false)
                      ? SizedBox(
                          width: IsmLiveDimens.hundred,
                          child: IsmLiveButton(
                            label: 'Leave ',
                            small: true,
                            onTap: () {
                              controller.disconnectStream(
                                  isHost: false,
                                  streamId: controller.streamId ?? '');
                            },
                          ),
                        )
                      : null,
            );
          },
        ),
      );
}
