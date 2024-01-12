import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveChat extends StatelessWidget {
  const IsmLiveChat({
    super.key,
    required this.messagesList,
    this.messageListController,
    required this.isHost,
    required this.onTapRemove,
  });
  final List<IsmLiveMessageModel> messagesList;
  final ScrollController? messageListController;
  final bool isHost;
  final void Function(String messageId) onTapRemove;

  @override
  Widget build(BuildContext context) => Obx(
        () => Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.4,
            maxWidth: Get.width * 0.75,
          ),
          child: ListView.builder(
            controller: messageListController,
            padding: IsmLiveDimens.edgeInsets0_8,
            shrinkWrap: true,
            itemBuilder: (_, index) => UnconstrainedBox(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: IsmLiveDimens.edgeInsets8_4,
                    margin: IsmLiveDimens.edgeInsets0_4,
                    constraints: BoxConstraints(
                      maxWidth: Get.width * 0.6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(IsmLiveDimens.twenty),
                      color: IsmLiveColors.black.withOpacity(0.2),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${messagesList[index].senderName}: ',
                            style: context.textTheme.labelMedium!.copyWith(
                                color: IsmLiveColors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: messagesList[index].body,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isHost)
                    IconButton(
                      onPressed: () {
                        onTapRemove(
                          messagesList[index].messageId,
                        );
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    )
                ],
              ),
            ),
            itemCount: messagesList.length,
          ),
        ),
      );
}
