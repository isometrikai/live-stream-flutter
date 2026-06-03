import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveMembersSheet extends StatefulWidget {
  const IsmLiveMembersSheet({super.key});

  static const String updateId = 'members_sheet';

  @override
  State<IsmLiveMembersSheet> createState() => _IsmLiveMembersSheetState();
}

class _IsmLiveMembersSheetState extends State<IsmLiveMembersSheet> {
  Timer? _searchDebounce;
  bool _isSearching = false;

  static const _debounceDuration = Duration(milliseconds: 500);

  /// Set to `true` when member search should be shown again.
  static const _showSearchBar = false;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchQueryChanged(
    IsmLiveStreamController controller,
    String value,
  ) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_debounceDuration, () async {
      if (!mounted) return;
      setState(() => _isSearching = true);
      await controller.searchMember(value);
      if (mounted) {
        setState(() => _isSearching = false);
      }
    });
  }

  void _clearSearch(IsmLiveStreamController controller) {
    _searchDebounce?.cancel();
    controller.searchExistingMembesFieldController.clear();
    setState(() {
      _isSearching = false;
    });
    unawaited(controller.searchMember(''));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);

    return GetBuilder<IsmLiveStreamController>(
      id: IsmLiveMembersSheet.updateId,
      initState: (_) {
        Get.find<IsmLiveStreamController>()
          ..searchExistingMembesFieldController.clear();
      },
      builder: (controller) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minHeight: 360,
        ),
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(context, textColor),
                    if (_showSearchBar) ...[
                      _buildSearchBar(
                        context,
                        textColor: textColor,
                        controller: controller,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _showSearchBar && _isSearching
                            ? const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IsmLiveScrollSheet(
                              showHeader: false,
                              showSearchBar: false,
                              placeHolder:
                                  IsmLiveAssetConstants.user_placeholder,
                              placeHolderText: IsmLiveStrings.noUsers,
                              title: IsmLiveStrings.members,
                              controller:
                                  controller.existingMembersListController,
                              itemCount: controller.streamMembersList.length,
                              itemBuilder: (context, index) {
                                final existingMember =
                                    controller.streamMembersList[index];
                                final imageUrl = IsmLiveDelegate
                                            .getUserProfileUrl
                                            ?.call(existingMember.image) ??
                                    existingMember.image;
                                return InkWell(
                                  onTap: IsmLiveDelegate
                                          .restrictProfileSheetOnProfileClick
                                      ? null
                                      : () {
                                          IsmLiveUtility.openBottomSheet(
                                            StreamLiveSheet(
                                              widget: IsmLiveImage.network(
                                                imageUrl,
                                                isProfileImage: true,
                                                name: existingMember.name,
                                                initials: existingMember
                                                    .profileInitials,
                                                height: IsmLiveDimens.hundred,
                                                width: IsmLiveDimens.hundred,
                                              ),
                                              title: existingMember.name,
                                              subTitle: null,
                                              buttonLable:
                                                  IsmLiveStrings.viewProfile,
                                              onTap: () {
                                                IsmLiveDelegate
                                                    .openUserProfileView
                                                    ?.call(existingMember
                                                        .userIdentifier);
                                              },
                                            ),
                                            isScrollController: true,
                                          );
                                        },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: IsmLiveImage.network(
                                      imageUrl,
                                      name: existingMember.name,
                                      initials:
                                          existingMember.profileInitials,
                                      dimensions: IsmLiveDimens.forty,
                                      isProfileImage: true,
                                    ),
                                    title: Text(
                                      existingMember.name,
                                      style: TextStyle(color: textColor),
                                    ),
                                    subtitle: existingMember.displayUserName !=
                                            existingMember.fullName
                                        ? Text(
                                            existingMember.displayUserName,
                                            style: TextStyle(
                                              color: subtitleColor,
                                              fontSize: 12,
                                            ),
                                          )
                                        : null,
                                    trailing: (controller.isHost) &&
                                            controller.user?.userId !=
                                                existingMember.userId
                                        ? IsmLiveButton.icon(
                                            icon: Icons.person_remove_rounded,
                                            onTap: () {
                                              controller.removeMember(
                                                streamId:
                                                    controller.streamId ?? '',
                                                memberId:
                                                    existingMember.userId,
                                              );
                                            },
                                          )
                                        : (controller.user?.userId ==
                                                    existingMember.userId) &&
                                                (controller.isHost == false)
                                            ? IsmLiveButton.icon(
                                                icon: Icons.exit_to_app_rounded,
                                                onTap: () {
                                                  IsmLiveRoute.pop();
                                                  controller.disconnectStream(
                                                    isHost: false,
                                                    streamId: controller
                                                            .streamId ??
                                                        '',
                                                    endStream: false,
                                                    goBack: false,
                                                  );
                                                },
                                              )
                                            : null,
                                  ),
                                );
                              },
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Row(
          children: [
            const SizedBox(width: 24),
            Expanded(
              child: Center(
                child: Text(
                  IsmLiveStrings.members,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: IsmLiveRoute.pop,
              child: Icon(
                Icons.close,
                size: 20,
                color: textColor,
              ),
            ),
          ],
        ),
      );

  Widget _buildSearchBar(
    BuildContext context, {
    required Color textColor,
    required IsmLiveStreamController controller,
    required bool isDarkMode,
  }) {
    final fillColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFF5F5F5);
    final searchController =
        controller.searchExistingMembesFieldController;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
              controller: searchController,
              style: TextStyle(color: textColor, fontSize: 14),
              onChanged: (value) {
                setState(() {});
                _onSearchQueryChanged(controller, value);
              },
              decoration: InputDecoration(
                hintText: IsmLiveStrings.searchByUsername,
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
          if (searchController.text.isNotEmpty)
            InkWell(
              onTap: () => _clearSearch(controller),
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
}
