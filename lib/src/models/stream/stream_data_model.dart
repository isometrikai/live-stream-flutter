// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLiveStreamDataModel {
  IsmLiveStreamDataModel({
    this.amount,
    this.isBuy,
    this.streamId,
    this.streamTitle,
    this.streamImage,
    this.startDateTime,
    this.recordUrl,
    this.streamDescription,
    this.isRecorded,
    this.isGroupStream,
    this.isPublicStream,
    this.userId,
    this.userType,
    this.audioOnly,
    this.isPaid,
    this.alreadyPaid,
    this.isScheduledStream,
    this.paymentCurrencyCode,
    this.country,
    this.duration,
    this.scheduleStartTime,
    this.streamTags,
    this.streamTypes,
    this.members,
    this.paymentAmount,
    this.paymentType,
    this.viewersCount,
    this.coinsCount,
    this.userDetails,
    this.type,
    this.hdBroadcast,
    this.restream,
    this.productsLinked,
    this.productsCount,
    required this.products,
    this.firstUserDetails,
    this.secondUserDetails,
    this.inviteId,
    this.isPkChallenge,
    this.pkId,
    this.selfHosted,
    this.rtmpIngest,
    this.persistRtmpIngestEndpoint,
    this.firstUserCoins,
    this.secondUserCoins,
    this.status,
    this.isStreamActive,
    this.eventId,
    this.metaData,
  });

  factory IsmLiveStreamDataModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveStreamDataModel(
        streamId: map['streamId'] != null ? map['streamId'] as String : null,
        streamTitle:
            map['streamTitle'] != null ? map['streamTitle'] as String : null,
        streamImage:
            map['streamImage'] != null ? map['streamImage'] as String : null,
        startDateTime: (map['startDateTime'] as Object?).asEpochDateTime,
        scheduleStartTime:
            (map['scheduleStartTime'] as Object?).asEpochDateTime,
        recordUrl: map['recordUrl'] != null ? map['recordUrl'] as String : null,
        streamDescription: map['streamDescription'] != null
            ? map['streamDescription'] as String
            : null,
        isRecorded:
            map['isRecorded'] != null ? map['isRecorded'] as bool : null,
        isGroupStream:
            map['isGroupStream'] != null ? map['isGroupStream'] as bool : null,
        isPublicStream: map['isPublicStream'] != null
            ? map['isPublicStream'] as bool
            : null,
        userId: map['userId'] != null ? map['userId'] as String : null,
        userType: map['userType'] != null ? map['userType'] as int : null,
        audioOnly: map['audioOnly'] != null ? map['audioOnly'] as bool : null,
        isPaid: map['isPaid'] != null ? map['isPaid'] as bool : null,
        alreadyPaid:
            map['alreadyPaid'] != null ? map['alreadyPaid'] as bool : null,
        isBuy: map['isBuy'] != null ? map['isBuy'] as bool : null,
        isScheduledStream: map['isScheduledStream'] != null
            ? map['isScheduledStream'] as bool
            : null,
        paymentCurrencyCode: map['paymentCurrencyCode'] != null
            ? map['paymentCurrencyCode'] as String
            : null,
        country: map['country'] != null ? map['country'] as String : null,
        duration: map['duration'] != null ? map['duration'] as int : null,
        amount: map['amount'] != null ? map['amount'] as num : null,
        streamTags:
            map['streamTags'] != null ? map['streamTags'] as String : null,
        streamTypes:
            map['streamTypes'] != null ? map['streamTypes'] as String : null,
        members: map['members'] != null
            ? List<dynamic>.from(map['members'] as List<dynamic>)
            : null,
        paymentAmount:
            map['paymentAmount'] != null ? map['paymentAmount'] as num : null,
        paymentType:
            map['paymentType'] != null ? map['paymentType'] as int : null,
        viewersCount:
            map['viewersCount'] != null ? map['viewersCount'] as int : null,
        coinsCount: map['coinsCount'] != null ? map['coinsCount'] as num : null,
        userDetails: map['userDetails'] != null
            ? IsmLiveUser.fromMap(map['userDetails'] as Map<String, dynamic>)
            : null,
        type: map['type'] != null ? map['type'] as String : null,
        status: map['status'] != null ? map['status'] as String : null,
        eventId: map['eventId'] != null ? map['eventId'] as String : null,
        metaData: map['metaData'] != null
            ? IsmLiveMetaData.fromMap(
                Map<String, dynamic>.from(map['metaData'] as Map))
            : null,
        isStreamActive: map['isStreamActive'] != null
            ? map['isStreamActive'] as bool
            : null,
        hdBroadcast:
            map['hdBroadcast'] != null ? map['hdBroadcast'] as bool : null,
        restream: map['restream'] != null ? map['restream'] as bool : null,
        productsLinked: map['productsLinked'] != null
            ? map['productsLinked'] as bool
            : null,
        productsCount:
            map['productsCount'] != null ? map['productsCount'] as int : null,
        products:
            map['products'] != null ? List.from(map['products'] as List) : [],
        firstUserDetails: map['firstUserDetails'] != null
            ? IsmLivePkUserDetails.fromMap(
                map['firstUserDetails'] as Map<String, dynamic>)
            : null,
        secondUserDetails: map['secondUserDetails'] != null
            ? IsmLivePkUserDetails.fromMap(
                map['secondUserDetails'] as Map<String, dynamic>)
            : null,
        inviteId: map['inviteId'] != null ? map['inviteId'] as String : null,
        isPkChallenge:
            map['isPkChallenge'] != null ? map['isPkChallenge'] as bool : null,
        pkId: map['pkId'] != null ? map['pkId'] as String : null,
        selfHosted:
            map['selfHosted'] != null ? map['selfHosted'] as bool : null,
        rtmpIngest:
            map['rtmpIngest'] != null ? map['rtmpIngest'] as bool : null,
        persistRtmpIngestEndpoint: map['persistRtmpIngestEndpoint'] != null
            ? map['persistRtmpIngestEndpoint'] as bool
            : null,
        firstUserCoins:
            map['firstUserCoins'] != null ? map['firstUserCoins'] as num : null,
        secondUserCoins: map['secondUserCoins'] != null
            ? map['secondUserCoins'] as num
            : null,
      );

  /// Creates [IsmLiveStreamDataModel] from the recordings API response item.
  factory IsmLiveStreamDataModel.fromRecordingMap(Map<String, dynamic> map) {
    final startTime = map['startTime'];
    final endTime = map['endTime'];
    int? duration;
    if (startTime != null && endTime != null) {
      final start =
          startTime is int ? startTime : int.tryParse(startTime.toString());
      final end = endTime is int ? endTime : int.tryParse(endTime.toString());
      if (start != null && end != null)
        duration = ((end - start) / 1000).round();
    }
    final createdBy = map['createdBy'] as String?;
    final initiatorName = map['initiatorName'] as String?;
    final initiatorImage = map['initiatorImage'] as String?;
    final initiatorIdentifier = map['initiatorIdentifier'] as String?;
    IsmLiveUser? userDetails;
    if (initiatorName != null || initiatorImage != null || createdBy != null) {
      userDetails = IsmLiveUser(
        id: createdBy,
        appUserId: initiatorIdentifier,
        userName: initiatorName,
        userProfile: initiatorImage,
      );
    }
    return IsmLiveStreamDataModel(
      streamId: map['streamId'] != null ? map['streamId'] as String : null,
      streamTitle: initiatorName ?? map['streamDescription'] as String?,
      streamImage:
          map['streamImage'] != null ? map['streamImage'] as String : null,
      startDateTime: (startTime as Object?).asEpochDateTime,
      recordUrl:
          map['recordingUrl'] != null ? map['recordingUrl'] as String : null,
      streamDescription: map['streamDescription'] != null
          ? map['streamDescription'] as String
          : null,
      isRecorded: true,
      isPublicStream: map['isPublic'] != null ? map['isPublic'] as bool : null,
      userId: createdBy,
      viewersCount:
          map['viewersCount'] != null ? map['viewersCount'] as int : null,
      duration: duration,
      userDetails: userDetails,
      hdBroadcast:
          map['hdBroadcast'] != null ? map['hdBroadcast'] as bool : null,
      restream: map['restream'] != null ? map['restream'] as bool : null,
      productsLinked:
          map['productsLinked'] != null ? map['productsLinked'] as bool : null,
      productsCount:
          map['productsCount'] != null ? map['productsCount'] as int : null,
      selfHosted: map['selfHosted'] != null ? map['selfHosted'] as bool : null,
      rtmpIngest: map['rtmpIngest'] != null ? map['rtmpIngest'] as bool : null,
      persistRtmpIngestEndpoint: map['persistRtmpIngestEndpoint'] != null
          ? map['persistRtmpIngestEndpoint'] as bool
          : null,
      products:
          map['products'] != null ? List.from(map['products'] as List) : [],
    );
  }

  factory IsmLiveStreamDataModel.fromJson(String source) =>
      IsmLiveStreamDataModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final String? streamId;
  final String? streamTitle;
  final String? streamImage;
  final DateTime? startDateTime;
  final String? recordUrl;
  final String? streamDescription;
  final bool? isRecorded;
  final bool? isGroupStream;
  final bool? isPublicStream;
  final String? userId;
  final int? userType;
  final bool? audioOnly;
  final bool? isPaid;
  final bool? alreadyPaid;
  final bool? isScheduledStream;
  final String? paymentCurrencyCode;
  final String? country;
  final int? duration;
  final DateTime? scheduleStartTime;
  final String? streamTags;
  final String? streamTypes;
  final List<dynamic>? members;
  final num? paymentAmount;
  final num? amount;
  final bool? isBuy;
  final int? paymentType;
  final int? viewersCount;
  final num? coinsCount;
  final IsmLiveUser? userDetails;
  final String? type;
  final bool? hdBroadcast;
  final bool? restream;
  final bool? productsLinked;
  final int? productsCount;
  final List products;
  final IsmLivePkUserDetails? firstUserDetails;
  final IsmLivePkUserDetails? secondUserDetails;
  final String? inviteId;
  final bool? isPkChallenge;
  final String? pkId;
  final bool? selfHosted;
  final bool? rtmpIngest;
  final bool? persistRtmpIngestEndpoint;
  final num? firstUserCoins;
  final num? secondUserCoins;
  final String? status;
  final bool? isStreamActive;
  final String? eventId;
  final IsmLiveMetaData? metaData;

  IsmLiveStreamDataModel copyWith({
    String? streamId,
    String? streamTitle,
    String? streamImage,
    DateTime? startDateTime,
    DateTime? scheduleStartTime,
    String? recordUrl,
    String? streamDescription,
    bool? isRecorded,
    bool? isGroupStream,
    bool? isPublicStream,
    String? userId,
    int? userType,
    bool? audioOnly,
    bool? isPaid,
    bool? alreadyPaid,
    bool? isScheduledStream,
    String? paymentCurrencyCode,
    String? country,
    num? amount,
    bool? isBuy,
    int? duration,
    String? streamTags,
    String? streamTypes,
    List<String>? members,
    num? paymentAmount,
    int? paymentType,
    int? viewersCount,
    num? coinsCount,
    IsmLiveUser? userDetails,
    String? type,
    bool? hdBroadcast,
    bool? restream,
    bool? productsLinked,
    int? productsCount,
    List? products,
    IsmLivePkUserDetails? firstUserDetails,
    IsmLivePkUserDetails? secondUserDetails,
    String? inviteId,
    bool? isPkChallenge,
    String? pkId,
    bool? selfHosted,
    bool? rtmpIngest,
    bool? persistRtmpIngestEndpoint,
    num? firstUserCoins,
    num? secondUserCoins,
    String? status,
    bool? isStreamActive,
    String? eventId,
    IsmLiveMetaData? metaData,
  }) =>
      IsmLiveStreamDataModel(
        streamId: streamId ?? this.streamId,
        streamTitle: streamTitle ?? this.streamTitle,
        streamImage: streamImage ?? this.streamImage,
        startDateTime: startDateTime ?? this.startDateTime,
        scheduleStartTime: scheduleStartTime ?? this.scheduleStartTime,
        recordUrl: recordUrl ?? this.recordUrl,
        streamDescription: streamDescription ?? this.streamDescription,
        isRecorded: isRecorded ?? this.isRecorded,
        isGroupStream: isGroupStream ?? this.isGroupStream,
        isPublicStream: isPublicStream ?? this.isPublicStream,
        userId: userId ?? this.userId,
        amount: amount ?? this.amount,
        isBuy: isBuy ?? this.isBuy,
        userType: userType ?? this.userType,
        audioOnly: audioOnly ?? this.audioOnly,
        isPaid: isPaid ?? this.isPaid,
        alreadyPaid: alreadyPaid ?? this.alreadyPaid,
        isScheduledStream: isScheduledStream ?? this.isScheduledStream,
        paymentCurrencyCode: paymentCurrencyCode ?? this.paymentCurrencyCode,
        country: country ?? this.country,
        duration: duration ?? this.duration,
        streamTags: streamTags ?? this.streamTags,
        streamTypes: streamTypes ?? this.streamTypes,
        members: members ?? this.members,
        paymentAmount: paymentAmount ?? this.paymentAmount,
        paymentType: paymentType ?? this.paymentType,
        viewersCount: viewersCount ?? this.viewersCount,
        coinsCount: coinsCount ?? this.coinsCount,
        userDetails: userDetails ?? this.userDetails,
        type: type ?? this.type,
        hdBroadcast: hdBroadcast ?? this.hdBroadcast,
        restream: restream ?? this.restream,
        productsLinked: productsLinked ?? this.productsLinked,
        productsCount: productsCount ?? this.productsCount,
        products: products ?? this.products,
        firstUserDetails: firstUserDetails ?? this.firstUserDetails,
        secondUserDetails: secondUserDetails ?? this.secondUserDetails,
        inviteId: inviteId ?? this.inviteId,
        isPkChallenge: isPkChallenge ?? this.isPkChallenge,
        pkId: pkId ?? this.pkId,
        selfHosted: selfHosted ?? this.selfHosted,
        rtmpIngest: rtmpIngest ?? this.rtmpIngest,
        persistRtmpIngestEndpoint:
            persistRtmpIngestEndpoint ?? this.persistRtmpIngestEndpoint,
        firstUserCoins: firstUserCoins ?? this.firstUserCoins,
        secondUserCoins: secondUserCoins ?? this.secondUserCoins,
        status: status ?? this.status,
        isStreamActive: isStreamActive ?? this.isStreamActive,
        eventId: eventId ?? this.eventId,
        metaData: metaData ?? this.metaData,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'streamId': streamId,
        'streamTitle': streamTitle,
        'streamImage': streamImage,
        'startDateTime': startDateTime.epochMilliseconds,
        'startDateTimeInSeconds': startDateTime.epochSeconds,
        'scheduleStartTime': scheduleStartTime.epochMilliseconds,
        'scheduleStartTimeInSeconds': scheduleStartTime.epochSeconds,
        'recordUrl': recordUrl,
        'streamDescription': streamDescription,
        'isRecorded': isRecorded,
        'isGroupStream': isGroupStream,
        'isPublicStream': isPublicStream,
        'userId': userId,
        'isBuy': isBuy,
        'amount': amount,
        'userType': userType,
        'audioOnly': audioOnly,
        'isPaid': isPaid,
        'alreadyPaid': alreadyPaid,
        'isScheduledStream': isScheduledStream,
        'paymentCurrencyCode': paymentCurrencyCode,
        'country': country,
        'duration': duration,
        'streamTags': streamTags,
        'streamTypes': streamTypes,
        'members': members,
        'paymentAmount': paymentAmount,
        'paymentType': paymentType,
        'viewersCount': viewersCount,
        'coinsCount': coinsCount,
        'userDetails': userDetails?.toMap(),
        'type': type,
        'hdBroadcast': hdBroadcast,
        'restream': restream,
        'productsLinked': productsLinked,
        'productsCount': productsCount,
        'products': products,
        'firstUserDetails': firstUserDetails?.toMap(),
        'secondUserDetails': secondUserDetails?.toMap(),
        'inviteId': inviteId,
        'isPkChallenge': isPkChallenge,
        'pkId': pkId,
        'selfHosted': selfHosted,
        'rtmpIngest': rtmpIngest,
        'persistRtmpIngestEndpoint': persistRtmpIngestEndpoint,
        'firstUserCoins': firstUserCoins,
        'secondUserCoins': secondUserCoins,
        'status': status,
        'isStreamActive': isStreamActive,
        'eventId': eventId,
        'metaData': metaData?.toMap(),
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveStreamDataModel(streamId: $streamId, amount: $amount, scheduleStartTime: $scheduleStartTime, scheduleStartTimeInMilliseconds: ${scheduleStartTime.epochMilliseconds}, scheduleStartTimeInSeconds: ${scheduleStartTime.epochSeconds}, isBuy: $isBuy, streamTitle: $streamTitle, streamImage: $streamImage, startDateTime: $startDateTime, startDateTimeInMilliseconds: ${startDateTime.epochMilliseconds}, startDateTimeInSeconds: ${startDateTime.epochSeconds}, recordUrl: $recordUrl, streamDescription: $streamDescription, isRecorded: $isRecorded, isGroupStream: $isGroupStream, isPublicStream: $isPublicStream,      status: $status, isStreamActive: $isStreamActive , eventId: $eventId , metaData: $metaData, userId: $userId, userType: $userType, audioOnly: $audioOnly, isPaid: $isPaid, alreadyPaid: $alreadyPaid, isScheduledStream: $isScheduledStream, paymentCurrencyCode: $paymentCurrencyCode, country: $country, duration: $duration, streamTags: $streamTags, streamTypes: $streamTypes, members: $members, paymentAmount: $paymentAmount, paymentType: $paymentType, viewersCount: $viewersCount, coinsCount: $coinsCount, userDetails: $userDetails, type: $type, hdBroadcast: $hdBroadcast, restream: $restream, productsLinked: $productsLinked, productsCount: $productsCount, products: $products, firstUserDetails: $firstUserDetails, secondUserDetails: $secondUserDetails, inviteId: $inviteId, isPkChallenge: $isPkChallenge, pkId: $pkId, selfHosted: $selfHosted, rtmpIngest: $rtmpIngest, persistRtmpIngestEndpoint: $persistRtmpIngestEndpoint, firstUserCoins: $firstUserCoins, secondUserCoins: $secondUserCoins)';

  @override
  bool operator ==(covariant IsmLiveStreamDataModel other) {
    if (identical(this, other)) return true;

    return other.streamId == streamId &&
        other.streamTitle == streamTitle &&
        other.streamImage == streamImage &&
        other.startDateTime == startDateTime &&
        other.scheduleStartTime == scheduleStartTime &&
        other.recordUrl == recordUrl &&
        other.streamDescription == streamDescription &&
        other.isRecorded == isRecorded &&
        other.isGroupStream == isGroupStream &&
        other.isPublicStream == isPublicStream &&
        other.userId == userId &&
        other.userType == userType &&
        other.audioOnly == audioOnly &&
        other.isPaid == isPaid &&
        other.amount == amount &&
        other.isBuy == isBuy &&
        other.alreadyPaid == alreadyPaid &&
        other.isScheduledStream == isScheduledStream &&
        other.paymentCurrencyCode == paymentCurrencyCode &&
        other.country == country &&
        other.duration == duration &&
        other.streamTags == streamTags &&
        other.streamTypes == streamTypes &&
        listEquals(other.members, members) &&
        other.paymentAmount == paymentAmount &&
        other.paymentType == paymentType &&
        other.viewersCount == viewersCount &&
        other.coinsCount == coinsCount &&
        other.userDetails == userDetails &&
        other.type == type &&
        other.hdBroadcast == hdBroadcast &&
        other.restream == restream &&
        other.productsLinked == productsLinked &&
        other.productsCount == productsCount &&
        listEquals(other.products, products) &&
        other.firstUserDetails == firstUserDetails &&
        other.secondUserDetails == secondUserDetails &&
        other.inviteId == inviteId &&
        other.isPkChallenge == isPkChallenge &&
        other.pkId == pkId &&
        other.selfHosted == selfHosted &&
        other.rtmpIngest == rtmpIngest &&
        other.persistRtmpIngestEndpoint == persistRtmpIngestEndpoint &&
        other.firstUserCoins == firstUserCoins &&
        other.status == status &&
        other.isStreamActive == isStreamActive &&
        other.eventId == eventId &&
        other.metaData == metaData &&
        other.secondUserCoins == secondUserCoins;
  }

  @override
  int get hashCode =>
      streamId.hashCode ^
      streamTitle.hashCode ^
      streamImage.hashCode ^
      startDateTime.hashCode ^
      scheduleStartTime.hashCode ^
      recordUrl.hashCode ^
      streamDescription.hashCode ^
      isRecorded.hashCode ^
      isGroupStream.hashCode ^
      isPublicStream.hashCode ^
      userId.hashCode ^
      userType.hashCode ^
      audioOnly.hashCode ^
      isPaid.hashCode ^
      isBuy.hashCode ^
      amount.hashCode ^
      alreadyPaid.hashCode ^
      isScheduledStream.hashCode ^
      paymentCurrencyCode.hashCode ^
      country.hashCode ^
      duration.hashCode ^
      streamTags.hashCode ^
      streamTypes.hashCode ^
      members.hashCode ^
      paymentAmount.hashCode ^
      paymentType.hashCode ^
      viewersCount.hashCode ^
      coinsCount.hashCode ^
      userDetails.hashCode ^
      type.hashCode ^
      hdBroadcast.hashCode ^
      restream.hashCode ^
      productsLinked.hashCode ^
      productsCount.hashCode ^
      products.hashCode ^
      firstUserDetails.hashCode ^
      secondUserDetails.hashCode ^
      inviteId.hashCode ^
      isPkChallenge.hashCode ^
      pkId.hashCode ^
      selfHosted.hashCode ^
      rtmpIngest.hashCode ^
      persistRtmpIngestEndpoint.hashCode ^
      firstUserCoins.hashCode ^
      status.hashCode ^
      eventId.hashCode ^
      isStreamActive.hashCode ^
      metaData.hashCode ^
      secondUserCoins.hashCode;
}

class IsmLiveUser {
  final String? id;
  final String? appUserId;
  final String? userName;
  final String? firstName;
  final IsmLiveMetaData? userMetaData;
  final String? lastName;
  final String? userProfile;
  IsmLiveUser({
    this.id,
    this.appUserId,
    this.userName,
    this.firstName,
    this.userMetaData,
    this.lastName,
    this.userProfile,
  });

  IsmLiveUser copyWith({
    String? id,
    String? appUserId,
    String? userName,
    String? firstName,
    IsmLiveMetaData? userMetaData,
    String? lastName,
    String? userProfile,
  }) =>
      IsmLiveUser(
        id: id ?? this.id,
        appUserId: appUserId ?? this.appUserId,
        userName: userName ?? this.userName,
        firstName: firstName ?? this.firstName,
        userMetaData: userMetaData ?? this.userMetaData,
        lastName: lastName ?? this.lastName,
        userProfile: userProfile ?? this.userProfile,
      );

  String get name {
    if (userName?.isEmpty ?? true) {
      return '${userMetaData?.firstName} ${userMetaData?.lastName}';
    }
    return userName!;
  }

  String get getFirstname {
    if (firstName?.isEmpty ?? true) {
      return '${userMetaData?.firstName}';
    }
    return firstName!;
  }

  String get getLastName {
    if (lastName?.isEmpty ?? true) {
      return '${userMetaData?.lastName}';
    }
    return lastName!;
  }

  String get image {
    if (userProfile?.isEmpty ?? true) {
      return '${userMetaData?.profilePic} ${userMetaData?.profilePic}';
    }
    return userProfile!;
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'appUserId': appUserId,
        'userName': userName,
        'firstName': firstName,
        'metaData': userMetaData?.toMap(),
        'lastName': lastName,
        'userProfile': userProfile,
      };

  factory IsmLiveUser.fromMap(Map<String, dynamic> map) => IsmLiveUser(
        id: map['id'] != null ? map['id'] as String : null,
        appUserId: map['appUserId'] != null ? map['appUserId'] as String : null,
        userName: map['userName'] != null ? map['userName'] as String : null,
        firstName: map['firstName'] != null ? map['firstName'] as String : null,
        userMetaData: map['metaData'] != null
            ? IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>)
            : null,
        lastName: map['lastName'] != null ? map['lastName'] as String : null,
        userProfile:
            map['userProfile'] != null ? map['userProfile'] as String : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveUser.fromJson(String source) =>
      IsmLiveUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveUser(id: $id, appUserId: $appUserId, userName: $userName, firstName: $firstName, userMetaData: $userMetaData, lastName: $lastName, userProfile: $userProfile)';

  @override
  bool operator ==(covariant IsmLiveUser other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.appUserId == appUserId &&
        other.userName == userName &&
        other.firstName == firstName &&
        other.userMetaData == userMetaData &&
        other.lastName == lastName &&
        other.userProfile == userProfile;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      appUserId.hashCode ^
      userName.hashCode ^
      firstName.hashCode ^
      userMetaData.hashCode ^
      lastName.hashCode ^
      userProfile.hashCode;
}
