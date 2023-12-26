import 'dart:io';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManager {
  const FileManager._();

  static ImagePicker get _picker {
    $picker ??= ImagePicker();
    return $picker!;
  }

  static ImagePicker? $picker;

  static Future<bool> _hasPermission(Permission permission) async {
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
      IsmLiveLog.error('Permission Error $e\n$st');
      return false;
    }
  }

  static Future<void> _checkPermission([bool isVideo = false]) async {
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

  static Future<XFile?> pickImage(ImageSource imageSource) async {
    await _checkPermission();

    try {
      if (imageSource == ImageSource.camera) {
        final cameraMedia = await IsLiveRouteManagement.goToCamera(true, true);
        return cameraMedia;
      } else {
        return await _picker.pickImage(source: imageSource);
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  static Future<XFile?> pickVideo() async {
    await _checkPermission();

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
    await _checkPermission();
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
}
