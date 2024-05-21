// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLivePkInviteResponceModel {
  final String message;
  final IsmLivePkStreamDetails streamData;
  IsmLivePkInviteResponceModel({
    required this.message,
    required this.streamData,
  });

  IsmLivePkInviteResponceModel copyWith({
    String? message,
    IsmLivePkStreamDetails? streamData,
  }) =>
      IsmLivePkInviteResponceModel(
        message: message ?? this.message,
        streamData: streamData ?? this.streamData,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'message': message,
        'streamData': streamData.toMap(),
      };

  factory IsmLivePkInviteResponceModel.fromMap(Map<String, dynamic> map) =>
      IsmLivePkInviteResponceModel(
        message: map['message'] as String,
        streamData: IsmLivePkStreamDetails.fromMap(
            map['streamData'] as Map<String, dynamic>),
      );

  String toJson() => json.encode(toMap());

  factory IsmLivePkInviteResponceModel.fromJson(String source) =>
      IsmLivePkInviteResponceModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLivePkInviteResponceModel(message: $message, streamData: $streamData)';

  @override
  bool operator ==(covariant IsmLivePkInviteResponceModel other) {
    if (identical(this, other)) return true;

    return other.message == message && other.streamData == streamData;
  }

  @override
  int get hashCode => message.hashCode ^ streamData.hashCode;
}

class IsmLivePkStreamDetails {
  final String? streamId;
  final String? streamTitle;
  final String? streamImage;
  final num? startDateTime;
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
  final String? streamTags;
  final String? streamTypes;
  final List<dynamic>? members;
  final int? paymentAmount;
  final int? paymentType;
  final int? viewersCount;
  final int? coinsCount;
  final IsmLivePkUserDetails? userDetails;
  final String? type;
  final bool? hdBroadcast;
  final bool? restream;
  final bool? productsLinked;
  final int? productsCount;
  final List<dynamic>? products;
  final IsmLivePkUserDetails? firstUserDetails;
  final IsmLivePkUserDetails? secondUserDetails;
  final String? inviteId;
  final bool? isPkChallenge;
  final String? pkId;
  final bool? selfHosted;
  final bool? rtmpIngest;
  final bool? persistRtmpIngestEndpoint;
  final int? firstUserCoins;
  final int? secondUserCoins;
  IsmLivePkStreamDetails({
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
    this.products,
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
  });

  IsmLivePkStreamDetails copyWith({
    String? streamId,
    String? streamTitle,
    String? streamImage,
    num? startDateTime,
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
    int? duration,
    String? streamTags,
    String? streamTypes,
    List<dynamic>? members,
    int? paymentAmount,
    int? paymentType,
    int? viewersCount,
    int? coinsCount,
    IsmLivePkUserDetails? userDetails,
    String? type,
    bool? hdBroadcast,
    bool? restream,
    bool? productsLinked,
    int? productsCount,
    List<dynamic>? products,
    IsmLivePkUserDetails? firstUserDetails,
    IsmLivePkUserDetails? secondUserDetails,
    String? inviteId,
    bool? isPkChallenge,
    String? pkId,
    bool? selfHosted,
    bool? rtmpIngest,
    bool? persistRtmpIngestEndpoint,
    int? firstUserCoins,
    int? secondUserCoins,
  }) =>
      IsmLivePkStreamDetails(
        streamId: streamId ?? this.streamId,
        streamTitle: streamTitle ?? this.streamTitle,
        streamImage: streamImage ?? this.streamImage,
        startDateTime: startDateTime ?? this.startDateTime,
        recordUrl: recordUrl ?? this.recordUrl,
        streamDescription: streamDescription ?? this.streamDescription,
        isRecorded: isRecorded ?? this.isRecorded,
        isGroupStream: isGroupStream ?? this.isGroupStream,
        isPublicStream: isPublicStream ?? this.isPublicStream,
        userId: userId ?? this.userId,
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
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'streamId': streamId,
        'streamTitle': streamTitle,
        'streamImage': streamImage,
        'startDateTime': startDateTime,
        'recordUrl': recordUrl,
        'streamDescription': streamDescription,
        'isRecorded': isRecorded,
        'isGroupStream': isGroupStream,
        'isPublicStream': isPublicStream,
        'userId': userId,
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
      };

  factory IsmLivePkStreamDetails.fromMap(Map<String, dynamic> map) =>
      IsmLivePkStreamDetails(
        streamId: map['streamId'] != null ? map['streamId'] as String : null,
        streamTitle:
            map['streamTitle'] != null ? map['streamTitle'] as String : null,
        streamImage:
            map['streamImage'] != null ? map['streamImage'] as String : null,
        startDateTime:
            map['startDateTime'] != null ? map['startDateTime'] as num : null,
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
        isScheduledStream: map['isScheduledStream'] != null
            ? map['isScheduledStream'] as bool
            : null,
        paymentCurrencyCode: map['paymentCurrencyCode'] != null
            ? map['paymentCurrencyCode'] as String
            : null,
        country: map['country'] != null ? map['country'] as String : null,
        duration: map['duration'] != null ? map['duration'] as int : null,
        streamTags:
            map['streamTags'] != null ? map['streamTags'] as String : null,
        streamTypes:
            map['streamTypes'] != null ? map['streamTypes'] as String : null,
        members: map['members'] != null
            ? List<String>.from(map['members'] as List<dynamic>)
            : null,
        paymentAmount:
            map['paymentAmount'] != null ? map['paymentAmount'] as int : null,
        paymentType:
            map['paymentType'] != null ? map['paymentType'] as int : null,
        viewersCount:
            map['viewersCount'] != null ? map['viewersCount'] as int : null,
        coinsCount: map['coinsCount'] != null ? map['coinsCount'] as int : null,
        userDetails: map['userDetails'] != null
            ? IsmLivePkUserDetails.fromMap(
                map['userDetails'] as Map<String, dynamic>)
            : null,
        type: map['type'] != null ? map['type'] as String : null,
        hdBroadcast:
            map['hdBroadcast'] != null ? map['hdBroadcast'] as bool : null,
        restream: map['restream'] != null ? map['restream'] as bool : null,
        productsLinked: map['productsLinked'] != null
            ? map['productsLinked'] as bool
            : null,
        productsCount:
            map['productsCount'] != null ? map['productsCount'] as int : null,
        products: map['products'] != null
            ? List<String>.from(map['products'] as List<dynamic>)
            : null,
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
            map['firstUserCoins'] != null ? map['firstUserCoins'] as int : null,
        secondUserCoins: map['secondUserCoins'] != null
            ? map['secondUserCoins'] as int
            : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLivePkStreamDetails.fromJson(String source) =>
      IsmLivePkStreamDetails.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLivePkStreamDetails(streamId: $streamId, streamTitle: $streamTitle, streamImage: $streamImage, startDateTime: $startDateTime, recordUrl: $recordUrl, streamDescription: $streamDescription, isRecorded: $isRecorded, isGroupStream: $isGroupStream, isPublicStream: $isPublicStream, userId: $userId, userType: $userType, audioOnly: $audioOnly, isPaid: $isPaid, alreadyPaid: $alreadyPaid, isScheduledStream: $isScheduledStream, paymentCurrencyCode: $paymentCurrencyCode, country: $country, duration: $duration, streamTags: $streamTags, streamTypes: $streamTypes, members: $members, paymentAmount: $paymentAmount, paymentType: $paymentType, viewersCount: $viewersCount, coinsCount: $coinsCount, userDetails: $userDetails, type: $type, hdBroadcast: $hdBroadcast, restream: $restream, productsLinked: $productsLinked, productsCount: $productsCount, products: $products, firstUserDetails: $firstUserDetails, secondUserDetails: $secondUserDetails, inviteId: $inviteId, isPkChallenge: $isPkChallenge, pkId: $pkId, selfHosted: $selfHosted, rtmpIngest: $rtmpIngest, persistRtmpIngestEndpoint: $persistRtmpIngestEndpoint, firstUserCoins: $firstUserCoins, secondUserCoins: $secondUserCoins)';

  @override
  bool operator ==(covariant IsmLivePkStreamDetails other) {
    if (identical(this, other)) return true;

    return other.streamId == streamId &&
        other.streamTitle == streamTitle &&
        other.streamImage == streamImage &&
        other.startDateTime == startDateTime &&
        other.recordUrl == recordUrl &&
        other.streamDescription == streamDescription &&
        other.isRecorded == isRecorded &&
        other.isGroupStream == isGroupStream &&
        other.isPublicStream == isPublicStream &&
        other.userId == userId &&
        other.userType == userType &&
        other.audioOnly == audioOnly &&
        other.isPaid == isPaid &&
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
        other.secondUserCoins == secondUserCoins;
  }

  @override
  int get hashCode =>
      streamId.hashCode ^
      streamTitle.hashCode ^
      streamImage.hashCode ^
      startDateTime.hashCode ^
      recordUrl.hashCode ^
      streamDescription.hashCode ^
      isRecorded.hashCode ^
      isGroupStream.hashCode ^
      isPublicStream.hashCode ^
      userId.hashCode ^
      userType.hashCode ^
      audioOnly.hashCode ^
      isPaid.hashCode ^
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
      secondUserCoins.hashCode;
}

class IsmLivePkUserDetails {
  final String? userid;
  final String? username;
  final String? firstname;
  final IsmLiveMetaData? userMetaData;
  final String? lastname;
  final String? profilepic;
  final int? coins;
  final String? streamimage;
  final String? isometrikuserid;
  final String? streamid;
  IsmLivePkUserDetails({
    this.userid,
    this.username,
    this.firstname,
    this.userMetaData,
    this.lastname,
    this.profilepic,
    this.coins,
    this.streamimage,
    this.isometrikuserid,
    this.streamid,
  });

  IsmLivePkUserDetails copyWith({
    String? userid,
    String? username,
    String? firstname,
    IsmLiveMetaData? userMetaData,
    String? lastname,
    String? profilepic,
    int? coins,
    String? streamimage,
    String? isometrikuserid,
    String? streamid,
  }) =>
      IsmLivePkUserDetails(
        userid: userid ?? this.userid,
        username: username ?? this.username,
        firstname: firstname ?? this.firstname,
        userMetaData: userMetaData ?? this.userMetaData,
        lastname: lastname ?? this.lastname,
        profilepic: profilepic ?? this.profilepic,
        coins: coins ?? this.coins,
        streamimage: streamimage ?? this.streamimage,
        isometrikuserid: isometrikuserid ?? this.isometrikuserid,
        streamid: streamid ?? this.streamid,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userid': userid,
        'username': username,
        'firstname': firstname,
        'userMetaData': userMetaData?.toMap(),
        'lastname': lastname,
        'profilepic': profilepic,
        'coins': coins,
        'streamimage': streamimage,
        'isometrikuserid': isometrikuserid,
        'streamid': streamid,
      };

  factory IsmLivePkUserDetails.fromMap(Map<String, dynamic> map) =>
      IsmLivePkUserDetails(
        userid: map['userid'] != null ? map['userid'] as String : null,
        username: map['username'] != null ? map['username'] as String : null,
        firstname: map['firstname'] != null ? map['firstname'] as String : null,
        userMetaData: map['userMetaData'] != null
            ? IsmLiveMetaData.fromMap(
                map['userMetaData'] as Map<String, dynamic>)
            : null,
        lastname: map['lastname'] != null ? map['lastname'] as String : null,
        profilepic:
            map['profilepic'] != null ? map['profilepic'] as String : null,
        coins: map['coins'] != null ? map['coins'] as int : null,
        streamimage:
            map['streamimage'] != null ? map['streamimage'] as String : null,
        isometrikuserid: map['isometrikuserid'] != null
            ? map['isometrikuserid'] as String
            : null,
        streamid: map['streamid'] != null ? map['streamid'] as String : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLivePkUserDetails.fromJson(String source) =>
      IsmLivePkUserDetails.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLivePkUserDetails(userid: $userid, username: $username, firstname: $firstname, userMetaData: $userMetaData, lastname: $lastname, profilepic: $profilepic, coins: $coins, streamimage: $streamimage, isometrikuserid: $isometrikuserid, streamid: $streamid)';

  @override
  bool operator ==(covariant IsmLivePkUserDetails other) {
    if (identical(this, other)) return true;

    return other.userid == userid &&
        other.username == username &&
        other.firstname == firstname &&
        other.userMetaData == userMetaData &&
        other.lastname == lastname &&
        other.profilepic == profilepic &&
        other.coins == coins &&
        other.streamimage == streamimage &&
        other.isometrikuserid == isometrikuserid &&
        other.streamid == streamid;
  }

  @override
  int get hashCode =>
      userid.hashCode ^
      username.hashCode ^
      firstname.hashCode ^
      userMetaData.hashCode ^
      lastname.hashCode ^
      profilepic.hashCode ^
      coins.hashCode ^
      streamimage.hashCode ^
      isometrikuserid.hashCode ^
      streamid.hashCode;
}
