import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PicKImageSheet extends StatelessWidget {
  const PicKImageSheet({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        builder: (controller) {
          FileManager.checkPermission();
          var attachments = FileManager.attachmentBottomList(
              enableDoc: false, enableVideo: false);
          return Padding(
            padding: IsmLiveDimens.edgeInsets16,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: List.generate(
                attachments.length,
                (index) => GestureDetector(
                  onTap: () async {
                    Get.back();
                    if (index == 0) {
                      await FileManager.checkPermission();

                      controller.uploadImage(ImageSource.camera);
                    } else if (index == 1) {
                      await FileManager.checkPermission();
                      controller.uploadImage(ImageSource.gallery);
                    } else if (index == 2) {
                      await FileManager.checkPermission(true);
                      var file = await ImagePicker()
                          .pickVideo(source: ImageSource.gallery);

                      if (file == null) {
                        return;
                      }
                    } else if (index == 3) {
                      await FileManager.checkPermission();
                      var file = await FileManager.pickDocument(false);

                      if (file != null) {}
                    }
                  },
                  child: Text(attachments[index].label.tr),
                  //
                  // Column(
                  //   mainAxisSize: MainAxisSize.min,
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     // SvgWidget(attachments[index].iconPath),
                  //     // IsmLiveDimens.boxHeight10,
                  //     Text(attachments[index].label.tr),
                  //   ],
                  // ),
                ),
              ),
            ),
          );
        },
      );
}

// class SvgWidget extends StatelessWidget {
//   const SvgWidget(
//     this.asset, {
//     super.key,
//     this.color,
//     this.dimensions,
//     this.fit = BoxFit.contain,
//     this.package,
//     this.height,
//     this.width,
//   });

//   final String asset;
//   final Color? color;
//   final double? dimensions;
//   final BoxFit fit;
//   final String? package;
//   final double? height;
//   final double? width;

//   @override
//   Widget build(BuildContext context) => SvgPicture.asset(
//         AssetConstants.backRounded,
//         colorFilter: color != null
//             ? ColorFilter.mode(
//                 color!,
//                 BlendMode.srcIn,
//               )
//             : null,
//         fit: fit,
//         height: height ?? dimensions,
//         width: width ?? dimensions,
//         package: package,
//       );
// }
