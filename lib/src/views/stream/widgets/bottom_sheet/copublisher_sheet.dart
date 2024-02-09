import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveCopublisherSheet extends StatelessWidget {
  const IsmLiveCopublisherSheet({super.key});
  static const String updateId = 'stream-copublisher-sheet';

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16_30_16_5,
        child: Column(
          children: [
            GetX<IsmLiveStreamController>(
              initState: (state) {
                Get.find<IsmLiveStreamController>().fetchCopublisherRequests(
                    streamId:
                        Get.find<IsmLiveStreamController>().streamId ?? '');
                Get.find<IsmLiveStreamController>().fetchEligibleMembers(
                    streamId:
                        Get.find<IsmLiveStreamController>().streamId ?? '');
                Get.find<IsmLiveStreamController>().getStreamMembers(
                    streamId:
                        Get.find<IsmLiveStreamController>().streamId ?? '');
              },
              builder: (controller) => TabBar(
                dividerHeight: 0,
                indicatorColor: Colors.transparent,
                labelPadding: IsmLiveDimens.edgeInsets8_0,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                controller: controller.cobublisTabController,
                onTap: (index) {
                  controller.copublisher = IsmLiveCopublisher.values[index];
                },
                tabs: IsmLiveCopublisher.values.map(
                  (type) {
                    var isSelected = type == controller.copublisher;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.liveTheme.primaryColor
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
                                ? context.liveTheme.selectedTextColor
                                : context.liveTheme.unselectedTextColor,
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
                            dimensions: IsmLiveDimens.forty,
                            isProfileImage: true,
                          ),
                          title: Text(members.userName),
                          subtitle: Text(members.userIdentifier),
                          trailing: controller.isHost ?? false
                              ? SizedBox(
                                  width: IsmLiveDimens.hundred,
                                  child: IsmLiveButton(
                                    label: 'Add Copublisher',
                                    small: true,
                                    onTap: () {
                                      controller.addMember(
                                        streamId: controller.streamId ?? '',
                                        memberId: members.userId,
                                      );
                                    },
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                    IsmLiveScrollSheet(
                      showSearchBar: true,
                      showHeader: false,
                      textEditingController:
                          controller.searchExistingMembesFieldController,
                      hintText: 'Search Copublisher',
                      onchange: controller.searchMember,
                      title: '',
                      controller: controller.existingMembersListController,
                      itemCount: controller.streamMembersList.length,
                      itemBuilder: (context, index) {
                        final existingMember =
                            controller.streamMembersList[index];
                        return ListTile(
                          leading: IsmLiveImage.network(
                            existingMember.userProfileImageUrl,
                            dimensions: IsmLiveDimens.forty,
                            isProfileImage: true,
                          ),
                          title: Text(existingMember.userName),
                          subtitle: Text(existingMember.userIdentifier),
                          trailing: controller.isHost ?? false
                              ? SizedBox(
                                  width: IsmLiveDimens.hundred,
                                  child: IsmLiveButton(
                                    label: 'Remove Copublisher',
                                    small: true,
                                    onTap: () {
                                      controller.removeMember(
                                        streamId: controller.streamId ?? '',
                                        memberId: existingMember.userId,
                                      );
                                    },
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                    IsmLiveScrollSheet(
                      showSearchBar: true,
                      showHeader: false,
                      textEditingController:
                          controller.searchCopublisherFieldController,
                      hintText: 'Search Request',
                      onchange: controller.searchRequest,
                      title: '',
                      controller: controller.copublisherListController,
                      itemCount: controller.copublisherRequestsList.length,
                      itemBuilder: (context, index) {
                        final copublisher =
                            controller.copublisherRequestsList[index];
                        return ListTile(
                          leading: IsmLiveImage.network(
                            copublisher.profileUrl,
                            dimensions: IsmLiveDimens.forty,
                            isProfileImage: true,
                          ),
                          title: Text(copublisher.userName),
                          subtitle: Text(copublisher.userIdentifier),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: IsmLiveDimens.sixty,
                                child: IsmLiveButton(
                                  label: 'Accept',
                                  small: true,
                                  onTap: () {
                                    controller.acceptCopublisherRequest(
                                        requestById: copublisher.userId,
                                        streamId: controller.streamId ?? '');
                                  },
                                ),
                              ),
                              IsmLiveDimens.boxWidth4,
                              SizedBox(
                                width: IsmLiveDimens.sixty,
                                child: IsmLiveButton(
                                  label: 'Deny',
                                  small: true,
                                  onTap: () {},
                                ),
                              )
                            ],
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
      );
}
