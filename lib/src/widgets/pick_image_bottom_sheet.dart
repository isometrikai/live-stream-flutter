import 'dart:io';
import 'dart:typed_data';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/attachment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PicKImageSheet extends StatelessWidget {
  PicKImageSheet({super.key});
  Uint8List? bytes;
  Future<bool> _hasPermission(Permission permission) async {
    try {
      if (await permission.isGranted) {
        return true;
      }
      var status = await permission.request();
      if ([
        PermissionStatus.permanentlyDenied,
        PermissionStatus.restricted,
      ].contains(status)) {
        var canOpen = await openAppSettings();
        if (!canOpen) {
          return false;
        }
      }
      status = await permission.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
      return true;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<void> _checkPermission([bool isVideo = false]) async {
    if (Platform.isIOS) {
      await _hasPermission(Permission.storage);
    } else {
      // if (DeviceConfig.versionNumber <= 28) {
      if (isVideo) {
        await _hasPermission(Permission.videos);
      } else {
        await _hasPermission(Permission.photos);
      }
      // }
    }
  }

  static List<AttachmentModel> attachmentBottomList({
    bool enableDoc = false,
    bool enableVideo = false,
  }) =>
      <AttachmentModel>[
        AttachmentModel(
          label: 'Camera',
          iconPath: AssetConstants.camera,
          onTap: () => FileManager.pickImage(ImageSource.camera),
        ),
        AttachmentModel(
          label: 'Gallery',
          iconPath: AssetConstants.photoVideo,
          onTap: () => FileManager.pickImage(ImageSource.gallery),
        ),
        if (enableVideo)
          const AttachmentModel(
            label: 'Video',
            iconPath: AssetConstants.videoIcon,
            onTap: FileManager.pickVideo,
          ),
        if (enableDoc)
          const AttachmentModel(
            label: 'Doc',
            iconPath: AssetConstants.document,
            onTap: FileManager.pickDocument,
          ),
      ];
  @override
  Widget build(BuildContext context) {
    _checkPermission();
    var attachments =
        attachmentBottomList(enableDoc: false, enableVideo: false);

    return GetBuilder<IsmLiveStreamController>(
      builder: (controller) => Padding(
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
                  await _checkPermission();

                  var file = await FileManager.pickImage(ImageSource.camera);

                  if (file != null) {
                    var croppedFile = await ImageCropper().cropImage(
                      sourcePath: file.path,
                      cropStyle: CropStyle.circle,
                      compressQuality: 100,
                      uiSettings: [
                        AndroidUiSettings(
                          toolbarTitle: 'Cropper'.tr,
                          toolbarColor: Colors.black,
                          toolbarWidgetColor: Colors.white,
                          initAspectRatio: CropAspectRatioPreset.original,
                          lockAspectRatio: false,
                        ),
                        IOSUiSettings(
                          title: 'Cropper',
                        )
                      ],
                    );
                    bytes = File(croppedFile!.path).readAsBytesSync();
                    var extension = file.name.split('.').last;
                    await controller.getPresignedUrl(extension, bytes!);

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
                  }
                } else if (index == 1) {
                  await _checkPermission();
                  var file = await FileManager.pickImage(ImageSource.gallery);

                  if (file != null) {
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
                  }
                } else if (index == 2) {
                  await _checkPermission(true);
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
                  await _checkPermission();
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
      ),
    );
  }
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
