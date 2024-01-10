import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveChat extends StatelessWidget {
  const IsmLiveChat(
      {super.key, required this.messagesList, this.messageListController});
  final List<IsmLiveMessageModel> messagesList;
  final ScrollController? messageListController;

  @override
  Widget build(BuildContext context) => Obx(
        () => SizedBox(
          height: Get.height * 0.4,
          width: Get.width * 0.75,
          child: ListView.builder(
            controller: messageListController,
            padding: IsmLiveDimens.edgeInsets0_8,
            shrinkWrap: true,
            itemBuilder: (_, index) => UnconstrainedBox(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: IsmLiveDimens.edgeInsets8_4,
                margin: IsmLiveDimens.edgeInsets0_4,
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
            ),
            itemCount: messagesList.length,
          ),
        ),
      );
}
