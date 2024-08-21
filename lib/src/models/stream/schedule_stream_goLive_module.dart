// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class IsmLiveScheduleStreamParam {
  final int? saleType;
  final String? streamImage;
  final String? streamDescription;
  final String? streamTitle;
  final bool? isPublicStream;
  final String? userName;
  final String? isometrikUserId;
  final bool? audioOnly;
  final List<dynamic>? members;
  final bool? multiLive;
  final bool? restream;
  final String? eventId;
  final bool? enableRecording;
  final bool? lowLatencyMode;
  final bool? hdBroadcast;
  final bool? isSelfHosted;
  final bool? productsLinked;
  final List<dynamic>? products;
  final bool? rtmpIngest;
  final bool? persistRtmpIngestEndpoint;
  final bool? isPaid;
  final num? paymentAmount;
  final String? paymentCurrencyCode;
  IsmLiveScheduleStreamParam({
    this.saleType,
    this.streamImage,
    this.streamDescription,
    this.streamTitle,
    this.isPublicStream,
    this.userName,
    this.isometrikUserId,
    this.audioOnly,
    this.members,
    this.multiLive,
    this.restream,
    this.eventId,
    this.enableRecording,
    this.lowLatencyMode,
    this.hdBroadcast,
    this.isSelfHosted,
    this.productsLinked,
    this.products,
    this.rtmpIngest,
    this.persistRtmpIngestEndpoint,
    this.isPaid,
    this.paymentAmount,
    this.paymentCurrencyCode,
  });

  IsmLiveScheduleStreamParam copyWith({
    int? saleType,
    String? streamImage,
    String? streamDescription,
    String? streamTitle,
    bool? isPublicStream,
    String? userName,
    String? isometrikUserId,
    bool? audioOnly,
    List<dynamic>? members,
    bool? multiLive,
    bool? restream,
    String? eventId,
    bool? enableRecording,
    bool? lowLatencyMode,
    bool? hdBroadcast,
    bool? isSelfHosted,
    bool? productsLinked,
    List<dynamic>? products,
    bool? rtmpIngest,
    bool? persistRtmpIngestEndpoint,
    bool? isPaid,
    num? paymentAmount,
    String? paymentCurrencyCode,
  }) =>
      IsmLiveScheduleStreamParam(
        saleType: saleType ?? this.saleType,
        streamImage: streamImage ?? this.streamImage,
        streamDescription: streamDescription ?? this.streamDescription,
        streamTitle: streamTitle ?? this.streamTitle,
        isPublicStream: isPublicStream ?? this.isPublicStream,
        userName: userName ?? this.userName,
        isometrikUserId: isometrikUserId ?? this.isometrikUserId,
        audioOnly: audioOnly ?? this.audioOnly,
        members: members ?? this.members,
        multiLive: multiLive ?? this.multiLive,
        restream: restream ?? this.restream,
        eventId: eventId ?? this.eventId,
        enableRecording: enableRecording ?? this.enableRecording,
        lowLatencyMode: lowLatencyMode ?? this.lowLatencyMode,
        hdBroadcast: hdBroadcast ?? this.hdBroadcast,
        isSelfHosted: isSelfHosted ?? this.isSelfHosted,
        productsLinked: productsLinked ?? this.productsLinked,
        products: products ?? this.products,
        rtmpIngest: rtmpIngest ?? this.rtmpIngest,
        persistRtmpIngestEndpoint:
            persistRtmpIngestEndpoint ?? this.persistRtmpIngestEndpoint,
        isPaid: isPaid ?? this.isPaid,
        paymentAmount: paymentAmount ?? this.paymentAmount,
        paymentCurrencyCode: paymentCurrencyCode ?? this.paymentCurrencyCode,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'saleType': saleType,
        'streamImage': streamImage,
        'streamDescription': streamDescription,
        'streamTitle': streamTitle,
        'isPublicStream': isPublicStream,
        'userName': userName,
        'isometrikUserId': isometrikUserId,
        'audioOnly': audioOnly,
        'members': members,
        'multiLive': multiLive,
        'restream': restream,
        'eventId': eventId,
        'enableRecording': enableRecording,
        'lowLatencyMode': lowLatencyMode,
        'hdBroadcast': hdBroadcast,
        'isSelfHosted': isSelfHosted,
        'productsLinked': productsLinked,
        'products': products,
        'rtmpIngest': rtmpIngest,
        'persistRtmpIngestEndpoint': persistRtmpIngestEndpoint,
        'isPaid': isPaid,
        'paymentAmount': paymentAmount,
        'paymentCurrencyCode': paymentCurrencyCode,
      };

  factory IsmLiveScheduleStreamParam.fromMap(Map<String, dynamic> map) =>
      IsmLiveScheduleStreamParam(
        saleType: map['saleType'] != null ? map['saleType'] as int : null,
        streamImage:
            map['streamImage'] != null ? map['streamImage'] as String : null,
        streamDescription: map['streamDescription'] != null
            ? map['streamDescription'] as String
            : null,
        streamTitle:
            map['streamTitle'] != null ? map['streamTitle'] as String : null,
        isPublicStream: map['isPublicStream'] != null
            ? map['isPublicStream'] as bool
            : null,
        userName: map['userName'] != null ? map['userName'] as String : null,
        isometrikUserId: map['isometrikUserId'] != null
            ? map['isometrikUserId'] as String
            : null,
        audioOnly: map['audioOnly'] != null ? map['audioOnly'] as bool : null,
        members: map['members'] != null
            ? List<dynamic>.from(map['members'] as List<dynamic>)
            : null,
        multiLive: map['multiLive'] != null ? map['multiLive'] as bool : null,
        restream: map['restream'] != null ? map['restream'] as bool : null,
        eventId: map['eventId'] != null ? map['eventId'] as String : null,
        enableRecording: map['enableRecording'] != null
            ? map['enableRecording'] as bool
            : null,
        lowLatencyMode: map['lowLatencyMode'] != null
            ? map['lowLatencyMode'] as bool
            : null,
        hdBroadcast:
            map['hdBroadcast'] != null ? map['hdBroadcast'] as bool : null,
        isSelfHosted:
            map['isSelfHosted'] != null ? map['isSelfHosted'] as bool : null,
        productsLinked: map['productsLinked'] != null
            ? map['productsLinked'] as bool
            : null,
        products: map['products'] != null
            ? List<dynamic>.from(map['products'] as List<dynamic>)
            : null,
        rtmpIngest:
            map['rtmpIngest'] != null ? map['rtmpIngest'] as bool : null,
        persistRtmpIngestEndpoint: map['persistRtmpIngestEndpoint'] != null
            ? map['persistRtmpIngestEndpoint'] as bool
            : null,
        isPaid: map['isPaid'] != null ? map['isPaid'] as bool : null,
        paymentAmount:
            map['paymentAmount'] != null ? map['paymentAmount'] as num : null,
        paymentCurrencyCode: map['paymentCurrencyCode'] != null
            ? map['paymentCurrencyCode'] as String
            : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveScheduleStreamParam.fromJson(String source) =>
      IsmLiveScheduleStreamParam.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveScheduleStreamParam(saleType: $saleType, streamImage: $streamImage, streamDescription: $streamDescription, streamTitle: $streamTitle, isPublicStream: $isPublicStream, userName: $userName, isometrikUserId: $isometrikUserId, audioOnly: $audioOnly, members: $members, multiLive: $multiLive, restream: $restream, eventId: $eventId, enableRecording: $enableRecording, lowLatencyMode: $lowLatencyMode, hdBroadcast: $hdBroadcast, isSelfHosted: $isSelfHosted, productsLinked: $productsLinked, products: $products, rtmpIngest: $rtmpIngest, persistRtmpIngestEndpoint: $persistRtmpIngestEndpoint, isPaid: $isPaid, paymentAmount: $paymentAmount, paymentCurrencyCode: $paymentCurrencyCode)';

  @override
  bool operator ==(covariant IsmLiveScheduleStreamParam other) {
    if (identical(this, other)) return true;

    return other.saleType == saleType &&
        other.streamImage == streamImage &&
        other.streamDescription == streamDescription &&
        other.streamTitle == streamTitle &&
        other.isPublicStream == isPublicStream &&
        other.userName == userName &&
        other.isometrikUserId == isometrikUserId &&
        other.audioOnly == audioOnly &&
        listEquals(other.members, members) &&
        other.multiLive == multiLive &&
        other.restream == restream &&
        other.eventId == eventId &&
        other.enableRecording == enableRecording &&
        other.lowLatencyMode == lowLatencyMode &&
        other.hdBroadcast == hdBroadcast &&
        other.isSelfHosted == isSelfHosted &&
        other.productsLinked == productsLinked &&
        listEquals(other.products, products) &&
        other.rtmpIngest == rtmpIngest &&
        other.persistRtmpIngestEndpoint == persistRtmpIngestEndpoint &&
        other.isPaid == isPaid &&
        other.paymentAmount == paymentAmount &&
        other.paymentCurrencyCode == paymentCurrencyCode;
  }

  @override
  int get hashCode =>
      saleType.hashCode ^
      streamImage.hashCode ^
      streamDescription.hashCode ^
      streamTitle.hashCode ^
      isPublicStream.hashCode ^
      userName.hashCode ^
      isometrikUserId.hashCode ^
      audioOnly.hashCode ^
      members.hashCode ^
      multiLive.hashCode ^
      restream.hashCode ^
      eventId.hashCode ^
      enableRecording.hashCode ^
      lowLatencyMode.hashCode ^
      hdBroadcast.hashCode ^
      isSelfHosted.hashCode ^
      productsLinked.hashCode ^
      products.hashCode ^
      rtmpIngest.hashCode ^
      persistRtmpIngestEndpoint.hashCode ^
      isPaid.hashCode ^
      paymentAmount.hashCode ^
      paymentCurrencyCode.hashCode;
}
