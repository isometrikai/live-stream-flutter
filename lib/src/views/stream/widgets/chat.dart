import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveChatView extends StatefulWidget {
  IsmLiveChatView({
    super.key,
    required this.isHost,
    required this.streamId,
  });

  final bool isHost;
  final String streamId;

  @override
  State<IsmLiveChatView> createState() => _IsmLiveChatViewState();
}

class _IsmLiveChatViewState extends State<IsmLiveChatView> {
  final messagesListController = ScrollController();
  final _controller = Get.find<IsmLiveStreamController>();

  @override
  void initState() {
    messagesListController.addListener(
        () async => _controller.messagePagination(messagesListController));
    super.initState();
  }

  @override
  void dispose() {
    try {
      messagesListController.removeListener(
          () => _controller.messagePagination(messagesListController));
      messagesListController.dispose();
    } catch (e) {
      IsmLiveLog('chat controller error $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GetX<IsmLiveStreamController>(
        builder: (controller) {
          IsmLiveUtility.updateLater(() => unawaited(
                messagesListController.animateTo(
                  messagesListController.position.maxScrollExtent +
                      IsmLiveDimens.fifty,
                  duration: const Duration(milliseconds: 10),
                  curve: Curves.ease,
                ),
              ));

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: controller.participantTracks.length < 2
                  ? IsmLiveDimens.percentHeight(0.4)
                  : controller.participantTracks.length < 4
                      ? IsmLiveDimens.percentHeight(0.3)
                      : IsmLiveDimens.percentHeight(0.15),
              maxWidth: //isHost ? Get.width * 0.5 :
                  Get.width * 0.75,
            ),
            child: ListView.separated(
              controller: messagesListController,
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
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(IsmLiveDimens.ten),
                      ),
                      child: Padding(
                        padding: IsmLiveDimens.edgeInsets8_4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IsmLiveImage.network(
                              message.imageUrl,
                              name: message.userName,
                              dimensions: IsmLiveDimens.twentyFour,
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
                                      style: context.textTheme.labelSmall!
                                          .copyWith(
                                        color: IsmLiveColors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (message.sentByHost) ...[
                                      IsmLiveDimens.boxWidth8,
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: (context.liveTheme
                                                      ?.primaryColor ??
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
                                      maxWidth: widget.isHost
                                          ? Get.width * 0.35
                                          : Get.width * 0.6,
                                    ),
                                    child: Text(
                                      ' ${message.body} Deleted Message',
                                      style: context.textTheme.labelMedium
                                          ?.copyWith(
                                        color: context
                                            .liveTheme?.unselectedTextColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                else ...[
                                  if (message.isReply &&
                                      message.parentBody != null) ...[
                                    Text(
                                      'Reply to ${message.parentBody}',
                                      style: context.textTheme.labelSmall
                                          ?.copyWith(
                                        color: Colors.white70,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: // isHost
                                          //  ? Get.width * 0.35
                                          //  :
                                          Get.width * 0.6,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          message.body,
                                          style: context.textTheme.labelMedium
                                              ?.copyWith(
                                            color: IsmLiveColors.white,
                                          ),
                                          softWrap: true,
                                        ),
                                        if (message.isCopublisherRequest)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: IsmLiveDimens.hundred,
                                                height:
                                                    IsmLiveDimens.thirtyTwo +
                                                        IsmLiveDimens.two,
                                                child: IsmLiveButton(
                                                  label: 'accept',
                                                  onTap: () {
                                                    controller
                                                        .acceptCopublisherRequest(
                                                      requestById:
                                                          message.userId,
                                                      streamId:
                                                          controller.streamId ??
                                                              '',
                                                    );
                                                    controller.streamMessagesList[
                                                            index] =
                                                        message.copyWith(
                                                            isCopublisherRequest:
                                                                false);
                                                  },
                                                ),
                                              ),
                                              IsmLiveDimens.boxWidth2,
                                              SizedBox(
                                                width: IsmLiveDimens.hundred,
                                                height:
                                                    IsmLiveDimens.thirtyTwo +
                                                        IsmLiveDimens.two,
                                                child: IsmLiveButton(
                                                  label: 'deny',
                                                  onTap: () {
                                                    controller
                                                        .denyCopublisherRequest(
                                                      requestById:
                                                          message.userId,
                                                      streamId:
                                                          controller.streamId ??
                                                              '',
                                                    );
                                                    controller.streamMessagesList[
                                                            index] =
                                                        message.copyWith(
                                                            isCopublisherRequest:
                                                                false);
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
}
