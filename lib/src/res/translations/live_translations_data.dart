import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLiveTranslationsData with Diagnosticable {
  const IsmLiveTranslationsData({
    this.streamTranslations,
    this.uploadingImage,
  });

  final IsmLiveStreamTranslations? streamTranslations;
  final String? uploadingImage;
}
