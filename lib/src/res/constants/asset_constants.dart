// coverage:ignore-file
/// An asset constant class which will hold all the
/// assets path which are used in the application.
///
/// Will be ignored for test since all are static values and would not change.
class IsmLiveAssetConstants {
  const IsmLiveAssetConstants._();

  static const String _path = 'assets';

  static const String noImage = _Images.noImage;
  static const String isometrik = _Logos.isometrik;
}

class _Images {
  const _Images();

  static const String _path = '${IsmLiveAssetConstants._path}/images';

  static const String noImage = '$_path/noperson.png';
}

class _Logos {
  static const String _path = '${IsmLiveAssetConstants._path}/logo';

  static const String isometrik = '$_path/isometric.png';
}
