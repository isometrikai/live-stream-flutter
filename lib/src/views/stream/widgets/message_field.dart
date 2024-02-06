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

  static const String updateId = 'message-field-id';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        builder: (controller) => Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                children: [
                  if (controller.parentMessage != null) ...[
                    Container(
                      padding: IsmLiveDimens.edgeInsets4,
                      margin: IsmLiveDimens.edgeInsets8_0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(IsmLiveDimens.twelve),
                        color: Colors.white70,
                      ),
                      child: Row(
                        children: [
                          IsmLiveImage.network(
                            controller.parentMessage!.imageUrl,
                            dimensions: IsmLiveDimens.twentyFour,
                            isProfileImage: true,
                          ),
                          IsmLiveDimens.boxWidth4,
                          Expanded(
                            child: Text(
                              'Replying to @${controller.parentMessage!.userName}: ${controller.parentMessage!.body}',
                              style: context.textTheme.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IsmLiveDimens.boxWidth4,
                          CustomIconButton(
                            color: Colors.transparent,
                            onTap: () {
                              controller.parentMessage = null;
                              controller.update([updateId]);
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              size: IsmLiveDimens.twenty,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IsmLiveDimens.boxHeight2,
                  ],
                  IsmLiveInputField(
                    controller: controller.messageFieldController,
                    hintText: 'Say Something…',
                    contentPadding: IsmLiveDimens.edgeInsets0,
                    fillColor: Colors.white70,
                    borderColor: Colors.white70,
                    onchange: (value) => controller.update([IsmLiveStreamView.updateId]),
                    textInputAction: TextInputAction.send,
                    onFieldSubmit: (value) => controller.sendTextMessage(
                      streamId: streamId,
                      body: value,
                      parentMessage: controller.parentMessage,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: controller.messageFieldController.isNotEmpty
                          ? () => controller.sendTextMessage(
                                streamId: streamId,
                                body: controller.messageFieldController.text,
                                parentMessage: controller.parentMessage,
                              )
                          : null,
                    ),
                    prefixIcon: const Icon(
                      Icons.sentiment_satisfied_alt,
                    ),
                  ),
                ],
              ),
            ),
            if (!isHost) ...[
              IsmLiveDimens.boxWidth8,
              IsmLiveHeartButton(
                size: IsmLiveDimens.fortyFive,
                onTap: () => controller.sendHeartMessage(streamId),
              ),
            ]
          ],
        ),
      );
}

class IsmLiveHeartButton extends StatelessWidget {
  const IsmLiveHeartButton({
    super.key,
    this.onTap,
    this.size,
  });

  final VoidCallback? onTap;
  final double? size;

  @override
  Widget build(BuildContext context) => CustomIconButton(
        dimension: size,
        icon: const UnconstrainedBox(
          child: IsmLiveImage.svg(
            IsmLiveAssetConstants.heartSvg,
            color: IsmLiveColors.white,
          ),
        ),
        onTap: onTap,
        color: IsmLiveColors.red,
      );
}
