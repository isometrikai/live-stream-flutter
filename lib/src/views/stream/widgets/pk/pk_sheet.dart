import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkSheet extends StatelessWidget {
  const IsmLivePkSheet({super.key});

  static const String updateId = 'stream-pk-sheet';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);
    final selectedTabBg = isDarkMode ? Colors.white : Colors.black;
    final selectedTabTextColor =
        selectedTabBg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final unselectedTabColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);
    final unselectedTabBg = context.liveTheme?.cardBackgroundColor ??
        (isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade100);

    return Container(
      decoration: BoxDecoration(
        color: context.liveTheme?.backgroundColor ??
            (isDarkMode ? const Color(0xFF121212) : Colors.white),
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
              IsmLiveDimens.boxHeight8,
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  IsmLiveStrings.pkWithFriends,
                  style: IsmLiveStyles.blackBold20.copyWith(color: textColor),
                ),
              ),
              IsmLiveDimens.boxHeight10,
              GetX<IsmLivePkController>(
                initState: (state) {
                  Get.find<IsmLivePkController>()
                    ..pkInviteList.clear()
                    ..pkReceivedInviteList.clear()
                    ..getUsersToInviteForPK()
                    ..pkTabController.index = 0
                    ..pk = IsmLivePk.values[0];
                },
                builder: (controller) => TabBar(
                  dividerHeight: 0,
                  indicatorColor: Colors.transparent,
                  labelPadding: IsmLiveDimens.edgeInsets8_0,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  controller: controller.pkTabController,
                  onTap: (index) {
                    controller.pk = IsmLivePk.values[index];
                    if (index == IsmLivePk.inviteList.index) {
                      controller.getPkInvites();
                    }
                  },
                  tabs: IsmLivePk.values.map(
                    (type) {
                      var isSelected = (type == controller.pk);

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
                child: GetX<IsmLivePkController>(
                  builder: (controller) => TabBarView(
                    controller: controller.pkTabController,
                    children: [
                      IsmLiveScrollSheet(
                        showSearchBar: true,
                        controller: controller.pkInviteListController,
                        onPressClearIcon: () {
                          controller.pkInviteTextController.clear();
                          controller.getUsersToInviteForPK();
                        },
                        showHeader: false,
                        textEditingController:
                            controller.pkInviteTextController,
                        hintText: IsmLiveStrings.search,
                        onchange: (value) {
                          controller.getUsersToInviteForPK(searchTag: value);
                        },
                        title: '',
                        placeHolderText: IsmLiveStrings.noDataFound,
                        itemCount: controller.pkInviteList.length,
                        itemBuilder: (context, index) {
                          var details = controller.pkInviteList[index];
                          return ListTile(
                            leading: IsmLiveImage.network(
                              details.profilePic ?? '',
                              name: details.name,
                              dimensions: IsmLiveDimens.forty,
                              isProfileImage: true,
                            ),
                            title: Text(
                              details.name,
                              style: TextStyle(color: textColor),
                            ),
                            subtitle: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.remove_red_eye,
                                  size: 16,
                                  color: subtitleColor,
                                ),
                                IsmLiveDimens.boxWidth4,
                                Text(
                                  '${details.viewerCount}',
                                  style: TextStyle(color: subtitleColor),
                                ),
                              ],
                            ),
                            trailing: SizedBox(
                              width: IsmLiveDimens.hundred,
                              child: IsmLiveButton.secondary(
                                showBorder: true,
                                label: IsmLiveStrings.invite,
                                onTap: () {
                                  controller.sendInvitationToUserForPK(
                                    reciverDetails: details,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      IsmLiveScrollSheet(
                        controller: controller.pkReceivedInviteListController,
                        placeHolderText: IsmLiveStrings.noDataFound,
                        showHeader: false,
                        title: '',
                        itemCount: controller.pkReceivedInviteList.length,
                        itemBuilder: (context, index) {
                          if (index >= controller.pkReceivedInviteList.length) {
                            return const SizedBox.shrink();
                          }
                          var details =
                              controller.pkReceivedInviteList[index];
                          return ListTile(
                            leading: IsmLiveImage.network(
                              details.displayProfilePic,
                              name: details.name,
                              dimensions: IsmLiveDimens.forty,
                              isProfileImage: true,
                            ),
                            title: Text(
                              details.name,
                              style: TextStyle(color: textColor),
                            ),
                            subtitle: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.remove_red_eye,
                                  size: 16,
                                  color: subtitleColor,
                                ),
                                IsmLiveDimens.boxWidth4,
                                Text(
                                  '${details.viewerCount}',
                                  style: TextStyle(color: subtitleColor),
                                ),
                              ],
                            ),
                            trailing: SizedBox(
                              width: IsmLiveDimens.hundred,
                              child: IsmLiveButton(
                                label: IsmLiveStrings.accept,
                                onTap: () {
                                  IsmLiveRoute.pop();
                                  controller.inviteId =
                                      details.inviteId ?? '';
                                  controller.invitationPk(
                                    inviteId: details.inviteId ?? '',
                                    reciverStreamId: details.streamId,
                                    response: IsmLivePkResponceToSend
                                        .accepted.value,
                                    context: context,
                                  );
                                },
                              ),
                            ),
                          );
                        },
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
