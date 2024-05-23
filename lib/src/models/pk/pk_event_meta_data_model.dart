import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLivePkEventMetaDataModel {
  IsmLivePkEventMetaDataModel({
    this.timeInMin,
    this.streamData,
    this.pkId,
    this.message,
    this.createdTs,
  });

  factory IsmLivePkEventMetaDataModel.fromMap(Map<String, dynamic> map) =>
      IsmLivePkEventMetaDataModel(
        timeInMin: map['timeInMin'] != null ? map['timeInMin'] as int : null,
        streamData: map['streamData'] != null
            ? List<IsmLivePkStreamDetails>.from(
                (map['streamData'] as List<dynamic>)
                    .map<IsmLivePkStreamDetails?>(
                  (x) =>
                      IsmLivePkStreamDetails.fromMap(x as Map<String, dynamic>),
                ),
              )
            : null,
        pkId: map['pkId'] != null ? map['pkId'] as String : null,
        message: map['message'] != null
            ? IsmLiveStatus.fromValue(map['message'] as String)
            : null,
        createdTs: map['createdTs'] != null ? map['createdTs'] as int : null,
      );

  factory IsmLivePkEventMetaDataModel.fromJson(String source) =>
      IsmLivePkEventMetaDataModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final int? timeInMin;
  final List<IsmLivePkStreamDetails>? streamData;
  final String? pkId;
  final IsmLiveStatus? message;
  final int? createdTs;

  IsmLivePkEventMetaDataModel copyWith({
    int? timeInMin,
    List<IsmLivePkStreamDetails>? streamData,
    String? pkId,
    IsmLiveStatus? message,
    int? createdTs,
  }) =>
      IsmLivePkEventMetaDataModel(
        timeInMin: timeInMin ?? this.timeInMin,
        streamData: streamData ?? this.streamData,
        pkId: pkId ?? this.pkId,
        message: message ?? this.message,
        createdTs: createdTs ?? this.createdTs,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'timeInMin': timeInMin,
        'streamData': streamData?.map((x) => x.toMap()).toList(),
        'pkId': pkId,
        'message': message,
        'createdTs': createdTs,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLivePkEventMetaDataModel(timeInMin: $timeInMin, streamData: $streamData, pkId: $pkId, message: $message, createdTs: $createdTs)';

  @override
  bool operator ==(covariant IsmLivePkEventMetaDataModel other) {
    if (identical(this, other)) return true;

    return other.timeInMin == timeInMin &&
        listEquals(other.streamData, streamData) &&
        other.pkId == pkId &&
        other.message == message &&
        other.createdTs == createdTs;
  }

  @override
  int get hashCode =>
      timeInMin.hashCode ^
      streamData.hashCode ^
      pkId.hashCode ^
      message.hashCode ^
      createdTs.hashCode;
}
