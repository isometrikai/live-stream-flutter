import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/my_meeting_model.dart';

class MeetingViewModel {
  MeetingViewModel(this.repository);
  final MeetingRepository repository;

  Future<List<MyMeetingModel>?> getMeetingsList(
      {required String token,
      required String licenseKey,
      required String appSecret}) async {
    try {
      var res = await repository.getMeetingsList(
          token: token, licenseKey: licenseKey, appSecret: appSecret);
      if (res?.hasError ?? true) {
        return null;
      }
      var data = jsonDecode(res!.data) as Map<String, dynamic>;

      var meetinglistdata = data['meetings'] as List;

      var meetingList = <MyMeetingModel>[];
      for (var i in meetinglistdata) {
        meetingList.add(MyMeetingModel.fromMap(i));
      }

      return meetingList;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<String?> joinMeeting(
      {required String token,
      required String licenseKey,
      required String appSecret,
      required String meetingId}) async {
    try {
      var res = await repository.joinMeeting(
          token: token,
          licenseKey: licenseKey,
          appSecret: appSecret,
          meetingId: meetingId);
      if (res?.hasError ?? true) {
        return null;
      }
      var data = jsonDecode(res!.data);

      var rtcToken = data['rtcToken'];

      return rtcToken;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<List<UserDetails>?> getMembersList(
      {required String userSecret,
      required String licenseKey,
      required String appSecret,
      required int skip,
      required int limit,
      required String searchTag}) async {
    try {
      var res = await repository.getMembersList(
          userSecret: userSecret,
          licenseKey: licenseKey,
          appSecret: appSecret,
          skip: skip,
          limit: limit,
          searchTag: searchTag);

      if (res?.hasError ?? true) {
        return null;
      }

      var data = jsonDecode(res!.data);

      List listOfUsers = data['users'];
      var userDetailsList = <UserDetails>[];

      for (var i in listOfUsers) {
        userDetailsList.add(UserDetails.fromMap(i));
      }

      return userDetailsList;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }
}
