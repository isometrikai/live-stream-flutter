import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLiveCreateStreamModel {
  const IsmLiveCreateStreamModel({
    required this.streamImage,
    required this.streamDescription,
    this.selfHosted = true,
    this.restream = false,
    this.productsLinked = false,
    this.products = const [],
    this.multiLive = true,
    this.searchableTags,
    this.metaData,
    this.members = const [],
    this.lowLatencyMode = false,
    this.isPublic = true,
    this.hdBroadcast = false,
    this.enableRecording = false,
    this.audioOnly = false,
    this.rtmpIngest = false,
    this.isScheduledStream = false,
    this.persistRtmpIngestEndpoint = false,
    this.paymentCurrencyCode = 'coins',
    this.paymentAmount = 0,
    this.scheduleStartTime,
    this.paymentType = 0,
    this.isPaid = false,
  });

  factory IsmLiveCreateStreamModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveCreateStreamModel(
        streamImage: map['streamImage'] as String,
        streamDescription: map['streamDescription'] as String,
        selfHosted: map['selfHosted'] as bool,
        isScheduledStream: map['isScheduledStream'] as bool,
        searchableTags:
            (map['searchableTags'] as List<dynamic>?)?.cast<String>(),
        restream: map['restream'] as bool,
        productsLinked: map['productsLinked'] as bool,
        products: (map['products'] as List<dynamic>).cast<String>(),
        multiLive: map['multiLive'] as bool,
        metaData:
            IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>),
        members: (map['members'] as List<dynamic>).cast<String>(),
        lowLatencyMode: map['lowLatencyMode'] as bool,
        isPublic: map['isPublic'] as bool,
        hdBroadcast: map['hdBroadcast'] as bool,
        enableRecording: map['enableRecording'] as bool,
        audioOnly: map['audioOnly'] as bool,
        rtmpIngest: map['rtmpIngest'] as bool,
        persistRtmpIngestEndpoint: map['persistRtmpIngestEndpoint'] as bool,
        paymentCurrencyCode: map['paymentCurrencyCode'] as String,
        paymentAmount: map['paymentAmount'] as double,
        scheduleStartTime: map['scheduleStartTime'] as double,
        paymentType: map['paymentType'] as int,
        isPaid: map['isPaid'] as bool,
      );

  factory IsmLiveCreateStreamModel.fromJson(String source) =>
      IsmLiveCreateStreamModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  final String streamImage;
  final String streamDescription;
  final bool selfHosted;
  final List<String>? searchableTags;
  final bool restream;
  final bool productsLinked;
  final List<String> products;
  final bool multiLive;
  final IsmLiveMetaData? metaData;
  final List<String> members;
  final bool lowLatencyMode;
  final bool isPublic;
  final bool hdBroadcast;
  final bool enableRecording;
  final bool audioOnly;
  final bool rtmpIngest;
  final bool isScheduledStream;
  final bool persistRtmpIngestEndpoint;
  final String paymentCurrencyCode;
  final double paymentAmount;
  final num? scheduleStartTime;
  final int paymentType;
  final bool isPaid;

  IsmLiveCreateStreamModel copyWith({
    String? streamImage,
    String? streamDescription,
    bool? selfHosted,
    List<String>? searchableTags,
    bool? restream,
    bool? productsLinked,
    List<String>? products,
    bool? multiLive,
    IsmLiveMetaData? metaData,
    List<String>? members,
    bool? lowLatencyMode,
    bool? isPublic,
    bool? hdBroadcast,
    bool? enableRecording,
    bool? audioOnly,
    bool? rtmpIngest,
    bool? isScheduledStream,
    bool? persistRtmpIngestEndpoint,
    String? paymentCurrencyCode,
    double? paymentAmount,
    num? scheduleStartTime,
    int? paymentType,
    bool? isPaid,
  }) =>
      IsmLiveCreateStreamModel(
        streamImage: streamImage ?? this.streamImage,
        streamDescription: streamDescription ?? this.streamDescription,
        selfHosted: selfHosted ?? this.selfHosted,
        searchableTags: searchableTags ?? this.searchableTags,
        restream: restream ?? this.restream,
        productsLinked: productsLinked ?? this.productsLinked,
        products: products ?? this.products,
        multiLive: multiLive ?? this.multiLive,
        metaData: metaData ?? this.metaData,
        members: members ?? this.members,
        lowLatencyMode: lowLatencyMode ?? this.lowLatencyMode,
        isPublic: isPublic ?? this.isPublic,
        hdBroadcast: hdBroadcast ?? this.hdBroadcast,
        enableRecording: enableRecording ?? this.enableRecording,
        audioOnly: audioOnly ?? this.audioOnly,
        rtmpIngest: rtmpIngest ?? this.rtmpIngest,
        isScheduledStream: isScheduledStream ?? this.isScheduledStream,
        persistRtmpIngestEndpoint:
            persistRtmpIngestEndpoint ?? this.persistRtmpIngestEndpoint,
        paymentCurrencyCode: paymentCurrencyCode ?? this.paymentCurrencyCode,
        paymentAmount: paymentAmount ?? this.paymentAmount,
        scheduleStartTime: scheduleStartTime ?? this.scheduleStartTime,
        paymentType: paymentType ?? this.paymentType,
        isPaid: isPaid ?? this.isPaid,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'streamImage': streamImage,
        'streamDescription': streamDescription,
        'selfHosted': selfHosted,
        'searchableTags': searchableTags,
        'restream': restream,
        'productsLinked': productsLinked,
        'products': products,
        'multiLive': multiLive,
        'metaData': metaData?.toMap(),
        'members': members,
        'lowLatencyMode': lowLatencyMode,
        'isPublic': isPublic,
        'hdBroadcast': hdBroadcast,
        'enableRecording': enableRecording,
        'audioOnly': audioOnly,
        'rtmpIngest': rtmpIngest,
        'isScheduledStream': isScheduledStream,
        'persistRtmpIngestEndpoint': persistRtmpIngestEndpoint,
        'paymentCurrencyCode': paymentCurrencyCode,
        'paymentAmount': paymentAmount,
        'scheduleStartTime': scheduleStartTime,
        'paymentType': paymentType,
        'isPaid': isPaid,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveCreateStreamModel(streamImage: $streamImage, streamDescription: $streamDescription, selfHosted: $selfHosted, scheduleStartTime: $scheduleStartTime, searchableTags: $searchableTags, isScheduledStream: $isScheduledStream, restream: $restream, productsLinked: $productsLinked, products: $products, multiLive: $multiLive, metaData: $metaData, members: $members, lowLatencyMode: $lowLatencyMode, isPublic: $isPublic, hdBroadcast: $hdBroadcast, enableRecording: $enableRecording, audioOnly: $audioOnly, rtmpIngest: $rtmpIngest, persistRtmpIngestEndpoint: $persistRtmpIngestEndpoint, paymentCurrencyCode: $paymentCurrencyCode, paymentAmount: $paymentAmount, paymentType: $paymentType, isPaid: $isPaid)';

  @override
  bool operator ==(covariant IsmLiveCreateStreamModel other) {
    if (identical(this, other)) return true;

    return other.streamImage == streamImage &&
        other.streamDescription == streamDescription &&
        other.selfHosted == selfHosted &&
        listEquals(other.searchableTags, searchableTags) &&
        other.restream == restream &&
        other.productsLinked == productsLinked &&
        listEquals(other.products, products) &&
        other.multiLive == multiLive &&
        other.metaData == metaData &&
        listEquals(other.members, members) &&
        other.lowLatencyMode == lowLatencyMode &&
        other.isPublic == isPublic &&
        other.hdBroadcast == hdBroadcast &&
        other.enableRecording == enableRecording &&
        other.audioOnly == audioOnly &&
        other.rtmpIngest == rtmpIngest &&
        other.isScheduledStream == isScheduledStream &&
        other.persistRtmpIngestEndpoint == persistRtmpIngestEndpoint &&
        other.paymentCurrencyCode == paymentCurrencyCode &&
        other.paymentAmount == paymentAmount &&
        other.scheduleStartTime == scheduleStartTime &&
        other.paymentType == paymentType &&
        other.isPaid == isPaid;
  }

  @override
  int get hashCode =>
      streamImage.hashCode ^
      streamDescription.hashCode ^
      selfHosted.hashCode ^
      searchableTags.hashCode ^
      restream.hashCode ^
      productsLinked.hashCode ^
      products.hashCode ^
      multiLive.hashCode ^
      metaData.hashCode ^
      members.hashCode ^
      lowLatencyMode.hashCode ^
      isPublic.hashCode ^
      hdBroadcast.hashCode ^
      enableRecording.hashCode ^
      audioOnly.hashCode ^
      rtmpIngest.hashCode ^
      isScheduledStream.hashCode ^
      scheduleStartTime.hashCode ^
      persistRtmpIngestEndpoint.hashCode ^
      paymentCurrencyCode.hashCode ^
      paymentAmount.hashCode ^
      paymentType.hashCode ^
      isPaid.hashCode;
}
