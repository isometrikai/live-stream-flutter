// coverage:ignore-file
/// An asset constant class which will hold all the
/// assets path which are used in the application.
///
/// Will be ignored for test since all are static values and would not change.

class IsmLiveAssetConstants {
  const IsmLiveAssetConstants._();

  static const String _path = 'assets';

  static const String _images = '$_path/images';

  static const String _logo = '$_path/logo';

  static const String _icons = '$_path/icon';

  static const String appscrip = '$_logo/appscrip.png';
  static const String isometrik = '$_logo/isometrik.png';

  static const String noImage = '$_images/noperson.png';

  static const String backRounded = '$_icons/back_rounded.svg';
  static const String galerryRoundedSvg = '$_icons/gallery_rounded.svg';
  static const String switchCameraSvg = '$_icons/switch_camera.svg';
  static const String photoVideo = '$_icons/photos_videos.svg';
  static const String document = '$_icons/document.svg';
  static const String camera = '$_icons/camera.svg';
  static const String videoIcon = '$_icons/video_icon.svg';
}
