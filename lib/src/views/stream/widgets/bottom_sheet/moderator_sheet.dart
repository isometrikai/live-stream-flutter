import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveModeratorSheet extends StatelessWidget {
  const IsmLiveModeratorSheet({super.key});

  static const String updateId = 'stream-moderator-sheet';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (_) {
          var controller = Get.find<IsmLiveStreamController>();
          controller.usersList.clear();
          controller.fetchUsers(forceFetch: true);
        },
        builder: (controller) => IsmLiveScrollSheet(
          showSearchBar: true,
          textEditingController: controller.searchModeratorFieldController,
          hintText: 'Search moderators',
          onchange: controller.searchModerators,
          title: 'Moderators',
          controller: controller.userListController,
          itemCount: controller.usersList.length,
          itemBuilder: (context, index) {
            final user = controller.usersList[index];
            return ListTile(
              leading: IsmLiveImage.network(
                user.profileUrl,
                dimensions: IsmLiveDimens.forty,
                isProfileImage: true,
              ),
              title: Text(user.userName),
              subtitle: Text(user.userIdentifier),
              trailing: SizedBox(
                width: IsmLiveDimens.eighty,
                child: IsmLiveButton(
                  label: 'Make Moderator',
                  small: true,
                  onTap: () {
                    controller.makeModerator(
                      moderatorId: user.userId,
                      streamId: controller.streamId ?? '',
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
}
