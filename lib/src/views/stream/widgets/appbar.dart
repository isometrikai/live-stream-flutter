import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class IsmLiveAppbar extends StatelessWidget implements PreferredSizeWidget {
  const IsmLiveAppbar({
    super.key,
    this.height,
  });

  final double? height;

  static const String updateId = 'ismlive-appbar';

  @override
  Size get preferredSize =>
      Size(Get.width, height ?? IsmLiveDimens.appBarHeight);

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        builder: (controller) => AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          leadingWidth: IsmLiveDimens.sixty,
          actions: [
            InkWell(
              onTap: IsmLiveRouteManagement.goToCoinsPlanWallet,
              child: Row(
                children: [
                  SvgPicture.asset(IsmLiveAssetConstants.coinSvg),
                  IsmLiveDimens.boxWidth10,
                  Text(
                    'Add Coins',
                    style: IsmLiveStyles.black16,
                  ),
                  IsmLiveDimens.boxWidth10,
                ],
              ),
            )
          ],
          leading: IsmLiveTapHandler(
            onTap: () {
              if (controller.user == null) {
                return;
              }
              IsmLiveUtility.openBottomSheet(
                IsmLiveLogoutBottomSheet(user: controller.user!),
              );
            },
            child: UnconstrainedBox(
              child: Stack(
                children: [
                  IsmLiveImage.network(
                    controller.user?.profileUrl ?? '',
                    name: controller.user?.userName ?? 'U',
                    isProfileImage: true,
                    dimensions: IsmLiveDimens.forty,
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: IsmLiveApp.isMqttConnected
                            ? IsmLiveColors.green
                            : IsmLiveColors.red,
                        borderRadius: BorderRadius.circular(IsmLiveDimens.ten),
                      ),
                      child: const SizedBox.square(dimension: 8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: Text(
            IsmLiveStrings.title,
            style: IsmLiveStyles.blackBold16,
          ),
        ),
      );
}
