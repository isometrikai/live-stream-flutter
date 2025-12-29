import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum IsmLiveModeratorBottomSheetType {
  addedToModerator,
  currentlyModerating,
  hostModerating,
}

class IsmLiveModeratorBottomSheet extends StatelessWidget {
  const IsmLiveModeratorBottomSheet({
    super.key,
    required this.type,
    this.moderatorName,
    this.initiatorName,
    this.streamId,
    this.onManageModerators,
  });

  final IsmLiveModeratorBottomSheetType type;
  final String? moderatorName;
  final String? initiatorName;
  final String? streamId;
  final VoidCallback? onManageModerators;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IsmLiveStreamController>();

    return Padding(
      padding: EdgeInsets.only(
        left: IsmLiveDimens.twelve,
        right: IsmLiveDimens.twelve,
        top: IsmLiveDimens.sixteen,
        bottom: IsmLiveDimens.sixteen,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IsmLiveDimens.boxHeight10,
              if (type == IsmLiveModeratorBottomSheetType.addedToModerator) ...[
                Text(
                  IsmLiveStrings.addedToModeratorGroupTitle,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IsmLiveDimens.boxHeight16,
                Text(
                  IsmLiveStrings.addedToModeratorGroupDescription
                      .replaceAll('@moderatorName', moderatorName ?? 'User')
                      .replaceAll('@initiatorName', initiatorName ?? 'Host'),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ] else ...[
                Text(
                  IsmLiveStrings.currentlyModeratingTitle,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IsmLiveDimens.boxHeight16,
                Text(
                  IsmLiveStrings.currentlyModeratingDescription,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
              IsmLiveDimens.boxHeight32,
              Row(
                children: [
                  Expanded(
                    child: IsmLiveButton(
                      label:
                          type == IsmLiveModeratorBottomSheetType.hostModerating
                              ? IsmLiveStrings.manageModerators
                              : IsmLiveStrings.stopModerating,
                      onTap: () async {
                        IsmLiveRoute.pop();
                        if (type ==
                            IsmLiveModeratorBottomSheetType.hostModerating) {
                          // Host wants to manage moderators - call the callback
                          onManageModerators?.call();
                        } else if (streamId != null) {
                          if (type ==
                              IsmLiveModeratorBottomSheetType
                                  .addedToModerator) {
                            // User is rejecting moderator role, remove from list and call API
                            final userId = controller.user?.userId;
                            if (userId != null) {
                              controller.moderatorsList
                                  .removeWhere((e) => e.userId == userId);
                            }
                            await controller.leaveModerator(streamId!);
                          } else {
                            // User is currently moderating and wants to stop
                            await controller.leaveModerator(streamId!);
                          }
                          // Update UI
                          controller.update([IsmLiveStreamView.updateId]);
                        }
                      },
                    ),
                  ),
                  IsmLiveDimens.boxWidth8,
                  Expanded(
                    child: IsmLiveButton.secondary(
                      label: IsmLiveStrings.gotIt,
                      onTap: () {
                        IsmLiveRoute.pop();
                        if (type ==
                            IsmLiveModeratorBottomSheetType.addedToModerator) {
                          // Update userRole to moderator without disconnect/rejoin
                          controller.userRole?.makeModerator();
                          // Update UI
                          controller.update([IsmLiveStreamView.updateId]);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: CustomIconButton(
              icon: IsmLiveImage.svg(
                IsmLiveAssetConstants.cancel,
              ),
              color: Colors.transparent,
              onTap: IsmLiveRoute.pop,
            ),
          ),
        ],
      ),
    );
  }
}
