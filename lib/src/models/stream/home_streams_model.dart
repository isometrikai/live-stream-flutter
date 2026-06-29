import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLiveHomeStreamsModel {
  const IsmLiveHomeStreamsModel({
    this.scheduled = const [],
    this.live = const [],
    this.pk = const [],
    this.restream = const [],
    this.recorded = const [],
  });

  final List<IsmLiveStreamDataModel> scheduled;
  final List<IsmLiveStreamDataModel> live;
  final List<IsmLiveStreamDataModel> pk;
  final List<IsmLiveStreamDataModel> restream;
  final List<IsmLiveStreamDataModel> recorded;

  bool get isEmpty =>
      scheduled.isEmpty &&
      live.isEmpty &&
      pk.isEmpty &&
      restream.isEmpty &&
      recorded.isEmpty;

  factory IsmLiveHomeStreamsModel.fromMap(Map<String, dynamic> map) {
    List<IsmLiveStreamDataModel> parseList(String key) {
      final list = map[key] as List? ?? [];
      return list
          .map(
            (e) => IsmLiveStreamDataModel.fromMap(e as Map<String, dynamic>),
          )
          .toList();
    }

    return IsmLiveHomeStreamsModel(
      scheduled: parseList('scheduled'),
      live: parseList('live'),
      pk: parseList('pk'),
      restream: parseList('restream'),
      recorded: parseList('recorded'),
    );
  }

  IsmLiveHomeStreamsModel copyWith({
    List<IsmLiveStreamDataModel>? scheduled,
    List<IsmLiveStreamDataModel>? live,
    List<IsmLiveStreamDataModel>? pk,
    List<IsmLiveStreamDataModel>? restream,
    List<IsmLiveStreamDataModel>? recorded,
  }) =>
      IsmLiveHomeStreamsModel(
        scheduled: scheduled ?? this.scheduled,
        live: live ?? this.live,
        pk: pk ?? this.pk,
        restream: restream ?? this.restream,
        recorded: recorded ?? this.recorded,
      );

  IsmLiveHomeStreamsModel withoutStream(String streamId) {
    if (streamId.isEmpty) {
      return this;
    }

    List<IsmLiveStreamDataModel> filter(List<IsmLiveStreamDataModel> streams) =>
        streams.where((stream) => stream.streamId != streamId).toList();

    return copyWith(
      scheduled: filter(scheduled),
      live: filter(live),
      pk: filter(pk),
      restream: filter(restream),
      recorded: filter(recorded),
    );
  }
}
