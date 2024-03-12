import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveChatView extends StatelessWidget {
  const IsmLiveChatView({
    super.key,
    required this.isHost,
    required this.streamId,
  });

  final bool isHost;
  final String streamId;

  @override
  Widget build(BuildContext context) => GetX<IsmLiveStreamController>(
        builder: (controller) => Container(
          padding: IsmLiveDimens.edgeInsets4_0,
          constraints: BoxConstraints(
            maxHeight: controller.participantTracks.length < 3
                ? Get.height * 0.4
                : Get.height * 0.25,
            maxWidth: isHost ? Get.width * 0.5 : Get.width * 0.75,
          ),
          child: ListView.separated(
            controller: controller.messagesListController,
            padding: IsmLiveDimens.edgeInsets0_8,
            shrinkWrap: true,
            itemCount: controller.streamMessagesList.length,
            separatorBuilder: (_, __) => IsmLiveDimens.boxHeight10,
            itemBuilder: (_, index) {
              final message = controller.streamMessagesList[index];
              return UnconstrainedBox(
                alignment: Alignment.centerLeft,
                child: IsmLiveTapHandler(
                  onTap: () {
                    if (!message.isEvent) {
                      IsmLiveUtility.openBottomSheet(
                        ChatBottomSheet(
                          message: message,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: IsmLiveDimens.edgeInsets5,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(IsmLiveDimens.ten),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IsmLiveImage.network(
                          height: IsmLiveDimens.twentyFour,
                          message.imageUrl,
                          name: message.userName,
                          dimensions: IsmLiveDimens.thirtyTwo,
                          isProfileImage: true,
                        ),
                        IsmLiveDimens.boxWidth4,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${message.userName}${message.sentByMe ? " (You)" : ""}',
                                  style: context.textTheme.labelSmall!.copyWith(
                                    color: IsmLiveColors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (message.sentByHost) ...[
                                  IsmLiveDimens.boxWidth8,
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: (context.liveTheme.primaryColor ??
                                              IsmLiveColors.primary)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(
                                          IsmLiveDimens.four),
                                    ),
                                    child: Padding(
                                      padding: IsmLiveDimens.edgeInsets6_2,
                                      child: Text(
                                        'Host',
                                        style: context.textTheme.labelSmall
                                            ?.copyWith(
                                          color: IsmLiveColors.white
                                              .withOpacity(0.7),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (message.isDeleted)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isHost
                                      ? Get.width * 0.35
                                      : Get.width * 0.6,
                                ),
                                child: Text(
                                  ' ${message.body} Deleted Message',
                                  style:
                                      context.textTheme.labelMedium?.copyWith(
                                    color:
                                        context.liveTheme.unselectedTextColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else ...[
                              if (message.isReply &&
                                  message.parentBody != null) ...[
                                Text(
                                  'Reply to ${message.parentBody}',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isHost
                                      ? Get.width * 0.35
                                      : Get.width * 0.6,
                                ),
                                child: Text(
                                  message.body,
                                  style:
                                      context.textTheme.labelMedium?.copyWith(
                                    color: IsmLiveColors.white,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
}

class _TextButton extends StatelessWidget {
  const _TextButton({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => IsmLiveTapHandler(
        onTap: onTap,
        child: Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
