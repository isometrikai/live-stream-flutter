import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveMessageField extends StatelessWidget {
  const IsmLiveMessageField({
    super.key,
    required this.streamId,
    required this.isHost,
    this.customFillColor,
    this.customBorderColor,
    this.customRadius,
    this.customStyle,
    this.customHintStyle,
    this.customContentPadding,
  });

  final String streamId;
  final bool isHost;
  final Color? customFillColor;
  final Color? customBorderColor;
  final double? customRadius;
  final TextStyle? customStyle;
  final TextStyle? customHintStyle;
  final EdgeInsets? customContentPadding;

  static const String updateId = 'message-field-id';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        builder: (controller) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.parentMessage != null) ...[
              Container(
                padding: IsmLiveDimens.edgeInsets4,
                margin: EdgeInsets.only(
                    left: IsmLiveDimens.eight,
                    right: IsmLiveDimens.eight,
                    top: IsmLiveDimens.eight),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(IsmLiveDimens.twelve),
                  color: Colors.white70,
                ),
                child: Row(
                  children: [
                    IsmLiveImage.network(
                      controller.parentMessage!.imageUrl,
                      name: controller.parentMessage!.userName,
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
                    InkWell(
                      onTap: () {
                        controller.parentMessage = null;
                        controller.update([updateId]);
                      },
                      child: IsmLiveImage.svg(
                        IsmLiveAssetConstants.close_rounded_fill,
                        height: IsmLiveDimens.twenty,
                        width: IsmLiveDimens.twenty,
                      ),
                    ),
                  ],
                ),
              ),
              IsmLiveDimens.boxHeight2,
            ],
            Row(
              children: [
                Expanded(
                  child: IsmLiveInputField(
                    onTap: () {
                      // Ensure emoji board is hidden and explicitly request focus
                      controller.showEmojiBoard = false;
                      FocusScope.of(context)
                          .requestFocus(controller.messageFocusNode);
                      controller.update([IsmLiveStreamView.updateId]);
                    },
                    focusNode: controller.messageFocusNode,
                    cursorColor: Colors.white,
                    style: customStyle ??
                        context.textTheme.bodySmall
                            ?.copyWith(color: Colors.white),
                    controller: controller.messageFieldController,
                    hintText: 'Say Something…',
                    contentPadding: customContentPadding ??
                        const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 12.0),
                    fillColor:
                        customFillColor ?? IsmLiveColors.white.withOpacity(0.3),
                    hintStyle: customHintStyle ??
                        context.textTheme.bodySmall
                            ?.copyWith(color: Colors.white),
                    borderColor: customBorderColor ?? Colors.transparent,
                    radius: customRadius,
                    onchange: (value) =>
                        controller.update([IsmLiveStreamView.updateId]),
                    textInputAction: TextInputAction.send,
                    onFieldSubmit: (value) {
                      controller.sendTextMessage(
                        streamId: streamId,
                        body: value.trim(),
                        parentMessage: controller.parentMessage,
                      );
                    },
                    suffixIcon: IsmLiveDelegate.productStream == true &&
                            controller.messageFieldController.text
                                .trim()
                                .isNotEmpty
                        ? Container(
                            child: InkWell(
                              onTap: controller
                                      .messageFieldController.isNotEmpty
                                  ? () => controller.sendTextMessage(
                                        streamId: streamId,
                                        body: controller
                                            .messageFieldController.text
                                            .trim(),
                                        parentMessage: controller.parentMessage,
                                      )
                                  : null,
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                    prefixIcon: Container(
                      child: InkWell(
                          onTap: () {
                            controller.toggleEmojiBoard(context);
                          },
                          child: const Icon(
                            Icons.mood,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
                if (IsmLiveDelegate.productStream != true) ...[
                  IsmLiveDimens.boxWidth15,
                  CustomIconButton(
                    dimension: IsmLiveDimens.forty,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onTap: controller.messageFieldController.isNotEmpty
                        ? () => controller.sendTextMessage(
                              streamId: streamId,
                              body:
                                  controller.messageFieldController.text.trim(),
                              parentMessage: controller.parentMessage,
                            )
                        : null,
                    gradient: IsmLiveDelegate.streamOptionsBgGradient,
                  )
                ]
              ],
            ),
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
        gradient: IsmLiveDelegate.streamOptionsBgGradient,
      );
}
