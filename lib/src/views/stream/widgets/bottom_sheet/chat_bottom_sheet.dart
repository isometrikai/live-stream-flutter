import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatBottomSheet extends StatelessWidget {
  ChatBottomSheet({super.key, required this.message});
  final IsmLiveChatModel message;

  final controller = Get.find<IsmLiveStreamController>();

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16_0_16_20,
        child: IsmLiveScrollSheet(
          separatedWidgat: IsmLiveDimens.boxHeight24,
          title: 'Message Options',
          showHeader: false,
          showCancelIcon: true,
          itemCount: (controller.isModerator ||
                      controller.isHost ||
                      controller.isMember ||
                      message.sentByMe) &&
                  message.isReply == false
              ? 2
              : 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Reply item
              return IsmLiveTapHandler(
                onTap: () {
                  controller.parentMessage = message;
                  controller.update([IsmLiveMessageField.updateId]);
                  IsmLiveRoute.pop();
                },
                child: Row(
                  children: [
                    IsmLiveImage.svg(
                      IsmLiveAssetConstants.message,
                      height: IsmLiveDimens.twentyTwo,
                      width: IsmLiveDimens.twentyTwo,
                    ),
                    IsmLiveDimens.boxWidth10,
                    const Text('Reply'),
                  ],
                ),
              );
            } else {
              // Delete item
              return IsmLiveTapHandler(
                onTap: () {
                  controller.deleteMessage(
                    streamId: controller.streamId ?? '',
                    messageId: message.messageId,
                  );
                  IsmLiveRoute.pop();
                },
                child: Row(
                  children: [
                    IsmLiveImage.svg(
                      IsmLiveAssetConstants.delete,
                      color: IsmLiveColors.black,
                      height: IsmLiveDimens.twentyTwo,
                      width: IsmLiveDimens.twentyTwo,
                    ),
                    IsmLiveDimens.boxWidth10,
                    const Text('Delete'),
                  ],
                ),
              );
            }
          },
        ),
      );
}
