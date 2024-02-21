import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatBottomSheet extends StatelessWidget {
  ChatBottomSheet({super.key, required this.message});
  final IsmLiveChatModel message;

  final controller = Get.find<IsmLiveStreamController>();

  @override
  Widget build(BuildContext context) => Container(
        margin: IsmLiveDimens.edgeInsets16,
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: Get.width * 0.4,
              child: IsmLiveButton(
                label: 'Reply',
                onTap: () {
                  controller.parentMessage = message;
                  controller.update([IsmLiveMessageField.updateId]);
                },
              ),
            ),
            if (controller.isModerator) ...[
              IsmLiveDimens.boxWidth8,
              SizedBox(
                width: Get.width * 0.4,
                child: IsmLiveButton(
                  label: 'Delete',
                  onTap: () => controller.deleteMessage(
                    streamId: controller.streamId ?? '',
                    messageId: message.messageId,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}
