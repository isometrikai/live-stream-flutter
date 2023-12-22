import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class IsmLiveImageProvider extends ImageProvider<IsmLiveImageProvider> {
  const IsmLiveImageProvider(this.imageUrl);

  final String imageUrl;

  @override
  Future<IsmLiveImageProvider> obtainKey(ImageConfiguration configuration) => SynchronousFuture<IsmLiveImageProvider>(this);
}
