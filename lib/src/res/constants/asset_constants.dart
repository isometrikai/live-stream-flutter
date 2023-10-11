// coverage:ignore-file
/// An asset constant class which will hold all the
/// assets path which are used in the application.
///
/// Will be ignored for test since all are static values and would not change.
class IsmLiveAssetConstants {
  const IsmLiveAssetConstants._();

  static const String $path = 'assets';

  static $Images get images => const $Images._();

  static $Logos get logos => const $Logos._();

  static $Icons get icons => const $Icons._();
}

class $Images {
  const $Images._();

  static const String _path = '${IsmLiveAssetConstants.$path}/images';

  String get noImage => '$_path/noperson.png';
}

class $Logos {
  const $Logos._();

  static const String _path = '${IsmLiveAssetConstants.$path}/logo';

  String get isometrik => '$_path/isometric.png';
}

class $Icons {
  const $Icons._();

  static const String _path = '${IsmLiveAssetConstants.$path}/icons';
}
