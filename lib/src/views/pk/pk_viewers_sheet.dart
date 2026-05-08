import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkViewersSheet extends StatelessWidget {
  const IsmLivePkViewersSheet({super.key});

  static const String updateId = 'pk-viewers-sheet';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);
    final selectedTabBg = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final selectedTabTextColor =
        selectedTabBg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final unselectedTabColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);
    final unselectedTabBg = context.liveTheme?.cardBackgroundColor ??
        (isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade100);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                IsmLiveDimens.thirty,
          ),
        ),
      ),
      child: Padding(
        padding: IsmLiveDimens.edgeInsetsT16,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              IsmLiveDimens.boxHeight16,
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  IsmLiveStrings.viewers,
                  style: IsmLiveStyles.blackBold20.copyWith(color: textColor),
                ),
              ),
              IsmLiveDimens.boxHeight10,
              GetX<IsmLivePkController>(
                initState: (state) {
                  var controller = Get.find<IsmLivePkController>();
                  controller.pkViewersTabController.index = 0;
                  controller.pkViewers = IsmLivePkViewers.values[0];
                },
                builder: (controller) => TabBar(
                  dividerHeight: 0,
                  indicatorColor: Colors.transparent,
                  labelPadding: IsmLiveDimens.edgeInsets8_0,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  controller: controller.pkViewersTabController,
                  onTap: (index) {
                    controller.pkViewers = IsmLivePkViewers.values[index];
                  },
                  tabs: IsmLivePkViewers.values.map(
                    (type) {
                      var isSelected = (type == controller.pkViewers);

                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: isSelected ? selectedTabBg : unselectedTabBg,
                          borderRadius:
                              BorderRadius.circular(IsmLiveDimens.eighty),
                        ),
                        child: Padding(
                          padding: IsmLiveDimens.edgeInsets16_10,
                          child: Text(
                            type.label,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: isSelected
                                  ? selectedTabTextColor
                                  : unselectedTabColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: GetBuilder<IsmLivePkController>(
                  id: updateId,
                  builder: (controller) => TabBarView(
                    controller: controller.pkViewersTabController,
                    children: [
                      IsmLiveScrollSheet(
                        showSearchBar: false,
                        showHeader: false,
                        title: '',
                        placeHolderText: IsmLiveStrings.noDataFound,
                        itemCount: 5,
                        itemBuilder: (context, index) => ListTile(
                          leading: IsmLiveImage.network(
                            '',
                            name: '@tayne22',
                            dimensions: IsmLiveDimens.forty,
                            isProfileImage: true,
                          ),
                          title: Text('@tayne22', style: TextStyle(color: textColor)),
                          subtitle: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.remove_red_eye, color: subtitleColor),
                              Text('123', style: TextStyle(color: subtitleColor)),
                            ],
                          ),
                        ),
                      ),
                      IsmLiveScrollSheet(
                        placeHolderText: IsmLiveStrings.noDataFound,
                        showHeader: false,
                        title: '',
                        itemCount: 0,
                        itemBuilder: (context, index) => ListTile(
                          leading: IsmLiveImage.network(
                            '',
                            name: '@tayne22',
                            dimensions: IsmLiveDimens.forty,
                            isProfileImage: true,
                          ),
                          title: Text('@tayne22', style: TextStyle(color: textColor)),
                          subtitle: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.remove_red_eye, color: subtitleColor),
                              Text('123', style: TextStyle(color: subtitleColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
