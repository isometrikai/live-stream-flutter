import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatBottomSheet extends StatelessWidget {
  ChatBottomSheet({super.key, required this.message});
  final IsmLiveChatModel message;

  final controller = Get.find<IsmLiveStreamController>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final textColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);

    // Host or moderator: reply/delete on any message. Others: own messages only.
    // Keep in sync with tap gate in [IsmLiveChatView] (chat.dart).
    final isHostOrModerator =
        controller.isHost || controller.isModerator;
    final canActOnMessage = isHostOrModerator || message.sentByMe;

    return Padding(
      padding: IsmLiveDimens.edgeInsets16_0_16_20.copyWith(bottom: 0),
      child: IsmLiveScrollSheet(
        separatedWidgat: IsmLiveDimens.boxHeight24,
        title: IsmLiveStrings.messageOptions,
        showHeader: false,
        showCancelIcon: true,
        itemCount: !message.isReply && canActOnMessage ? 2 : 1,
        itemBuilder: (context, index) {
          if (index == 0 && message.isReply == false) {
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
                    color: iconColor,
                  ),
                  IsmLiveDimens.boxWidth10,
                  Text(
                    IsmLiveStrings.reply,
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            );
          } else {
            // Delete row (second slot when itemCount is 2; sole row for replies)
            return IsmLiveTapHandler(
              onTap: () {
                controller.deleteMessage(
                  streamId: controller.streamId ?? '',
                  messageId: message.messageId,
                  isReply: message.isReply,
                  parentMessageId: message.parentId,
                );
                IsmLiveRoute.pop();
              },
              child: Row(
                children: [
                  IsmLiveImage.svg(
                    IsmLiveAssetConstants.delete,
                    color: iconColor,
                    height: IsmLiveDimens.twentyTwo,
                    width: IsmLiveDimens.twentyTwo,
                  ),
                  IsmLiveDimens.boxWidth10,
                  Text(
                    IsmLiveStrings.delete,
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
