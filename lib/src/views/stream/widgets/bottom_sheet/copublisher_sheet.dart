import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveCopublishingHostSheet extends StatefulWidget {
  const IsmLiveCopublishingHostSheet({super.key});
  static const String updateId = 'stream-copublisher-sheet';

  @override
  State<IsmLiveCopublishingHostSheet> createState() =>
      _IsmLiveCopublishingHostSheetState();
}

class _IsmLiveCopublishingHostSheetState
    extends State<IsmLiveCopublishingHostSheet> {
  Timer? _copublisherSearchDebounce;
  Timer? _membersSearchDebounce;
  static const _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    final controller = Get.find<IsmLiveStreamController>();
    // Clear before the TextField is built so onChanged does not fire an extra
    // search while GetX also runs the initial fetch for this sheet.
    controller.searchCopublisherFieldController.clear();
    controller.searchMembersFieldController.clear();
  }

  @override
  void dispose() {
    _copublisherSearchDebounce?.cancel();
    _membersSearchDebounce?.cancel();
    super.dispose();
  }

  Widget _buildSearchBar({
    required BuildContext context,
    required Color textColor,
    required TextEditingController textController,
    required String hintText,
    required ValueChanged<String> onDebouncedQuery,
    required VoidCallback onClear,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFF5F5F5);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: context.liveTheme?.unselectedTextColor ?? Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: textController,
              style: TextStyle(color: textColor, fontSize: 14),
              onChanged: (value) {
                setState(() {});
                onDebouncedQuery(value);
              },
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: context.liveTheme?.unselectedTextColor ?? Colors.grey,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ),
          if (textController.text.isNotEmpty)
            InkWell(
              onTap: onClear,
              child: Icon(
                Icons.clear,
                color: context.liveTheme?.unselectedTextColor ?? Colors.grey,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  static const Widget _loadMoreIndicator = Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );

  Widget _buildEmptyPlaceholder({
    required String? placeHolder,
    required String? placeHolderText,
  }) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (placeHolder != null)
            Container(
              padding: IsmLiveDimens.edgeInsetsL20,
              child: IsmLiveImage.svg(placeHolder),
            ),
          IsmLiveDimens.boxHeight2,
          Text(placeHolderText ?? ''),
        ],
      );

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
    final showCopublisherTabBar = IsmLiveStreamOption.viewersOptions
        .contains(IsmLiveStreamOption.multiLive);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        minHeight: 360,
      ),
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
          mainAxisSize: MainAxisSize.max,
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
                  forceFetch: true,
                );
                final copublisherTabs = IsmLiveCopublisher.values;
                final showTabs = IsmLiveStreamOption.viewersOptions
                    .contains(IsmLiveStreamOption.multiLive);
                if (copublisherTabs.isNotEmpty) {
                  if (showTabs) {
                    controller.cobublisTabController.index = 0;
                    controller.copublisher = copublisherTabs.first;
                  } else {
                    final usersIndex =
                        copublisherTabs.indexOf(IsmLiveCopublisher.users);
                    if (usersIndex >= 0) {
                      controller.cobublisTabController.index = usersIndex;
                      controller.copublisher = IsmLiveCopublisher.users;
                    } else {
                      controller.cobublisTabController.index = 0;
                      controller.copublisher = copublisherTabs.first;
                    }
                  }
                }
              },
              builder: (controller) {
                // Always read Rx so GetX subscribes even when the TabBar is hidden.
                final currentCopublisher = controller.copublisher;
                if (!showCopublisherTabBar) {
                  return const SizedBox(height: 8);
                }
                return TabBar(
                  dividerHeight: 0,
                  indicatorColor: Colors.transparent,
                  labelPadding: IsmLiveDimens.edgeInsets8_0,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  controller: controller.cobublisTabController,
                  onTap: (index) {
                    final tabs = IsmLiveCopublisher.values;
                    if (index >= 0 && index < tabs.length) {
                      controller.copublisher = tabs[index];
                    }
                  },
                  tabs: IsmLiveCopublisher.values.map(
                    (type) {
                      var isSelected = (type == currentCopublisher);

                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? selectedTabBg : unselectedTabBg,
                              borderRadius: BorderRadius.circular(
                                IsmLiveDimens.eighty,
                              ),
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
                );
              },
            ),
            Expanded(
              child: GetBuilder<IsmLiveStreamController>(
                id: IsmLiveCopublishingHostSheet.updateId,
                builder: (controller) {
                  final copublisherRequests =
                      List.from(controller.copublisherRequestsList);
                  final eligibleMembers =
                      List.from(controller.eligibleMembersList);

                  return TabBarView(
                    controller: controller.cobublisTabController,
                    physics: showCopublisherTabBar
                        ? null
                        : const NeverScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: IsmLiveDimens.edgeInsetsT8,
                        child: Column(
                          children: [
                            _buildSearchBar(
                              context: context,
                              textColor: textColor,
                              textController:
                                  controller.searchCopublisherFieldController,
                              hintText: IsmLiveStrings.searchRequest,
                              onDebouncedQuery: (value) {
                                _copublisherSearchDebounce?.cancel();
                                _copublisherSearchDebounce = Timer(
                                  _debounceDuration,
                                  () => controller.searchRequest(value),
                                );
                              },
                              onClear: () {
                                _copublisherSearchDebounce?.cancel();
                                controller.searchCopublisherFieldController
                                    .clear();
                                setState(() {});
                                controller.searchRequest('');
                              },
                            ),
                            IsmLiveDimens.boxHeight10,
                            Expanded(
                              child: copublisherRequests.isEmpty
                                  ? controller.isCopublisherApiCall
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Center(
                                          child: _buildEmptyPlaceholder(
                                            placeHolder: IsmLiveAssetConstants
                                                .user_request_placeholder,
                                            placeHolderText: IsmLiveStrings
                                                .noRequestUsers,
                                          ),
                                        )
                                  : ListView.separated(
                                      controller:
                                          controller.copublisherListController,
                                      itemCount: copublisherRequests.length +
                                          (controller.isCopublisherApiCall
                                              ? 1
                                              : 0),
                                      itemBuilder: (context, index) {
                                        if (index >=
                                            copublisherRequests.length) {
                                          return _loadMoreIndicator;
                                        }
                                        if (index < 0) {
                                          return const SizedBox.shrink();
                                        }
                                        final copublisher =
                                            copublisherRequests[index];
                                        return ListTile(
                                          leading: IsmLiveImage.network(
                                            copublisher.profileUrl,
                                            name: copublisher.name,
                                            dimensions: IsmLiveDimens.forty,
                                            initials:
                                                copublisher.profileInitials,
                                            isProfileImage: true,
                                          ),
                                          title: Text(
                                            copublisher.fullName,
                                            style: TextStyle(color: textColor),
                                          ),
                                          subtitle: Text(
                                            copublisher.displayUserName,
                                            style:
                                                TextStyle(color: subtitleColor),
                                          ),
                                          trailing: copublisher.pending ?? false
                                              ? Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IsmLiveButton.icon(
                                                      icon: Icons.check_rounded,
                                                      onTap: () {
                                                        IsmLiveRoute.pop();
                                                        controller
                                                            .acceptCopublisherRequest(
                                                          requestById:
                                                              copublisher
                                                                  .userId,
                                                          streamId: controller
                                                                  .streamId ??
                                                              '',
                                                        );
                                                      },
                                                    ),
                                                    IsmLiveDimens.boxWidth4,
                                                    IsmLiveButton.icon(
                                                      icon: Icons.close_rounded,
                                                      secondary: true,
                                                      onTap: () {
                                                        IsmLiveRoute.pop();
                                                        controller
                                                            .denyCopublisherRequest(
                                                          requestById:
                                                              copublisher
                                                                  .userId,
                                                          streamId: controller
                                                                  .streamId ??
                                                              '',
                                                        );
                                                      },
                                                    )
                                                  ],
                                                )
                                              : copublisher.accepted ?? false
                                                  ? const Text(
                                                      IsmLiveStrings.accepted,
                                                      style: TextStyle(
                                                          color: Colors.green),
                                                    )
                                                  : const Text(
                                                      IsmLiveStrings.deny,
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          IsmLiveDimens.box0,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: IsmLiveDimens.edgeInsetsT8,
                        child: Column(
                          children: [
                            _buildSearchBar(
                              context: context,
                              textColor: textColor,
                              textController:
                                  controller.searchMembersFieldController,
                              hintText: IsmLiveStrings.searchByUsername,
                              onDebouncedQuery: (value) {
                                _membersSearchDebounce?.cancel();
                                _membersSearchDebounce = Timer(
                                  _debounceDuration,
                                  () => controller.searchMembers(value),
                                );
                              },
                              onClear: () {
                                _membersSearchDebounce?.cancel();
                                controller.searchMembersFieldController.clear();
                                setState(() {});
                                controller.searchMembers('');
                              },
                            ),
                            IsmLiveDimens.boxHeight10,
                            Expanded(
                              child: eligibleMembers.isEmpty
                                  ? controller.isMembersApiCall
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Center(
                                          child: _buildEmptyPlaceholder(
                                            placeHolder: IsmLiveAssetConstants
                                                .user_placeholder,
                                            placeHolderText:
                                                IsmLiveStrings.noUsers,
                                          ),
                                        )
                                  : ListView.separated(
                                      controller:
                                          controller.membersListController,
                                      itemCount: eligibleMembers.length +
                                          (controller.isMembersApiCall
                                              ? 1
                                              : 0),
                                      itemBuilder: (context, index) {
                                        if (index >= eligibleMembers.length) {
                                          return _loadMoreIndicator;
                                        }
                                        if (index < 0) {
                                          return const SizedBox.shrink();
                                        }
                                        final members = eligibleMembers[index];
                                        return ListTile(
                                          leading: IsmLiveImage.network(
                                            IsmLiveDelegate.getUserProfileUrl
                                                    ?.call(members.profileUrl ??
                                                        '') ??
                                                members.profileUrl ??
                                                '',
                                            name: members.name,
                                            dimensions: IsmLiveDimens.forty,
                                            initials: members.profileInitials,
                                            isProfileImage: true,
                                          ),
                                          title: Text(
                                            members.name,
                                            style: TextStyle(color: textColor),
                                          ),
                                          subtitle: Text(
                                            members.userName,
                                            style:
                                                TextStyle(color: subtitleColor),
                                          ),
                                          trailing: controller.isHost == true
                                              ? IsmLiveButton.icon(
                                                  icon:
                                                      Icons.person_add_rounded,
                                                  onTap: () {
                                                    controller.addMember(
                                                      streamId:
                                                          controller.streamId ??
                                                              '',
                                                      memberId: members.userId,
                                                    );
                                                  },
                                                )
                                              : null,
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          IsmLiveDimens.box0,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
