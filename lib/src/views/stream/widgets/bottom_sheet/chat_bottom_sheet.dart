import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/widgets/custom_button.dart';
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
              child: CustomButton(
                title: 'Reply',
                onPress: () {
                  controller.parentMessage = message;

                  controller.update([IsmLiveMessageField.updateId]);
                  Get.back();
                },
              ),
            ),
            if ((controller.isModerator ||
                    controller.isHost ||
                    controller.isMember) &&
                message.isReply == false) ...[
              IsmLiveDimens.boxWidth8,
              SizedBox(
                width: Get.width * 0.4,
                child: CustomButton(
                  title: 'Delete',
                  onPress: () {
                    controller.deleteMessage(
                      streamId: controller.streamId ?? '',
                      messageId: message.messageId,
                    );
                    Get.back();
                  },
                ),
              ),
            ],
          ],
        ),
      );
}
