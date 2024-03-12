import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The `EmojiBoard` widget is a Flutter component that provides a visual representation
/// of an emoji board, allowing users to select and insert emojis into their desired context.
///
/// It offers a grid-based layout with scrollable functionality, ensuring an intuitive and engaging user experience.
class IsmLiveEmojis extends StatelessWidget {
  const IsmLiveEmojis({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        builder: (controller) => SizedBox(
          height: IsmLiveDimens.twoHundredFifty,
          width: Get.width,
          child: EmojiPicker(
            textEditingController: controller.messageFieldController,
            config: const Config(
              bottomActionBarConfig: BottomActionBarConfig(
                showBackspaceButton: true,
                enabled: true,
                // customBottomActionBar: (config, state, showSearchView) {
                // },
                buttonIconColor: Colors.black,
                buttonColor: Colors.white,
                backgroundColor: Colors.white,
              ),
              categoryViewConfig: CategoryViewConfig(
                indicatorColor: Colors.white,
                iconColorSelected: Colors.white,
                backspaceColor: Colors.white,
              ),
              skinToneConfig: SkinToneConfig(
                dialogBackgroundColor: Colors.white,
                indicatorColor: Colors.black,
              ),
              emojiViewConfig: EmojiViewConfig(
                emojiSizeMax: 24,
                columns: 8,
                backgroundColor: Colors.white,
              ),
            ),
            onBackspacePressed: () {
              controller.messageFieldController.text = controller
                  .messageFieldController.text
                  .substring(0, controller.messageFieldController.text.length);
            },
          ),
        ),
      );
}
