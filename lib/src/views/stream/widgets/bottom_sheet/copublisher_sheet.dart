import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveCopublishingHostSheet extends StatelessWidget {
  const IsmLiveCopublishingHostSheet({super.key});
  static const String updateId = 'stream-copublisher-sheet';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);
    final selectedTabBg = isDarkMode ? Colors.white : Colors.black;
    // Contrast with selected tab background so text is always readable
    final selectedTabTextColor = selectedTabBg.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GetX<IsmLiveStreamController>(
              initState: (state) {
                var controller = Get.find<IsmLiveStreamController>();

                controller.fetchCopublisherRequests(
                  streamId: controller.streamId ?? '',
                  forceFetch: true,
                );
                controller.fetchEligibleMembers(
                  streamId: controller.streamId ?? '',
                );
                controller.cobublisTabController.index = 0;
                controller.copublisher = IsmLiveCopublisher.values[0];
              },
              builder: (controller) => TabBar(
                dividerHeight: 0,
                indicatorColor: Colors.transparent,
                labelPadding: IsmLiveDimens.edgeInsets8_0,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                controller: controller.cobublisTabController,
                onTap: (index) {
                  controller.copublisher = IsmLiveCopublisher.values[index];
                },
                tabs: IsmLiveCopublisher.values.map(
                  (type) {
                    var isSelected = (type == controller.copublisher);

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selectedTabBg
                            : unselectedTabBg,
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
              child: GetBuilder<IsmLiveStreamController>(
                id: updateId,
                initState: (state) {
                  Get.find<IsmLiveStreamController>()
                    ..searchCopublisherFieldController.clear()
                    ..searchMembersFieldController.clear();
                },
                builder: (controller) => TabBarView(
                  controller: controller.cobublisTabController,
                  children: [
                    IsmLiveScrollSheet(
                      showSearchBar: true,
                      onPressClearIcon: () {
                        controller.searchCopublisherFieldController.clear();
                        controller.searchRequest(
                            controller.searchCopublisherFieldController.text);
                      },
                      showHeader: false,
                      textEditingController:
                          controller.searchCopublisherFieldController,
                      hintText: IsmLiveStrings.searchRequest,
                      onchange: controller.searchRequest,
                      title: '',
                      placeHolder:
                          IsmLiveAssetConstants.user_request_placeholder,
                      placeHolderText: IsmLiveStrings.noRequestUsers,
                      controller: controller.copublisherListController,
                      itemCount: controller.copublisherRequestsList.length,
                      itemBuilder: (context, index) {
                        final copublisher =
                            controller.copublisherRequestsList[index];
                        return ListTile(
                          leading: IsmLiveImage.network(
                            copublisher.profileUrl,
                            name: copublisher.userName,
                            dimensions: IsmLiveDimens.forty,
                            isProfileImage: true,
                          ),
                          title: Text(
                            copublisher.userName,
                            style: TextStyle(color: textColor),
                          ),
                          subtitle: Text(
                            copublisher.userIdentifier,
                            style: TextStyle(color: subtitleColor),
                          ),
                          trailing: copublisher.pending ?? false
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IsmLiveButton.icon(
                                      icon: Icons.check_rounded,
                                      onTap: () {
                                        IsmLiveRoute.pop();
                                        controller.acceptCopublisherRequest(
                                          requestById: copublisher.userId,
                                          streamId: controller.streamId ?? '',
                                        );
                                      },
                                    ),
                                    IsmLiveDimens.boxWidth4,
                                    IsmLiveButton.icon(
                                      icon: Icons.close_rounded,
                                      secondary: true,
                                      onTap: () {
                                        IsmLiveRoute.pop();
                                        controller.denyCopublisherRequest(
                                          requestById: copublisher.userId,
                                          streamId: controller.streamId ?? '',
                                        );
                                      },
                                    )
                                  ],
                                )
                              : copublisher.accepted ?? false
                                  ? Text(
                                      IsmLiveStrings.accepted,
                                      style: const TextStyle(
                                          color: Colors.green),
                                    )
                                  : Text(
                                      IsmLiveStrings.deny,
                                      style: const TextStyle(
                                          color: Colors.red),
                                    ),
                        );
                      },
                    ),
                    IsmLiveScrollSheet(
                      showSearchBar: true,
                      placeHolder: IsmLiveAssetConstants.user_placeholder,
                      placeHolderText: IsmLiveStrings.noUsers,
                      onPressClearIcon: () {
                        controller.searchMembersFieldController.clear();
                        controller.searchMembers(
                            controller.searchMembersFieldController.text);
                      },
                      showHeader: false,
                      textEditingController:
                          controller.searchMembersFieldController,
                      hintText: IsmLiveStrings.searchUser,
                      onchange: controller.searchMembers,
                      title: '',
                      controller: controller.membersListController,
                      itemCount: controller.eligibleMembersList.length,
                      itemBuilder: (context, index) {
                        final members =
                            controller.eligibleMembersList[index];
                        return ListTile(
                          leading: IsmLiveImage.network(
                            members.profileUrl,
                            name: members.userName,
                            dimensions: IsmLiveDimens.forty,
                            isProfileImage: true,
                          ),
                          title: Text(
                            members.userName,
                            style: TextStyle(color: textColor),
                          ),
                          subtitle: Text(
                            members.userIdentifier,
                            style: TextStyle(color: subtitleColor),
                          ),
                          trailing: controller.isHost == true
                              ? IsmLiveButton.icon(
                                  icon: Icons.person_add_rounded,
                                  onTap: () {
                                    controller.addMember(
                                      streamId: controller.streamId ?? '',
                                      memberId: members.userId,
                                    );
                                  },
                                )
                              : null,
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
    );
  }
}
