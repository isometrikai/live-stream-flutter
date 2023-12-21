import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/views/stream/widgets/logout_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveHeader extends StatelessWidget implements PreferredSizeWidget {
  const IsmLiveHeader({
    super.key,
    this.height,
  });

  final double? height;

  static const String updateId = 'IsmLive-header';

  @override
  Size get preferredSize => Size(Get.width, height ?? IsmLiveDimens.appBarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
        automaticallyImplyLeading: false,
        title: GetBuilder<IsmLiveStreamController>(
          id: updateId,
          builder: (controller) => IsmLiveTapHandler(
            onTap: () {
              if (controller.user == null) {
                return;
              }
              IsmLiveUtility.openBottomSheet(
                IsmLiveLogoutBottomSheet(user: controller.user!),
                isDismissible: true,
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IsmLiveImage.network(
                  controller.user?.profileUrl ?? '',
                  name: controller.user?.userName ?? 'U',
                  isProfileImage: true,
                ),
                IsmLiveDimens.boxWidth8,
                Text(
                  IsmLiveStrings.title,
                  style: IsmLiveStyles.blackBold16,
                ),
              ],
            ),
          ),
        ),
      );
}
