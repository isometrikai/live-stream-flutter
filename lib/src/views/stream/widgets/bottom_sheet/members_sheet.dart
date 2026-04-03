import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveMembersSheet extends StatelessWidget {
  const IsmLiveMembersSheet({super.key});

  static const String updateId = 'members_sheet';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);

    return GetBuilder<IsmLiveStreamController>(
      id: updateId,
      initState: (_) {
        Get.find<IsmLiveStreamController>()
          ..searchExistingMembesFieldController.clear();
      },
      builder: (controller) => Container(
        decoration: BoxDecoration(
          color: bgColor,
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
            controller.searchExistingMembesFieldController.clear();
            controller.searchMember(
                controller.searchExistingMembesFieldController.text);
          },
          textEditingController: controller.searchExistingMembesFieldController,
          hintText: IsmLiveStrings.searchCopublisher,
          onchange: controller.searchMember,
          title: IsmLiveStrings.members,
          controller: controller.existingMembersListController,
          itemCount: controller.streamMembersList.length,
          itemBuilder: (context, index) {
            final existingMember = controller.streamMembersList[index];
            return ListTile(
              leading: IsmLiveImage.network(
                existingMember.userProfileImageUrl,
                name: existingMember.name,
                initials: existingMember.profileInitials,
                dimensions: IsmLiveDimens.forty,
                isProfileImage: true,
              ),
              title: Text(existingMember.name),
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
                            IsmLiveRoute.pop();
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
      ),
    );
  }
}
