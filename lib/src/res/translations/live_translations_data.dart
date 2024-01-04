import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLiveTranslationsData with Diagnosticable {
  const IsmLiveTranslationsData({
    this.streamTranslations,
    this.uploadingImage,
    this.kickoutMessage,
    this.attention,
  });

  final IsmLiveStreamTranslations? streamTranslations;
  final String? uploadingImage;
  final String? kickoutMessage;
  final String? attention;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IsmLiveStreamTranslations>('streamTranslations', streamTranslations));
    properties.add(StringProperty('uploadingImage', uploadingImage));
    properties.add(StringProperty('kickoutMessage', kickoutMessage));
    properties.add(StringProperty('attention', attention));
  }

  IsmLiveTranslationsData copyWith({
    IsmLiveStreamTranslations? streamTranslations,
    String? uploadingImage,
    String? kickoutMessage,
    String? attention,
  }) =>
      IsmLiveTranslationsData(
        streamTranslations: streamTranslations ?? this.streamTranslations,
        uploadingImage: uploadingImage ?? this.uploadingImage,
        kickoutMessage: kickoutMessage ?? this.kickoutMessage,
        attention: attention ?? this.attention,
      );
}
