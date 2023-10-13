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
    } catch (e) {}
    return null;
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
    } catch (e) {}
    return null;
  }
}
