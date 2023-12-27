import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PicKImageSheet extends StatelessWidget {
  const PicKImageSheet({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        builder: (controller) {
          controller.checkPermission();
          var attachments = controller.attachmentBottomList(
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
                      await controller.checkPermission();

                      // var file = await FileManager.pickImage();

                      // if (file != null) {
                      controller.uploadImage(ImageSource.camera);
                      // final res = await _homeViewModel.uploadDoc(
                      //   image: file.path,
                      //   folderName: 'nurse/media',
                      //   fileName: '${userController.user.id!}_${file.name}',
                      //   fileType: 'image',
                      // );

                      // final jsonRes = jsonDecode(res!) as Map<String, dynamic>;
                      // handleSendPressed(
                      //   jsonRes['url'].toString(),
                      //   2,
                      //   isGroupChat: isGroupChat,
                      //   chatId: chatId,
                      //   imageUrl: imageUrl,
                      //   receiverId: receiverId,
                      //   userType: userType,
                      // );
                      // }
                    } else if (index == 1) {
                      await controller.checkPermission();
                      controller.uploadImage(ImageSource.gallery);

                      // if (file != null) {
                      // final res = await _homeViewModel.uploadDoc(
                      //   image: file.path,
                      //   folderName: 'nurse/media',
                      //   fileName: '${userController.user.id!}_${file.name}',
                      //   fileType: 'image',
                      // );
                      // final jsonRes = jsonDecode(res!) as Map<String, dynamic>;
                      // handleSendPressed(
                      //   jsonRes['url'].toString(),
                      //   2,
                      //   isGroupChat: isGroupChat,
                      //   chatId: chatId,
                      //   imageUrl: imageUrl,
                      //   receiverId: receiverId,
                      //   userType: userType,
                      // );
                      // }
                    } else if (index == 2) {
                      await controller.checkPermission(true);
                      var file = await ImagePicker()
                          .pickVideo(source: ImageSource.gallery);

                      if (file == null) {
                        return;
                      }

                      // final uint8list = await VideoThumbnail.thumbnailData(
                      //   video: file.path,
                      //   imageFormat: ImageFormat.JPEG,
                      //   maxWidth: 128,
                      //   quality: 25,
                      // );
                      // final imageEncoded = base64.encode(uint8list!);

                      // final res = await _homeViewModel.uploadDoc(
                      //   image: file.path,
                      //   folderName: 'nurse/media',
                      //   fileName: '${userController.user.id!}_${file.name}',
                      //   fileType: 'image',
                      // );

                      // final jsonRes = jsonDecode(res!) as Map<String, dynamic>;
                      // final size = await file.length();

                      // handleSendPressed(
                      //   '${jsonRes['url']}',
                      //   3,
                      //   fileName: file.name,
                      //   fileSize: size,
                      //   thumbnail: imageEncoded,
                      //   isGroupChat: isGroupChat,
                      //   chatId: chatId,
                      //   imageUrl: imageUrl,
                      //   receiverId: receiverId,
                      //   userType: userType,
                      // );
                    } else if (index == 3) {
                      await controller.checkPermission();
                      var file = await FileManager.pickDocument(false);

                      if (file != null) {
                        // final res = await _homeViewModel.uploadDoc(
                        //   image: file.path,
                        //   folderName: 'nurse/media',
                        //   fileName: '${userController.user.id!}_${file.name}',
                        //   fileType: 'image',
                        // );

                        // final jsonRes = jsonDecode(res!) as Map<String, dynamic>;
                        // handleSendPressed(
                        //   '${jsonRes['url']},${file.name}',
                        //   10,
                        //   fileName: file.name,
                        //   fileSize: await file.length(),
                        //   isGroupChat: isGroupChat,
                        //   chatId: chatId,
                        //   imageUrl: imageUrl,
                        //   receiverId: receiverId,
                        //   userType: userType,
                        // );
                      }
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
