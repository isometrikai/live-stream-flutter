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
  static const String icMembersLiveStream = '$_icons/ic_members_stream.svg';
  static const String icRotateCamera = '$_icons/ic_rotate_camera.svg';
  static const String icFavouriteStream = '$_icons/ic_favourite_stream.svg';
  static const String icSettingStream = '$_icons/ic_setting_stream.svg';
  static const String icGiftStream = '$_icons/ic_gift_stream.svg';
  static const String icShareLiveStream = '$_icons/ic_share_live_stream.svg';
  static const String icMuteLiveStream = '$_icons/ic_mute_live_stream.svg';
  static const String icMultiLiveStream = '$_icons/ic_multi_live_stream.svg';
  static const String box = '$_icons/vuesax-bold-box.svg';
  static const String clock = '$_icons/vuesax-bold-clock.svg';
  static const String dollar = '$_icons/vuesax-bold-dollar-circle.svg';
  static const String eye = '$_icons/vuesax-bold-eye.svg';
  static const String heart = '$_icons/vuesax-bold-heart.svg';
  static const String profileUser = '$_icons/vuesax-bold-profile-2user.svg';
}
