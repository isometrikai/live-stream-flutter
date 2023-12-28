import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PickImageSheet extends StatelessWidget {
  const PickImageSheet({
    super.key,
    this.beforePicking,
    this.enableDoc = false,
    this.enableVideo = false,
    this.afterPicking,
  });

  final VoidCallback? beforePicking;
  final bool enableVideo;
  final bool enableDoc;
  final void Function(XFile?)? afterPicking;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        builder: (controller) {
          var attachments = FileManager.attachmentBottomList(
            enableVideo: enableVideo,
            enableDoc: enableDoc,
          );
          return GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            children: List.generate(
              attachments.length,
              (index) => GestureDetector(
                onTap: () async {
                  Get.back();
                  beforePicking?.call();
                  XFile? file;
                  if (index == 0) {
                    file = await FileManager.pickImage(ImageSource.camera);
                  } else if (index == 1) {
                    file = await FileManager.pickImage(ImageSource.gallery);
                  } else if (index == 2) {
                    if (enableVideo) {
                      file = await FileManager.pickVideo();
                    } else {
                      file = await FileManager.pickDocument();
                    }
                  } else if (index == 3) {
                    file = await FileManager.pickDocument();
                  }
                  afterPicking?.call(file);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IsmLiveImage.svg(
                      attachments[index].iconPath,
                      dimensions: IsmLiveDimens.fifty,
                    ),
                    IsmLiveDimens.boxHeight10,
                    Text(
                      attachments[index].label.tr,
                      style: context.textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}
