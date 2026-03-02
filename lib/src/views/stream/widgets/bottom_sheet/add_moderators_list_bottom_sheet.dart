import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bottom sheet for adding new moderators.
///
/// This keeps the general UX of the reference implementation (search,
/// scrollable list with "Add" chips and a bottom confirm button) but is
/// implemented using only the SDK's own theming and controller API.
class AddModeratorsListBottomSheet extends StatefulWidget {
  const AddModeratorsListBottomSheet({super.key});

  @override
  State<AddModeratorsListBottomSheet> createState() => _AddModeratorsListBottomSheetState();
}

class _AddModeratorsListBottomSheetState extends State<AddModeratorsListBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedUserIds = <String>{};
  bool _isSearching = false;
  Timer? _debounce;

  static const _debounceDuration = Duration(milliseconds: 500);

  IsmLiveStreamController get _controller => IsmLiveApp.getStreamController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();

    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      // Reload full list when search is cleared
      final controller = Get.find<IsmLiveStreamController>();
      controller.fetchUsers(forceFetch: true);
      return;
    }

    _debounce = Timer(_debounceDuration, () async {
      setState(() {
        _isSearching = true;
      });

      // Use existing controller search API (results will rebuild via GetBuilder)
      final controller = Get.find<IsmLiveStreamController>();
      controller.searchUser(query);

      setState(() {
        _isSearching = false;
      });
    });
  }

  void _toggleSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  Future<void> _onConfirm() async {
    if (_selectedUserIds.isEmpty) return;

    final streamId = _controller.streamId ?? '';

    // Apply moderator role to all selected users
    for (final userId in _selectedUserIds) {
      await _controller.makeModerator(
        streamId: streamId,
        moderatorId: userId,
      );
    }

    // Refresh moderators list so next open shows updated state
    await _controller.fetchModerators(
      forceFetch: true,
      streamId: streamId,
    );

    IsmLiveRoute.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        context.liveTheme?.backgroundColor ?? (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return GetBuilder<IsmLiveStreamController>(
      id: IsmLiveUsersSheet.updateId,
      initState: (_) {
        final controller = Get.find<IsmLiveStreamController>();
        controller.searchUserFieldController.clear();
        controller.usersList.clear();
        controller.fetchUsers(forceFetch: true);
      },
      builder: (controller) {
        final hostId = controller.hostDetails?.userId;
        final hostIdentifier = controller.hostDetails?.userIdentifier;

        // Base user list (skip host)
        final allUsers = controller.usersList.where((user) {
          if (hostId != null && user.userId == hostId) return false;
          if (hostIdentifier != null && user.userIdentifier == hostIdentifier) {
            return false;
          }
          return true;
        }).toList();

        // Local filter by search text
        final query = _searchController.text.trim().toLowerCase();
        final filteredUsers = query.isEmpty
            ? allUsers
            : allUsers
                .where(
                  (u) =>
                      u.userName.toLowerCase().contains(query) ||
                      u.userIdentifier.toLowerCase().contains(query),
                )
                .toList();

        final isInitialLoading = !_isSearching && controller.usersList.isEmpty;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            minHeight: 360,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ?? IsmLiveDimens.thirty,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context, textColor),
              _buildSearchBar(context, textColor),
              const SizedBox(height: 12),
              Expanded(
                child: (_isSearching || isInitialLoading)
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : filteredUsers.isEmpty
                        ? _buildEmptyState(context, textColor)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              final imageUrl =
                                  IsmLiveDelegate.getUserProfileUrl?.call(user.profileUrl) ??
                                      user.profileUrl;
                              final isSelected = _selectedUserIds.contains(user.userId);
                              final canAdd = !controller.checkCanMakeModerator(user.userId);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: IsmLiveImage.network(
                                    imageUrl,
                                    name: user.userName,
                                    dimensions: IsmLiveDimens.forty,
                                    isProfileImage: true,
                                  ),
                                  title: Text(
                                    user.userName,
                                    style: TextStyle(color: textColor),
                                  ),
                                  subtitle: Text(
                                    user.userIdentifier,
                                    style: TextStyle(
                                      color: context.liveTheme?.unselectedTextColor ??
                                          (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey),
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: canAdd
                                      ? SizedBox(
                                          width: 84,
                                          height: 32,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                              ),
                                              side: BorderSide(
                                                color: context.liveTheme?.primaryColor ??
                                                    IsmLiveColors.primary,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              backgroundColor: isSelected
                                                  ? context.liveTheme?.primaryColor ??
                                                      IsmLiveColors.primary
                                                  : Colors.transparent,
                                              foregroundColor: isSelected
                                                  ? Colors.white
                                                  : context.liveTheme?.primaryColor ??
                                                      IsmLiveColors.primary,
                                            ),
                                            onPressed: () => _toggleSelection(
                                              user.userId,
                                            ),
                                            child: Text(
                                              isSelected
                                                  ? IsmLiveStrings.selected
                                                  : IsmLiveStrings.add,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              );
                            },
                          ),
              ),
              if (allUsers.isNotEmpty) _buildConfirmButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Row(
          children: [
            const SizedBox(width: 24), // spacer to balance close icon
            Expanded(
              child: Center(
                child: Text(
                  IsmLiveStrings.addModerator,
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

  Widget _buildSearchBar(BuildContext context, Color textColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDarkMode ? Colors.white.withOpacity(0.06) : const Color(0xFFF5F5F5);

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
              controller: _searchController,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: IsmLiveStrings.searchByUsername,
                hintStyle: TextStyle(
                  color: context.liveTheme?.unselectedTextColor ?? Colors.grey,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            InkWell(
              onTap: () {
                _searchController.clear();
                final controller = Get.find<IsmLiveStreamController>();
                controller.fetchUsers(forceFetch: true);
              },
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

  Widget _buildEmptyState(BuildContext context, Color textColor) => SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_search_outlined,
                  size: 28,
                  color: context.liveTheme?.unselectedTextColor ?? Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                IsmLiveStrings.noUsers,
                style: TextStyle(
                  color: context.liveTheme?.unselectedTextColor ?? Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildConfirmButton(BuildContext context) {
    final hasSelection = _selectedUserIds.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: IsmLiveButton(
          label: IsmLiveStrings.confirm,
          onTap: hasSelection ? _onConfirm : null,
        ),
      ),
    );
  }
}
