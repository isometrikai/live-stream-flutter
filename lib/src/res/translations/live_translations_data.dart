import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLiveTranslationsData with Diagnosticable {
  const IsmLiveTranslationsData({
    this.streamTranslations,
    this.uploadingImage,
  });

  final IsmLiveStreamTranslations? streamTranslations;
  final String? uploadingImage;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IsmLiveStreamTranslations>('streamTranslations', streamTranslations));
    properties.add(StringProperty('uploadingImage', uploadingImage));
  }

  IsmLiveTranslationsData copyWith({
    IsmLiveStreamTranslations? streamTranslations,
    String? uploadingImage,
  }) =>
      IsmLiveTranslationsData(
        streamTranslations: streamTranslations ?? this.streamTranslations,
        uploadingImage: uploadingImage ?? this.uploadingImage,
      );
}
