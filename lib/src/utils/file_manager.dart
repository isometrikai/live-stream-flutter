import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/attachment_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class FileManager {
  const FileManager._();

  static ImagePicker get _picker {
    $picker ??= ImagePicker();
    return $picker!;
  }

  static ImagePicker? $picker;

  static Future<XFile?> pickCameraImage({
    bool shouldCrop = true,
  }) =>
      _pickImage(
        ImageSource.camera,
        shouldCrop: shouldCrop,
      );

  static Future<XFile?> pickGalleryImage({
    bool shouldCrop = true,
  }) =>
      _pickImage(
        ImageSource.gallery,
        shouldCrop: shouldCrop,
      );

  static Future<XFile?> _pickImage(
    ImageSource imageSource, {
    bool shouldCrop = true,
  }) async {
    try {
      XFile? result;
      if (imageSource == ImageSource.camera) {
        result = await IsmLiveRouteManagement.goToCamera(true, true);
      } else {
        result = await _picker.pickImage(source: imageSource);
      }
      if (result == null) {
        return null;
      }
      if (shouldCrop) {
        return await cropImage(result.path);
      } else {
        return result;
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  static Future<XFile?> pickVideo() async {
    var file = await _picker.pickVideo(source: ImageSource.gallery);

    if (file == null) {
      return null;
    }

    try {
      return XFile(file.path);
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  static Future<XFile?> pickDocument([bool pdfOnly = true]) async {
    var file = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: pdfOnly ? ['pdf'] : null,
      type: pdfOnly ? FileType.custom : FileType.any,
      withData: true,
    );
    if (file == null || file.files.isEmpty) {
      return null;
    }
    try {
      var platformFile = file.files.first;
      return XFile(platformFile.path!);
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  static Future<XFile?> cropImage(String sourcePath) async {
    var croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: IsmLiveColors.black,
          toolbarWidgetColor: IsmLiveColors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        )
      ],
    );

    if (croppedFile == null) {
      return null;
    } else {
      return XFile(croppedFile.path);
    }
  }

  static List<AttachmentModel> attachmentBottomList({
    bool enableDoc = false,
    bool enableVideo = false,
  }) =>
      <AttachmentModel>[
        const AttachmentModel(
          label: 'Camera',
          iconPath: IsmLiveAssetConstants.camera,
          onTap: FileManager.pickCameraImage,
        ),
        const AttachmentModel(
          label: 'Gallery',
          iconPath: IsmLiveAssetConstants.photoVideo,
          onTap: FileManager.pickGalleryImage,
        ),
        if (enableVideo)
          const AttachmentModel(
            label: 'Video',
            iconPath: IsmLiveAssetConstants.videoIcon,
            onTap: FileManager.pickVideo,
          ),
        if (enableDoc)
          const AttachmentModel(
            label: 'Doc',
            iconPath: IsmLiveAssetConstants.document,
            onTap: FileManager.pickDocument,
          ),
      ];
}
