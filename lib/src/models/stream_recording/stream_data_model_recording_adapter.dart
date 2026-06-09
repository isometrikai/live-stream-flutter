import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

/// Adapts [IsmLiveStreamDataModel] to [IsmLiveStreamRecordingItem] for use in
/// the recording player.
class IsmLiveStreamDataModelRecordingAdapter
    implements
        IsmLiveStreamRecordingItem,
        IsmLiveStreamRecordingReplayCapable {
  IsmLiveStreamDataModelRecordingAdapter(this._model);

  final IsmLiveStreamDataModel _model;

  @override
  String get streamId => _model.streamId ?? '';

  @override
  List<String> get recordedUrls {
    final fromApi = _model.recordedUrls;
    if (fromApi != null && fromApi.isNotEmpty) return fromApi;
    final single = _model.recordUrl;
    if (single != null && single.isNotEmpty) return [single];
    return [];
  }

  @override
  int get recordViewCount => _model.viewersCount ?? 0;

  @override
  String? get storeId => null;

  @override
  String? get userId => _model.userId ?? _model.userDetails?.id;

  @override
  String? get userName => _model.userDetails?.userName ?? _model.streamTitle;

  @override
  String? get userImageUrl => _model.userDetails?.userProfile;

  @override
  String? get thumbnailUrl => _model.streamImage;

  @override
  DateTime? get streamStartTime => _model.startDateTime;
}
