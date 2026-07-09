import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class IsmLiveAppbar extends StatelessWidget implements PreferredSizeWidget {
  const IsmLiveAppbar({
    super.key,
    this.height,
    this.showBackArrow = false,
    this.title,
  });

  final double? height;
  final bool showBackArrow;
  final String? title;

  static const String updateId = 'ismlive-appbar';

  @override
  Size get preferredSize =>
      Size.fromHeight(height ?? IsmLiveDimens.appBarHeight);

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        builder: (controller) => AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          leadingWidth: IsmLiveDimens.sixty,
          actions: showBackArrow
              ? []
              : [
                  InkWell(
                    onTap: IsmLiveRouteManagement.goToCoinsPlanWallet,
                    child: Row(
                      children: [
                        SvgPicture.asset(IsmLiveAssetConstants.coinSvg),
                        IsmLiveDimens.boxWidth10,
                        Text(
                          IsmLiveStrings.addCoins,
                          style: IsmLiveStyles.black16.copyWith(
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                        IsmLiveDimens.boxWidth10,
                      ],
                    ),
                  )
                ],
          leading: showBackArrow
              ? ismLiveBuildBackButton(
                  context,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                )
              : IsmLiveTapHandler(
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
                          IsmLiveDelegate.getUserProfileUrl
                                  ?.call(controller.user?.profileUrl ?? '') ??
                              controller.user?.profileUrl ??
                              '',
                          name: controller.user?.userName ?? 'U',
                          isProfileImage: true,
                          dimensions: IsmLiveDimens.forty,
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Obx(
                            () => DecoratedBox(
                              decoration: BoxDecoration(
                                color: IsmLiveApp.isMqttConnectedRx.value
                                    ? IsmLiveColors.green
                                    : IsmLiveColors.red,
                                borderRadius:
                                    BorderRadius.circular(IsmLiveDimens.ten),
                              ),
                              child: const SizedBox.square(dimension: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          title: Text(
            title ?? IsmLiveStrings.title,
            style: IsmLiveStyles.blackBold16.copyWith(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
            ),
          ),
        ),
      );
}
