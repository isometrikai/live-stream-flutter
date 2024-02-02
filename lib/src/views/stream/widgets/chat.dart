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
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 0),
              ),
            ],
            // color: Colors.black26,
            borderRadius: BorderRadius.circular(IsmLiveDimens.four),
          ),
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.4,
            maxWidth: Get.width * 0.75,
          ),
          child: ListView.separated(
            controller: controller.messagesListController,
            padding: IsmLiveDimens.edgeInsets0_8,
            shrinkWrap: true,
            itemCount: controller.streamMessagesList.length,
            separatorBuilder: (_, __) => IsmLiveDimens.boxHeight10,
            itemBuilder: (_, index) {
              final message = controller.streamMessagesList[index];
              return IsmLiveTapHandler(
                onTap: () => IsmLiveUtility.openBottomSheet(
                  IsmLiveMessageBottomSheet(
                    isHost: isHost,
                    onDelete: () => controller.deleteMessage(
                      streamId: streamId,
                      messageId: message.messageId,
                    ),
                    // TODO: Reply - Implement onReply
                    onReply: null,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IsmLiveImage.network(
                      message.imageUrl,
                      name: message.userName,
                      dimensions: IsmLiveDimens.thirtyTwo,
                      isProfileImage: true,
                    ),
                    IsmLiveDimens.boxWidth8,
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
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
                              IsmLiveDimens.boxHeight2,
                              if (message.isDeleted)
                                Text(
                                  '[Message Deleted]',
                                  style:
                                      context.textTheme.labelMedium?.copyWith(
                                    color:
                                        context.liveTheme.unselectedTextColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              else
                                Text(
                                  message.body,
                                  style:
                                      context.textTheme.labelMedium?.copyWith(
                                    color: IsmLiveColors.white,
                                  ),
                                  softWrap: true,
                                ),
                            ],
                          ),
                          if (message.sentByHost) ...[
                            IsmLiveDimens.boxWidth8,
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: (context.liveTheme.primaryColor ??
                                        IsmLiveColors.primary)
                                    .withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(IsmLiveDimens.four),
                              ),
                              child: Padding(
                                padding: IsmLiveDimens.edgeInsets6_2,
                                child: Text(
                                  'Host',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.liveTheme.primaryColor ??
                                        IsmLiveColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
}
