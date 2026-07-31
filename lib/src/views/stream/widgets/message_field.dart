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
    this.disabled = false,
  });

  final String streamId;
  final bool isHost;
  final Color? customFillColor;
  final Color? customBorderColor;
  final double? customRadius;
  final TextStyle? customStyle;
  final TextStyle? customHintStyle;
  final EdgeInsets? customContentPadding;
  final bool disabled;

  static const String updateId = 'message-field-id';

  bool get _sendIconInsideInputField =>
      IsmLiveDelegate.streamScreenConfigure
          .resolveMessageSendIconInsideInputField();

  VoidCallback? _onSendTap(
    IsmLiveStreamController controller, {
    required bool disabled,
  }) {
    if (disabled || controller.messageFieldController.text.trim().isEmpty) {
      return null;
    }
    return () => controller.sendTextMessage(
          streamId: streamId,
          body: controller.messageFieldController.text.trim(),
          parentMessage: controller.parentMessage,
        );
  }

  Widget _buildSendButton(
    BuildContext context,
    IsmLiveStreamController controller, {
    required bool disabled,
    required bool isInsideInputField,
  }) {
    final messageText = controller.messageFieldController.text;
    final onSend = _onSendTap(controller, disabled: disabled);
    final customBuilder =
        IsmLiveDelegate.streamScreenConfigure.messageSendButtonBuilder;

    if (customBuilder != null) {
      return customBuilder(
        context,
        streamId,
        isHost,
        disabled,
        messageText,
        onSend,
        isInsideInputField,
      );
    }

    if (isInsideInputField) {
      return InkWell(
        onTap: onSend,
        child: const Icon(
          Icons.send,
          color: Colors.white,
        ),
      );
    }

    return CustomIconButton(
      dimension: IsmLiveDimens.forty,
      icon: const Icon(
        Icons.send,
        color: Colors.white,
      ),
      onTap: onSend,
      gradient: IsmLiveDelegate.sideIconsConfigure.controlOptionBgGradient,
    );
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        builder: (controller) {
          // Unfocus when disabled
          if (disabled && controller.messageFocusNode.hasFocus) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.messageFocusNode.unfocus();
            });
          }

          return Opacity(
            opacity: disabled ? 0.6 : 1.0,
            child: AbsorbPointer(
              absorbing: disabled,
              child: Column(
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
                        borderRadius:
                            BorderRadius.circular(IsmLiveDimens.twelve),
                        color: Colors.white70,
                      ),
                      child: Row(
                        children: [
                          IsmLiveImage.network(
                            IsmLiveDelegate.getUserProfileUrl?.call(
                                    controller.parentMessage!.imageUrl) ??
                                controller.parentMessage!.imageUrl,
                            name: controller.parentMessage!.userName,
                            dimensions: IsmLiveDimens.twentyFour,
                            isProfileImage: true,
                            initials: controller.parentMessage?.profileInitials,
                          ),
                          IsmLiveDimens.boxWidth4,
                          Expanded(
                            child: Text(
                              IsmLiveStrings.replyingToFormat(
                                controller.parentMessage!.userName,
                                controller.parentMessage!.body,
                              ),
                              style: context.textTheme.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IsmLiveDimens.boxWidth4,
                          InkWell(
                            onTap: disabled
                                ? null
                                : () {
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
                          onTap: disabled
                              ? null
                              : () {
                                  controller.showEmojiBoard = false;
                                  controller.messageFocusNode.requestFocus();
                                  controller
                                      .update([IsmLiveStreamView.updateId]);
                                },
                          focusNode: controller.messageFocusNode,
                          cursorColor: Colors.white,
                          style: customStyle ??
                              context.textTheme.bodySmall
                                  ?.copyWith(color: Colors.white),
                          controller: controller.messageFieldController,
                          textInputType: TextInputType.text,
                          maxLines: 1,
                          hintText: IsmLiveStrings.saySomething,
                          contentPadding: customContentPadding ??
                              const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 12.0),
                          fillColor: customFillColor ??
                              IsmLiveColors.white.withValues(alpha: 0.3),
                          hintStyle: customHintStyle ??
                              context.textTheme.bodySmall
                                  ?.copyWith(color: Colors.white),
                          borderColor: customBorderColor ?? Colors.transparent,
                          radius: customRadius,
                          readOnly: disabled,
                          onchange: disabled
                              ? null
                              : (value) => controller
                                  .update([IsmLiveStreamView.updateId]),
                          textInputAction: TextInputAction.send,
                          onFieldSubmit: (value) {
                            if (disabled) {
                              return;
                            }
                            final body = value.trim();
                            if (body.isEmpty) {
                              return;
                            }
                            controller.sendTextMessage(
                              streamId: streamId,
                              body: body,
                              parentMessage: controller.parentMessage,
                            );
                          },
                          suffixIcon: _sendIconInsideInputField &&
                                  controller.messageFieldController.text
                                      .trim()
                                      .isNotEmpty &&
                                  !disabled
                              ? _buildSendButton(
                                  context,
                                  controller,
                                  disabled: disabled,
                                  isInsideInputField: true,
                                )
                              : null,
                        ),
                      ),
                      if (!_sendIconInsideInputField && !disabled) ...[
                        IsmLiveDimens.boxWidth15,
                        _buildSendButton(
                          context,
                          controller,
                          disabled: disabled,
                          isInsideInputField: false,
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
        gradient: IsmLiveDelegate.sideIconsConfigure.controlOptionBgGradient,
      );
}
