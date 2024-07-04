import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveCopublishingHostSheet extends StatelessWidget {
  const IsmLiveCopublishingHostSheet({super.key});
  static const String updateId = 'stream-copublisher-sheet';

  @override
  Widget build(BuildContext context) => Padding(
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
                            ? Colors.black //context.liveTheme?.primaryColor
                            : Colors.grey.shade100,
                        borderRadius:
                            BorderRadius.circular(IsmLiveDimens.eighty),
                      ),
                      child: Padding(
                        padding: IsmLiveDimens.edgeInsets16_10,
                        child: Text(
                          type.label,
                          style: context.textTheme.titleSmall?.copyWith(
                              color: isSelected
                                  ? IsmLiveColors
                                      .white //context.liveTheme?.selectedTextColor
                                  : IsmLiveColors
                                      .grey //context.liveTheme?.unselectedTextColor,
                              ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            SizedBox(
              height: Get.height * 0.4,
              child: GetBuilder<IsmLiveStreamController>(
                id: updateId,
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
                      hintText: 'Search Request',
                      onchange: controller.searchRequest,
                      title: '',
                      placeHolder:
                          IsmLiveAssetConstants.user_request_placeholder,
                      placeHolderText: 'No request users',
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
                          title: Text(copublisher.userName),
                          subtitle: Text(copublisher.userIdentifier),
                          trailing: copublisher.pending ?? false
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IsmLiveButton.icon(
                                      icon: Icons.check_rounded,
                                      onTap: () {
                                        Get.back();
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
                                        Get.back();
                                        controller.denyCopublisherRequest(
                                          requestById: copublisher.userId,
                                          streamId: controller.streamId ?? '',
                                        );
                                      },
                                    )
                                  ],
                                )
                              : copublisher.accepted ?? false
                                  ? const Text(
                                      'accepted',
                                      style: TextStyle(color: Colors.green),
                                    )
                                  : const Text(
                                      'deny',
                                      style: TextStyle(color: Colors.red),
                                    ),
                        );
                      },
                    ),
                    IsmLiveScrollSheet(
                      showSearchBar: true,
                      placeHolder: IsmLiveAssetConstants.user_placeholder,
                      placeHolderText: 'No users',
                      onPressClearIcon: () {
                        controller.searchMembersFieldController.clear();
                        controller.searchMembers(
                            controller.searchMembersFieldController.text);
                      },
                      showHeader: false,
                      textEditingController:
                          controller.searchMembersFieldController,
                      hintText: 'Search User',
                      onchange: controller.searchMembers,
                      title: '',
                      controller: controller.membersListController,
                      itemCount: controller.eligibleMembersList.length,
                      itemBuilder: (context, index) {
                        final members = controller.eligibleMembersList[index];
                        return ListTile(
                          leading: IsmLiveImage.network(
                            members.profileUrl,
                            name: members.userName,
                            dimensions: IsmLiveDimens.forty,
                            isProfileImage: true,
                          ),
                          title: Text(members.userName),
                          subtitle: Text(members.userIdentifier),
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
      );
}
