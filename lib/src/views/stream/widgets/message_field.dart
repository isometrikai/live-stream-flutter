import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveMessageField extends StatelessWidget {
  const IsmLiveMessageField({
    super.key,
    required this.streamId,
    required this.isHost,
  });

  final String streamId;
  final bool isHost;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        builder: (controller) => Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: IsmLiveInputField(
                controller: controller.messageFieldController,
                hintText: 'Say Something…',
                radius: IsmLiveDimens.fifty,
                onchange: (value) => controller.update([IsmLiveStreamView.updateId]),
                textInputAction: TextInputAction.send,
                onFieldSubmit: (value) => controller.sendTextMessage(
                  streamId: streamId,
                  body: value,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: controller.messageFieldController.isNotEmpty
                      ? () => controller.sendTextMessage(
                            streamId: streamId,
                            body: controller.messageFieldController.text,
                          )
                      : null,
                ),
                prefixIcon: const Icon(
                  Icons.sentiment_satisfied_alt,
                ),
                borderColor: IsmLiveColors.white,
              ),
            ),
            if (!isHost) ...[
              IsmLiveDimens.boxWidth16,
              CustomIconButton(
                dimension: IsmLiveDimens.fifty,
                icon: UnconstrainedBox(
                  child: IsmLiveImage.svg(
                    IsmLiveAssetConstants.heart,
                    color: IsmLiveColors.white,
                    dimensions: IsmLiveDimens.twentyFour,
                  ),
                ),
                onTap: () => controller.sendHeartMessage(streamId),
                color: IsmLiveColors.red,
              ),
            ]
          ],
        ),
      );
}
