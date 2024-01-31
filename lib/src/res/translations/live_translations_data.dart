import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLiveTranslationsData with Diagnosticable {
  const IsmLiveTranslationsData({
    this.streamTranslations,
    this.uploadingImage,
    this.kickoutMessage,
    this.addedModerator,
    this.streamEnded,
    this.attention,
  });

  final IsmLiveStreamTranslations? streamTranslations;
  final String? uploadingImage;

  /// The string message to show in the dialog once the user is removed from the stream.
  ///
  /// defaults to [IsmLiveStrings.kickoutMessage]
  final String? kickoutMessage;

  /// The string message to show in the dialog once the user is added as a moderator by host of a stream.
  ///
  /// Make sure you include `@name` in the string to show the name of the host in the dialog
  ///
  /// defaults to [IsmLiveStrings.addedModerator]
  final String? addedModerator;
  final String? streamEnded;
  final String? attention;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IsmLiveStreamTranslations>('streamTranslations', streamTranslations));
    properties.add(StringProperty('uploadingImage', uploadingImage));
    properties.add(StringProperty('kickoutMessage', kickoutMessage));
    properties.add(StringProperty('addedModerator', addedModerator));
    properties.add(StringProperty('streamEnded', streamEnded));
    properties.add(StringProperty('attention', attention));
  }

  IsmLiveTranslationsData copyWith({
    IsmLiveStreamTranslations? streamTranslations,
    String? uploadingImage,
    String? kickoutMessage,
    String? addedModerator,
    String? streamEnded,
    String? attention,
  }) =>
      IsmLiveTranslationsData(
        streamTranslations: streamTranslations ?? this.streamTranslations,
        uploadingImage: uploadingImage ?? this.uploadingImage,
        kickoutMessage: kickoutMessage ?? this.kickoutMessage,
        addedModerator: addedModerator ?? this.addedModerator,
        streamEnded: streamEnded ?? this.streamEnded,
        attention: attention ?? this.attention,
      );
}
