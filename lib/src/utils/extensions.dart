import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

extension IsmLiveNullString on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
}

extension IsmLiveMapExtension on Map<String, dynamic> {
  Map<String, dynamic> removeNullValues() {
    var result = <String, dynamic>{};
    for (var entry in entries) {
      var k = entry.key;
      if (entry.value != null) {
        if (entry.value.runtimeType.toString().contains('Map')) {
          result[k] = (entry.value as Map<String, dynamic>).removeNullValues();
        } else {
          result[k] = entry.value;
        }
      }
    }
    return result;
  }

  String makeQuery() {
    var res = [];
    for (var entry in removeNullValues().entries) {
      var key = entry.key;
      var value = entry.value;
      res.add('$key=$value');
    }
    return res.join('&');
  }
}

extension IsmLiveStreamTypeExtension on IsmLiveStreamType {
  IsmLiveStreamQueryModel get queryModel {
    var model = const IsmLiveStreamQueryModel();
    switch (this) {
      case IsmLiveStreamType.all:
        return model;
      case IsmLiveStreamType.audioOnly:
        return model.copyWith(audioOnly: true);
      case IsmLiveStreamType.multilive:
        return model.copyWith(multiLive: true);
      case IsmLiveStreamType.private:
        return model.copyWith(public: false);
      case IsmLiveStreamType.ecommerce:
        return model.copyWith(productsLinked: true);
      case IsmLiveStreamType.restream:
        return model.copyWith(reStream: true);
      case IsmLiveStreamType.hd:
        return model.copyWith(hdBroadcast: true);
      case IsmLiveStreamType.recorded:
        return model.copyWith(recorded: true);
    }
  }
}
